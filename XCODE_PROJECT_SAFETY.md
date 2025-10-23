# Xcode Project Safety Guide

## 🛡️ Protection Measures in Place

### 1. Automatic Backups
**Script:** `src/.xcode-backup.sh`

Run before making project changes:
```bash
cd src && ./.xcode-backup.sh
```

- Creates timestamped backups in `src/.xcodeproj-backups/`
- Keeps last 10 backups automatically
- Validates project file format

### 2. Git Tracking
The project file (`BuilderOS.xcodeproj/project.pbxproj`) is tracked in git:
- ✅ Commit after adding/removing files
- ✅ Review changes before committing
- ✅ Can revert to previous versions if corrupted

### 3. Manual Validation
Check project health:
```bash
# Validate project can be parsed
xcodebuild -project BuilderOS.xcodeproj -list

# Check file format
head -1 BuilderOS.xcodeproj/project.pbxproj
# Should output: // !$*UTF8*$!
```

## ⚠️ Common Causes of Corruption

### 1. Concurrent Edits
**Problem:** Opening project in multiple Xcode instances or editing while Xcode is open
**Solution:**
- Close Xcode before programmatic changes
- Only open project in one Xcode instance
- Use `xcodebuild` commands only when Xcode is closed

### 2. Incomplete Writes
**Problem:** Process killed while writing project file
**Solution:**
- Let Xcode operations complete
- Don't force-quit Xcode during saves
- Use atomic writes (backup, write, move)

### 3. Manual Edits Gone Wrong
**Problem:** Direct text editing of .pbxproj file with errors
**Solution:**
- Avoid manual edits when possible
- Use Xcode GUI for adding/removing files
- If scripting, use tools like `xcodeproj` Ruby gem

### 4. Merge Conflicts
**Problem:** Git merge conflicts in project file
**Solution:**
- Be extra careful resolving .pbxproj conflicts
- Test with `xcodebuild -list` after resolving
- When in doubt, regenerate project from scratch

## 🔧 Recovery Steps

### If Project Becomes Corrupted:

**Option 1: Restore from Backup**
```bash
cd src/.xcodeproj-backups
ls -lt  # Find latest good backup
cp project.pbxproj.TIMESTAMP ../BuilderOS.xcodeproj/project.pbxproj
```

**Option 2: Restore from Git**
```bash
cd /Users/Ty/BuilderOS/capsules/builder-system-mobile
git checkout -- src/BuilderOS.xcodeproj/project.pbxproj
```

**Option 3: Regenerate from Scratch**
```bash
# Mobile Dev agent can recreate project
# Takes ~5 minutes but guarantees clean state
```

## 📋 Best Practices

### When Adding Files to Project:
1. **Run backup:** `./src/.xcode-backup.sh`
2. **Use Xcode GUI:** File → Add Files to "BuilderOS"...
3. **Commit changes:** `git add src/BuilderOS.xcodeproj && git commit`

### When Using Command-Line Tools:
1. **Close Xcode first**
2. **Run backup before changes**
3. **Validate after changes:** `xcodebuild -project BuilderOS.xcodeproj -list`
4. **Commit if successful**

### Daily Workflow:
- ✅ Commit project file changes regularly
- ✅ Run backup before risky operations
- ✅ Keep Xcode closed when using build scripts
- ✅ Test project opens in Xcode after programmatic changes

## 🚨 Emergency Contacts

If project corruption persists:
1. Check `src/.xcodeproj-backups/` for recent backups
2. Review `git log src/BuilderOS.xcodeproj/` for last good commit
3. Delegate to 📱 Mobile Dev agent to regenerate project

---

**Last Updated:** October 22, 2025
**Current Project Status:** ✅ Healthy (validated and backed up)
