# IAP Analytics System Guide

## Overview

This comprehensive IAP (In-App Purchase) analytics system provides detailed tracking for both **subscription conversions** and **individual book purchases** in BoxFort. The system is built around the `IAPAnalyticsService` class and integrates seamlessly with RevenueCat and Firebase Analytics.

## 🎯 **Key Features**

### **Subscription Tracking**
- ✅ **Conversion tracking** (`app_store_subscription_convert`)
- ✅ **New subscription purchases** (`app_store_subscription_purchase`)
- ✅ **Subscription renewals** (`app_store_subscription_renewal`)
- ✅ **Subscription cancellations** (`app_store_subscription_cancelled`)
- ✅ **Trial management** (started, converted, cancelled)
- ✅ **Purchase restoration**

### **Book Purchase Tracking**
- ✅ **Individual book purchases** (`app_store_book_purchase`)
- ✅ **Purchase attempts** (`app_store_book_purchase_attempt`)
- ✅ **Purchase failures** (`app_store_book_purchase_failed`)
- ✅ **Purchase restoration**

### **Paywall Analytics**
- ✅ **Paywall shown/dismissed** tracking
- ✅ **Time spent on paywall**
- ✅ **User interaction tracking**

## 📊 **Analytics Events**

### **Subscription Events**

#### `app_store_subscription_convert`
**Triggered when:** User converts from free trial to paid subscription
```swift
Parameters:
- product_id: String
- price: Decimal
- currency: String
- subscription_period: String
- previous_status: String
- conversion_source: String
```

#### `app_store_subscription_purchase`
**Triggered when:** New subscription is purchased
```swift
Parameters:
- product_id: String
- price: Decimal
- currency: String
- subscription_period: String
- purchase_source: String
- is_first_subscription: Bool
```

#### `app_store_subscription_renewal`
**Triggered when:** Subscription renews
```swift
Parameters:
- product_id: String
- price: Decimal
- currency: String
- subscription_period: String
- renewal_count: Int
```

#### `app_store_subscription_cancelled`
**Triggered when:** Subscription is cancelled
```swift
Parameters:
- product_id: String
- cancellation_reason: String? (optional)
- subscription_duration_days: Int? (optional)
```

#### `app_store_subscription_trial_started`
**Triggered when:** Free trial begins
```swift
Parameters:
- product_id: String
- trial_duration: String
- trial_source: String
```

#### `app_store_subscription_trial_converted`
**Triggered when:** Trial converts to paid
```swift
Parameters:
- product_id: String
- price: Decimal
- currency: String
- subscription_period: String
- trial_duration: String
```

### **Book Purchase Events**

#### `app_store_book_purchase`
**Triggered when:** Individual book is purchased
```swift
Parameters:
- book_id: String
- book_title: String
- product_id: String
- price: Decimal
- currency: String
- purchase_source: String
```

#### `app_store_book_purchase_attempt`
**Triggered when:** User attempts to purchase a book
```swift
Parameters:
- book_id: String
- book_title: String
- product_id: String
- price: Decimal
- currency: String
- purchase_source: String
```

#### `app_store_book_purchase_failed`
**Triggered when:** Book purchase fails
```swift
Parameters:
- book_id: String
- book_title: String
- product_id: String
- error_message: String
- purchase_source: String
```

### **Paywall Events**

#### `paywall_shown`
**Triggered when:** Paywall is displayed
```swift
Parameters:
- paywall_source: String
- user_type: String
- books_in_library: Int
```

#### `paywall_dismissed`
**Triggered when:** Paywall is dismissed
```swift
Parameters:
- paywall_source: String
- user_type: String
- time_spent_seconds: TimeInterval? (optional)
```

#### `paywall_interaction`
**Triggered when:** User interacts with paywall
```swift
Parameters:
- paywall_source: String
- interaction_type: String
- product_id: String? (optional)
```

### **System Events**

#### `revenuecat_customer_info_updated`
**Triggered when:** RevenueCat customer info changes
```swift
Parameters:
- active_entitlements_count: Int
- total_entitlements_count: Int
- has_active_subscription: Bool
- purchased_products_count: Int
```

#### `purchase_restoration`
**Triggered when:** Purchases are restored
```swift
Parameters:
- restoration_success: Bool
- restored_items_count: Int
```

#### `iap_error`
**Triggered when:** IAP errors occur
```swift
Parameters:
- error_type: String
- error_message: String
- error_source: String
- product_id: String? (optional)
```

## 🔧 **Implementation**

### **1. Service Integration**

The `IAPAnalyticsService` is automatically integrated into:

- **UserViewModel**: Tracks subscription changes and purchase restoration
- **BookDetailView**: Tracks book purchase attempts and completions
- **PaywallView**: Tracks paywall interactions and time spent

### **2. RevenueCat Integration**

The service automatically tracks:
- Customer info updates
- Subscription status changes
- Purchase restoration
- Error handling

### **3. Firebase Analytics**

All events are sent to Firebase Analytics with detailed parameters for:
- Revenue tracking
- User behavior analysis
- Conversion funnel optimization
- Error monitoring

## 📈 **Analytics Dashboard Setup**

### **Firebase Analytics Events to Monitor**

1. **Revenue Events**
   - `app_store_subscription_convert`
   - `app_store_subscription_purchase`
   - `app_store_book_purchase`

2. **Conversion Events**
   - `paywall_shown` → `paywall_dismissed`
   - `app_store_book_purchase_attempt` → `app_store_book_purchase`
   - `app_store_subscription_trial_started` → `app_store_subscription_trial_converted`

3. **Error Events**
   - `iap_error`
   - `app_store_book_purchase_failed`

### **Key Metrics to Track**

#### **Subscription Metrics**
- **Conversion Rate**: `app_store_subscription_trial_converted` / `app_store_subscription_trial_started`
- **Churn Rate**: `app_store_subscription_cancelled` / `app_store_subscription_purchase`
- **ARPU**: Average revenue per user
- **LTV**: Customer lifetime value

#### **Book Purchase Metrics**
- **Purchase Success Rate**: `app_store_book_purchase` / `app_store_book_purchase_attempt`
- **Average Order Value**: Total book purchase revenue / number of purchases
- **Popular Books**: Most purchased books by `book_id`

#### **Paywall Metrics**
- **Paywall Conversion**: Purchases after paywall shown
- **Time to Purchase**: Time between `paywall_shown` and purchase
- **Dismissal Rate**: `paywall_dismissed` / `paywall_shown`

## 🚀 **Usage Examples**

### **Manual Event Tracking**

```swift
// Track subscription conversion
iapAnalytics.trackSubscriptionConvert(
    productId: "bf_4999_1y",
    price: 49.99,
    currency: "USD",
    period: "year",
    previousStatus: "free_trial"
)

// Track book purchase
iapAnalytics.trackBookPurchase(
    bookId: "surprise",
    bookTitle: "Surprise",
    productId: "book_surprise",
    price: 2.99,
    currency: "USD",
    source: "book_detail"
)

// Track paywall interaction
iapAnalytics.trackPaywallInteraction(
    source: "homepage",
    interactionType: "subscription_button_tapped",
    productId: "bf_4999_1y"
)
```

### **Error Tracking**

```swift
iapAnalytics.trackIAPError(
    errorType: "purchase_failed",
    errorMessage: "Payment declined",
    productId: "book_surprise",
    source: "BookDetailView"
)
```

## 🔍 **Debugging**

### **Console Logs**

All IAP events include detailed console logging:
```
📊 IAP Analytics: Subscription converted - bf_4999_1y (49.99 USD)
📊 IAP Analytics: Book purchased - Surprise (2.99 USD)
📊 IAP Analytics: Paywall shown - paywall_view
📊 IAP Analytics: Error - purchase_failed: Payment declined
```

### **Testing**

1. **Test Purchase Flow**: Use sandbox accounts
2. **Test Restoration**: Use RevenueCat's restore purchases
3. **Test Errors**: Disconnect internet during purchase
4. **Verify Events**: Check Firebase Analytics dashboard

## 📋 **Best Practices**

### **1. Event Consistency**
- Use consistent parameter names across events
- Include all relevant context in parameters
- Use standardized source values

### **2. Error Handling**
- Track all IAP errors with context
- Include product IDs when available
- Categorize errors by type

### **3. User Privacy**
- Don't log sensitive payment information
- Use hashed user IDs when needed
- Follow GDPR/CCPA compliance

### **4. Performance**
- Events are sent asynchronously
- No blocking operations in tracking calls
- Minimal impact on app performance

## 🎯 **Next Steps**

1. **Set up Firebase Analytics dashboard** with custom events
2. **Create conversion funnels** for subscription and book purchases
3. **Monitor key metrics** daily/weekly
4. **A/B test paywall variations** using analytics data
5. **Optimize conversion rates** based on user behavior

---

**This analytics system provides comprehensive tracking for all IAP activities, enabling data-driven decisions to optimize revenue and user experience.** 