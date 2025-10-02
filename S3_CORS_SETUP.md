# 🔧 S3 CORS Configuration Fix

## 🚨 **Problem**
Browser is blocking S3 requests due to missing CORS policy:
```
A resource is blocked by OpaqueResponseBlocking
NS_BINDING_ABORTED
```

## ✅ **Solution: Add CORS Policy to S3 Bucket**

### **Step 1: Go to AWS S3 Console**
1. Open [AWS S3 Console](https://s3.console.aws.amazon.com/)
2. Click on your bucket: `boxfort-storybooks`
3. Go to **Permissions** tab
4. Scroll down to **Cross-origin resource sharing (CORS)**
5. Click **Edit**

### **Step 2: Add CORS Configuration**
Paste this JSON configuration:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "HEAD"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [
            "ETag",
            "x-amz-meta-*"
        ],
        "MaxAgeSeconds": 3000
    }
]
```

### **Step 3: Save Configuration**
1. Click **Save changes**
2. Wait 1-2 minutes for changes to propagate

## 🎯 **What This Does**

- **`AllowedOrigins: ["*"]`** - Allows requests from any domain (including your web app)
- **`AllowedMethods: ["GET", "HEAD"]`** - Allows image loading
- **`AllowedHeaders: ["*"]`** - Allows all headers
- **`MaxAgeSeconds: 3000`** - Caches CORS preflight for 50 minutes

## 🔍 **Testing**

After adding CORS policy:

1. **Clear browser cache** (Ctrl+Shift+R or Cmd+Shift+R)
2. **Open a Read Together session**
3. **Check browser console** - no more CORS errors
4. **Images should load** including GIFs

## 🚨 **Alternative: More Restrictive CORS (Recommended for Production)**

If you want to be more secure, replace `"*"` with your specific domains:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "HEAD"
        ],
        "AllowedOrigins": [
            "https://boxfort-6a746.web.app",
            "https://boxfort-6a746.firebaseapp.com"
        ],
        "ExposeHeaders": [
            "ETag"
        ],
        "MaxAgeSeconds": 3000
    }
]
```

## ⚡ **Quick Fix Commands**

If you have AWS CLI installed:

```bash
# Get current CORS policy
aws s3api get-bucket-cors --bucket boxfort-storybooks

# Set CORS policy
aws s3api put-bucket-cors --bucket boxfort-storybooks --cors-configuration file://cors.json
```

Where `cors.json` contains the JSON above.

## 🎉 **Expected Result**

After applying CORS policy:
- ✅ **No more CORS errors** in browser console
- ✅ **Images load properly** from S3
- ✅ **GIFs work** with extension fallback
- ✅ **Read Together sync** works perfectly

**This should fix the image loading issues immediately!** 🚀
