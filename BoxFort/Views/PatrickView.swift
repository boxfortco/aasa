//
//  PatrickView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  PatrickView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/5/22.
//

import SwiftUI
import FirebaseAnalytics

struct PatrickView: View {
    
    var patFeat: [Book] = Book.patFeat
    @State private var selectedBook: Book?
    let patRand = Book.patFeat.shuffled()
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
                            
                            Image("Patrick")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity)
                                .ignoresSafeArea()
                            
                            Text("Meet Patrick")
                                .font(Font.custom("LondrinaSolid-Light", size: 38))
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                            
                            Text("Whether it's attempting to reach space by waffle, or offering bagles to xylophones, Patrick loves an adevnture. He has a big heart and a head full of ideas. The only problem is, he usually can't remember what they are.")
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
                            ForEach(BookSection.sampleBooks.filter { $0.characters.contains("Patrick") }) { book in
                                Button(action: {
                                    selectedBook = book
                                }) {
                                    Image(book.posterImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        
                        /*
                         LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 10) {
                         
                         ForEach(BookSection.patrickChannel) { section in
                         BookSectionView(bookSection: section)
                         .frame(width: UIScreen.main.bounds.width)
                         }
                         Spacer()
                         
                         }*/
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
                        AnalyticsParameterScreenName: "Patrick",
                        AnalyticsParameterScreenClass: String(describing: PatrickView.self)
                    ])
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PatrickView_Previews: PreviewProvider {
    static var previews: some View {
        PatrickView()
    }
}
