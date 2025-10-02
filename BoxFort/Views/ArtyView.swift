//
//  ArtyView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  ArtyView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/5/22.
//

import SwiftUI
import FirebaseAnalytics


struct ArtyView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedBook: Book?
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                
                HStack {
                    Spacer()
                    
                    VStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                // Header with close button
                                HStack {
                                    Spacer()
                                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                }
                                
                                // Arty image and intro
                                VStack(alignment: .leading, spacing: 10) {
                                    Image("Arty")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(20)
                                        .shadow(radius: 10)
                                    
                                    Text("Meet Arty!")
                                        .font(Font.custom("LondrinaSolid-Light", size: 32))
                                        .foregroundColor(.white)
                                    
                                    Text("Join Arty on his adventures as he explores the world around him, making new friends and discovering exciting places.")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 20)
                                }
                                .padding(.horizontal)
                                
                                // Books section
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: horizontalSizeClass == .regular ? 200 : 300))], spacing: 20) {
                                    ForEach(BookSection.sampleBooks.filter { $0.characters.contains("Arty") }) { book in
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
                            }
                        }
                    }
                    .frame(width: min(geometry.size.width * 0.95, 600))
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: "Arty",
                AnalyticsParameterScreenClass: String(describing: ArtyView.self)
            ])
        }
    }
}

struct ArtyView_Previews: PreviewProvider {
    static var previews: some View {
        ArtyView()
    }
}
