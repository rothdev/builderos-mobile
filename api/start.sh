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

# NOTE: We use Claude subscription, not API key
# The server automatically removes ANTHROPIC_API_KEY if present

# Start server
echo "✅ Starting server on http://localhost:8080"
echo "🔌 WebSocket endpoints:"
echo "   - ws://localhost:8080/api/claude/ws"
echo "   - ws://localhost:8080/api/codex/ws"
echo ""
python3 server.py
