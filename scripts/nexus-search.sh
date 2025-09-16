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
