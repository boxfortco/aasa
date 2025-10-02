# iOS App Store Review System

## Overview

This implementation adds an intelligent iOS App Store review prompt system that triggers after users complete 3 books, with proper timing controls and loyalty point rewards.

## Features

### 1. Smart Review Triggering
- **Trigger Condition**: Shows review prompt after completing 3 unique books
- **Timing Control**: Only shows once every 30 days to avoid spam
- **Unique Tracking**: Tracks individual book completions to ensure 3 different books
- **Rate Limiting**: Respects Apple's guidelines for review frequency

### 2. Loyalty Integration
- **Points Award**: 20 loyalty points for review submission
- **Automatic Detection**: Attempts to detect when users return from App Store
- **Analytics Tracking**: Logs review events for analysis

### 3. Debug Tools
- **Debug Panel**: Available in Profile view (debug builds only)
- **Statistics Display**: Shows completion count, request count, and timing
- **Test Functions**: Simulate book completions and reset tracking
- **Console Logging**: Detailed logs for troubleshooting

## Implementation Details

### Key Files

1. **`ReviewService.swift`** - Core review logic and tracking
2. **`BookView.swift`** - Integration point for book completion
3. **`LoyaltyService.swift`** - Points awarding system
4. **`Boxfort_PlusApp.swift`** - App state monitoring
5. **`ProfileView.swift`** - Debug interface

### Review Trigger Logic

```swift
// Triggered in BookView when book completion reaches 100%
reviewService.checkForReviewPrompt(afterBookCompletion: book.id)
```

### Review Request Flow

1. **Book Completion** → `checkForReviewPrompt()`
2. **Count Check** → Verify 3+ unique books completed
3. **Timing Check** → Ensure 30+ days since last request
4. **System Check** → Verify `SKStoreReviewController.canRequestReview()`
5. **Show Prompt** → `SKStoreReviewController.requestReview()`
6. **Track Event** → Log analytics and update timestamps

### Points Awarding Logic

```swift
// Triggered when app becomes active (potential return from App Store)
ReviewService.shared.checkForReviewSubmission(userId: userViewModel.user?.id)
```

**Note**: This is a simplified approach that awards points after 5 minutes if the user recently saw a review prompt. In production, you might want more sophisticated detection.

## Configuration

### Review Timing
- **Minimum Books**: 3 unique book completions
- **Cooldown Period**: 30 days between requests
- **Points Awarded**: 20 loyalty points per review

### UserDefaults Keys
- `reviewTriggerCount` - Number of review requests made
- `lastReviewRequestDate` - Timestamp of last request
- `booksCompletedForReview` - Array of completed book IDs
- `hasAwardedPointsForReview` - Boolean for points tracking

## Testing

### Debug Panel (Profile View)
1. **Statistics Display**: Shows current completion count and timing
2. **Reset Button**: Clears all tracking data
3. **Simulate Button**: Adds test book completions

### Manual Testing
1. Complete 3 different books
2. Check console for review service logs
3. Verify review prompt appears
4. Check loyalty points after potential review

### Console Logs to Watch
```
ReviewService: Simulating completion of book: test_book_123
ReviewService: Review prompt requested
ReviewService: Awarded loyalty points for review submission
📝 Awarded 20 loyalty points to user [user_id] for review
```

## Analytics Events

### Review Prompt Shown
```swift
Analytics.logEvent("review_prompt_shown", parameters: [
    "completed_books_count": completedBooksCount,
    "total_completed_books": bookIds.joined(separator: ",")
])
```

### Points Awarded
```swift
Analytics.logEvent("review_points_awarded", parameters: [
    "user_id": userId,
    "points_awarded": 20
])
```

## Best Practices

### Apple Guidelines Compliance
- ✅ Respects `SKStoreReviewController.canRequestReview()`
- ✅ 30-day cooldown between requests
- ✅ Natural trigger points (book completion)
- ✅ No aggressive prompting

### User Experience
- ✅ Triggers after positive engagement (book completion)
- ✅ Integrates with existing loyalty system
- ✅ Provides value (loyalty points) for reviews
- ✅ Debug tools for development

### Technical Implementation
- ✅ Proper error handling and logging
- ✅ UserDefaults for persistent tracking
- ✅ Analytics integration
- ✅ Clean separation of concerns

## Future Enhancements

### Potential Improvements
1. **Server-side Verification**: Check actual review status via backend
2. **A/B Testing**: Test different trigger conditions
3. **Smart Timing**: Use machine learning to predict optimal review times
4. **Review Sentiment**: Track positive vs negative review likelihood
5. **Alternative Rewards**: Different rewards for different review types

### Advanced Detection Methods
1. **App Store API**: Use App Store Connect API for review verification
2. **User Feedback**: Allow users to manually claim review rewards
3. **Time-based Detection**: More sophisticated return-from-App-Store detection
4. **Engagement Metrics**: Use app usage patterns to predict review likelihood

## Troubleshooting

### Common Issues
1. **Review prompt not showing**: Check completion count and timing
2. **Points not awarded**: Verify user ID and network connectivity
3. **Debug panel not visible**: Ensure running in debug mode

### Debug Commands
```swift
// Reset all tracking
ReviewService.shared.resetReviewTracking()

// Simulate book completion
ReviewService.shared.simulateBookCompletion(bookId: "test_book")

// Check current stats
let stats = ReviewService.shared.getReviewStats()
print("Completed: \(stats.completedBooks), Requests: \(stats.triggerCount)")
```

## Integration Notes

### Dependencies
- StoreKit framework
- Firebase Analytics
- UserDefaults for persistence
- NotificationCenter for app state monitoring

### Required Permissions
- None (uses system review prompt)

### iOS Version Support
- iOS 10.3+ (SKStoreReviewController availability)
- Current target: iOS 17.6+ 