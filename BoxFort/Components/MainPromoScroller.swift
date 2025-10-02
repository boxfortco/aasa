//
//  MainPromoScroller.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  MainPromoScroller.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/5/22.
//

import SwiftUI

struct MainPromoScroller: View {
    let selectedChildId: String?
    @Binding var selectedBook: Book?
    
    var body: some View {
        CarouselView(books: BookSection.featured.books, selectedChildId: selectedChildId, selectedBook: $selectedBook)
    }
}

struct MainPromoScroller_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            MainPromoScroller(selectedChildId: nil, selectedBook: .constant(nil))
        }
    }
}

struct FeaturedScroller: View {
    let selectedChildId: String?
    @State private var selectedBook: Book? = nil

    var body: some View {
        CarouselView(books: BookSection.featured.books, selectedChildId: selectedChildId, selectedBook: $selectedBook)
    }
}

struct FeaturedScroller_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            FeaturedScroller(selectedChildId: nil)
        }
    }
}
