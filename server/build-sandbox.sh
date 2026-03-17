#!/bin/bash
set -e

echo "Building apollo-shell (filesystem problems)..."
docker build -t apollo-shell ./docker/shell/

echo ""
echo "Building apollo-shell-sql (SQL + psql problems)..."
docker build -t apollo-shell-sql ./docker/shell_sql/

echo ""
echo "Done. Test:"
echo "  docker run --rm -it -e PROBLEM=grep-errors apollo-shell bash"
echo "  docker run --rm -it -e PROBLEM=run-migration apollo-shell-sql bash"