# Weekly Book Delivery System - Deployment Guide

## Prerequisites

1. Firebase project with Firestore enabled
2. Firebase Functions deployed
3. iOS app with Firebase SDK configured
4. Admin access to Firebase Console

## Step 1: Deploy Firebase Functions

1. **Navigate to your functions directory:**
   ```bash
   cd functions
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Deploy functions:**
   ```bash
   firebase deploy --only functions
   ```

4. **Verify deployment:**
   - Check Firebase Console > Functions
   - Ensure all functions are deployed successfully

## Step 2: Set Up Firestore Database

1. **Create Collections:**
   - Go to Firebase Console > Firestore Database
   - Create collection: `weekly_deliveries`
   - Create collection: `app_config`
   - Ensure `books` collection exists (or create it)

2. **Add Initial Configuration:**
   - In `app_config` collection, create document with ID `countdown`
   - Add the following data:
   ```json
   {
     "targetDay": 4,
     "targetHour": 18,
     "targetMinute": 0,
     "timezone": "America/New_York",
     "enabled": true,
     "updatedAt": "serverTimestamp()"
   }
   ```

3. **Add Sample Weekly Delivery:**
   - In `weekly_deliveries` collection, create a new document
   - Add the following data:
   ```json
   {
     "bookIds": ["thebox", "sportsday", "theexpert"],
     "deliveryDate": "serverTimestamp()",
     "countdownEndTime": "serverTimestamp()",
     "createdAt": "serverTimestamp()"
   }
   ```

## Step 3: Configure Security Rules

1. **Go to Firestore Database > Rules**
2. **Replace existing rules with:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Weekly deliveries - read by all authenticated users, write by admins only
       match /weekly_deliveries/{document} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && isAdmin(request.auth.uid);
       }
       
       // App config - read by all authenticated users, write by admins only
       match /app_config/{document} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && isAdmin(request.auth.uid);
       }
       
       // Books - read by all, write by admins only
       match /books/{document} {
         allow read: if true;
         allow write: if request.auth != null && isAdmin(request.auth.uid);
       }
       
       // Existing rules for other collections...
     }
   }
   
   function isAdmin(uid) {
     return uid in ['your_admin_uid_here']; // Replace with your admin UID
   }
   ```

## Step 4: Update iOS App

1. **Add new files to your Xcode project:**
   - `WeeklyBookService.swift`
   - `WeeklyBooksSection.swift`
   - `AdminWeeklyBooksView.swift`

2. **Update HomePage.swift:**
   - The weekly books section has been automatically integrated
   - It will only show for subscribed users

3. **Build and test:**
   - Ensure all imports are correct
   - Test the weekly books section appears for subscribed users
   - Test the countdown timer functionality

## Step 5: Configure Admin Access

1. **Update Firebase Functions:**
   - Open `functions/index.js`
   - Find the `isAdmin` function
   - Add your admin UID to the array:
   ```javascript
   function isAdmin(uid) {
     const adminUids = [
       'your_firebase_auth_uid_here', // Replace with your actual UID
     ];
     return adminUids.includes(uid);
   }
   ```

2. **Redeploy functions:**
   ```bash
   firebase deploy --only functions
   ```

## Step 6: Test the System

1. **Test Countdown Timer:**
   - Temporarily set countdown to a few minutes from now
   - Verify countdown displays correctly
   - Verify countdown expires and shows "New books available!"

2. **Test Weekly Books:**
   - Use admin interface to add books to weekly delivery
   - Verify books appear in the weekly books section
   - Test clicking on books opens the book detail view

3. **Test Admin Interface:**
   - Access `AdminWeeklyBooksView` (you'll need to add navigation to it)
   - Test updating countdown configuration
   - Test publishing weekly deliveries

## Step 7: Production Setup

1. **Set Production Countdown:**
   - Use admin interface to set countdown to Thursday 6pm ET
   - Verify timezone is set to "America/New_York"

2. **Add Production Books:**
   - Upload new book assets to your app bundle
   - Add book metadata to Firestore `books` collection
   - Use admin interface to add books to weekly delivery

3. **Monitor and Maintain:**
   - Check Firebase Functions logs for errors
   - Monitor Firestore usage
   - Update weekly deliveries as needed

## Troubleshooting

### Common Issues:

1. **Functions not deploying:**
   - Check Node.js version (should be 22)
   - Ensure all dependencies are installed
   - Check Firebase CLI is up to date

2. **Countdown not working:**
   - Verify timezone configuration
   - Check Firestore security rules
   - Ensure countdown config document exists

3. **Books not loading:**
   - Verify book IDs exist in Firestore
   - Check weekly delivery document structure
   - Ensure user is authenticated

4. **Admin access denied:**
   - Verify admin UID is correct
   - Check Firebase Functions logs
   - Ensure user is authenticated

### Debug Commands:

```bash
# Check Firebase Functions logs
firebase functions:log

# Test functions locally
firebase emulators:start --only functions

# Check Firestore rules
firebase firestore:rules:get
```

## Maintenance

1. **Weekly Tasks:**
   - Add new books to weekly delivery
   - Monitor countdown timer
   - Check for any errors in Firebase logs

2. **Monthly Tasks:**
   - Review Firestore usage and costs
   - Update admin UIDs if needed
   - Backup important data

3. **Quarterly Tasks:**
   - Review and update security rules
   - Update Firebase SDK versions
   - Review and optimize functions 