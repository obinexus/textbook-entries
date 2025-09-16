# OBINexus Nexus-Search Scripts

**Directory:** `scripts/`  
**Primary Script:** `nexus-search.sh`  
**Purpose:** Phenomorphic document search interface for OBINexus textbook entries  
**Compatible:** nsc.exe polyglot search engine

---

## Overview

This directory contains the nexus-search scripts that provide advanced document search capabilities across the OBINexus textbook entries repository. The system implements a phenomorphic document model with weighted relationships, multi-algorithm search, and cost-function optimization.

## Quick Start

```bash
# Basic search across all documents
./nexus-search.sh "civil collapse"

# Pattern-based file search
./nexus-search.sh "*.pdf" regex

# Fuzzy content search
./nexus-search.sh "thurrock" fuzzy

# Relationship-based search
./nexus-search.sh "housing" topological
```

## Search Algorithms

### 1. BFS (Breadth-First Search)
**Usage:** `./nexus-search.sh "query" bfs`  
**Purpose:** Comprehensive content discovery across all document types  
**Best for:** Finding all occurrences of terms, exploring document relationships

```bash
# Find all documents containing "dimensional game theory"
./nexus-search.sh "dimensional game theory" bfs

# Search for bureaucratic patterns
./nexus-search.sh "delay deny defer" bfs
```

### 2. A* Search
**Usage:** `./nexus-search.sh "query" a_star`  
**Purpose:** Cost-optimized pathfinding through document relationships  
**Best for:** Finding most relevant documents based on weight and cost functions

```bash
# Find most relevant dark psychology documents
./nexus-search.sh "dark psychology mitigation" a_star

# Cost-optimized search for legal documents
./nexus-search.sh "housing act 1996" a_star
```

### 3. Regex Pattern Matching
**Usage:** `./nexus-search.sh "pattern" regex`  
**Purpose:** File and content pattern matching with wildcards  
**Best for:** Finding specific file types, structured patterns

```bash
# Find all PDF documents
./nexus-search.sh "*.pdf" regex

# Find all image files
./nexus-search.sh "*.{png,jpg,jpeg}" regex

# Find files with specific naming patterns
./nexus-search.sh "*civil*collapse*" regex
```

### 4. Fuzzy Search
**Usage:** `./nexus-search.sh "query" fuzzy`  
**Purpose:** Approximate string matching for partial or misspelled terms  
**Best for:** When you're unsure of exact spelling or want broader matches

```bash
# Find variations of "bureaucratic"
./nexus-search.sh "bureacratic" fuzzy

# Find related terms
./nexus-search.sh "auraseal" fuzzy
```

### 5. Topological Search
**Usage:** `./nexus-search.sh "query" topological`  
**Purpose:** Relationship-based document traversal  
**Best for:** Finding documents connected through references, citations, or content relationships

```bash
# Find documents related to specific topics
./nexus-search.sh "constitutional framework" topological

# Explore document relationship networks
./nexus-search.sh "obinexus ecosystem" topological
```

## Document Types Supported

### PhenoMarkdownDocument (.md)
- **Weight:** 1.0
- **Indexable Fields:** title, content, headers, links
- **Search Tokens:** Headers, content words, markdown links
- **Relationships:** Reference links, same-directory proximity

### PhenoPDFDocument (.pdf)
- **Weight:** 0.8
- **Indexable Fields:** title, content, metadata
- **Search Tokens:** Extracted text content (if pdftotext available)
- **Relationships:** Directory proximity, filename similarity

### PhenoImageDocument (.png, .jpg, .jpeg, .webp)
- **Weight:** 0.6
- **Indexable Fields:** filename, alt_text, metadata, OCR content
- **Search Tokens:** Filename components, EXIF metadata
- **Relationships:** Directory proximity, naming patterns

### PhenoCodeDocument (.js, .rs, .py, .sh)
- **Weight:** 1.2
- **Indexable Fields:** functions, comments, imports, exports
- **Search Tokens:** Function names, class definitions, comments
- **Relationships:** Import/export dependencies, same-project proximity

## Advanced Usage

### Search Options
The nexus-search script supports additional options for refined searching:

```bash
# Combine multiple search terms
./nexus-search.sh "civil collapse AND housing" bfs

# Exclude certain terms
./nexus-search.sh "obinexus NOT archived" fuzzy

# Search specific document types only
./nexus-search.sh "constitutional" regex --type=md
```

### Cost Function Optimization

Each document has an associated cost based on:
- **Content length** for markdown documents
- **File size** for PDFs and images
- **Complexity score** for code documents
- **Relationship depth** for topological searches

Lower cost documents appear higher in search results when using A* algorithm.

### Relationship Mapping

Documents are connected through:
- **Proximity relationships:** Files in same directory (weight: 0.5)
- **Reference relationships:** Markdown links between documents (weight: 1.0)
- **Content similarity:** Shared tokens and concepts (weight: 0.7)
- **Hierarchical relationships:** Parent/child document structures (weight: 0.8)

## Technical Architecture

### Index Structure
```
.nexus-search/
├── trie/
│   ├── master_tokens.txt          # All unique tokens
│   └── trie_structure.json        # AVL trie configuration
├── metadata/
│   └── {doc_id}.json              # Document metadata and weights
├── relationships/
│   └── {doc_id}.relations         # Document relationship graphs
└── phenomorphic.config.json       # Global configuration
```

### Token Extraction

**Markdown Documents:**
- Headers (# ## ###)
- Content words (filtered, stemmed)
- Link text and URLs
- Code blocks and inline code

**PDF Documents:**
- Full text extraction (via pdftotext)
- Filtered and normalized content
- Metadata fields

**Image Documents:**
- Filename component analysis
- EXIF metadata extraction
- OCR text (if tesseract available)

**Code Documents:**
- Function and class definitions
- Comment extraction
- Import/export statements
- Variable names and keywords

## Integration with OBINexus Ecosystem

### Dark Psychology Mitigation
The search system can identify patterns related to dark psychology mitigation:

```bash
# Find gaslighting pattern documentation
./nexus-search.sh "gaslighting detection" bfs

# Search for bureaucratic tactics
./nexus-search.sh "delay deny defend defer" topological

# Find vulnerability assessment documents
./nexus-search.sh "neurodivergent protection" a_star
```

### Constitutional Framework
Search through constitutional and legal documents:

```bash
# Find constitutional provisions
./nexus-search.sh "universal pension allocation" bfs

# Search legal frameworks
./nexus-search.sh "truth project documentation" regex

# Find policy implementations
./nexus-search.sh "machine verifiable governance" fuzzy
```

### Technical Documentation
Search through technical specifications and implementations:

```bash
# Find API documentation
./nexus-search.sh "libpolycall architecture" bfs

# Search build system docs
./nexus-search.sh "nlink polybuild" topological

# Find security specifications
./nexus-search.sh "auraseal cryptographic" a_star
```

## Performance Optimization

### Search Performance
- **BFS:** O(V + E) where V = documents, E = relationships
- **A*:** O(b^d) where b = branching factor, d = solution depth
- **Regex:** O(n) where n = number of files matching pattern
- **Fuzzy:** O(nm) where n = query length, m = content length
- **Topological:** O(V + E) with relationship weighting

### Memory Usage
The search index is optimized for memory efficiency:
- Token files are loaded on-demand
- Relationship graphs use sparse representation
- Metadata is cached for frequently accessed documents

### Caching
Search results are cached based on:
- Query fingerprint (hash of search terms + algorithm)
- Document modification timestamps
- Index generation timestamp

## Troubleshooting

### Common Issues

**"No results found"**
- Check spelling of search terms
- Try fuzzy search for approximate matches
- Use broader search terms or BFS algorithm

**"Permission denied"**
- Ensure nexus-search.sh is executable: `chmod +x nexus-search.sh`
- Check file permissions in the repository

**"Index not found"**
- Run the refactor script: `./nexus-search-refactor.sh`
- Verify .nexus-search directory exists

**"Pattern matching failed"**
- Ensure proper regex syntax for pattern searches
- Test patterns with simpler expressions first

### Debug Mode
Enable debug output by setting environment variable:

```bash
NEXUS_DEBUG=1 ./nexus-search.sh "query" bfs
```

## Contributing

### Adding New Search Algorithms
1. Edit `nexus-search.sh`
2. Add new case in algorithm switch statement
3. Implement search logic
4. Update help text and documentation

### Extending Document Types
1. Edit `nexus-search-refactor.sh`
2. Add new document type in phenomorphic configuration
3. Implement token extraction for new file type
4. Update relationship mapping logic

## Related Documentation

- [OBINexus Constitutional Framework](../docs/constitutional_framework.md)
- [Dark Psychology Mitigation Specification](../docs/dark_psychology_mitigation.md)
- [Phenomorphic Document Model](../docs/phenomorphic_model.md)
- [AVL Trie Implementation](../docs/avl_trie_specification.md)

---

**Script Status:** Production Ready  
**nsc.exe Compatible:** Yes  
**Index Version:** 1.0.0  
**Last Updated:** Generated by nexus-search-refactor.sh

*Computing from the Heart • Building with Purpose • Searching with Precision*  
**OBINexus: Machine-Verifiable Knowledge Discovery**