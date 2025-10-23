# Builder System Mobile

A native iOS application for remotely accessing and managing your Builder System server through a mobile-first chat interface.

## Features

- **Mobile-First Chat Interface**: Clean, readable chat interface optimized for mobile interaction
- **SSH Connection Management**: Secure connections to your Builder System server
- **Voice Input**: One-tap voice recording with text preview and editing
- **Text-to-Speech**: Read Builder System responses aloud
- **Quick Actions**: Common Builder System commands at your fingertips
- **Light/Dark Mode**: Automatically follows iOS system appearance
- **Push Notifications**: Get notified of critical Builder System events

## Architecture

Built using SwiftUI with MVVM architecture:

```
├── App/                    # Application entry point
├── Features/               # Feature modules
│   ├── Chat/              # Chat interface and messaging
│   └── Connection/        # SSH connection management
├── Services/              # Core services
│   ├── SSH/               # SSH connectivity
│   ├── Voice/             # Speech recognition and TTS
│   └── Notifications/     # Push notifications
└── Common/                # Shared utilities and themes
```

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.8+

## Dependencies

- NMSSH: SSH client library for iOS

## Getting Started

1. Clone the repository
2. Open in Xcode
3. Build and run on device or simulator
4. Configure SSH connection to your Builder System server
5. Grant microphone and notification permissions for full functionality

## Configuration

The app requires the following permissions:
- **Microphone**: For voice command input
- **Speech Recognition**: For converting voice to text
- **Notifications**: For Builder System event alerts

## SSH Connection

To connect to your Builder System:
1. Tap the info button in the header
2. Tap "Connect to Builder System"
3. Enter your server details:
   - Host (IP address or hostname)
   - Port (default 22)
   - Username
   - Password (SSH keys supported in future update)

## Voice Commands

1. Tap the microphone button to start recording
2. Speak your command
3. Tap stop when finished
4. Review and edit the transcribed text
5. Tap "Send" to execute

## Quick Actions

Access common Builder System operations:
- System Status
- List Capsules  
- Health Check
- Recent Logs
- Agent Status
- Custom Commands

## Development

This is part of the Builder System ecosystem. The app is designed to work with Builder System servers running the standard toolkit and automation scripts.

Built with love for the Builder System community. 🚀