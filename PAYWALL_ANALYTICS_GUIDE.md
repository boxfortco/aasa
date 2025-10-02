# Paywall Analytics Guide

## Problem Solved

The previous paywall tracking system had a fundamental flaw where `paywall_dismissed` events were firing for **both** successful purchases and explicit dismissals, creating misleading 1:1 ratios in Google Analytics. This made it impossible to accurately measure paywall performance.

## New Paywall Tracking System

### Key Events

#### 1. `paywall_shown`
**When:** Paywall is displayed to user
```swift
Parameters:
- paywall_source: String (e.g., "paywall_view", "onboarding_paywall")
- user_type: String (e.g., "non_subscriber", "trial_user")
- books_in_library: Int
```

#### 2. `paywall_dismissed_without_purchase`
**When:** User explicitly dismisses paywall without purchasing
```swift
Parameters:
- paywall_source: String
- user_type: String
- dismissal_method: String (e.g., "close_button", "parental_gate_close", "sheet_dismiss")
- time_spent_seconds: TimeInterval (optional)
```

#### 3. `paywall_purchase_attempt`
**When:** User starts a purchase flow
```swift
Parameters:
- paywall_source: String
- product_id: String
- user_type: String
```

#### 4. `paywall_purchase_completed`
**When:** Purchase is successfully completed
```swift
Parameters:
- paywall_source: String
- product_id: String
- price: Decimal
- currency: String
- user_type: String
```

#### 5. `paywall_purchase_failed`
**When:** Purchase attempt fails
```swift
Parameters:
- paywall_source: String
- product_id: String
- error_message: String
- user_type: String
```

#### 6. `paywall_interaction`
**When:** User interacts with paywall elements
```swift
Parameters:
- paywall_source: String
- interaction_type: String (e.g., "button_tap", "scroll", "product_view")
- product_id: String (optional)
```

## Implementation Details

### PaywallView Changes

The `PaywallView` now tracks different dismissal scenarios:

1. **Explicit dismissals** (close button, parental gate close)
2. **Sheet dismissals** (swipe down, tap outside)
3. **Purchase completions** (via RevenueCat notifications)

### Purchase Flow Tracking

```swift
// 1. Paywall shown
iapAnalytics.trackPaywallShown(source: "paywall_view")

// 2. User attempts purchase (handled by RevenueCat UI)
// 3. Purchase completed (RevenueCat notification)
NotificationCenter.default.post(name: .purchaseCompleted, object: nil, userInfo: [
    "productId": productId,
    "isTrialConversion": isTrialConversion
])

// 4. Paywall tracks completion
iapAnalytics.trackPaywallPurchaseCompleted(
    source: "paywall_view",
    productId: productId,
    price: price,
    currency: currency
)
```

## Analytics Dashboard Setup

### Key Metrics to Track

#### 1. **Paywall Conversion Rate**
```
Formula: paywall_purchase_completed / paywall_shown
```

#### 2. **Dismissal Rate**
```
Formula: paywall_dismissed_without_purchase / paywall_shown
```

#### 3. **Purchase Success Rate**
```
Formula: paywall_purchase_completed / paywall_purchase_attempt
```

#### 4. **Average Time to Purchase**
```
Metric: Average time_spent_seconds for paywall_purchase_completed events
```

#### 5. **Dismissal Method Analysis**
```
Breakdown: paywall_dismissed_without_purchase by dismissal_method
```

### Firebase Analytics Funnels

#### **Complete Paywall Funnel**
1. `paywall_shown`
2. `paywall_interaction` (optional)
3. `paywall_purchase_attempt`
4. `paywall_purchase_completed` OR `paywall_purchase_failed`
5. `paywall_dismissed_without_purchase` (if no purchase)

#### **Conversion Funnel**
1. `paywall_shown`
2. `paywall_purchase_attempt`
3. `paywall_purchase_completed`

### Custom Dimensions

Set up these custom dimensions in Firebase Analytics:

1. **paywall_source** - Track performance by paywall location
2. **dismissal_method** - Understand how users exit
3. **product_id** - Track performance by subscription tier
4. **user_type** - Segment by user status

## Migration from Old System

### Legacy Events
- `paywall_dismissed` - Still tracked for backward compatibility
- Use `paywall_dismissed_without_purchase` for new implementations

### Data Comparison
- **Old:** `paywall_shown` vs `paywall_dismissed` (misleading 1:1 ratio)
- **New:** `paywall_shown` vs `paywall_dismissed_without_purchase` (accurate dismissal rate)

## Best Practices

### 1. **Source Tracking**
Always use specific sources:
```swift
// Good
source: "onboarding_paywall"
source: "book_limit_paywall"
source: "feature_paywall"

// Avoid
source: "paywall"
```

### 2. **User Type Segmentation**
Track different user segments:
```swift
userType: "non_subscriber"     // Never subscribed
userType: "trial_user"         // Currently in trial
userType: "expired_subscriber" // Previously subscribed
```

### 3. **Dismissal Method Analysis**
Understand user behavior:
```swift
dismissalMethod: "close_button"      // Intentional close
dismissalMethod: "sheet_dismiss"     // Swipe down
dismissalMethod: "parental_gate_close" // Failed parental gate
```

### 4. **Time Tracking**
Use time spent to optimize paywall:
```swift
// Track engagement
if timeSpent > 30 {
    // User engaged with paywall
}

// Track quick dismissals
if timeSpent < 5 {
    // User dismissed immediately
}
```

## Example Analytics Queries

### **Paywall Performance by Source**
```sql
SELECT 
  paywall_source,
  COUNT(*) as shows,
  COUNTIF(event_name = 'paywall_purchase_completed') as conversions,
  COUNTIF(event_name = 'paywall_dismissed_without_purchase') as dismissals,
  COUNTIF(event_name = 'paywall_purchase_completed') / COUNT(*) as conversion_rate
FROM analytics_events 
WHERE event_name IN ('paywall_shown', 'paywall_purchase_completed', 'paywall_dismissed_without_purchase')
GROUP BY paywall_source
```

### **Dismissal Method Analysis**
```sql
SELECT 
  dismissal_method,
  COUNT(*) as dismissals,
  AVG(time_spent_seconds) as avg_time_spent
FROM analytics_events 
WHERE event_name = 'paywall_dismissed_without_purchase'
GROUP BY dismissal_method
```

### **Purchase Funnel Analysis**
```sql
SELECT 
  COUNTIF(event_name = 'paywall_shown') as shows,
  COUNTIF(event_name = 'paywall_purchase_attempt') as attempts,
  COUNTIF(event_name = 'paywall_purchase_completed') as completions,
  COUNTIF(event_name = 'paywall_purchase_failed') as failures
FROM analytics_events 
WHERE event_name IN ('paywall_shown', 'paywall_purchase_attempt', 'paywall_purchase_completed', 'paywall_purchase_failed')
```

## Benefits of New System

1. **Accurate Conversion Rates** - No more 1:1 ratios
2. **Detailed User Behavior** - Track every interaction
3. **Purchase Flow Visibility** - See where users drop off
4. **Source Performance** - Compare different paywall locations
5. **Optimization Insights** - Data-driven paywall improvements

## Implementation Checklist

- [ ] Update PaywallView to use new tracking methods
- [ ] Add notification handling for purchase completion
- [ ] Set up Firebase Analytics custom dimensions
- [ ] Create analytics dashboards for new metrics
- [ ] Test tracking accuracy with sandbox purchases
- [ ] Monitor legacy events during transition
- [ ] Document paywall performance baselines 