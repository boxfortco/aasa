import SwiftUI
import OneSignalFramework

struct NotificationPermissionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var oneSignalService = OneSignalService.shared
    @State private var showingSettings = false
    @State private var showingRecovery = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Full-bleed image at top
            Image("accessPaywall")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
            
            VStack(spacing: 0) {
                // Modern typography section
                VStack(spacing: 16) {
                    Text("Rescue bedtime")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Get notified when new books are added.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 24)

                // Scrollable testimonials section
                ScrollView {
                    VStack(spacing: 16) {
                        // Styled testimonial in light grey rounded container
                        VStack(spacing: 12) {
                            Text("⭐️ ⭐️ ⭐️ ⭐️ ⭐️")
                                .font(.system(size: 18))
                            
                            Text("\"These books are so hilarious. I love them. I wish there were like 1 million of them. Whoever reads these be aware that you will get a laugh attack.\"")
                                .font(.system(size: 15, weight: .regular))
                                .italic()
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )

                        // Styled testimonial in light grey rounded container
                        VStack(spacing: 12) {
                            Text("⭐️ ⭐️ ⭐️ ⭐️ ⭐️")
                                .font(.system(size: 18))
                            
                            Text("\"My daughter (4) and I have been reading Boxfort books for about a year - we love the light hearted but meaningful stories and fun characters, especially Dr Toast (the best doctor in town!!). She loves the occasional animations, trying to make the same faces as Patrick or hand gestures of the eloquent penguin as we read. We have a lot of little inside jokes stemming from the books as well, you big chunky fish.\"")
                                .font(.system(size: 15, weight: .regular))
                                .italic()
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )

                        // Styled testimonial in light grey rounded container
                        VStack(spacing: 12) {
                            Text("⭐️ ⭐️ ⭐️ ⭐️ ⭐️")
                                .font(.system(size: 18))
                            
                            Text("\"I want to start of with my 5 year old has been obsessed with your books for two years now, his absolute favorite character is Patrick(ironic as his name is Kevin). We were super thrilled for this option to read your books!\"")
                                .font(.system(size: 15, weight: .regular))
                                .italic()
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                // Fixed CTA buttons at bottom
                VStack(spacing: 12) {
                    Button(action: requestPermission) {
                        HStack(spacing: 8) {
                            Text("✅")
                            Text("Yes, keep me up to date")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    Button(action: { 
                        OneSignalService.shared.handlePermissionResponse(accepted: false)
                        presentationMode.wrappedValue.dismiss() 
                    }) {
                        Text("Well now I do not want to 😡")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .alert("Time for some settings magic!", isPresented: $showingSettings) {
            Button("Let's do this") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Nah", role: .cancel) { }
        } message: {
            Text("Pop into Settings and turn on notifications so you don't miss any of the new storybooks")
        }
        .sheet(isPresented: $showingRecovery) {
            PermissionRecoveryView()
        }
    }
    
    private func requestPermission() {
        // Directly request permission from OneSignal to show the native iOS dialog
        OneSignal.Notifications.requestPermission({ accepted in
            print("OneSignal: User accepted notifications: \(accepted)")
            
            DispatchQueue.main.async {
                OneSignalService.shared.handlePermissionResponse(accepted: accepted)
                
                if accepted {
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    OneSignalService.shared.handlePermissionDenied()
                    self.showingRecovery = true
                }
            }
        }, fallbackToSettings: false)
    }
}

// Chaos-focused benefit row matching BoxFort's absurdist tone
struct ChaosBenefitRow: View {
    let emoji: String
    let chaos: String
    let detail: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chaos)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// Recovery view with BoxFort's unhinged-but-friendly tone
struct PermissionRecoveryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("🤷‍♂️")
                    .font(.system(size: 50))
                
                Text("Well, this is awkward...")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("No worries though! Patrick, Kevin, Arty, and Dr. Toast will still be here. If you change your mind and want alerts about their latest adventures, just flip the switch in Settings!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("⚙️")
                        Text("Settings Adventure")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Back to the chaos")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color.orange.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct NotificationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionView()
    }
}