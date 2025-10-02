import SwiftUI
import FirebaseAnalytics

struct OnboardingCarouselView: View {
    @Binding var isPresented: Bool
    @StateObject private var completionService = BookCompletionService.shared
    @State private var selectedBook: Book?
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showingBookDetail = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // Only show 3 specific books for onboarding
    private let onboardingBooks = BookSection.sampleBooks.filter { book in
        ["fireworks", "letstacoboutit", "chaosterrormarshmallows"].contains(book.id)
    }
    
    // MARK: - Dynamic Layout Properties
    private var isPad: Bool { horizontalSizeClass == .regular }
    private var cardWidth: CGFloat { isPad ? 400 : 280 }
    private var cardHeight: CGFloat { isPad ? 500 : 350 }
    private var carouselHeight: CGFloat { isPad ? 600 : 450 }
    private var topPadding: CGFloat { isPad ? 80 : 60 }
    private var titleFontSize: CGFloat { isPad ? 52 : 42 }
    private var subtitleFontSize: CGFloat { isPad ? 30 : 24 }
    private var bookTitleFontSize: CGFloat { isPad ? 36 : 32 }
    private var bookDetailsFontSize: CGFloat { isPad ? 22 : 18 }
    private var buttonFontSize: CGFloat { isPad ? 28 : 24 }
    private var skipFontSize: CGFloat { isPad ? 20 : 18 }
    private var cardTitleFontSize: CGFloat { isPad ? 24 : 20 }
    private let cardSpacing: CGFloat = 20

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {
                // Header
                VStack(spacing: 16) {
                    Text("Choose Your First Story!")
                        .font(Font.custom("LondrinaSolid-Regular", size: titleFontSize))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Swipe to explore and tap to start reading")
                        .font(Font.custom("LondrinaSolid-Light", size: subtitleFontSize))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, topPadding)
                
                // Carousel
                GeometryReader { geometry in
                    ZStack {
                        // Background cards (for depth effect)
                        ForEach(Array(onboardingBooks.enumerated()), id: \.element.id) { index, book in
                            if abs(index - currentIndex) <= 2 {
                                OnboardingBookCard(
                                    book: book,
                                    isSelected: index == currentIndex,
                                    scale: getScale(for: index),
                                    opacity: getOpacity(for: index),
                                    width: cardWidth,
                                    height: cardHeight,
                                    titleSize: cardTitleFontSize
                                )
                                .offset(x: getOffset(for: index, in: geometry))
                                .onTapGesture {
                                    if index == currentIndex {
                                        selectBook(book)
                                    } else {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            currentIndex = index
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold = cardWidth * 0.3
                                if value.translation.width > threshold && currentIndex > 0 {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        currentIndex -= 1
                                    }
                                } else if value.translation.width < -threshold && currentIndex < onboardingBooks.count - 1 {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        currentIndex += 1
                                    }
                                }
                                dragOffset = 0
                            }
                    )
                }
                .frame(height: carouselHeight)
                
                // Book info
                if currentIndex < onboardingBooks.count {
                    VStack(spacing: 12) {
                        Text(onboardingBooks[currentIndex].title)
                            .font(Font.custom("LondrinaSolid-Regular", size: bookTitleFontSize))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(onboardingBooks[currentIndex].details)
                            .font(Font.custom("LondrinaSolid-Light", size: bookDetailsFontSize))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 40)
                    }
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        selectBook(onboardingBooks[currentIndex])
                    }) {
                        HStack {
                            Text("Start Reading")
                                .font(Font.custom("LondrinaSolid-Light", size: buttonFontSize))
                                .foregroundColor(.white)
                            
                            Image(systemName: "book.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(25)
                    }
                    
                    Button(action: {
                        completionService.markOnboardingComplete()
                        isPresented = false
                    }) {
                        Text("Skip for now")
                            .font(Font.custom("LondrinaSolid-Light", size: skipFontSize))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
            
            Button(action: {
                completionService.markOnboardingComplete()
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.6, blue: 0.8),
                    Color(red: 0.4, green: 0.8, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                             showingBookDetail = false
                             // Complete onboarding and dismiss carousel when returning from book detail
                             completionService.markOnboardingComplete()
                             isPresented = false
                         },
                         selectedChildId: nil,
                         isFromOnboarding: true)
        }
        .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                             showingBookDetail = false
                             // Complete onboarding and dismiss carousel when returning from book detail
                             completionService.markOnboardingComplete()
                             isPresented = false
                         },
                         selectedChildId: nil,
                         isFromOnboarding: true)
        }

        .onAppear {
            Analytics.logEvent("onboarding_carousel_shown", parameters: [
                "onboarding_books_count": onboardingBooks.count
            ])
        }
    }
    
    private func selectBook(_ book: Book) {
        Analytics.logEvent("onboarding_book_selected", parameters: [
            "book_id": book.id,
            "book_title": book.title
        ])
        selectedBook = book
        showingBookDetail = true
    }
    
    private func getOffset(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let centerX = geometry.size.width / 2
        let cardOffset = CGFloat(index - currentIndex) * (cardWidth + cardSpacing)
        return centerX - cardWidth / 2 + cardOffset + dragOffset
    }
    
    private func getScale(for index: Int) -> CGFloat {
        let distance = abs(index - currentIndex)
        switch distance {
        case 0: return 1.0
        case 1: return 0.85
        case 2: return 0.7
        default: return 0.5
        }
    }
    
    private func getOpacity(for index: Int) -> Double {
        let distance = abs(index - currentIndex)
        switch distance {
        case 0: return 1.0
        case 1: return 0.8
        case 2: return 0.6
        default: return 0.3
        }
    }
}

struct OnboardingBookCard: View {
    let book: Book
    let isSelected: Bool
    let scale: CGFloat
    let opacity: Double
    let width: CGFloat
    let height: CGFloat
    let titleSize: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            Image(book.posterImage)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: isSelected ? .white.opacity(0.3) : .black.opacity(0.3),
                       radius: isSelected ? 15 : 8,
                       x: 0,
                       y: isSelected ? 8 : 4)

            Text(book.title)
                .font(Font.custom("LondrinaSolid-Regular", size: titleSize))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSelected)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: scale)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: opacity)
    }
}

struct OnboardingCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCarouselView(isPresented: .constant(true))
    }
} 