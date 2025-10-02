//
//  BookManager.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  BookManager.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 10/9/24.
//


import Foundation

class BookManager {
    static func markBookAsRead(_ book: Book) {
        let key = "readCount_\(book.id)"
        let currentCount = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(currentCount + 1, forKey: key)
    }
    
    // You can add other book-related methods here
}