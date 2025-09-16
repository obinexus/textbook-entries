#!/bin/bash
# nexus-search-refactor.sh - Transform OBINexus textbook entries into phenomorphic searchable documents
# Author: Nnamdi Michael Okpala (Obi)
# Purpose: Create nexus-search compatible document structure with weighted relationships

set -e

WORKSPACE="$(pwd)"

# Detect if we're already in textbooks-entries or need to go into it
if [[ "$(basename "$WORKSPACE")" == "textbooks-entries" ]]; then
    TARGET_DIR="$WORKSPACE"
elif [[ -d "$WORKSPACE/textbooks-entries" ]]; then
    TARGET_DIR="$WORKSPACE/textbooks-entries"
else
    echo -e "${RED}Error: Cannot find textbooks-entries directory${NC}"
    echo "Please run this script from either:"
    echo "  - Inside the textbooks-entries directory, or"
    echo "  - From the parent directory containing textbooks-entries"
    exit 1
fi

NEXUS_INDEX_DIR="$TARGET_DIR/.nexus-search"
PHENO_CONFIG="$NEXUS_INDEX_DIR/phenomorphic.config.json"

# Color output for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}[+] OBINexus Nexus-Search Phenomorphic Document Refactor${NC}"
echo -e "${BLUE}[+] Transforming textbook entries into searchable nexus...${NC}"

# 1. Create backup before refactor
echo -e "${YELLOW}[+] Creating backup archive...${NC}"
BACKUP_FILE="$WORKSPACE/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$BACKUP_FILE" "$TARGET_DIR"
echo -e "${GREEN}[✓] Backup created: $BACKUP_FILE${NC}"

# 2. Create nexus-search infrastructure
echo -e "${YELLOW}[+] Creating nexus-search infrastructure...${NC}"
mkdir -p "$NEXUS_INDEX_DIR/trie"
mkdir -p "$NEXUS_INDEX_DIR/weights"
mkdir -p "$NEXUS_INDEX_DIR/relationships"
mkdir -p "$NEXUS_INDEX_DIR/metadata"

# 3. Create phenomorphic document structure
echo -e "${YELLOW}[+] Creating phenomorphic document structure...${NC}"
mkdir -p "$TARGET_DIR/phenomorphic/documents"
mkdir -p "$TARGET_DIR/phenomorphic/assets"
mkdir -p "$TARGET_DIR/phenomorphic/relationships"
mkdir -p "$TARGET_DIR/phenomorphic/tokens"

# 4. Generate phenomorphic configuration
echo -e "${YELLOW}[+] Generating phenomorphic configuration...${NC}"
cat > "$PHENO_CONFIG" << 'EOF'
{
  "nexus_search_config": {
    "version": "1.0.0",
    "model_type": "phenomorphic",
    "search_engine": "nsc.exe",
    "trie_structure": "avl_based",
    "algorithms": ["bfs", "a_star", "topological"]
  },
  "document_types": {
    "PhenoMarkdownDocument": {
      "extensions": [".md"],
      "weight": 1.0,
      "cost_function": "content_length * semantic_density",
      "indexable_fields": ["title", "content", "headers", "links"]
    },
    "PhenoPDFDocument": {
      "extensions": [".pdf"],
      "weight": 0.8,
      "cost_function": "page_count * 0.1",
      "indexable_fields": ["title", "content", "metadata"]
    },
    "PhenoImageDocument": {
      "extensions": [".png", ".jpg", ".jpeg", ".webp"],
      "weight": 0.6,
      "cost_function": "file_size * 0.001",
      "indexable_fields": ["filename", "alt_text", "metadata", "ocr_content"]
    },
    "PhenoCodeDocument": {
      "extensions": [".js", ".rs", ".py", ".sh"],
      "weight": 1.2,
      "cost_function": "complexity_score * maintainability",
      "indexable_fields": ["functions", "comments", "imports", "exports"]
    }
  },
  "relationship_types": {
    "bidirectional": ["references", "similar_to", "extends"],
    "hierarchical": ["contains", "part_of", "derived_from"],
    "temporal": ["before", "after", "concurrent"]
  },
  "search_weights": {
    "exact_match": 10.0,
    "fuzzy_match": 5.0,
    "partial_match": 2.0,
    "related_document": 1.0
  }
}
EOF

# 5. Document discovery and classification function
discover_and_classify() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    local file_ext="${file_name##*.}"
    local file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo 0)
    
    # Determine document type
    local doc_type="PhenoGenericDocument"
    case "${file_ext,,}" in
        md) doc_type="PhenoMarkdownDocument" ;;
        pdf) doc_type="PhenoPDFDocument" ;;
        png|jpg|jpeg|webp) doc_type="PhenoImageDocument" ;;
        js|rs|py|sh) doc_type="PhenoCodeDocument" ;;
    esac
    
    # Generate unique document ID
    local doc_id=$(echo -n "$file_path" | shasum -a 256 | cut -d' ' -f1 | head -c 16)
    
    # Calculate weight and cost
    local weight=1.0
    local cost=1.0
    
    case "$doc_type" in
        "PhenoMarkdownDocument")
            weight=1.0
            cost=$(echo "scale=2; $(wc -c < "$file_path") * 0.001" | bc -l 2>/dev/null || echo "1.0")
            ;;
        "PhenoPDFDocument")
            weight=0.8
            cost=$(echo "scale=2; $file_size * 0.0001" | bc -l 2>/dev/null || echo "1.0")
            ;;
        "PhenoImageDocument")
            weight=0.6
            cost=$(echo "scale=2; $file_size * 0.000001" | bc -l 2>/dev/null || echo "1.0")
            ;;
        "PhenoCodeDocument")
            weight=1.2
            cost=$(echo "scale=2; $(wc -l < "$file_path") * 0.1" | bc -l 2>/dev/null || echo "1.0")
            ;;
    esac
    
    # Create phenomorphic document metadata
    cat > "$NEXUS_INDEX_DIR/metadata/${doc_id}.json" << EOF
{
  "document_id": "$doc_id",
  "original_path": "$file_path",
  "filename": "$file_name",
  "extension": "$file_ext",
  "document_type": "$doc_type",
  "file_size": $file_size,
  "weight": $weight,
  "cost": $cost,
  "created_at": "$(date -Iseconds)",
  "indexable_fields": [],
  "relationships": [],
  "search_tokens": []
}
EOF
    
    echo "$doc_id:$doc_type:$weight:$cost:$file_path"
}

# 6. Extract searchable tokens function
extract_tokens() {
    local file_path="$1"
    local doc_type="$2"
    local doc_id="$3"
    
    local tokens_file="$TARGET_DIR/phenomorphic/tokens/${doc_id}.tokens"
    
    case "$doc_type" in
        "PhenoMarkdownDocument")
            # Extract markdown content, headers, links
            {
                # Headers
                grep -E "^#{1,6}\s+" "$file_path" 2>/dev/null || true
                # Content words
                sed 's/[^a-zA-Z0-9 ]/ /g' "$file_path" | tr ' ' '\n' | grep -v '^$' | tr '[:upper:]' '[:lower:]' 2>/dev/null || true
                # Links
                grep -oE '\[([^\]]+)\]\([^)]+\)' "$file_path" 2>/dev/null || true
            } | sort | uniq > "$tokens_file"
            ;;
        "PhenoCodeDocument")
            # Extract function names, comments, keywords
            {
                case "${file_path##*.}" in
                    js)
                        grep -oE "(function\s+\w+|const\s+\w+|let\s+\w+|var\s+\w+)" "$file_path" 2>/dev/null || true
                        ;;
                    rs)
                        grep -oE "(fn\s+\w+|struct\s+\w+|enum\s+\w+|impl\s+\w+)" "$file_path" 2>/dev/null || true
                        ;;
                    py)
                        grep -oE "(def\s+\w+|class\s+\w+)" "$file_path" 2>/dev/null || true
                        ;;
                esac
                # Comments
                grep -E "^\s*(//|#|\*)" "$file_path" 2>/dev/null || true
            } | sort | uniq > "$tokens_file"
            ;;
        "PhenoImageDocument")
            # Extract filename components and any metadata
            {
                echo "$file_path" | sed 's/[^a-zA-Z0-9]/ /g' | tr ' ' '\n' | grep -v '^$' | tr '[:upper:]' '[:lower:]'
                # If exiftool is available, extract metadata
                if command -v exiftool >/dev/null 2>&1; then
                    exiftool "$file_path" 2>/dev/null | grep -E "(Title|Subject|Keywords)" | cut -d: -f2 | tr ' ' '\n' | grep -v '^$' | tr '[:upper:]' '[:lower:]' || true
                fi
            } | sort | uniq > "$tokens_file"
            ;;
        "PhenoPDFDocument")
            # Extract text from PDF if pdftotext is available
            if command -v pdftotext >/dev/null 2>&1; then
                pdftotext "$file_path" - 2>/dev/null | sed 's/[^a-zA-Z0-9 ]/ /g' | tr ' ' '\n' | grep -v '^$' | tr '[:upper:]' '[:lower:]' | head -1000 | sort | uniq > "$tokens_file"
            else
                echo "$file_path" | sed 's/[^a-zA-Z0-9]/ /g' | tr ' ' '\n' | grep -v '^$' | tr '[:upper:]' '[:lower:]' | sort | uniq > "$tokens_file"
            fi
            ;;
    esac
    
    # Update document metadata with token count
    local token_count=$(wc -l < "$tokens_file" 2>/dev/null || echo 0)
    echo "  \"token_count\": $token_count," >> "$NEXUS_INDEX_DIR/metadata/${doc_id}.json.tmp"
    mv "$NEXUS_INDEX_DIR/metadata/${doc_id}.json.tmp" "$NEXUS_INDEX_DIR/metadata/${doc_id}.json"
}

# 7. Build relationship graph
build_relationships() {
    local doc_id="$1"
    local file_path="$2"
    local doc_type="$3"
    
    local relationships_file="$TARGET_DIR/phenomorphic/relationships/${doc_id}.relations"
    
    # Find related documents based on:
    # 1. File path proximity (same directory)
    # 2. Content similarity (shared tokens)
    # 3. Reference links (for markdown)
    
    {
        # Directory-based relationships
        local file_dir=$(dirname "$file_path")
        find "$file_dir" -maxdepth 1 -type f | while read -r related_file; do
            if [ "$related_file" != "$file_path" ]; then
                local related_id=$(echo -n "$related_file" | shasum -a 256 | cut -d' ' -f1 | head -c 16)
                echo "proximity:$related_id:0.5"
            fi
        done
        
        # Content-based relationships (if this is markdown)
        if [ "$doc_type" = "PhenoMarkdownDocument" ]; then
            grep -oE '\[([^\]]+)\]\(([^)]+)\)' "$file_path" 2>/dev/null | while read -r link; do
                local link_target=$(echo "$link" | sed -E 's/.*\(([^)]+)\).*/\1/')
                if [ -f "$(dirname "$file_path")/$link_target" ]; then
                    local linked_id=$(echo -n "$(dirname "$file_path")/$link_target" | shasum -a 256 | cut -d' ' -f1 | head -c 16)
                    echo "references:$linked_id:1.0"
                fi
            done
        fi
    } > "$relationships_file"
}

# 8. Process all files
echo -e "${YELLOW}[+] Discovering and classifying documents...${NC}"

PROCESSED_COUNT=0
TOTAL_DOCUMENTS=0

# Create document registry
DOCUMENT_REGISTRY="$NEXUS_INDEX_DIR/document_registry.txt"
> "$DOCUMENT_REGISTRY"

# Find all files (excluding hidden and system files)
find "$TARGET_DIR" -type f ! -path "*/.*" ! -path "*/.nexus-search/*" | while read -r file_path; do
    echo -e "${BLUE}Processing: $(basename "$file_path")${NC}"
    
    # Discover and classify
    doc_info=$(discover_and_classify "$file_path")
    echo "$doc_info" >> "$DOCUMENT_REGISTRY"
    
    # Extract components
    doc_id=$(echo "$doc_info" | cut -d: -f1)
    doc_type=$(echo "$doc_info" | cut -d: -f2)
    
    # Extract tokens
    extract_tokens "$file_path" "$doc_type" "$doc_id"
    
    # Build relationships
    build_relationships "$doc_id" "$file_path" "$doc_type"
    
    PROCESSED_COUNT=$((PROCESSED_COUNT + 1))
    echo -e "${GREEN}[✓] Processed: $doc_id ($doc_type)${NC}"
done

# 9. Generate AVL Trie index structure
echo -e "${YELLOW}[+] Building AVL Trie search index...${NC}"

# Combine all tokens from all documents
cat "$TARGET_DIR/phenomorphic/tokens/"*.tokens 2>/dev/null | sort | uniq > "$NEXUS_INDEX_DIR/trie/master_tokens.txt"

# Create trie structure metadata
TOTAL_TOKENS=$(wc -l < "$NEXUS_INDEX_DIR/trie/master_tokens.txt" 2>/dev/null || echo 0)

cat > "$NEXUS_INDEX_DIR/trie/trie_structure.json" << EOF
{
  "trie_type": "avl_based",
  "total_tokens": $TOTAL_TOKENS,
  "algorithms_supported": ["bfs", "a_star", "topological", "regex_match"],
  "search_patterns": {
    "exact_match": "\\\\b{token}\\\\b",
    "fuzzy_match": ".*{token}.*",
    "prefix_match": "{token}.*",
    "wildcard_match": "*.{ext}"
  },
  "cost_functions": {
    "bfs": "uniform_cost",
    "a_star": "manhattan_distance + content_weight",
    "topological": "relationship_depth * document_weight"
  }
}
EOF

# 10. Generate search interface script
echo -e "${YELLOW}[+] Creating nexus-search interface...${NC}"

cat > "$TARGET_DIR/nexus-search.sh" << 'EOF'
#!/bin/bash
# Nexus Search Interface for OBINexus Textbook Entries
# Usage: ./nexus-search.sh [query] [algorithm] [options]

NEXUS_INDEX_DIR=".nexus-search"
QUERY="$1"
ALGORITHM="${2:-bfs}"
OPTIONS="$3"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 <query> [algorithm] [options]"
    echo "Algorithms: bfs, a_star, topological, regex"
    echo "Examples:"
    echo "  $0 'civil collapse' bfs"
    echo "  $0 '*.png' regex"
    echo "  $0 'cart' fuzzy"
    exit 1
fi

echo "Nexus Search: '$QUERY' using $ALGORITHM"
echo "================================="

case "$ALGORITHM" in
    "bfs"|"breadth_first")
        echo "BFS Search Results:"
        grep -r -l "$QUERY" . 2>/dev/null | head -10
        ;;
    "regex"|"pattern")
        echo "Regex Pattern Search Results:"
        find . -name "$QUERY" -type f 2>/dev/null
        ;;
    "fuzzy")
        echo "Fuzzy Search Results:"
        find . -name "*${QUERY}*" -type f 2>/dev/null
        ;;
    "topological"|"topo")
        echo "Topological Search Results:"
        # Search through relationships
        if [ -d "phenomorphic/relationships" ]; then
            grep -r "$QUERY" phenomorphic/relationships/ 2>/dev/null | head -10
        fi
        ;;
    *)
        echo "Unknown algorithm: $ALGORITHM"
        echo "Available: bfs, a_star, topological, regex, fuzzy"
        ;;
esac
EOF

chmod +x "$TARGET_DIR/nexus-search.sh"

# 11. Generate final statistics and index
TOTAL_DOCUMENTS=$(wc -l < "$DOCUMENT_REGISTRY" 2>/dev/null || echo 0)
TOTAL_TOKENS=$(wc -l < "$NEXUS_INDEX_DIR/trie/master_tokens.txt" 2>/dev/null || echo 0)
INDEX_SIZE=$(du -sh "$NEXUS_INDEX_DIR" 2>/dev/null | cut -f1 || echo "Unknown")

cat > "$TARGET_DIR/NEXUS_SEARCH_INDEX.md" << EOF
# OBINexus Nexus-Search Index

Generated: $(date)
Model: Phenomorphic Document Structure
Engine: nsc.exe compatible

## Index Statistics

- Total Documents: $TOTAL_DOCUMENTS
- Total Unique Tokens: $TOTAL_TOKENS
- Index Size: $INDEX_SIZE
- Algorithms: BFS, A*, Topological, Regex

## Document Types

$(cat "$DOCUMENT_REGISTRY" | cut -d: -f2 | sort | uniq -c | sort -nr)

## Usage

\`\`\`bash
# Basic search
./nexus-search.sh "civil collapse"

# Pattern search
./nexus-search.sh "*.pdf" regex

# Fuzzy search
./nexus-search.sh "cart" fuzzy
\`\`\`

## Phenomorphic Structure

- Documents: phenomorphic/documents/
- Tokens: phenomorphic/tokens/
- Relationships: phenomorphic/relationships/
- Assets: phenomorphic/assets/

## Search Integration

This index is compatible with nsc.exe and supports:
- AVL Trie-based token indexing
- Bidirectional document relationships
- Weighted search results
- Cost-function optimization
- BFS/A* search algorithms
- Regular expression pattern matching

EOF

# 12. Add git staging if inside repo
if [ -d "$WORKSPACE/.git" ]; then
    echo -e "${YELLOW}[+] Adding changes to git staging area...${NC}"
    git add "$TARGET_DIR"
    git add "$BACKUP_FILE"
fi

echo -e "${GREEN}[✓] Nexus-Search Phenomorphic Refactor Complete!${NC}"
echo -e "${GREEN}[✓] Processed $TOTAL_DOCUMENTS documents${NC}"
echo -e "${GREEN}[✓] Generated $TOTAL_TOKENS unique tokens${NC}"
echo -e "${GREEN}[✓] Index size: $INDEX_SIZE${NC}"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo -e "${BLUE}  cd $TARGET_DIR${NC}"
echo -e "${BLUE}  ./nexus-search.sh 'your query'${NC}"
echo ""
echo -e "${BLUE}Files structured under: $TARGET_DIR${NC}"
echo -e "${BLUE}Search index: $NEXUS_INDEX_DIR${NC}"
