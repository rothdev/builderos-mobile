#!/usr/bin/env python3
"""
Quick test script for BuilderOS Mobile API Server
Tests WebSocket connection and message flow
"""

import asyncio
import json
import websockets

API_KEY = "1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3"
WS_URL = "ws://localhost:8080/api/claude/ws"


async def test_claude_connection():
    """Test Claude WebSocket connection and message flow"""

    print("🧪 Testing BuilderOS Mobile API Server")
    print(f"📡 Connecting to: {WS_URL}")
    print()

    try:
        async with websockets.connect(WS_URL) as ws:
            print("✅ WebSocket connected")

            # Step 1: Authenticate
            print("🔑 Sending API key...")
            await ws.send(API_KEY)

            # Receive authentication response
            auth_response = await ws.recv()
            print(f"📬 Auth response: {auth_response}")

            if auth_response != "authenticated":
                print("❌ Authentication failed!")
                return False

            print("✅ Authenticated")

            # Step 2: Receive ready message
            ready_msg = await ws.recv()
            ready_data = json.loads(ready_msg)
            print(f"📬 Ready: {ready_data['type']} - {ready_data['content']}")

            if ready_data['type'] != 'ready':
                print("❌ Ready message not received!")
                return False

            print("✅ Server ready")
            print()

            # Step 3: Send test message
            test_message = {"content": "Hello! Please respond with just 'Hi there!'"}
            print(f"📤 Sending test message: {test_message['content']}")
            await ws.send(json.dumps(test_message))

            # Step 4: Receive response
            print("📬 Receiving response chunks...")
            response_text = ""
            complete = False

            while not complete:
                response = await ws.recv()
                data = json.loads(response)

                if data['type'] == 'message':
                    response_text += data['content']
                    print(f"   📦 Chunk: {data['content'][:50]}...")

                elif data['type'] == 'complete':
                    complete = True
                    print(f"✅ Response complete")

                elif data['type'] == 'error':
                    print(f"❌ Error: {data['content']}")
                    return False

            print()
            print(f"📝 Full response: {response_text}")
            print()

            # Final validation
            if len(response_text) > 0:
                print("✅ All tests passed!")
                print()
                print("🎉 Server is working correctly!")
                return True
            else:
                print("❌ No response received")
                return False

    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False


async def main():
    success = await test_claude_connection()

    if not success:
        print()
        print("💡 Troubleshooting:")
        print("   1. Ensure server is running: ./start.sh")
        print("   2. Check ANTHROPIC_API_KEY is set")
        print("   3. Verify port 8080 is not in use")
        exit(1)


if __name__ == '__main__':
    asyncio.run(main())
