//
//  BookViewModel.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


import Foundation

class BookViewModel: ObservableObject {
    @Published var selectedBook: Book? = nil
}

func markBookAsRead(_ book: Book) {
        let key = "readCount_\(book.id)"
        let currentCount = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(currentCount + 1, forKey: key)
    }
