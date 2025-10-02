# Deep Link Structure Update

## Overview

The deep link structure has been revised to direct users to search queries instead of specific books. This change provides a more flexible and user-friendly experience, allowing users to discover related content and similar stories.

## Changes Made

### 1. Updated Deep Link Generation

**Before:**
```
boxfort://book?id=thebox
https://boxfort.co/book?id=thebox
```

**After:**
```
boxfort://search?q=patrick%20monster%20box
https://boxfort.co/search?q=patrick%20monster%20box
```

### 2. Search Query Generation

The system now generates intelligent search queries based on:
- Book title (excluding common words like "the", "a", "an", etc.)
- Character names from the book
- Book category/tags (if available)

**Example:**
- Book: "The Box"
- Characters: ["Patrick", "Monster"]
- Generated Query: "Box Patrick Monster"

### 3. Updated Components

#### StoryPreviewService.swift
- Modified `generateDeepLink()` and `generateWebDeepLink()` to create search-based URLs
- Added `generateSearchQuery()` method for intelligent query generation
- Added `parseSearchDeepLink()` method for parsing search queries
- Updated share text to reflect search-based approach

#### DeepLinkHandler.swift
- Added support for search deep links with `pendingSearchQuery` and `shouldNavigateToSearch`
- Added `handleSearchDeepLink()` method
- Added `getSearchQueryFromDeepLink()` and `clearPendingSearch()` methods

#### Boxfort_PlusApp.swift (AppDelegate)
- Updated URL handling to prioritize search deep links
- Maintained backward compatibility for book-specific links
- Added support for legacy search parameter format

#### ContentView.swift
- Added `onReceive` handler for search deep links
- Automatically sets search text when deep link is received

### 4. Backward Compatibility

The system maintains backward compatibility with:
- Existing book-specific deep links (`boxfort://book?id=...`)
- Legacy search parameter format (`boxfort://?search=...`)
- OneSignal notification deep links

## URL Structure

### New Search Deep Links
```
boxfort://search?q=<encoded_search_query>
https://boxfort.co/search?q=<encoded_search_query>
```

### Examples
```
boxfort://search?q=patrick%20monster
boxfort://search?q=arty%20seasons
boxfort://search?q=kevin%20adventure
```

## Implementation Details

### Search Query Generation Logic
1. **Title Processing**: Extracts meaningful words from book title, excluding common stop words
2. **Character Integration**: Adds all character names from the book
3. **Category Addition**: Includes book category if available
4. **Deduplication**: Removes duplicate terms
5. **Space Separation**: Joins terms with spaces

### Deep Link Flow
1. User clicks deep link or notification
2. AppDelegate receives URL and parses search query
3. NotificationCenter posts "DeepLinkSearch" event
4. DeepLinkHandler processes the search query
5. ContentView receives the search query and sets search text
6. HomePage automatically shows search results

## Testing

Use the `DeepLinkTest.swift` file to test the new functionality:

```swift
// Test deep link generation
DeepLinkTest.testDeepLinkGeneration()

// Test search query generation
DeepLinkTest.testSearchQueryGeneration()

// Test notification deep links
DeepLinkTest.testNotificationDeepLinks()
```

## Benefits

1. **Better Discovery**: Users find related stories, not just the specific book
2. **Flexible Content**: Search results can include similar stories and themes
3. **Improved UX**: Users can explore content more naturally
4. **Future-Proof**: Easy to add new search parameters and filters
5. **Analytics**: Better tracking of user interests and search patterns

## Migration Notes

- Existing book-specific deep links will continue to work
- Share links will now generate search-based URLs
- Notifications can use either `book_id` or `search_query` parameters
- Web deep links redirect to search results instead of specific books

## Future Enhancements

- Add search filters (age, category, length)
- Implement search result ranking
- Add search suggestions
- Support for multiple search terms with operators 