//
//  BookPageView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  BookPageView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 3/23/25.
//


import SwiftUI

struct BookPageView: View {
    let page: Int
    let book: Book
    
    var body: some View {
        if page < book.pages.count {
            Image(book.pages[page])
                .resizable()
                .scaledToFit()
        } else {
            Text("Page not available")
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct BookPageView_Previews: PreviewProvider {
    static var previews: some View {
        BookPageView(page: 0, book: Book.promos[0])
    }
}
#endif 