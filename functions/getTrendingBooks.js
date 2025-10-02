const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { BetaAnalyticsDataClient } = require('@google-analytics/data');

// Initialize Google Analytics Data API client
const analyticsDataClient = new BetaAnalyticsDataClient({
  keyFilename: 'path/to/your/service-account-key.json', // You'll need to add this
});

exports.getTrendingBooks = functions.https.onCall(async (data, context) => {
  try {
    // Get the current week's date range
    const now = new Date();
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - now.getDay()); // Start of week (Sunday)
    weekStart.setHours(0, 0, 0, 0);
    
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 7);
    
    // Query Google Analytics for book completion events
    const [response] = await analyticsDataClient.runReport({
      property: `properties/${process.env.GA_PROPERTY_ID}`, // Your GA4 property ID
      dateRanges: [
        {
          startDate: formatDate(weekStart),
          endDate: formatDate(weekEnd)
        }
      ],
      dimensions: [
        { name: 'customEvent:book_id' },
        { name: 'customEvent:book_title' },
        { name: 'customEvent:poster_image' }
      ],
      metrics: [
        { name: 'eventCount' }
      ],
      dimensionFilter: {
        filter: {
          fieldName: 'eventName',
          stringFilter: {
            matchType: 'EXACT',
            value: 'book_reading_completed'
          }
        }
      },
      orderBys: [
        {
          metric: { metricName: 'eventCount' },
          desc: true
        }
      ],
      limit: 10
    });
    
    // Process the results
    const trendingBooks = response.rows?.map((row, index) => ({
      bookId: row.dimensionValues[0].value,
      title: row.dimensionValues[1].value,
      posterImage: row.dimensionValues[2].value,
      readCount: parseInt(row.metricValues[0].value),
      rank: index + 1,
      isHot: parseInt(row.metricValues[0].value) >= 1000
    })) || [];
    
    // Cache the results in Firestore for 6 hours
    const cacheData = {
      books: trendingBooks,
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalReads: trendingBooks.reduce((sum, book) => sum + book.readCount, 0),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await admin.firestore()
      .collection('trending_cache')
      .doc('current_week')
      .set(cacheData);
    
    return { success: true, books: trendingBooks };
    
  } catch (error) {
    console.error('Error fetching trending books:', error);
    throw new functions.https.HttpsError('internal', 'Failed to fetch trending books');
  }
});

function formatDate(date) {
  return date.toISOString().split('T')[0];
}
