# BoxFort "Read Together" Feature - Setup Guide

## Overview
This feature enables grandparents (or other remote family members) to read BoxFort books synchronously with children. The host (parent/child with app) controls page navigation while the guest (grandparent) sees the same book update in real-time on any device via web link.

## Architecture
- **Backend:** Firebase Realtime Database (separate from existing Firestore)
- **iOS App:** Swift, integrated with existing BookView
- **Guest View:** Static web page hosted on Firebase Hosting
- **Security:** Subscriber-only feature with session expiration

## Setup Instructions

### 1. Firebase Realtime Database Setup

1. **Enable Realtime Database:**
   - Go to Firebase Console > Realtime Database
   - Create database in production mode
   - Choose a region close to your users

2. **Configure Security Rules:**
   - Go to Firebase Console > Realtime Database > Rules
   - Replace the rules with the content from `readTogetherRules.json`:
   ```json
   {
     "rules": {
       "readTogetherSessions": {
         "$sessionId": {
           ".read": "now < data.child('expiresAt').val() && data.child('status').val() == 'active'",
           ".write": "auth != null && (auth.uid == data.child('hostUserId').val() || auth.uid == newData.child('hostUserId').val())",
           ".validate": "newData.hasChildren(['bookId', 'currentPage', 'hostUserId', 'createdAt', 'expiresAt']) && newData.child('hostUserId').val() == auth.uid"
         }
       }
     }
   }
   ```

3. **Get Database URL:**
   - Copy the database URL (e.g., `https://boxfort-6a746-default-rtdb.firebaseio.com`)
   - You'll need this for the web guest view

https://boxfort-6a746-default-rtdb.firebaseio.com/

### 2. Firebase Hosting Setup

1. **Deploy the web guest view:**
   ```bash
   # From your project root
   firebase deploy --only hosting
   ```

2. **Update Firebase config in web view:**
   - Edit `public/read/index.html`
   - Replace the Firebase config with your actual values:
   ```javascript
   const firebaseConfig = {
     apiKey: "YOUR_ACTUAL_API_KEY",
     authDomain: "boxfort-6a746.firebaseapp.com",
     databaseURL: "https://boxfort-6a746-default-rtdb.firebaseio.com",
     projectId: "boxfort-6a746",
     storageBucket: "boxfort-6a746.appspot.com",
     messagingSenderId: "YOUR_ACTUAL_SENDER_ID",
     appId: "YOUR_ACTUAL_APP_ID"
   };
   ```

### 3. iOS App Integration

The following files have been added/modified:

**New Files:**
- `BoxFort/Services/ReadTogetherSessionManager.swift` - Manages Firebase sessions
- `BoxFort/Views/ReadTogetherView.swift` - UI for creating/managing sessions
- `public/read/index.html` - Web guest view

**Modified Files:**
- `BoxFort/Views/BookView.swift` - Added Read Together button for subscribers
- `firebase.json` - Added hosting configuration

### 4. Book Data Migration

You'll need to populate the web guest view with your book page URLs. Edit `public/read/index.html` and update the `bookMappings` object:

```javascript
const bookMappings = {
  'sheepover': {
    title: 'Sheep Over',
    pages: [
      'https://storage.boxfort.app/books/sheepover/SheepOver_000.jpg',
      'https://storage.boxfort.app/books/sheepover/SheepOver_001.jpg',
      // Add all page URLs for this book
    ]
  },
  'earworm': {
    title: 'Earworm',
    pages: [
      'https://storage.boxfort.app/books/earworm/Earworm_000.jpg',
      'https://storage.boxfort.app/books/earworm/Earworm_001.jpg',
      // Add all page URLs for this book
    ]
  }
  // Add more books as needed
};
```

### 5. Testing the Feature

1. **Build and run the iOS app**
2. **Open any book (must be a subscriber)**
3. **Tap the "Read Together" button (person icon)**
4. **Share the generated link**
5. **Open the link in a web browser**
6. **Test page navigation sync**

### 6. Analytics Tracking

The feature includes analytics tracking for:
- Session creation
- Page turns
- Session duration
- Session end

Events are automatically logged to Firebase Analytics.

## Security Features

1. **Subscriber-only access** - Only active subscribers can create sessions
2. **Session expiration** - Sessions expire after 24 hours
3. **Host-only control** - Only the session creator can control navigation
4. **Secure Firebase rules** - Prevents unauthorized access

## Cost Considerations

- **Realtime Database:** ~$1-5/month for moderate usage
- **Hosting:** Free tier sufficient for static files
- **Total estimated cost:** $5-10/month

## Troubleshooting

### Common Issues:

1. **"Session not found" error:**
   - Check if session has expired (24-hour limit)
   - Verify Firebase Realtime Database is enabled
   - Check security rules are properly configured

2. **Images not loading in web view:**
   - Verify image URLs are correct and accessible
   - Check CORS settings for your image storage
   - Update `bookMappings` with correct URLs

3. **Read Together button not showing:**
   - Verify user has active subscription
   - Check `userViewModel.isSubscriptionActive` is true

### Debug Steps:

1. Check Firebase Console > Realtime Database for session data
2. Verify Firebase Hosting deployment
3. Test with two devices (iOS app + web browser)
4. Check browser console for JavaScript errors

## Future Enhancements

Potential improvements for later:
- Multi-guest support
- Guest reactions/emojis
- Session recording
- Scheduled reading sessions
- Picture-in-picture video integration

## Support

For issues or questions:
1. Check Firebase Console logs
2. Verify all configuration steps completed
3. Test with a simple book first
4. Ensure both devices have stable internet connection
