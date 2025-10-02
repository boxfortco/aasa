import SwiftUI
import FirebaseFunctions

struct AdminWeeklyBooksView: View {
    @StateObject private var weeklyService = WeeklyBookService.shared
    @State private var selectedBookIds: Set<String> = []
    @State private var showingBookSelector = false
    @State private var isLoading = false
    @State private var message = ""
    @State private var showingMessage = false
    
    // Countdown configuration
    @State private var targetDay = 4 // Thursday
    @State private var targetHour = 18 // 6pm
    @State private var targetMinute = 0
    @State private var countdownEnabled = true
    
    private let functions = Functions.functions()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Countdown Configuration Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Countdown Timer Configuration")
                            .font(Font.custom("LondrinaSolid-Regular", size: 24))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Target Day:")
                                Spacer()
                                Picker("Day", selection: $targetDay) {
                                    Text("Sunday").tag(0)
                                    Text("Monday").tag(1)
                                    Text("Tuesday").tag(2)
                                    Text("Wednesday").tag(3)
                                    Text("Thursday").tag(4)
                                    Text("Friday").tag(5)
                                    Text("Saturday").tag(6)
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            HStack {
                                Text("Target Time:")
                                Spacer()
                                Picker("Hour", selection: $targetHour) {
                                    ForEach(0..<24) { hour in
                                        Text("\(hour):00").tag(hour)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 80)
                                
                                Picker("Minute", selection: $targetMinute) {
                                    ForEach(0..<60) { minute in
                                        Text(":\(String(format: "%02d", minute))").tag(minute)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 80)
                            }
                            
                            Toggle("Enable Countdown", isOn: $countdownEnabled)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        Button("Update Countdown Config") {
                            updateCountdownConfig()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading)
                    }
                    
                    // Weekly Books Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Weekly Books")
                                .font(Font.custom("LondrinaSolid-Regular", size: 24))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button("Add Books") {
                                showingBookSelector = true
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if selectedBookIds.isEmpty {
                            Text("No books selected for this week's delivery")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 120, maximum: 150))
                            ], spacing: 16) {
                                ForEach(Array(selectedBookIds), id: \.self) { bookId in
                                    if let book = BookSection.sampleBooks.first(where: { $0.id == bookId }) {
                                        VStack {
                                            Image(book.posterImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 120)
                                                .cornerRadius(8)
                                            
                                            Text(book.title)
                                                .font(.caption)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                        }
                                        .onTapGesture {
                                            selectedBookIds.remove(bookId)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !selectedBookIds.isEmpty {
                            Button("Publish Weekly Delivery") {
                                publishWeeklyDelivery()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                        }
                    }
                    
                    // Current Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Status")
                            .font(Font.custom("LondrinaSolid-Regular", size: 24))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Countdown Active:")
                                Spacer()
                                Text(weeklyService.isCountdownActive ? "Yes" : "No")
                                    .foregroundColor(weeklyService.isCountdownActive ? .green : .red)
                            }
                            
                            if weeklyService.isCountdownActive {
                                HStack {
                                    Text("Time Remaining:")
                                    Spacer()
                                    Text(weeklyService.countdownTime)
                                      //  .font(.monospacedDigit())
                                }
                            }
                            
                            HStack {
                                Text("Books Available:")
                                Spacer()
                                Text("\(weeklyService.weeklyBooks.count)")
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Weekly Books Admin")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingBookSelector) {
                BookSelectorView(selectedBookIds: $selectedBookIds)
            }
            .alert("Message", isPresented: $showingMessage) {
                Button("OK") { }
            } message: {
                Text(message)
            }
        }
    }
    
    private func updateCountdownConfig() {
        isLoading = true
        
        let config: [String: Any] = [
            "targetDay": targetDay,
            "targetHour": targetHour,
            "targetMinute": targetMinute,
            "timezone": "America/New_York",
            "enabled": countdownEnabled
        ]
        
        functions.httpsCallable("updateCountdownConfig").call(config) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    message = "Error updating countdown: \(error.localizedDescription)"
                } else {
                    message = "Countdown configuration updated successfully!"
                    weeklyService.loadCountdownConfig()
                }
                showingMessage = true
            }
        }
    }
    
    private func publishWeeklyDelivery() {
        isLoading = true
        
        let deliveryData: [String: Any] = [
            "bookIds": Array(selectedBookIds),
            "deliveryDate": Date(),
            "countdownEndTime": Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week from now
        ]
        
        functions.httpsCallable("updateWeeklyDelivery").call(deliveryData) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    message = "Error publishing delivery: \(error.localizedDescription)"
                } else {
                    message = "Weekly delivery published successfully!"
                    selectedBookIds.removeAll()
                    weeklyService.loadWeeklyBooks()
                }
                showingMessage = true
            }
        }
    }
}

struct BookSelectorView: View {
    @Binding var selectedBookIds: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(BookSection.sampleBooks) { book in
                    HStack {
                        Image(book.posterImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 80)
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                            
                            Text(book.characters.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedBookIds.contains(book.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedBookIds.contains(book.id) {
                            selectedBookIds.remove(book.id)
                        } else {
                            selectedBookIds.insert(book.id)
                        }
                    }
                }
            }
            .navigationTitle("Select Books")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AdminWeeklyBooksView_Previews: PreviewProvider {
    static var previews: some View {
        AdminWeeklyBooksView()
    }
} 
