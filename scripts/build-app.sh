#!/bin/bash

# Helper script to build Formula SAE applications
# Usage: ./build-app.sh <app-name> <board-name>

set -e

APP=$1
BOARD=$2

if [ -z "$APP" ] || [ -z "$BOARD" ]; then
  echo "Usage: $0 <app-name> <board-name>"
  echo ""
  echo "Examples:"
  echo "  $0 vcu vcu_board"
  echo "  $0 bms bms_board"
  echo "  $0 dashboard dashboard_board"
  exit 1
fi

if [ ! -d "$APP" ]; then
  echo "Error: Application '$APP' not found in workspace."
  echo ""
  echo "Did you clone it? Try:"
  echo "  git clone https://github.com/your-org/$APP"
  exit 1
fi

echo "======================================"
echo "Building: $APP"
echo "Board: $BOARD"
echo "======================================"
echo ""

cd "$APP"
west build -b "$BOARD" .

echo ""
echo "======================================"
echo "Build complete!"
echo "======================================"
echo ""
echo "To flash:"
echo "  cd $APP && west flash"
