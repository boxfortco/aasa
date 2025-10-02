/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const KIT_API_KEY = "kit_f381217da82f1f59fc259de723273aba";
const KIT_API_URL = "https://api.kit.com/v4";

// OpenAI API configuration
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || "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";
const OPENAI_IMAGE_GENERATION_URL = "https://api.openai.com/v1/images/generations";

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.sendWeeklyStats = functions.pubsub
    .schedule("0 9 * * 1") // Run at 9 AM every Monday
    .timeZone("America/New_York")
    .onRun(async () => {
        const db = admin.firestore();
        
        // Get all users who are subscribed to the newsletter
        const usersSnapshot = await db.collection("users")
            .where("isSubscribedToNewsletter", "==", true)
            .get();
            
        for (const userDoc of usersSnapshot.docs) {
            const user = userDoc.data();
            const userId = userDoc.id;
            
            try {
                // Get reading stats for the past week
                const stats = await getReadingStats(userId, user.children);
                
                // Generate email content
                const emailContent = generateEmailContent(stats);
                
                // Send email via KIT
                await sendEmailViaKit(user.email, emailContent);
                
                console.log(`Successfully sent weekly stats to ${user.email}`);
            } catch (error) {
                console.error(`Error sending weekly stats to ${user.email}:`, error);
            }
        }
    });

exports.sendTestStats = functions.https.onRequest(async (req, res) => {
    const db = admin.firestore();
    const email = req.query.email;
    if (!email) {
        res.status(400).send("Missing email query param");
        return;
    }
    // Find user by email
    const usersSnapshot = await db.collection("users").where("email", "==", email).get();
    if (usersSnapshot.empty) {
        res.status(404).send("User not found");
        return;
    }
    const userDoc = usersSnapshot.docs[0];
    const user = userDoc.data();
    const userId = userDoc.id;
    try {
        const stats = await getReadingStats(userId, user.children, true); // true = include covers
        const emailContent = await generateEmailContentHTML(stats);
        await sendEmailViaKitHTML(user.email, emailContent);
        res.status(200).send("Test stats email sent to " + user.email);
    } catch (error) {
        res.status(500).send("Error: " + error.message);
    }
});

exports.generateImageWithPatrick = functions.https.onCall(async (data, context) => {
    // Check if user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    
    const { image, childName } = data;
    
    if (!image) {
        throw new functions.https.HttpsError('invalid-argument', 'Image data is required');
    }
    
    try {
        // Create the prompt for OpenAI gpt-image-1
        const prompt = `Add Patrick, a friendly cartoon character with a round face, big eyes, and a cheerful expression, to this photo. Patrick should be seamlessly integrated into the scene without removing or altering any existing people or objects. Patrick should appear natural and well-lit, matching the photo's style and lighting. The character should be positioned appropriately in the scene - if it's a family photo, Patrick could be sitting with the family; if it's an outdoor scene, Patrick could be exploring or playing. Make sure Patrick's appearance is consistent with a children's book character style - cute, friendly, and age-appropriate. The final image should look like Patrick was actually present when the photo was taken.`;
        
        // For gpt-image-1, we need to use FormData with the image as input
        const FormData = require('form-data');
        const form = new FormData();
        
        // Convert base64 to buffer
        const imageBuffer = Buffer.from(image, 'base64');
        
        form.append('model', 'gpt-image-1');
        form.append('prompt', prompt);
        form.append('image', imageBuffer, {
            filename: 'input.jpg',
            contentType: 'image/jpeg'
        });
        form.append('n', '1');
        form.append('size', '1024x1024');
        form.append('quality', 'high');
        form.append('output_format', 'jpeg');
        
        // Call OpenAI gpt-image-1 API
        const response = await axios.post(OPENAI_IMAGE_GENERATION_URL, form, {
            headers: {
                'Authorization': `Bearer ${OPENAI_API_KEY}`,
                ...form.getHeaders()
            }
        });
        
        // Extract the generated image (gpt-image-1 returns base64)
        const generatedImageBase64 = response.data.data[0].b64_json;
        
        // Convert base64 to a publicly accessible URL
        // For now, we'll return the base64 data and handle the conversion on the client side
        // In a production environment, you might want to upload this to Firebase Storage
        
        return {
            imageUrl: `data:image/jpeg;base64,${generatedImageBase64}`
        };
        
    } catch (error) {
        console.error('Error generating image with Patrick:', error);
        
        if (error.response) {
            console.error('OpenAI API Error:', error.response.data);
            throw new functions.https.HttpsError('internal', `OpenAI API error: ${error.response.data.error?.message || 'Unknown error'}`);
        }
        
        throw new functions.https.HttpsError('internal', 'Failed to generate image');
    }
});

async function getReadingStats(userId, children, includeCovers = false) {
    const stats = [];
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
    for (const child of children) {
        const booksRead = await getBooksReadCount(userId, child.id, oneWeekAgo);
        const totalPagesRead = await getTotalPagesRead(userId, child.id, oneWeekAgo);
        const favoriteBookId = await getFavoriteBookId(userId, child.id, oneWeekAgo);
        let favoriteBook = null;
        let coverUrl = null;
        if (favoriteBookId && includeCovers) {
            const bookDoc = await admin.firestore().collection("books").doc(favoriteBookId).get();
            if (bookDoc.exists) {
                favoriteBook = bookDoc.data().title;
                coverUrl = bookDoc.data().coverUrl || null;
            }
        } else if (favoriteBookId) {
            const bookDoc = await admin.firestore().collection("books").doc(favoriteBookId).get();
            if (bookDoc.exists) {
                favoriteBook = bookDoc.data().title;
            }
        }
        stats.push({
            childName: child.name,
            booksRead,
            totalPagesRead,
            favoriteBook,
            coverUrl,
            readingStreak: child.streakDays || 0
        });
    }
    return stats;
}

async function getBooksReadCount(userId, childId, since) {
    const db = admin.firestore();
    const snapshot = await db.collection("reading_progress")
        .where("userId", "==", userId)
        .where("childId", "==", childId)
        .where("completed", "==", true)
        .where("timestamp", ">=", since)
        .get();
        
    return snapshot.size;
}

async function getTotalPagesRead(userId, childId, since) {
    const db = admin.firestore();
    const snapshot = await db.collection("reading_progress")
        .where("userId", "==", userId)
        .where("childId", "==", childId)
        .where("timestamp", ">=", since)
        .get();
        
    let totalPages = 0;
    snapshot.forEach(doc => {
        const data = doc.data();
        totalPages += data.pagesRead || 0;
    });
    
    return totalPages;
}

async function getFavoriteBookId(userId, childId, since) {
    const db = admin.firestore();
    const snapshot = await db.collection("reading_progress")
        .where("userId", "==", userId)
        .where("childId", "==", childId)
        .where("timestamp", ">=", since)
        .get();
    const bookCounts = new Map();
    snapshot.forEach(doc => {
        const data = doc.data();
        const bookId = data.bookId;
        if (bookId) {
            bookCounts.set(bookId, (bookCounts.get(bookId) || 0) + 1);
        }
    });
    let maxCount = 0;
    let favoriteBookId = null;
    bookCounts.forEach((count, bookId) => {
        if (count > maxCount) {
            maxCount = count;
            favoriteBookId = bookId;
        }
    });
    return favoriteBookId;
}

function generateEmailContent(stats) {
    let content = "Your Child's Reading Progress This Week\n\n";
    
    for (const stat of stats) {
        content += `📚 ${stat.childName}'s Reading Stats:\n`;
        content += `• Books Read: ${stat.booksRead}\n`;
        content += `• Total Pages: ${stat.totalPagesRead}\n`;
        if (stat.favoriteBook) {
            content += `• Favorite Book: ${stat.favoriteBook}\n`;
        }
        content += `• Reading Streak: ${stat.readingStreak} days\n\n`;
    }
    
    content += "Keep up the great reading! 📖✨";
    return content;
}

async function sendEmailViaKit(email, content) {
    try {
        await axios.post(`${KIT_API_URL}/emails`, {
            to: email,
            subject: "Your Child's Weekly Reading Progress",
            content: content
        }, {
            headers: {
                "X-Kit-Api-Key": KIT_API_KEY,
                "Content-Type": "application/json"
            }
        });
    } catch (error) {
        console.error("Error sending email via KIT:", error);
        throw error;
    }
}

async function generateEmailContentHTML(stats) {
    // Inline CSS for modern, minimal look
    let content = `
    <div style="font-family: 'Segoe UI', Arial, sans-serif; background: #f6f6f6; padding: 40px 0;">
      <div style="max-width: 480px; margin: 0 auto; background: #fff; border-radius: 16px; box-shadow: 0 2px 8px #0001; overflow: hidden;">
        <div style="padding: 32px 32px 16px 32px;">
          <img src="https://upload.wikimedia.org/wikipedia/commons/2/2d/BoxFort_logo.png" alt="BoxFort" style="height: 32px; margin-bottom: 24px;">
          <h1 style="font-size: 2rem; margin: 0 0 8px 0; color: #222; font-weight: 800;">Your Child's Reading Week</h1>
          <p style="font-size: 1.1rem; color: #444; margin: 0 0 24px 0;">Here's a look at your child's reading progress this week on BoxFort.</p>
        </div>
        <div style="padding: 0 32px 32px 32px;">
    `;
    for (const stat of stats) {
        content += `
          <div style="margin-bottom: 32px; border-bottom: 1px solid #eee; padding-bottom: 24px;">
            <h2 style="font-size: 1.2rem; color: #1a73e8; margin: 0 0 12px 0; font-weight: 700;">${stat.childName}'s Stats</h2>
            <ul style="list-style: none; padding: 0; margin: 0 0 12px 0;">
              <li style="margin-bottom: 6px;">📚 <b>Books Read:</b> ${stat.booksRead}</li>
              <li style="margin-bottom: 6px;">📄 <b>Total Pages:</b> ${stat.totalPagesRead}</li>
              <li style="margin-bottom: 6px;">🔥 <b>Reading Streak:</b> ${stat.readingStreak} days</li>
            </ul>
            ${stat.favoriteBook ? `<div style="display: flex; align-items: center; margin-top: 10px;">
              ${stat.coverUrl ? `<img src="${stat.coverUrl}" alt="${stat.favoriteBook}" style="width: 60px; height: 80px; object-fit: cover; border-radius: 8px; margin-right: 16px; box-shadow: 0 2px 8px #0002;">` : ""}
              <div>
                <span style="font-size: 1rem; color: #888;">Favorite Book</span><br>
                <span style="font-size: 1.1rem; color: #222; font-weight: 600;">${stat.favoriteBook}</span>
              </div>
            </div>` : ""}
          </div>
        `;
    }
    content += `
          <div style="text-align: center; margin-top: 24px;">
            <a href="https://boxfort.co" style="display: inline-block; background: #1a73e8; color: #fff; font-weight: 600; padding: 12px 32px; border-radius: 24px; text-decoration: none; font-size: 1.1rem;">Visit BoxFort</a>
          </div>
        </div>
      </div>
    </div>
    `;
    return content;
}

async function sendEmailViaKitHTML(email, htmlContent) {
    try {
        await axios.post(`${KIT_API_URL}/emails`, {
            to: email,
            subject: "Your Child's Weekly Reading Progress",
            html: htmlContent
        }, {
            headers: {
                "X-Kit-Api-Key": KIT_API_KEY,
                "Content-Type": "application/json"
            }
        });
    } catch (error) {
        console.error("Error sending HTML email via KIT:", error);
        throw error;
    }
}

// Weekly Book Delivery System
exports.getWeeklyBooks = functions.https.onCall(async (data, context) => {
    try {
        const db = admin.firestore();
        
        // Get current weekly delivery
        const weeklySnapshot = await db.collection("weekly_deliveries")
            .orderBy("deliveryDate", "desc")
            .limit(1)
            .get();
        
        if (weeklySnapshot.empty) {
            throw new functions.https.HttpsError("not-found", "No weekly delivery found");
        }
        
        const weeklyDelivery = weeklySnapshot.docs[0].data();
        const bookIds = weeklyDelivery.bookIds || [];
        
        // Fetch book details
        const books = [];
        for (const bookId of bookIds) {
            const bookDoc = await db.collection("books").doc(bookId).get();
            if (bookDoc.exists) {
                books.push({
                    id: bookDoc.id,
                    ...bookDoc.data()
                });
            }
        }
        
        return {
            weeklyDelivery: {
                id: weeklySnapshot.docs[0].id,
                deliveryDate: weeklyDelivery.deliveryDate,
                countdownEndTime: weeklyDelivery.countdownEndTime,
                books: books
            }
        };
        
    } catch (error) {
        console.error("Error fetching weekly books:", error);
        throw new functions.https.HttpsError("internal", "Failed to fetch weekly books");
    }
});

exports.getCountdownTimer = functions.https.onCall(async (data, context) => {
    try {
        const db = admin.firestore();
        
        // Get countdown configuration
        const configDoc = await db.collection("app_config").doc("countdown").get();
        
        if (!configDoc.exists) {
            // Default to Thursday 6pm ET
            return {
                targetDay: 4, // Thursday (0 = Sunday)
                targetHour: 18, // 6pm
                targetMinute: 0,
                timezone: "America/New_York",
                enabled: true
            };
        }
        
        return configDoc.data();
        
    } catch (error) {
        console.error("Error fetching countdown timer:", error);
        throw new functions.https.HttpsError("internal", "Failed to fetch countdown timer");
    }
});

// Admin function to update weekly delivery (protected)
exports.updateWeeklyDelivery = functions.https.onCall(async (data, context) => {
    // Check if user is admin (you'll need to implement admin authentication)
    if (!context.auth || !isAdmin(context.auth.uid)) {
        throw new functions.https.HttpsError("permission-denied", "Admin access required");
    }
    
    try {
        const { bookIds, deliveryDate, countdownEndTime } = data;
        const db = admin.firestore();
        
        const weeklyDelivery = {
            bookIds: bookIds,
            deliveryDate: deliveryDate,
            countdownEndTime: countdownEndTime,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        };
        
        await db.collection("weekly_deliveries").add(weeklyDelivery);
        
        return { success: true };
        
    } catch (error) {
        console.error("Error updating weekly delivery:", error);
        throw new functions.https.HttpsError("internal", "Failed to update weekly delivery");
    }
});

// Admin function to update countdown timer configuration
exports.updateCountdownConfig = functions.https.onCall(async (data, context) => {
    if (!context.auth || !isAdmin(context.auth.uid)) {
        throw new functions.https.HttpsError("permission-denied", "Admin access required");
    }
    
    try {
        const { targetDay, targetHour, targetMinute, timezone, enabled } = data;
        const db = admin.firestore();
        
        const config = {
            targetDay,
            targetHour,
            targetMinute,
            timezone,
            enabled,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };
        
        await db.collection("app_config").doc("countdown").set(config);
        
        return { success: true };
        
    } catch (error) {
        console.error("Error updating countdown config:", error);
        throw new functions.https.HttpsError("internal", "Failed to update countdown config");
    }
});

// Helper function to check if user is admin
function isAdmin(uid) {
    // Implement your admin check logic here
    // This could be checking against a specific UID or a role in Firestore
    const adminUids = [
        // Add your admin UIDs here
    ];
    return adminUids.includes(uid);
}
