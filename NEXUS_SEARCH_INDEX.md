# OBINexus Nexus-Search Index

Generated: Tue Sep 16 10:34:53 AM BST 2025
Model: Phenomorphic Document Structure
Engine: nsc.exe compatible

## Index Statistics

- Total Documents: 41
- Total Unique Tokens: 3231
- Index Size: 232K
- Algorithms: BFS, A*, Topological, Regex

## Document Types

     23 PhenoPDFDocument
      9 PhenoImageDocument
      6 PhenoMarkdownDocument
      2 PhenoGenericDocument
      1 PhenoCodeDocument

## Usage

```bash
# Basic search
./nexus-search.sh "civil collapse"

# Pattern search
./nexus-search.sh "*.pdf" regex

# Fuzzy search
./nexus-search.sh "cart" fuzzy
```

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

