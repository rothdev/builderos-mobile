# BuilderOS iOS - Feather Deployment Guide

Complete guide for building, signing, and installing BuilderOS iOS app using Feather.

## Prerequisites

- ✅ Mac with Xcode 15.0+
- ✅ Feather app installed on Mac ([feather.vercel.app](https://feather.vercel.app))
- ✅ iPhone connected to same WiFi as Mac
- ✅ Apple ID (free account works!)

## Step 1: Build IPA in Xcode

### 1a. Open Project
```bash
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile
open src/BuilderOS.xcodeproj
```

### 1b. Configure Signing (One-Time Setup)

In Xcode:
1. **Add Apple ID:**
   - Xcode → Preferences → Accounts
   - Click "+" → Apple ID
   - Sign in with your Apple ID

2. **Select Build Target:**
   - Top toolbar → Click "BuilderOS" (next to Run button)
   - Select "Any iOS Device (arm64)" from dropdown

3. **Configure Signing:**
   - Project Navigator → Click "BuilderOS" (blue icon)
   - Select "BuilderOS" under TARGETS
   - "Signing & Capabilities" tab
   - Team: Select your Apple ID
   - Bundle Identifier: Change to unique ID (e.g., `com.yourname.builderos`)

### 1c. Archive the App

1. **Menu Bar:** Product → Archive
2. **Wait for build** (takes 2-3 minutes first time)
3. **Archive Organizer appears** when complete

### 1d. Export IPA

In Archive Organizer:
1. Click **"Distribute App"**
2. Select **"Development"** → Next
3. Distribution method: **"App Thinning: None"** → Next
4. Re-sign: **"Automatically manage signing"** → Next
5. Review summary → **Export**
6. Choose save location: `/Users/Ty/Downloads/BuilderOS.ipa`

✅ **You now have BuilderOS.ipa ready for Feather!**

---

## Step 2: Sign & Install with Feather

### 2a. Open Feather

1. Launch **Feather** app on Mac
2. Ensure iPhone and Mac on **same WiFi**

### 2b. Add Certificate (First Time Only)

In Feather:
1. **Certificates tab** (top)
2. Click **"+"** → Add Certificate
3. **Sign in with Apple ID** (same one from Xcode)
4. Feather fetches your signing certificate
5. **Certificate appears** in list

### 2c. Import IPA

1. **Sources tab** → **"+"** → Import IPA
2. Navigate to `/Users/Ty/Downloads/BuilderOS.ipa`
3. Click **"Import"**
4. BuilderOS appears in app list

### 2d. Sign the IPA

1. Select **BuilderOS** in app list
2. Click **"Sign"** button
3. Choose your certificate from dropdown
4. Click **"Sign"** → Wait for signing (10-20 seconds)
5. ✅ Status changes to "Signed"

### 2e. Install to iPhone

**On iPhone:**
1. Open Safari
2. Navigate to: `http://[your-mac-ip]:3000`
   - Find Mac IP: System Settings → Network → WiFi → Details
   - Or Feather shows QR code to scan

**In Safari (iPhone):**
1. Tap **BuilderOS** app
2. Tap **"Install"**
3. Profile download popup → **"Allow"**
4. Settings app opens automatically
5. **"Profile Downloaded"** appears at top

**Install Profile:**
1. Settings → General → **"VPN & Device Management"**
2. Under "Downloaded Profile" → Tap **BuilderOS**
3. Tap **"Install"** (top right)
4. Enter iPhone passcode
5. Tap **"Install"** again (confirmation)
6. Tap **"Done"**

**Trust Developer:**
1. Settings → General → **"VPN & Device Management"**
2. Under "Developer App" → Tap your **Apple ID**
3. Tap **"Trust [Your Apple ID]"**
4. Tap **"Trust"** (confirmation popup)

✅ **BuilderOS app now on home screen!**

---

## Step 3: Launch & Configure

1. **Tap BuilderOS icon** on home screen
2. **Onboarding appears** → Tap "Get Started"
3. **Enter Cloudflare Tunnel URL:**
   ```
   https://viii-gmc-facing-salary.trycloudflare.com
   ```
4. **Enter API Token** (from Mac terminal when API server starts)
5. **Tap "Connect"** → Dashboard loads!

---

## Troubleshooting

### "Unable to Install"
- **Fix:** Check WiFi connection, retry install
- **Alt:** Connect iPhone via USB, use Xcode direct install

### "Untrusted Developer"
- **Fix:** Settings → General → VPN & Device Management → Trust developer

### "Profile Cannot Be Installed"
- **Fix:** Delete old profile first (if exists), then reinstall

### App Crashes on Launch
- **Fix:** Check Xcode console logs, verify bundle ID is unique

### Certificate Expired (After 7 Days)
- **Free Apple ID:** Re-sign with Feather, reinstall
- **Paid Apple ID ($99/yr):** Lasts 1 year

---

## Re-signing Updates (When App Expires)

App expires after 7 days (free) or 1 year (paid). To re-sign:

1. **Keep the IPA:** Don't delete `BuilderOS.ipa`
2. **Open Feather** when app expires
3. **Select BuilderOS** → **"Sign"**
4. **Install again** (same process as Step 2e)

Or rebuild from Xcode (Product → Archive) for latest code.

---

## Xcode Alternative (Faster for Development)

For quick testing during development:

```bash
# Connect iPhone via USB
# In Xcode: Select your iPhone from device dropdown
# Click Run (Cmd+R)
# Trust developer on iPhone
```

App installs in ~30 seconds but still expires after 7 days.

---

## Cost Summary

| Method | Cost | Duration | Notes |
|--------|------|----------|-------|
| Feather + Free Apple ID | $0 | 7 days | Re-sign weekly |
| Feather + Paid Apple ID | $99/year | 1 year | Re-sign yearly |
| Xcode Direct Install | $0 | 7 days | Requires USB cable |

**Recommendation:** Start free, upgrade to $99/year if you use daily.

---

## Next Steps

1. ✅ Build IPA in Xcode
2. ✅ Sign with Feather
3. ✅ Install on iPhone
4. 🚀 Use BuilderOS anywhere!

For TestFlight (Beta Distribution) or App Store release, see `docs/APP_STORE_DEPLOYMENT.md`.
