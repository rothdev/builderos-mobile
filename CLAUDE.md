# builder-system-mobile

<!--
AUTO-GENERATED FROM YAML SPECIFICATIONS
Generated: 2025-10-27T13:27:06.604546
Do not edit directly. Update specs/current.yaml instead.
Regenerate with: python3 tools/generate_claude_md.py <capsule>
-->

## Purpose
Native iOS mobile application providing mobile access to BuilderOS capabilities,
including capsule management, agent coordination, system monitoring, and on-the-go
Builder System operations from iPhone and iPad devices.


## Current Status
- **Phase:** development
- **Version:** 0.1.0

## Technical Overview
**Stack:**
- Swift 5.9+
- SwiftUI
- iOS SDK 17+
- Xcode 15+
- URLSession (networking)
- CoreData (local storage)

**Dependencies:**

*External:*
- iOS 17+ runtime
- BuilderOS backend APIs
- Push notification services (APNs)
- iCloud (optional sync)

*Internal (BuilderOS):*
- BuilderOS agent coordination APIs
- Builder Memory MCP integration
- Capsule status APIs
- System monitoring APIs

## Key Features
1. Mobile capsule dashboard
2. Capsule status monitoring
3. Agent task initiation
4. System health checks
5. Push notifications
6. Offline documentation access
7. Builder Memory queries
8. Quick actions and shortcuts
9. System performance metrics
10. Task history and logs
11. iOS Shortcuts integration
12. Widget support (planned)
13. Siri integration (planned)

## Architecture Notes
**Components:**
- **dashboard_view:** Overview of active capsules and system status
- **capsule_manager:** Browse, view, and manage capsule lifecycle
- **agent_coordinator:** Initiate and monitor agent task execution
- **system_monitor:** Real-time health metrics and performance tracking
- **notification_handler:** Push notifications for system alerts and task completion
- **data_sync_engine:** Bidirectional sync with BuilderOS backend
- **offline_cache:** Local storage for documentation and offline access

## Quality Standards
**Performance Targets:**
- Fast app launch (<2 seconds)
- Responsive UI (60fps)
- Efficient network usage
- Low battery impact

## Data & Storage
**Storage:**
- **src/ios/BuilderSystemMobile/:** Swift source files
- **BuilderSystemMobile.xcodeproj/:** Xcode project
- **ops/:** Operations scripts
- **runs/:** Execution logs

**Retention Policies:**
  **cache:** 30 days
  **logs:** 14 days
  **offline_docs:** until updated

## Maintenance
**Schedule:** as_needed

**Monitoring:**
- App performance and crashes
- API connectivity and latency
- Sync status and conflicts
- Battery and memory usage
- iOS version compatibility

**Automated Tasks:**
- Automated build via Xcode Cloud (planned)
- TestFlight distribution
- Cache cleanup on app launch
- Background sync when available

---
*This file is auto-generated from `specs/current.yaml`*
*Last generated:* 2025-10-27 13:27:06