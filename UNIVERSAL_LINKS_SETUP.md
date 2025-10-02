# Universal Links Setup Guide

## Overview

Universal Links allow your app to handle links from Safari and other apps. This guide covers the complete setup needed for BoxFort deep links to work from Safari.

## What Was Missing

The main issues preventing Safari deep links from working were:

1. **Missing Associated Domains** - Required for Universal Links
2. **No Universal Links handling** - Only custom URL schemes were configured
3. **Missing entitlements** - Associated Domains capability not enabled

## Changes Made

### 1. Info.plist Updates

Added Associated Domains configuration:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:boxfort.co</string>
</array>
```

### 2. Entitlements Updates

Added Associated Domains capability to `BoxFort.entitlements`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:boxfort.co</string>
</array>
```

### 3. AppDelegate Updates

Enhanced URL handling to support both:
- **Custom URL schemes**: `boxfort://search?q=patrick`
- **Universal Links**: `https://boxfort.co/search?q=patrick`

### 4. StoryPreviewService Updates

Updated parsing logic to handle both URL types:
- Custom schemes: `boxfort://search?q=...`
- Universal Links: `https://boxfort.co/search?q=...`

## Required Server-Side Setup

For Universal Links to work, you need a server-side configuration:

### 1. Apple App Site Association (AASA) File

Create a file at `https://boxfort.co/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.boxfort.Boxfort",
        "paths": [
          "/search*",
          "/book*"
        ]
      }
    ]
  }
}
```

**Important Notes:**
- Replace `TEAM_ID` with your actual Apple Developer Team ID
- The file must be served over HTTPS
- No redirects allowed
- Content-Type should be `application/json`

### 2. Team ID Lookup

To find your Team ID:
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Click on "Membership" in the left sidebar
3. Your Team ID is displayed there

## Testing Universal Links

### 1. Development Testing

```bash
# Test the AASA file
curl -I https://boxfort.co/.well-known/apple-app-site-association

# Test Universal Links
curl -I https://boxfort.co/search?q=patrick
```

### 2. Device Testing

1. **Install the app** on a device
2. **Open Safari** and navigate to `https://boxfort.co/search?q=patrick`
3. **Tap the link** - it should open your app
4. **Check console logs** for debug output

### 3. Simulator Testing

Universal Links work differently in the simulator:
- Use the custom URL scheme: `boxfort://search?q=patrick`
- Or use the simulator's built-in URL testing

## Debugging Tips

### 1. Check AASA File

```bash
# Verify the file is accessible
curl https://boxfort.co/.well-known/apple-app-site-association

# Check for proper JSON
curl https://boxfort.co/.well-known/apple-app-site-association | python -m json.tool
```

### 2. Enable Universal Links Debugging

Add this to your device's Settings:
1. Go to Settings > Developer
2. Enable "Universal Links Debugging"

### 3. Check Console Logs

Look for these debug messages:
```
DEBUG: Universal Link received for boxfort.co
DEBUG: Parsed Universal Link search query: 'patrick'
```

## Common Issues

### 1. "This link cannot be opened" Error

**Causes:**
- AASA file not accessible
- Incorrect Team ID
- HTTPS not configured properly
- File has redirects

**Solutions:**
- Verify AASA file is accessible via curl
- Check Team ID matches your developer account
- Ensure HTTPS is properly configured
- Remove any redirects

### 2. Links Open in Safari Instead of App

**Causes:**
- App not installed
- AASA file not configured correctly
- Associated Domains not enabled

**Solutions:**
- Install the app first
- Verify AASA file configuration
- Check entitlements are properly set

### 3. App Opens But Search Doesn't Work

**Causes:**
- URL parsing logic issue
- Search state not updating properly

**Solutions:**
- Check debug logs for URL parsing
- Verify search text is being set correctly

## Production Deployment

### 1. Update AASA File

Ensure your production server has the correct AASA file:
- Use production Team ID
- Include all necessary paths
- Test accessibility

### 2. Verify Entitlements

Check that the production build includes:
- Associated Domains capability
- Correct domain configuration

### 3. Test on Real Devices

Universal Links behavior can differ between:
- Simulator vs. real devices
- Different iOS versions
- Different network conditions

## Alternative: Custom URL Schemes

If Universal Links continue to have issues, you can fall back to custom URL schemes:

### 1. Manual URL Entry

Users can manually type: `boxfort://search?q=patrick`

### 2. QR Codes

Generate QR codes for custom URL schemes:
```swift
let url = URL(string: "boxfort://search?q=patrick")!
let qrCode = generateQRCode(for: url)
```

### 3. Share Sheets

Include custom URL schemes in share functionality:
```swift
let shareText = "Check out this story: boxfort://search?q=patrick"
```

## Summary

The key changes made:

1. ✅ Added Associated Domains to Info.plist
2. ✅ Added Associated Domains to entitlements
3. ✅ Enhanced AppDelegate to handle Universal Links
4. ✅ Updated StoryPreviewService to parse both URL types
5. ✅ Removed test buttons

**Next Steps:**
1. Set up the AASA file on your server
2. Test with real devices
3. Verify Universal Links work from Safari
4. Deploy to production

## Resources

- [Apple Universal Links Documentation](https://developer.apple.com/ios/universal-links/)
- [AASA File Specification](https://developer.apple.com/documentation/xcode/supporting-associated-domains)
- [Universal Links Debugging](https://developer.apple.com/documentation/xcode/supporting-associated-domains#Enable-Associated-Domains-Debugging) 

## Current Analytics Setup Analysis

**Yes, it is possible to track which onboarding carousel books perform best for paid conversions**, but there are some limitations in the current implementation that could be enhanced.

### What's Currently Tracked:

1. **Onboarding Book Selection** (`onboarding_book_selected`)
   - Tracks when users select a specific book from the onboarding carousel
   - Parameters: `book_id`, `book_title`

2. **Book Completion** (`book_reading_completed`)
   - Tracks when users complete reading a book
   - Parameters: `book_id`, `book_title`, `total_pages`

3. **Subscription Conversions** (`app_store_subscription_convert`)
   - Tracks when users convert to paid subscriptions
   - Parameters: `product_id`, `price`, `currency`, `subscription_period`, `previous_status`, `conversion_source`

4. **Paywall Interactions** (`paywall_shown`, `paywall_dismissed`)
   - Tracks paywall display and dismissal
   - Parameters: `paywall_source`, `user_type`, `time_spent_seconds`

### Current Limitations:

1. **Missing Connection**: The current setup doesn't directly link which onboarding book led to a subscription conversion
2. **Generic Conversion Source**: The `conversion_source` parameter is hardcoded as "paywall" rather than being dynamic
3. **No Onboarding-Specific Paywall Tracking**: The paywall shown after onboarding book completion uses the same generic source

### What You Can Currently Analyze:

In Firebase Analytics, you can create funnels to track:
1. `onboarding_carousel_shown` → `onboarding_book_selected` → `book_reading_completed` → `paywall_shown` → `app_store_subscription_convert`

However, you'd need to manually correlate the data since there's no direct parameter linking the onboarding book to the eventual conversion.

### Recommended Enhancement:

To get better insights, you could enhance the analytics by:

1. **Adding onboarding context to paywall tracking**:
   ```swift
   // In PaywallView, track the source more specifically
   iapAnalytics.trackPaywallShown(
       source: isFromOnboarding ? "onboarding_paywall" : "paywall_view",
       userType: "non_subscriber"
   )
   ```

2. **Adding onboarding book ID to conversion events**:
   ```swift
   // Track which onboarding book led to conversion
   Analytics.logEvent("app_store_subscription_convert", parameters: [
       "product_id": productId,
       "price": price as NSDecimalNumber,
       "currency": currency,
       "subscription_period": period,
       "previous_status": previousStatus,
       "conversion_source": "onboarding_paywall",
       "onboarding_book_id": onboardingBookId // Add this
   ])
   ```

This would allow you to directly see which onboarding books have the highest conversion rates to paid subscriptions in your Firebase Analytics dashboard. 