# Replace Service Account Key

## Steps:

1. **Find the downloaded JSON file**
   - It's probably in your Downloads folder
   - Named something like: `mediconnect-4b155-xxxxx.json`

2. **Copy it to backend folder**
   - Copy the file
   - Paste it into: `backend/` folder
   - Rename it to: `serviceAccountKey.json`
   - Replace the existing file if asked

3. **Or use this command:**
   ```bash
   # Replace PATH_TO_DOWNLOADED_FILE with actual path
   cp ~/Downloads/mediconnect-4b155-*.json backend/serviceAccountKey.json
   ```

4. **Verify the file:**
   ```bash
   cd backend
   ls -la serviceAccountKey.json
   ```

## After Replacing:

Run this command to test:
```bash
cd backend
node src/scripts/test-firestore.js
```

If it works, you'll see:
```
✅ Firestore connection is working!
```

If it still fails, tell me the error message!
