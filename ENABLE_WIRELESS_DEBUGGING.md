# Enable Wireless Debugging in Xcode - Step by Step

## What This Does

Enables wireless debugging in Xcode so your iPhone stays connected for builds, debugging, and **InjectionIII hot reload** without a USB cable.

## Prerequisites

- ✅ iPhone in Developer Mode (Settings → Privacy & Security → Developer Mode)
- ✅ Mac and iPhone on same Wi-Fi network
- ✅ Lightning/USB-C cable (for initial setup only)

## Step-by-Step Instructions

### 1. Connect iPhone via USB

**Connect your iPhone to Mac with Lightning/USB-C cable** (one time only)

### 2. Open Xcode Devices Window

**In Xcode:**
- Click **Window** menu → **Devices and Simulators**
- Or press **Cmd+Shift+2**

### 3. Select Your iPhone

**In the Devices window:**
- Left sidebar shows connected devices
- Click on your iPhone (should show under "iOS Devices")

### 4. Enable "Connect via network"

**In the device details pane:**
- Look for checkbox: **"Connect via network"**
- ✅ **Check this box**
- Status will change to "Connecting..."

### 5. Wait for Globe Icon

**Watch the device in left sidebar:**
- Initially shows USB icon 🔌
- After 10-15 seconds, globe icon 🌐 appears
- This means wireless connection is ready!

### 6. Disconnect USB Cable

**Once you see the globe icon 🌐:**
- Disconnect the USB cable
- iPhone stays connected wirelessly!
- Device name shows "network" in parentheses

### 7. Verify Wireless Connection

**Check these indicators:**
- ✅ Globe icon 🌐 visible next to iPhone name in Devices window
- ✅ iPhone still shows in Xcode scheme selector
- ✅ Device info still visible in Devices window
- ✅ Status shows "Connected" (not "Disconnected")

## Visual Guide

```
BEFORE:                      AFTER:
┌──────────────────┐         ┌──────────────────┐
│ iPhone 15 Pro 🔌 │         │ iPhone 15 Pro 🌐 │
│                  │  →→→→   │ (network)        │
│ [✅] Connect via │         │ Connected        │
│     network      │         │                  │
└──────────────────┘         └──────────────────┘
```

## Testing Wireless Debugging

### Quick Test:

1. **Ensure USB cable is disconnected**
2. **In Xcode:** Select your iPhone from scheme selector (top bar)
   - Should show globe icon 🌐 next to device name
3. **Press Cmd+R** to build and run
4. **App installs wirelessly!**

### If It Doesn't Work:

1. **Reconnect USB cable**
2. **In Devices window:**
   - Uncheck "Connect via network"
   - Wait 5 seconds
   - Re-check "Connect via network"
3. **Wait for globe icon 🌐**
4. **Try disconnecting USB again**

## Now Test InjectionIII Hot Reload

With wireless debugging enabled, you can now test hot reload:

### 1. Rebuild App (One Time)

Since we modified Info.plist, rebuild once:

```bash
# In Xcode:
1. Select iPhone (with globe 🌐) from scheme selector
2. Press Cmd+B (Build)
3. Press Cmd+R (Run)
4. App launches on iPhone wirelessly
```

### 2. Test Hot Reload

```bash
# 1. Leave app running on iPhone
# 2. In Xcode, open: src/ios/BuilderSystemMobile/Views/MainContentView.swift
# 3. Find line ~19: .navigationTitle("BuilderOS")
# 4. Change to: .navigationTitle("BuilderOS Mobile")
# 5. Save: Cmd+S
# 6. Watch iPhone: Title updates in 1-2 seconds! ⚡
```

### 3. Verify Console Output

**In Xcode console (bottom pane):**

```
💉 Injection connected
💉 Loaded .../MainContentView.swift
💉 Injected 1 file
```

## Troubleshooting

### "Globe icon not appearing"

**Wait longer:**
- Can take 10-20 seconds on first connection
- Both devices must be on same Wi-Fi network
- Try disabling/re-enabling "Connect via network"

**Check network:**
- Mac and iPhone on **same Wi-Fi network** (not separate bands)
- Not on different VLANs or guest networks
- Disable VPN if blocking local discovery

**Firewall:**
- Mac firewall may block Xcode connections
- System Settings → Network → Firewall → Options
- Allow incoming connections for Xcode

### "Device disconnects frequently"

**WiFi issues:**
- Ensure strong WiFi signal on both devices
- Router may be blocking Bonjour/mDNS traffic
- Try reconnecting via USB, then wireless again

**Power saving:**
- iPhone Auto-Lock can disconnect wireless debugging
- Keep iPhone awake during development
- Or reconnect when needed (globe icon persists)

### "Hot reload not working after enabling wireless"

**Rebuild app:**
- Info.plist changed, so rebuild once (Cmd+B, Cmd+R)

**Check console:**
- Look for "💉 Injection connected" message
- If missing, ensure app is running on device

**Verify configuration:**
- Info.plist has `_inject._tcp` in NSBonjourServices ✅
- Views have `@ObserveInjection` and `.enableInjection()` ✅

## Benefits of Wireless Debugging

✅ **No USB cable needed** - Freedom to move around
✅ **InjectionIII hot reload** - 1-2 second updates
✅ **Wireless builds** - Deploy apps over WiFi
✅ **Wireless debugging** - Breakpoints, console logs work
✅ **Persistent connection** - Stays connected between sessions

## Performance

- **Initial connection:** 10-15 seconds
- **Subsequent connections:** Instant (if on same network)
- **Build/deploy over WiFi:** ~5-10% slower than USB (minimal)
- **Hot reload:** 1-2 seconds ⚡ (same as USB/simulator)

## What's Next?

Once wireless debugging is enabled:

1. ✅ **Disconnect USB** - You're wireless now!
2. ✅ **Rebuild app once** - Info.plist changed
3. ✅ **Test hot reload** - Edit, save, watch changes appear
4. ✅ **Develop freely** - 30x faster iteration with hot reload!

## Maintaining Wireless Connection

**Connection persists:**
- Across Xcode restarts
- Across Mac restarts (if on same network)
- Across app builds and runs

**Reconnect if needed:**
- Temporarily connect USB
- Wireless connection re-establishes automatically
- Globe icon 🌐 reappears

**Best practice:**
- Keep USB cable handy for quick reconnect
- First connection of day may need USB briefly
- After that, stays wireless all day!

---

**Status:** Ready to enable wireless debugging
**Time needed:** 2-3 minutes
**Result:** Wireless hot reload working in 1-2 seconds! ⚡

## References

- **Complete setup:** `docs/INJECTION_SETUP.md`
- **Fix details:** `docs/WIRELESS_HOT_RELOAD_FIX.md`
- **Quick checklist:** `WIRELESS_HOT_RELOAD_CHECKLIST.txt`
