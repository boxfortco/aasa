//
//  TrendingBook.swift
//  BoxFort
//
//  Created by Matthew Ryan on 1/15/25.
//

import Foundation

struct TrendingBook: Identifiable, Codable {
    let id: String
    let bookId: String
    let title: String
    let posterImage: String
    let readCount: Int
    let rank: Int
    let isHot: Bool // True if 1000+ reads this week
    let lastUpdated: Date
    
    init(bookId: String, title: String, posterImage: String, readCount: Int, rank: Int) {
        self.id = "\(bookId)_\(Date().timeIntervalSince1970)"
        self.bookId = bookId
        self.title = title
        self.posterImage = posterImage
        self.readCount = readCount
        self.rank = rank
        self.isHot = readCount >= 1000
        self.lastUpdated = Date()
    }
}

struct TrendingBooksResponse: Codable {
    let books: [TrendingBook]
    let weekStart: Date
    let weekEnd: Date
    let totalReads: Int
}
