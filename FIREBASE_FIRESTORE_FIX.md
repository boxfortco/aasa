# 🔧 Firebase Firestore Permissions Fix

## 🚨 **Problem**
iOS app getting Firestore permission errors:
```
Permission denied: Missing or insufficient permissions.
App attestation failed.
```

## ✅ **Solution: Update Firestore Security Rules**

### **Step 1: Go to Firebase Console**
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `boxfort-6a746`
3. Go to **Firestore Database**
4. Click **Rules** tab

### **Step 2: Update Security Rules**

Replace your current rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow reading progress for authenticated users
    match /reading_progress/{document} {
      allow read, write: if request.auth != null;
    }
    
    // Allow reading session data
    match /reading_sessions/{document} {
      allow read, write: if request.auth != null;
    }
    
    // Allow public read access to books and content
    match /books/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /book_sections/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Allow reading together sessions
    match /read_together_sessions/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### **Step 3: Publish Rules**
1. Click **Publish**
2. Wait for deployment to complete

## 🔍 **What This Fixes**

- ✅ **Reading progress** - authenticated users can save progress
- ✅ **Reading sessions** - co-reading functionality works
- ✅ **Book data** - public read access for content
- ✅ **Read Together** - session management works

## 🚨 **Alternative: More Restrictive Rules**

If you want tighter security:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reading progress - users can only access their own
    match /reading_progress/{document} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Public book content
    match /books/{document} {
      allow read: if true;
    }
    
    // Read Together sessions - host can manage their sessions
    match /read_together_sessions/{document} {
      allow read, write: if request.auth != null && 
        (resource.data.hostUserId == request.auth.uid || 
         request.auth.uid == resource.data.hostUserId);
    }
  }
}
```

## 🎯 **Testing**

After updating rules:

1. **Restart iOS app** completely
2. **Try reading a book** - should save progress
3. **Start Read Together session** - should work
4. **Check console** - no more permission errors

## 💡 **Note**

The **Read Together feature uses Firebase Realtime Database**, not Firestore, so it should work regardless of Firestore rules. The Firestore errors are from other parts of your app (reading progress, user data, etc.).

**The main issue is the S3 CORS policy - fix that first!** 🚀
