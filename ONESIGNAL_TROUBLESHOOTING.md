# OneSignal Integration Troubleshooting Guide

## Overview

This guide helps you troubleshoot OneSignal push notification issues in the BoxFort app, specifically addressing the 0% CTR (Click-Through Rate) and notification delivery problems.

## Recent Fixes Implemented

### 1. Added Notification Click Tracking
- **Problem**: No notification click handlers were implemented
- **Solution**: Added `OSNotificationDelegate` to `AppDelegate` with proper click tracking
- **Files Modified**: `BoxFort/Boxfort_PlusApp.swift`

### 2. Created OneSignalService
- **Problem**: OneSignal functionality was scattered and inconsistent
- **Solution**: Created dedicated `OneSignalService` class for centralized management
- **Files Created**: `BoxFort/Services/OneSignalService.swift`

### 3. Added User Identification
- **Problem**: No user targeting or segmentation
- **Solution**: Integrated OneSignal user login with authentication
- **Files Modified**: `BoxFort/Services/AuthenticationService.swift`

### 4. Added Notification Permission UI
- **Problem**: No user-friendly way to request notification permissions
- **Solution**: Created `NotificationPermissionView` for better UX
- **Files Created**: `BoxFort/Views/NotificationPermissionView.swift`

## Testing Checklist

### 1. Basic Setup Verification

#### Check OneSignal Initialization
```swift
// In AppDelegate, verify these lines exist:
OneSignal.initialize("fd180212-5b86-413e-924c-ec2f56c697c0", withLaunchOptions: launchOptions)
OneSignal.Notifications.delegate = self
```

#### Verify App Delegate Protocol
```swift
// AppDelegate should implement OSNotificationDelegate
class AppDelegate: NSObject, UIApplicationDelegate, OSNotificationDelegate {
    // ... implementation
}
```

### 2. Notification Permission Testing

#### Check Permission Status
```swift
// In console, look for:
"OneSignal: User accepted notifications: true/false"
"OneSignal: Device state updated - opted in: true/false"
```

#### Test Permission Request
1. Delete and reinstall the app
2. Check if permission prompt appears
3. Accept/deny and verify console logs

### 3. User Identification Testing

#### Check User Login
```swift
// In console, look for:
"OneSignal: Set user ID: [user_id]"
"OneSignal: Set up user segmentation for user: [email]"
```

#### Verify User Tags
```swift
// Check that these tags are set:
- subscription_status: "subscribed" or "free"
- user_type: "authenticated"
- children_count: "[number]"
```

### 4. Notification Delivery Testing

#### Test Notification Reception
1. Send a test notification from OneSignal dashboard
2. Check console for: `"OneSignal: Notification received in foreground"`
3. Verify notification appears on device

#### Test Notification Clicks
1. Send a test notification
2. Tap the notification
3. Check console for: `"OneSignal: Notification clicked!"`
4. Verify deep link handling works

### 5. Deep Link Testing

#### Test Book Deep Links
```json
// Send notification with this data:
{
  "book_id": "thebox",
  "title": "Test Book Notification",
  "body": "Tap to read The Box!"
}
```

#### Test Search Deep Links
```json
// Send notification with this data:
{
  "search_query": "monster",
  "title": "Search for Monsters",
  "body": "Find monster stories!"
}
```

## Common Issues and Solutions

### Issue 1: 0% CTR (Click-Through Rate)

**Symptoms**: Notifications are delivered but no clicks are recorded

**Causes**:
- Missing `OSNotificationDelegate` implementation
- No `notificationDidClick` method
- Incorrect delegate assignment

**Solutions**:
1. Verify `AppDelegate` implements `OSNotificationDelegate`
2. Ensure `OneSignal.Notifications.delegate = self` is set
3. Check that `notificationDidClick` method exists and logs events

### Issue 2: Notifications Not Delivered

**Symptoms**: Test device doesn't receive notifications despite being opted in

**Causes**:
- Incorrect OneSignal App ID
- Missing APNs certificate
- Device not properly registered
- Notification permission denied

**Solutions**:
1. Verify OneSignal App ID: `fd180212-5b86-413e-924c-ec2f56c697c0`
2. Check APNs certificate in OneSignal dashboard
3. Verify device registration in OneSignal dashboard
4. Check notification permission status

### Issue 3: Deep Links Not Working

**Symptoms**: Notifications are clicked but app doesn't navigate to correct screen

**Causes**:
- Missing deep link data in notification
- Incorrect deep link handling
- Notification data not parsed correctly

**Solutions**:
1. Verify notification payload includes correct deep link data
2. Check `handleNotificationDeepLink` method implementation
3. Ensure `NotificationCenter` posts are working

### Issue 4: User Segmentation Not Working

**Symptoms**: Can't target specific users or user groups

**Causes**:
- User not logged in to OneSignal
- Tags not set correctly
- User properties not set

**Solutions**:
1. Verify `OneSignal.login(userId)` is called
2. Check user tags are set correctly
3. Verify user properties are set

## Debugging Steps

### 1. Enable Verbose Logging
```swift
OneSignal.Debug.setLogLevel(.LL_VERBOSE)
```

### 2. Check Console Output
Look for these key log messages:
- `"OneSignal: Set user ID: [user_id]"`
- `"OneSignal: Notification received in foreground"`
- `"OneSignal: Notification clicked!"`
- `"OneSignal: Set user tags: [tags]"`

### 3. Verify OneSignal Dashboard
1. Check device registration
2. Verify user identification
3. Check notification delivery status
4. Review click tracking data

### 4. Test with Different Scenarios
1. App in foreground
2. App in background
3. App closed
4. Different notification types

## Best Practices

### 1. Notification Content
- Keep titles under 40 characters
- Keep body text under 200 characters
- Use clear call-to-action
- Include relevant deep link data

### 2. Timing
- Avoid sending notifications during quiet hours
- Don't send too frequently (max 1-2 per day)
- Consider user timezone

### 3. Segmentation
- Use user tags for targeting
- Segment by subscription status
- Segment by user behavior
- Test with small segments first

### 4. Analytics
- Track notification performance
- Monitor CTR trends
- A/B test different content
- Analyze user engagement

## OneSignal Dashboard Configuration

### 1. App Settings
- Verify App ID matches code
- Check APNs certificate
- Configure default language
- Set up webhooks if needed

### 2. User Properties
- Configure custom user properties
- Set up user segments
- Define targeting rules

### 3. Notification Templates
- Create reusable templates
- Set up automated campaigns
- Configure delivery schedules

## Support Resources

- [OneSignal iOS SDK Documentation](https://documentation.onesignal.com/docs/ios-sdk-setup)
- [OneSignal Troubleshooting Guide](https://documentation.onesignal.com/docs/troubleshooting)
- [iOS Push Notification Guide](https://developer.apple.com/documentation/usernotifications)

## Contact Information

If issues persist after following this guide:
1. Check OneSignal dashboard for detailed error logs
2. Review console output for specific error messages
3. Test with a fresh app install
4. Contact OneSignal support with specific error details 