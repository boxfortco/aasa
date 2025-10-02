import SwiftUI
import FirebaseAuth

struct LoyaltyStatusView: View {
    @StateObject private var loyaltyService = LoyaltyService.shared
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var loyaltyStatus: (points: Int, tier: LoyaltyTier, streak: Int)?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if let status = loyaltyStatus {
                // Tier Badge
                VStack {
                    Image(systemName: status.tier.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(status.tier.color)
                    
                    Text(status.tier.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 5)
                )
                
                // Points and Streak
                HStack(spacing: 30) {
                    StatView(title: "Points", value: "\(status.points)", icon: "star.fill")
                    StatView(title: "Streak", value: "\(status.streak) days", icon: "flame.fill")
                }
                
                // Progress to next tier
                if let nextTier = status.tier.nextTier {
                    let progress = Double(status.points) / Double(nextTier.requiredPoints)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progress to \(nextTier.rawValue.capitalized)")
                            .font(.subheadline)
                        
                        ProgressView(value: progress)
                            .tint(status.tier.color)
                        
                        Text("\(status.points)/\(nextTier.requiredPoints) points")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 3)
                    )
                }
                
                // Benefits
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Benefits")
                        .font(.headline)
                    
                    ForEach(status.tier.benefits, id: \.self) { benefit in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(benefit)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 3)
                )
            }
        }
        .padding()
        .task {
            await loadLoyaltyStatus()
        }
    }
    
    private func loadLoyaltyStatus() async {
        guard let userId = userViewModel.user?.id else {
            errorMessage = "Please sign in to view your loyalty status"
            isLoading = false
            return
        }
        
        do {
            loyaltyStatus = try await loyaltyService.getLoyaltyStatus(userId: userId)
            isLoading = false
        } catch {
            errorMessage = "Failed to load loyalty status: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(radius: 3)
        )
    }
}

#Preview {
    LoyaltyStatusView()
        .environmentObject(UserViewModel())
} 