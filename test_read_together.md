# Read Together Feature - Testing Checklist

## Pre-Testing Setup

### 1. Firebase Configuration
- [ ] Firebase Realtime Database enabled
- [ ] Security rules applied (from `readTogetherRules.json`)
- [ ] Firebase Hosting deployed
- [ ] Web guest view config updated with your Firebase credentials

### 2. iOS App
- [ ] New files added to Xcode project:
  - [ ] `ReadTogetherSessionManager.swift`
  - [ ] `ReadTogetherView.swift`
- [ ] Modified `BookView.swift` with Read Together button
- [ ] App builds without errors

## Testing Steps

### Test 1: Basic Session Creation
1. **Open BoxFort app**
2. **Sign in with subscriber account**
3. **Open any book**
4. **Look for "Read Together" button (person icon) in toolbar**
5. **Tap the button**
6. **Verify Read Together view opens**
7. **Tap "Start Reading Together"**
8. **Verify session is created and share URL is generated**

### Test 2: Web Guest View
1. **Copy the share URL from iOS app**
2. **Open URL in web browser**
3. **Verify web page loads**
4. **Check that book title displays correctly**
5. **Verify "Connected" status shows**

### Test 3: Page Synchronization
1. **Keep both devices visible**
2. **In iOS app, navigate to next page**
3. **Verify web view updates automatically**
4. **Test going back a page**
5. **Verify both views stay in sync**

### Test 4: Session Management
1. **In iOS app, tap "End Reading Session"**
2. **Verify web view shows "session ended" message**
3. **Test creating a new session**

### Test 5: Error Handling
1. **Try opening an invalid session URL**
2. **Verify error message displays**
3. **Test with expired session (wait 24+ hours)**

## Expected Results

### iOS App Behavior:
- Read Together button only visible for subscribers
- Session creation works smoothly
- Share sheet opens with pre-written message
- Page navigation updates Firebase in real-time
- Session can be ended properly

### Web Guest View Behavior:
- Loads quickly and shows book information
- Updates automatically when host turns pages
- Shows appropriate error messages for invalid/expired sessions
- Works on both mobile and desktop browsers

## Troubleshooting

### If Read Together button doesn't appear:
- Check user subscription status
- Verify `userViewModel.isSubscriptionActive` is true
- Check that the button code was added to `BookView.swift`

### If session creation fails:
- Check Firebase Realtime Database is enabled
- Verify security rules are applied
- Check network connectivity
- Look for errors in Xcode console

### If web view doesn't load:
- Verify Firebase Hosting deployment
- Check Firebase config in `index.html`
- Test URL in different browsers
- Check browser console for JavaScript errors

### If pages don't sync:
- Check Firebase Realtime Database for session data
- Verify both devices have internet connection
- Test with simple page navigation first
- Check for Firebase authentication issues

## Performance Expectations

- **Session creation:** < 2 seconds
- **Page sync latency:** < 500ms
- **Web view load time:** < 3 seconds
- **Image loading:** < 2 seconds per page

## Success Criteria

✅ **Feature works end-to-end:**
- Subscriber can create session
- Guest can join via web link
- Pages sync in real-time
- Session can be ended properly
- Error handling works correctly

✅ **No production impact:**
- Existing app functionality unchanged
- Firebase Firestore data unaffected
- No performance degradation
- Subscriber-only access enforced

## Next Steps After Testing

1. **Deploy to production** (if tests pass)
2. **Monitor usage analytics**
3. **Gather user feedback**
4. **Plan future enhancements**

## Rollback Plan

If issues are found:
1. **Remove Read Together button** from `BookView.swift`
2. **Delete new files** if needed
3. **Revert `firebase.json`** changes
4. **No impact on existing functionality**
