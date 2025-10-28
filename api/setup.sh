#!/bin/bash
# Setup script for BuilderOS Mobile API Server

cd "$(dirname "$0")"

echo "🔧 BuilderOS Mobile API Server Setup"
echo ""

# Create virtual environment
if [ ! -d ".venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv .venv
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
source .venv/bin/activate

# Install dependencies
echo "📥 Installing Python dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo "✅ Dependencies installed"

# Check for API key
echo ""
echo "🔑 Checking API key configuration..."

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "⚠️  ANTHROPIC_API_KEY not found in environment"
    echo ""
    echo "To set it, add this to your ~/.zshrc or ~/.bashrc:"
    echo '   export ANTHROPIC_API_KEY="your_key_here"'
    echo ""
    echo "Or set it for this session:"
    echo '   export ANTHROPIC_API_KEY="your_key_here"'
    echo ""
else
    echo "✅ ANTHROPIC_API_KEY is set (${#ANTHROPIC_API_KEY} characters)"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the server:"
echo "   cd $(pwd)"
echo "   ./start.sh"
echo ""
