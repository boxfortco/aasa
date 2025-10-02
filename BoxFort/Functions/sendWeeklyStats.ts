const functions = require("firebase-functions");
import * as admin from 'firebase-admin';
import axios from 'axios';

admin.initializeApp();

const KIT_API_KEY = 'kit_f381217da82f1f59fc259de723273aba';
const KIT_API_URL = 'https://api.kit.com/v4';

interface ReadingStats {
    childName: string;
    booksRead: number;
    totalPagesRead: number;
    favoriteBook?: string;
}

exports.sendWeeklyStats = functions.pubsub.schedule("0 9 * * 1")
    .timeZone("America/New_York")
    .onRun(async (context) => {
        const db = admin.firestore();
        
        // Get all users who are subscribed to the newsletter
        const usersSnapshot = await db.collection('users')
            .where('isSubscribedToNewsletter', '==', true)
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

async function getReadingStats(userId: string, children: any[]): Promise<ReadingStats[]> {
    const db = admin.firestore();
    const stats: ReadingStats[] = [];
    
    // Get analytics data for the past week
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
    
    for (const child of children) {
        // Get books read count
        const booksRead = await getBooksReadCount(userId, child.id, oneWeekAgo);
        
        // Get total pages read
        const totalPagesRead = await getTotalPagesRead(userId, child.id, oneWeekAgo);
        
        // Get favorite book
        const favoriteBook = await getFavoriteBook(userId, child.id, oneWeekAgo);
        
        stats.push({
            childName: child.name,
            booksRead,
            totalPagesRead,
            favoriteBook
        });
    }
    
    return stats;
}

async function getBooksReadCount(userId: string, childId: string, since: Date): Promise<number> {
    // Query Firestore for completed books
    const db = admin.firestore();
    const snapshot = await db.collection('reading_progress')
        .where('userId', '==', userId)
        .where('childId', '==', childId)
        .where('completed', '==', true)
        .where('timestamp', '>=', since)
        .get();
        
    return snapshot.size;
}

async function getTotalPagesRead(userId: string, childId: string, since: Date): Promise<number> {
    // Query Firestore for page reading events
    const db = admin.firestore();
    const snapshot = await db.collection('reading_progress')
        .where('userId', '==', userId)
        .where('childId', '==', childId)
        .where('timestamp', '>=', since)
        .get();
        
    let totalPages = 0;
    snapshot.forEach(doc => {
        const data = doc.data();
        totalPages += data.pagesRead || 0;
    });
    
    return totalPages;
}

async function getFavoriteBook(userId: string, childId: string, since: Date): Promise<string | undefined> {
    // Query Firestore for most frequently read book
    const db = admin.firestore();
    const snapshot = await db.collection('reading_progress')
        .where('userId', '==', userId)
        .where('childId', '==', childId)
        .where('timestamp', '>=', since)
        .get();
        
    const bookCounts = new Map<string, number>();
    snapshot.forEach(doc => {
        const data = doc.data();
        const bookId = data.bookId;
        if (bookId) {
            bookCounts.set(bookId, (bookCounts.get(bookId) || 0) + 1);
        }
    });
    
    let maxCount = 0;
    let favoriteBookId: string | undefined;
    
    bookCounts.forEach((count, bookId) => {
        if (count > maxCount) {
            maxCount = count;
            favoriteBookId = bookId;
        }
    });
    
    if (favoriteBookId) {
        const bookDoc = await db.collection('books').doc(favoriteBookId).get();
        return bookDoc.data()?.title;
    }
    
    return undefined;
}

function generateEmailContent(stats: ReadingStats[]): string {
    let content = "Your Child's Reading Progress This Week\n\n";
    
    for (const stat of stats) {
        content += `📚 ${stat.childName}'s Reading Stats:\n`;
        content += `• Books Read: ${stat.booksRead}\n`;
        content += `• Total Pages: ${stat.totalPagesRead}\n`;
        if (stat.favoriteBook) {
            content += `• Favorite Book: ${stat.favoriteBook}\n`;
        }
        content += "\n";
    }
    
    content += "Keep up the great reading! 📖✨";
    return content;
}

async function sendEmailViaKit(email: string, content: string): Promise<void> {
    try {
        await axios.post(`${KIT_API_URL}/emails`, {
            to: email,
            subject: "Your Child's Weekly Reading Progress",
            content: content
        }, {
            headers: {
                'X-Kit-Api-Key': KIT_API_KEY,
                'Content-Type': 'application/json'
            }
        });
    } catch (error) {
        console.error('Error sending email via KIT:', error);
        throw error;
    }
} 