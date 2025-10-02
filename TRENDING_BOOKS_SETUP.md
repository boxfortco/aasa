# Trending Books Setup Guide

## 🎯 Overview
The trending books feature now shows **global** top 10 books across your entire userbase, not individual user data.

## 📊 How It Works

### Current Implementation (Recommended)
- **Data Source**: All reading sessions from Firestore (global aggregation)
- **Caching**: 6-hour cache in `trending_cache/current_week` document
- **Fallback**: Curated popular books when no data exists
- **Performance**: Fast, no external API calls needed

### Alternative: Google Analytics Integration
If you want to use Google Analytics data instead, you can implement the Firebase Function approach:

1. **Setup Google Analytics Reporting API**:
   ```bash
   npm install @google-analytics/data
   ```

2. **Add service account key** to your functions folder

3. **Deploy the function**:
   ```bash
   firebase deploy --only functions:getTrendingBooks
   ```

4. **Update TrendingBooksService** to call the function instead of querying Firestore directly

## 🚀 Current Status

### ✅ What's Working Now
- Global trending data from all users' reading sessions
- 6-hour intelligent caching
- Fallback books when no data exists
- Flame badges for 1000+ reads
- Netflix-style UI

### 📈 Data Flow
1. **User completes book** → Reading session saved to Firestore
2. **Trending service queries** → All completed sessions for current week
3. **Global aggregation** → Counts reads across entire userbase
4. **Caching** → Results cached for 6 hours
5. **Display** → Top 10 with flame badges for hot books

## 🔥 Flame Badge Logic
- Books with **1000+ reads this week** get the 🔥 badge
- Badge shows "Over 1,000 reads this week"
- Only appears for qualifying books

## 📱 User Experience
- **Week 1**: Fallback curated books (no flame badges)
- **Week 2+**: Real trending data starts appearing
- **Week 3+**: Flame badges appear for popular books
- **Always**: Users see a top 10 list, never empty state

## 🛠️ Customization Options

### Change Flame Badge Threshold
```swift
// In TrendingBook.swift, change the threshold:
self.isHot = readCount >= 500 // Change from 1000 to 500
```

### Update Fallback Books
```swift
// In TrendingBooksService.swift, modify getFallbackTrendingBooks()
let fallbackBooks = [
    ("YourBookId", "Your Book Title", "YourBookImage"),
    // Add your preferred books here
]
```

### Adjust Cache Duration
```swift
// In TrendingBooksService.swift, change cache duration:
if cacheAge < 2 * 3600 { // Change from 6 hours to 2 hours
```

## 🎉 Ready to Launch!
The system is ready to go live. Users will always see trending books, and the flame badges will start appearing as your userbase grows!
