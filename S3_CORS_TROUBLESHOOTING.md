# 🔧 S3 CORS Troubleshooting

## 🚨 **If Images Still Not Loading After CORS Setup**

### **Step 1: Verify CORS Policy Applied**
1. Go to AWS S3 Console → `boxfort-storybooks` bucket
2. Permissions tab → Cross-origin resource sharing (CORS)
3. **Verify the policy is there** and matches exactly:

```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "HEAD"],
        "AllowedOrigins": [
            "https://boxfort-6a746.web.app",
            "https://boxfort-6a746.firebaseapp.com"
        ],
        "ExposeHeaders": ["ETag"],
        "MaxAgeSeconds": 3000
    }
]
```

### **Step 2: Clear Browser Cache**
- **Chrome/Edge:** Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
- **Firefox:** Ctrl+F5 (Windows) or Cmd+Shift+R (Mac)
- **Safari:** Cmd+Option+R

### **Step 3: Test Direct S3 URL**
Test if S3 is accessible by opening this URL directly in browser:
```
https://boxfort-storybooks.s3.us-east-2.amazonaws.com/TheBox/TheBox_000.jpg
```

**Expected:** Image should load
**If not:** S3 bucket permissions issue

### **Step 4: Check S3 Bucket Permissions**
1. Go to S3 bucket → Permissions tab
2. **Block Public Access:** Should be OFF for public read access
3. **Bucket Policy:** Should allow public read access

**Add this bucket policy if missing:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::boxfort-storybooks/*"
        }
    ]
}
```

### **Step 5: Test with Simple CORS**
If still not working, try this simpler CORS policy:

```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET"],
        "AllowedOrigins": ["*"],
        "MaxAgeSeconds": 3000
    }
]
```

**Note:** This is less secure but will work for testing.

## 🔍 **Debug Steps**

### **Check Browser Console**
1. Open Read Together session
2. Open browser Developer Tools (F12)
3. Go to Console tab
4. Look for CORS errors

**Expected errors to disappear:**
- `Access to fetch at 'https://boxfort-storybooks.s3.us-east-2.amazonaws.com/...' from origin 'https://boxfort-6a746.web.app' has been blocked by CORS policy`
- `NS_BINDING_ABORTED`

### **Test Different Browsers**
- Try Chrome, Firefox, Safari
- If one works, it's a browser-specific issue

## 🚀 **Quick Fix Commands**

If you have AWS CLI:
```bash
# Check current CORS
aws s3api get-bucket-cors --bucket boxfort-storybooks

# Set simple CORS (for testing)
aws s3api put-bucket-cors --bucket boxfort-storybooks --cors-configuration '{
    "CORSRules": [
        {
            "AllowedHeaders": ["*"],
            "AllowedMethods": ["GET"],
            "AllowedOrigins": ["*"],
            "MaxAgeSeconds": 3000
        }
    ]
}'
```

## 🎯 **Expected Result**

After fixing CORS:
- ✅ **No CORS errors** in browser console
- ✅ **Images load** from S3
- ✅ **GIFs work** with extension fallback
- ✅ **Read Together sync** works perfectly

**If still not working, the issue might be S3 bucket permissions, not CORS!**
