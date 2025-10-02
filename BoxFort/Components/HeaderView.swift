import SwiftUI
import SwiftyGif

struct HeaderView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var selectedChildId: String?
    @State private var currentGreeting: (text: String, gif: String?) = ("", nil)
    
    private var greetingName: String {
        if userViewModel.user == nil {
            let alternatives = ["buddy", "dude", "chap", "pal", "friend", "mate", "chief", "sport", "champ", "partner"]
            return alternatives.randomElement() ?? "friend"
        }
        // For registered users, use selected child or first child
        if let id = selectedChildId, 
           let selectedChild = userViewModel.user?.children.first(where: { $0.id == id }) {
            return selectedChild.name
        }
        return userViewModel.user?.children.first?.name ?? "friend"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if let gifName = currentGreeting.gif {
                SwiftyGifView(imageName: gifName)
                    .frame(height: 200)
                    .cornerRadius(15)
            }
            
            Text(currentGreeting.text)
                .font(Font.custom("LondrinaSolid-Regular", size: 32))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 40)
        .onAppear {
            updateGreeting()
        }
        .onChange(of: selectedChildId) { _ in
            updateGreeting()
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Define available GIFs for each time period
        let morningGifs = ["header_morning_1", "header_morning_2", "header_morning_3"]
        let afternoonGifs = ["header_afternoon_1", "header_afternoon_2", "header_afternoon_3"]
        
        // Select random GIF for the time period
        let randomGif: String
        if hour < 12 {
            randomGif = morningGifs.randomElement() ?? "header_morning_1"
            currentGreeting = ("Good morning, \(greetingName)", randomGif)
        } else {
            randomGif = afternoonGifs.randomElement() ?? "header_afternoon_1"
            currentGreeting = ("Good afternoon, \(greetingName)", randomGif)
        }
        
        print("DEBUG: Selected GIF: \(randomGif) for: \(greetingName)")
    }
} 