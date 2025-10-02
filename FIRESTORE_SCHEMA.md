# Firestore Database Schema for Weekly Book Delivery

## Collections

### 1. `weekly_deliveries`
Stores weekly book delivery information.

```javascript
{
  id: "auto-generated",
  bookIds: ["book1", "book2", "book3"], // Array of book IDs
  deliveryDate: Timestamp, // When the delivery was created
  countdownEndTime: Timestamp, // When the countdown should end
  createdAt: Timestamp // Server timestamp
}
```

### 2. `app_config`
Stores application configuration, including countdown timer settings.

```javascript
{
  id: "countdown",
  targetDay: 4, // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  targetHour: 18, // 24-hour format (18 = 6pm)
  targetMinute: 0,
  timezone: "America/New_York",
  enabled: true,
  updatedAt: Timestamp
}
```

### 3. `books` (existing collection)
Extend your existing books collection to support dynamic content.

```javascript
{
  id: "book_id",
  title: "Book Title",
  featured: boolean,
  free: boolean,
  isPurchased: boolean,
  new: boolean,
  characters: ["patrick", "kevin"],
  littlebook: boolean,
  topRated: boolean,
  posterImage: "ImageName",
  promoImage: "PromoImageName",
  details: "Book description",
  bookUrl: "https://...",
  pages: ["page1", "page2", ...],
  allowsCoReading: boolean,
  // New fields for weekly delivery
  isWeeklyBook: boolean, // Mark as weekly delivery book
  weeklyDeliveryDate: Timestamp, // When this book was delivered
  weeklyDeliveryId: "weekly_delivery_id" // Reference to weekly delivery
}
```

## Security Rules

Add these security rules to your Firestore:

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
  }
}

// Helper function to check if user is admin
function isAdmin(uid) {
  return uid in ['admin_uid_1', 'admin_uid_2']; // Add your admin UIDs
}
```

## Setup Instructions

1. **Create Collections**: In Firebase Console, create the collections listed above.

2. **Add Initial Config**: Add a document to `app_config` with ID `countdown`:
   ```javascript
   {
     targetDay: 4,
     targetHour: 18,
     targetMinute: 0,
     timezone: "America/New_York",
     enabled: true,
     updatedAt: serverTimestamp()
   }
   ```

3. **Add Sample Weekly Delivery**: Create a sample weekly delivery:
   ```javascript
   {
     bookIds: ["thebox", "sportsday", "theexpert"],
     deliveryDate: serverTimestamp(),
     countdownEndTime: serverTimestamp(), // Set to next Thursday 6pm ET
     createdAt: serverTimestamp()
   }
   ```

4. **Update Security Rules**: Apply the security rules in your Firebase Console.

5. **Deploy Functions**: Deploy the Firebase Functions to enable the API endpoints.

## Admin Access

To grant admin access, update the `isAdmin` function in your Firebase Functions with your admin UIDs:

```javascript
function isAdmin(uid) {
  const adminUids = [
    'your_admin_uid_here',
    // Add more admin UIDs as needed
  ];
  return adminUids.includes(uid);
}
```

## Testing

1. Test the countdown timer by temporarily setting it to a few minutes from now
2. Test book delivery by creating a weekly delivery with existing book IDs
3. Verify the UI updates correctly when new books are delivered
4. Test the admin interface for managing deliveries and countdown settings 