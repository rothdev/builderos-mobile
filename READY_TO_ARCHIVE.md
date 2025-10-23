# ✅ BuilderOS Ready to Archive!

**Status:** App icon integrated, project ready

## Step 1: Configure Signing in Xcode (2 minutes)

Xcode is already open with the project. Now:

### 1a. Add Your Apple ID (if not already added)
1. **Xcode → Preferences** (or Settings)
2. **Accounts tab**
3. Click **"+" button** → **Apple ID**
4. Sign in with your Apple ID
5. Close Preferences

### 1b. Select Development Team
1. In **Project Navigator** (left sidebar) → Click **"BuilderOS"** (blue icon at top)
2. Select **"BuilderOS"** under **TARGETS** (not PROJECT)
3. Click **"Signing & Capabilities"** tab
4. Under **"Team"** dropdown → Select your **Apple ID**
   - If you have a paid account: Select your team name
   - If free account: Select your email address
5. Xcode may show "Provisioning profile created" ✅

### 1c. Change Bundle Identifier (Required for Free Account)
If using free Apple ID, you must use a unique bundle ID:

1. Same screen: **"Signing & Capabilities"** tab
2. **Bundle Identifier:** Change from `com.builderos.app` to:
   ```
   com.yourname.builderos
   ```
   (Replace "yourname" with your actual name or username)

---

## Step 2: Archive the App (2 minutes)

### 2a. Select Build Target
1. **Top toolbar:** Click dropdown next to "BuilderOS"
2. Scroll down and select **"Any iOS Device (arm64)"**
   - NOT a specific iPhone
   - NOT simulator

### 2b. Create Archive
1. **Menu Bar:** Product → **Archive**
   - Or press: **Shift + Cmd + B**
2. **Wait 2-3 minutes** for build
3. **Archive Organizer** window appears ✅

---

## Step 3: Export IPA (1 minute)

In the Archive Organizer window:

1. Click **"Distribute App"** button (right side)

2. **Select distribution method:**
   - Choose **"Development"**
   - Click **Next**

3. **Distribution options:**
   - App Thinning: **"None"**
   - Click **Next**

4. **Re-signing:**
   - Select **"Automatically manage signing"**
   - Click **Next**

5. **Review summary:**
   - Click **"Export"**

6. **Save location:**
   - Navigate to: `/Users/Ty/Downloads/`
   - Click **"Export"**

✅ **BuilderOS.ipa saved to Downloads!**

---

## Step 4: Sign & Install with Feather (3 minutes)

Now follow the Feather guide: `docs/FEATHER_DEPLOYMENT.md`

Quick summary:
1. Open **Feather** app on Mac
2. **Certificates** → Add your Apple ID (if not already)
3. **Sources** → **"+"** → Import `/Users/Ty/Downloads/BuilderOS.ipa`
4. Select BuilderOS → **"Sign"** → Choose certificate
5. **On iPhone (Safari):** Go to `http://[mac-ip]:3000`
6. Install BuilderOS → Trust developer in Settings

---

## Troubleshooting

### "Signing requires a development team"
- **Fix:** Complete Step 1b above (select team in Xcode)

### "Provisioning profile doesn't include signing certificate"
- **Fix:** Xcode → Preferences → Accounts → Download Manual Profiles
- Or: Change bundle ID to something unique

### "No signing certificate found"
- **Fix:** Free Apple ID works! Make sure you selected it in Team dropdown

### Build succeeds but Archive Organizer doesn't appear
- **Fix:** Window → Organizer (top menu)
- Or: Xcode may have opened it in background

---

## Summary

✅ **App icon installed** (Option 2 - Terminal Prompt ">")
🔄 **Ready to archive** → Follow steps above
📱 **Then install with Feather** → See FEATHER_DEPLOYMENT.md

**Total time:** ~6 minutes from here to app on your iPhone!
