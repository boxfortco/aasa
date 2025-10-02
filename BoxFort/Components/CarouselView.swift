//
//  CarouselView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  CarouselView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//


import SwiftUI
import FirebaseAnalytics

struct CarouselView: View {
    let books: [Book]
    let selectedChildId: String?
    @Binding var selectedBook: Book?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private func getScale(proxy: GeometryProxy) -> CGFloat {
        let midPoint: CGFloat = 315 / 2
        let viewFrame = proxy.frame(in: .global)
        let difference = abs(midPoint - viewFrame.midX)
        let scale = 1 + (midPoint - difference) / 1000
        return min(max(scale, 0.9), 1.0)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -20) {
                ForEach(books) { book in
                    GeometryReader { proxy in
                        let scale = getScale(proxy: proxy)
                        
                        Button(action: {
                            self.selectedBook = book
                        }) {
                            VStack(spacing: 0) {
                                Image(book.promoImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 315, height: 177)
                                    .clipped()
                                    .cornerRadius(8, corners: [.topLeft, .topRight])
                                    .shadow(radius: 4)
                                
                                // Book title
                                Text(book.title)
                                    .font(Font.custom("LondrinaSolid-Regular", size: 14))
                                    .foregroundColor(.white)
                                    .frame(width: 315, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                            }
                            .scaleEffect(scale)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(scale)
                        .animation(.easeOut(duration: 0.5))
                    }
                    .frame(width: 315, height: 220)
                    .padding(.leading, book.id == books.first?.id ? 20 : 5)
                    .padding(.trailing, book.id == books.last?.id ? 20 : 0)
                }
            }
        }
        .frame(height: 220)
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            CarouselView(books: BookSection.sampleBooks, selectedChildId: nil, selectedBook: .constant(nil))
        }
    }
}

/*
import SwiftUI

struct CarouselView: View {
    var promos: [Book] = Book.promos.shuffled()
    @State private var selectedBook: Book?

    // Function to calculate the scale based on the GeometryProxy
    func getScale(proxy: GeometryProxy) -> CGFloat {
        var scale: CGFloat = 1.0
        let midPoint: CGFloat = UIScreen.main.bounds.width / 2
        let viewFrame = proxy.frame(in: CoordinateSpace.global)

        // Distance from the center of the scrollView
        let diffFromCenter = abs(midPoint - viewFrame.midX)
        
        if diffFromCenter < 100 { // Adjust this value to change when the scale effect starts
            scale = 1 + (100 - diffFromCenter) / 300 // Adjust the denominator to control the amount of scaling
        }
        
        return scale
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(promos) { promo in
                    GeometryReader { proxy in
                        let scale = getScale(proxy: proxy)
                        
                        Button(action: {
                            self.selectedBook = promo
                            // Track carousel promo book selection
                            Analytics.logEvent("carousel_promo_selected", parameters: [
                                "book_id": promo.id,
                                "book_title": promo.title,
                                "is_free": promo.free,
                                "source": "carousel_promo"
                            ])
                        }) {
                            VStack(spacing: 0) { // Use VStack with no spacing to control the layout tightly
                                Image(promo.promoImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 420, height: 236) // Specifies image size
                                    .clipped()
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .scaleEffect(scale) // Apply scale
                                // No additional padding between image and text
                                
                                Text(promo.title)
                                    .foregroundColor(.white)
                                    .font(Font.custom("LondrinaSolid-Light", size: 18))
                                    .frame(width: 420) // Ensure this matches the image width for alignment
                                    .padding(.vertical, 8) // Control padding to reduce space
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(10)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(item: self.$selectedBook) { book in
                            BookDetailView(book: book)
                        }
                        .animation(.easeOut(duration: 0.5)) // Apply animation to the button as a whole
                    }
                    .frame(width: 420, height: 280) // Adjust the frame height to accommodate both image and text snugly
                    .padding(.horizontal, 32) // Adjust horizontal padding if necessary
                }
            }
        }
        .frame(height: 280) // Adjust based on your content size
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            CarouselView()
        }
    }
}
*/


/*
import SwiftUI

struct CarouselView: View {
    
    var promos: [Book] = Book.promos.shuffled()
    @State private var selectedBook: Book?
    @State private var animateOffset: CGFloat = 10

    
    var body: some View {
        TabView {
            ForEach(promos) { promo in
                Button(action: {
                    self.selectedBook = promo
                }) {
                    ZStack(alignment: .bottom) {
                        Image(promo.promoImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .frame(width: UIScreen.main.bounds.width * 0.93, height: 300)
                            //.background(Color.gray.opacity(0.1)) // Optional, for better visibility
                        
                        Text(promo.title)
                            .foregroundColor(.white)
                            .font(Font.custom("LondrinaSolid-Light", size: 18))
                            .padding(.vertical, 15)
                            .frame(maxWidth: 533)
                            .background(Color.black)
                            .cornerRadius(10) // Optional, to match the image corner radius
                    }
                }
                .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid button highlighting effect
                .sheet(item: self.$selectedBook) { book in
                    BookDetailView(book: book)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 300) // Adjust based on your content size
        
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            CarouselView()
        }
    }
}
*/

/*
import SwiftUI

struct CarouselView: View {
    
    var promos: [Book] = Book.promos
    @State private var selectedBook: Book?
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            ForEach(0..<promos.count) { i in
                ZStack(alignment: .bottom) {
                    Image(promos[i].promoImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                    
                    Button(action: {
                        self.selectedBook = promos[i]
                    }) {
                        Text(promos[i].title)
                            .foregroundColor(.white)
                            .font(Font.custom("LondrinaSolid-Light", size: 18))
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(ColorConstants.darkGrayColor)
                            //.background(Color.black.opacity(0.6).blur(radius: 3.0))
                    }
                    .sheet(item: self.$selectedBook) { book in
                        BookDetailView(book: book)
                    }
                }
                .frame(width: 400)
            }
            
        }.modifier(ScrollingHStackModifier(items: promos.count, itemWidth: UIScreen.main.bounds.width * 0.93, itemSpacing: 30))
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
        GradientBackgroundView()
        CarouselView()
        }
    }
}
*/

