# GitHub Pages Universal Links Setup

## Overview

This guide shows how to use GitHub Pages to host the Apple App Site Association (AASA) file for Universal Links, eliminating the need for a separate server.

## Setup Steps

### 1. Enable GitHub Pages

1. Go to your GitHub repository
2. Click **Settings** tab
3. Scroll down to **Pages** section
4. Under **Source**, select **Deploy from a branch**
5. Choose **main** branch and **/(root)** folder
6. Click **Save**

### 2. Create the AASA File

The file `aasa/apple-app-site-association` has been created in your repository. 

**Important**: The Team ID has been set to `M83E6KBJYA`.

### 3. AASA File Configuration

The file `aasa/apple-app-site-association` is configured with:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "M83E6KBJYA.com.boxfort.Boxfort",
        "paths": [
          "/aasa/search*",
          "/aasa/book*"
        ]
      }
    ]
  }
}
```

### 4. Commit and Push

```bash
git add aasa/apple-app-site-association
git commit -m "Add Apple App Site Association file for Universal Links"
git push origin main
```

### 5. Verify GitHub Pages

After pushing, wait a few minutes for GitHub Pages to deploy, then test:

```bash
# Test if the AASA file is accessible
curl https://boxfortco.github.io/aasa/apple-app-site-association

# Should return the JSON content
```

## Testing Universal Links

### 1. Test AASA File

```bash
# Verify the file is accessible and has correct content
curl https://boxfortco.github.io/aasa/apple-app-site-association | python -m json.tool
```

### 2. Test Universal Links

1. **Install the app** on a device
2. **Open Safari** and navigate to:
   ```
   https://boxfortco.github.io/aasa/search?q=patrick
   ```
3. **Tap the link** - it should open your app
4. **Check console logs** for debug output

### 3. Test Custom URL Schemes

You can also test the custom URL scheme directly:
```
boxfort://search?q=patrick
```

## URL Examples

### Universal Links (GitHub Pages)
```
https://boxfortco.github.io/aasa/search?q=patrick
https://boxfortco.github.io/aasa/search?q=kevin
https://boxfortco.github.io/aasa/search?q=arty
```

### Custom URL Schemes
```
boxfort://search?q=patrick
boxfort://search?q=kevin
boxfort://search?q=arty
```

## Troubleshooting

### 1. AASA File Not Accessible

**Check:**
- GitHub Pages is enabled
- File is in the correct location (`.well-known/apple-app-site-association`)
- Repository is public (or you have GitHub Pro for private repos)
- Wait a few minutes for deployment

### 2. Universal Links Not Working

**Check:**
- Team ID is correct in AASA file
- Associated Domains is enabled in entitlements
- App is installed on device
- Testing on real device (not simulator)

### 3. Debug Universal Links

Enable Universal Links debugging on your device:
1. Go to Settings > Developer
2. Enable "Universal Links Debugging"

## Advantages of GitHub Pages

✅ **Free hosting** - No server costs
✅ **Automatic HTTPS** - Required for Universal Links
✅ **Easy updates** - Just commit and push
✅ **Version control** - Track changes over time
✅ **No server maintenance** - GitHub handles everything

## Production Considerations

For production apps, you might want to:

1. **Use a custom domain** instead of `matthewryan.github.io`
2. **Set up proper redirects** from your main domain
3. **Add analytics** to track link usage
4. **Implement fallback pages** for when the app isn't installed

## Custom Domain Setup (Optional)

If you want to use a custom domain:

1. **Add custom domain** in GitHub Pages settings
2. **Update AASA file** to use your custom domain
3. **Update app configuration** to use your custom domain
4. **Set up DNS** to point to GitHub Pages

## Summary

✅ AASA file created at `aasa/apple-app-site-association`
✅ Info.plist updated for `boxfortco.github.io`
✅ Entitlements updated for `boxfortco.github.io`
✅ AppDelegate updated for GitHub Pages
✅ StoryPreviewService updated for GitHub Pages
✅ Web deep links updated for GitHub Pages

**Next Steps:**
1. Commit and push the AASA file
2. Enable GitHub Pages
3. Test Universal Links on a device 