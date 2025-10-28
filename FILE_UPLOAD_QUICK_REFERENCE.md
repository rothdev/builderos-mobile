# File Upload - Quick Reference

## User Flow

1. **Open Chat** → Tap paperclip icon (left of text field)
2. **Choose Type** → Select "Photos" or "Documents"
3. **Select Files** → Multi-select in system picker
4. **Review** → See chips with filename + size
5. **Remove** → Tap X on chip to remove (optional)
6. **Send** → Type message + tap send arrow

## File Locations

```
src/BuilderSystemMobile/
├── Features/Chat/
│   ├── Models/
│   │   └── FileAttachment.swift          # Attachment data model
│   └── Views/
│       ├── PhotoPickerView.swift          # Photo picker wrapper
│       ├── DocumentPickerView.swift       # Document picker wrapper
│       └── FileAttachmentChip.swift       # Preview chip UI
└── Services/
    └── FileUploadService.swift            # Upload logic
```

## API Usage

### Add Attachment Programmatically
```swift
let attachment = FileAttachment(
    type: .photo,
    data: imageData,
    filename: "screenshot.jpg",
    mimeType: "image/jpeg"
)
chatViewModel.addAttachment(attachment)
```

### Upload Files
```swift
// Automatic on send
chatViewModel.sendMessage("Check these files", hasVoiceAttachment: false)

// Manual upload
await chatViewModel.uploadAttachments()
```

### Remove Attachment
```swift
chatViewModel.removeAttachment(id: attachment.id)
```

## Supported File Types

**Photos:**
- JPEG images (auto-compressed to 0.8 quality)
- PNG images
- HEIC images (iOS format)
- Up to 5 photos per message

**Documents:**
- PDF documents
- Text files (.txt, .md)
- JSON files
- Images (all formats)
- Videos (all formats)
- Audio files
- Archives (.zip, .tar)
- Spreadsheets
- Presentations

## Permissions

**Required:** Photo Library Access
**Prompt:** "Builder System Mobile needs access to your photo library to attach images..."
**When:** First time user taps "Photos" button

## Customization

### Change Photo Limit
```swift
// PhotoPickerView.swift, line 15
configuration.selectionLimit = 5  // Change to desired limit
```

### Change JPEG Quality
```swift
// PhotoPickerView.swift, line 46
let imageData = image.jpegData(compressionQuality: 0.8)  // 0.0-1.0
```

### Add File Type
```swift
// DocumentPickerView.swift, line 9-20
let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
    .pdf,
    .text,
    // Add more UTTypes here
])
```

### Customize Upload Endpoint
```swift
// ChatViewModel.swift, line 150
let results = try await uploadService.uploadFiles(attachments, to: "/api/upload")
```

## Build & Run

```bash
cd /Users/Ty/BuilderOS/capsules/builderos-mobile

# Build
xcodebuild -project src/BuilderOS.xcodeproj \
  -scheme BuilderOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build

# Or open in Xcode
open src/BuilderOS.xcodeproj
```

## Testing Tips

1. **Simulator:** Photos work, but limited library
2. **Physical Device:** Full photo library access
3. **Test Files:** Use Files app to add test documents
4. **Network:** Test with/without backend endpoint
5. **Edge Cases:** Empty files, large files (10MB+), special characters in names

## Troubleshooting

**Picker doesn't open?**
- Check Info.plist has NSPhotoLibraryUsageDescription
- Verify permission granted in Settings → Privacy

**Upload fails?**
- Check backend endpoint exists at `/api/upload`
- Verify multipart/form-data support on backend
- Check network connectivity

**Files don't appear as chips?**
- Check chatViewModel.attachments array
- Verify main thread updates in picker coordinators
- Check ForEach binding in VoiceInputView

**Remove button doesn't work?**
- Verify removeAttachment(id:) called
- Check array mutation on @Published property
- Ensure UI updates via @EnvironmentObject

## Backend Endpoint Example

```python
# Flask example
@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return {'error': 'No file'}, 400

    file = request.files['file']
    filename = secure_filename(file.filename)
    file.save(os.path.join(UPLOAD_FOLDER, filename))

    return {'url': f'/uploads/{filename}'}, 200
```

---

**Implementation:** Complete ✅
**Build Status:** Passing ✅
**Ready For:** Testing & Backend Integration
