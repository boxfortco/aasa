//
//  KevinView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  KevinView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/5/22.
//

import SwiftUI
import FirebaseAnalytics

struct KevinView: View {
    var kevFeat: [Book] = Book.kevFeat
    @State private var selectedBook: Book?
    let kevRand = Book.kevFeat.shuffled()
    @Environment(\.presentationMode) var presentationMode
    @State private var isReadingBook = false
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                
                ScrollView {
                    VStack(alignment: .trailing, spacing: 0) {
                        
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        .padding(.vertical, 10)
                        .padding(.trailing, 10)
                        
                        VStack(alignment: .leading) {
                            
                            Image("Kevin")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity)
                                .ignoresSafeArea()
                            
                            Text("Meet Kevin")
                                .font(Font.custom("LondrinaSolid-Light", size: 38))
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                            
                            Text("Charming and stylish with impeccable hair, Kevin is a lot to look up to, and not just because he's really tall. Kevin loves joining in with Patrick and Arty's shenanigans. As long as he can fit.")
                                .font(Font.custom("LondrinaSolid-Light", size: 22))
                                .foregroundColor(.white)
                                .padding()
                            
                            Text("Start here...")
                            //.font(.footnote)
                                .font(Font.custom("LondrinaSolid-Light", size: 22))
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                            
                            Divider()
                                .frame(height: 2)
                                .background(Color.white)
                                .padding(.bottom, 30)
                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: horizontalSizeClass == .regular ? 200 : 300))], spacing: 20) {
                            ForEach(BookSection.sampleBooks.filter { $0.characters.contains("Kevin") }) { book in
                                Button(action: {
                                    selectedBook = book
                                    // Track Kevin view book selection
                                    Analytics.logEvent("kevin_view_book_selected", parameters: [
                                        "book_id": book.id,
                                        "book_title": book.title,
                                        "is_free": book.free,
                                        "source": "kevin_view"
                                    ])
                                }) {
                                    Image(book.posterImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
                    BookDetailView(book: book,
                                 dismissToRoot: {
                                     selectedBook = nil
                                     presentationMode.wrappedValue.dismiss()
                                 },
                                 selectedChildId: userViewModel.user?.children.first?.id)
                }
                .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
                    BookDetailView(book: book,
                                 dismissToRoot: {
                                     selectedBook = nil
                                     presentationMode.wrappedValue.dismiss()
                                 },
                                 selectedChildId: userViewModel.user?.children.first?.id)
                }
                .onAppear {
                    // Log the screen view when HomePage appears
                    Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                        AnalyticsParameterScreenName: "Kevin",
                        AnalyticsParameterScreenClass: String(describing: KevinView.self)
                    ])
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct KevinView_Previews: PreviewProvider {
    static var previews: some View {
        KevinView()
    }
}
