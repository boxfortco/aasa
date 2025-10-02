import SwiftUI

struct CharacterScheduleConfigView: View {
    @StateObject private var scheduleService = CharacterScheduleService.shared
    @State private var selectedCharacter: Channel = .Patrick
    @State private var showingAddActivity = false
    @State private var editingActivity: CharacterSchedule.ScheduledActivity?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            List {
                if let schedule = scheduleService.currentSchedule {
                    Section(header: Text("Daily Schedule")) {
                        ForEach(schedule.activities) { activity in
                            ActivityRow(activity: activity) {
                                editingActivity = activity
                            }
                        }
                    }
                    
                    Section {
                        Button(action: {
                            showingAddActivity = true
                        }) {
                            Label("Add Activity", systemImage: "plus.circle.fill")
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("\(selectedCharacter.rawValue)'s Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(Channel.allCases, id: \.self) { character in
                            Button(character.rawValue) {
                                selectedCharacter = character
                                loadSchedule()
                            }
                        }
                    } label: {
                        Label("Select Character", systemImage: "person.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                ActivityEditView(mode: .add) { newActivity in
                    addActivity(newActivity)
                }
            }
            .sheet(item: $editingActivity) { activity in
                ActivityEditView(mode: .edit(activity)) { updatedActivity in
                    updateActivity(updatedActivity)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
            .onAppear {
                loadSchedule()
            }
        }
    }
    
    private func loadSchedule() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await scheduleService.loadSchedule(for: selectedCharacter)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func addActivity(_ activity: CharacterSchedule.ScheduledActivity) {
        guard var schedule = scheduleService.currentSchedule else { return }
        schedule.activities.append(activity)
        
        Task {
            do {
                try await scheduleService.updateSchedule(schedule)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func updateActivity(_ activity: CharacterSchedule.ScheduledActivity) {
        Task {
            do {
                try await scheduleService.updateActivity(activity)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct ActivityRow: View {
    let activity: CharacterSchedule.ScheduledActivity
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: activity.iconName)
                        .foregroundColor(.orange)
                    Text(activity.name)
                        .font(.headline)
                }
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(formatTime(activity.startTime))
                    Text("-")
                    Text(formatTime(activity.endTime))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ActivityEditView: View {
    enum Mode {
        case add
        case edit(CharacterSchedule.ScheduledActivity)
    }
    
    let mode: Mode
    let onSave: (CharacterSchedule.ScheduledActivity) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600)
    @State private var iconName: String = "star.fill"
    @State private var isEnabled: Bool = true
    
    private let icons = [
        "sunrise.fill",
        "fork.knife",
        "book.fill",
        "figure.play",
        "fork.knife.circle.fill",
        "shower.fill",
        "mouth.fill",
        "book.closed.fill",
        "moon.zzz.fill"
    ]
    
    private var navigationTitle: String {
        switch mode {
        case .add:
            return "Add Activity"
        case .edit:
            return "Edit Activity"
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Time")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                iconName = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title)
                                    .foregroundColor(iconName == icon ? .orange : .gray)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(iconName == icon ? Color.orange.opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                Section {
                    Toggle("Enabled", isOn: $isEnabled)
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let activityId: String
                        switch mode {
                        case .add:
                            activityId = UUID().uuidString
                        case .edit(let activity):
                            activityId = activity.id
                        }
                        
                        let activity = CharacterSchedule.ScheduledActivity(
                            id: activityId,
                            name: name,
                            startTime: startTime,
                            endTime: endTime,
                            storyId: nil,
                            isEnabled: isEnabled,
                            iconName: iconName,
                            description: description
                        )
                        onSave(activity)
                        dismiss()
                    }
                }
            }
            .onAppear {
                if case .edit(let activity) = mode {
                    name = activity.name
                    description = activity.description
                    startTime = activity.startTime
                    endTime = activity.endTime
                    iconName = activity.iconName
                    isEnabled = activity.isEnabled
                }
            }
        }
    }
}

#Preview {
    CharacterScheduleConfigView()
} 