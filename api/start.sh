#!/bin/bash
# Start BuilderOS Mobile API Server

cd "$(dirname "$0")"

echo "🚀 Starting BuilderOS Mobile API Server..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -q -r requirements.txt
pip install -q aioapns

# Check for ANTHROPIC_API_KEY
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ ANTHROPIC_API_KEY not set"
    echo "   Set it with: export ANTHROPIC_API_KEY=your_key_here"
    exit 1
fi

# Start server
echo "✅ Starting server on http://localhost:8080"
echo "🔌 WebSocket endpoints:"
echo "   - ws://localhost:8080/api/claude/ws"
echo "   - ws://localhost:8080/api/codex/ws"
echo ""
python3 server.py
