//
//  BookSectionView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  BookSectionView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import SwiftUI

struct BookSectionView: View {
    let bookSection: BookSection
    @State private var selectedBook: Book?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText: String = ""
    let selectedChildId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if bookSection.sectionName != "❤️ Favorites" {
                Text(bookSection.sectionName)
                    .font(Font.custom("LondrinaSolid-Light", size: 22))
                    .foregroundColor(Color.white)
                    .padding(.leading, 16)
                    .padding(.bottom, 8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(bookSection.books) { book in
                        BookCard(book: book, 
                               selectedBook: $selectedBook,
                               selectedChildId: selectedChildId)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Group {
                if bookSection.sectionName == "❤️ Favorites" {
                    ColorConstants.navBar
                        .cornerRadius(20)
                }
            }
        )
        .padding(.vertical, bookSection.sectionName == "❤️ Favorites" ? 16 : 0)
        .padding(.horizontal, bookSection.sectionName == "❤️ Favorites" ? 16 : 0)
        .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                         },
                         selectedChildId: selectedChildId)
        }
        .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                         },
                         selectedChildId: selectedChildId)
        }
    }
    
    private func getOpenCount(for book: Book) -> Int {
        return UserDefaults.standard.integer(forKey: "openCount_\(book.id)")
    }
}

struct BookSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            BookSectionView(bookSection: BookSection.featured, selectedChildId: nil)
        }
    }
}

/* SEPTEMBER 12
import SwiftUI

struct BookSectionView: View {
    
    var bookSection: BookSection
    @State private var selectedBook: Book? = nil  // Use an optional Book for sheet presentation
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(bookSection.sectionName)
                .font(Font.custom("LondrinaSolid-Light", size: 22))
                .foregroundColor(Color.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(bookSection.books) { book in
                        Button(action: {
                            self.selectedBook = book  // Set the selected book here
                        }) {
                            DynamicBorderView(book: book)
                                .frame(width: 220, height: 330)
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(item: $selectedBook) { book in  // Present the sheet based on the selected book
            BookDetailView(book: book)
        }
    }
}
*/


/* MARCH 11
import SwiftUI

struct BookSectionView: View {
    
    var bookSection: BookSection
    @State private var selectedBook: Book?
    @State private var isSheetPresented = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(bookSection.sectionName)
                .font(Font.custom("LondrinaSolid-Light", size: 22))
                .foregroundColor(Color.white)
                /*
                .font(.title3)
                .bold()
                .foregroundColor(.gray)
                 */
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(bookSection.books) {book in
                        Button(action: {
                            self.selectedBook = book
                        }) {
                            DynamicBorderView(book: book)
                                       // .frame(width: 160, height: 237)
                                .frame(width: 220, height: 330)
                                .onTapGesture {
                                    print("Book tapped: \(book.title)")
                                    }
                            /*
                            Image(book.posterImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .frame(width: 150)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                            .stroke(borderColor(forBook: book), lineWidth: 6)
                                    )
                                */
                        }
                        .sheet(item: self.$selectedBook) { book in
                            BookDetailView(book: book)
                        }
                    }
                }
            }
            
        }.padding()
    }
}
 */

/*
extension BookSectionView {
    func borderColor(forBook book: Book) -> Color {
        let openCount = UserDefaults.standard.integer(forKey: "openCount_\(book.productId)")
        
        switch openCount {
        case 1..<2:
            return Color.clear
        case 2..<3:
            return ColorConstants.borderLow
        case 3..<5:
            return ColorConstants.borderMed
        case 6..<9:
            return ColorConstants.borderHigh
        case 10...:
            return ColorConstants.borderUltra
        default:
            return Color.clear
        }
    }
}
 */

