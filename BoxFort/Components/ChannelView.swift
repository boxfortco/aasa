//
//  ActiveSheet.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  ChannelView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case patrick, arty, kevin, catCallCrisis
    
    var id: Int {
        hashValue
    }
}

struct ChannelView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var activeSheet: ActiveSheet?
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var showingCatCallCrisis: Bool
    
    private var channels = Channel.allCases
    
    init(showingCatCallCrisis: Binding<Bool>) {
        self._showingCatCallCrisis = showingCatCallCrisis
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 15) {
                Button(action: { activeSheet = .patrick }) {
                    Image("Patrick")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: horizontalSizeClass == .regular ? 150 : geometry.size.width * 0.28,
                               height: horizontalSizeClass == .regular ? 150 : geometry.size.width * 0.28)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button(action: { activeSheet = .arty }) {
                    Image("Arty")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: horizontalSizeClass == .regular ? 150 : geometry.size.width * 0.28,
                               height: horizontalSizeClass == .regular ? 150 : geometry.size.width * 0.28)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button(action: { activeSheet = .kevin }) {
                    Image("Kevin")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: horizontalSizeClass == .regular ? 150 : geometry.size.width * 0.28,
                               height: horizontalSizeClass == .regular ? 150 : geometry.size.width * 0.28)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button(action: { showingCatCallCrisis = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                        
                        Text("Cat Call\nCrisis")
                            .font(.custom("LondrinaSolid-Regular", size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: horizontalSizeClass == .regular ? 150 : geometry.size.width * 0.28,
                           height: horizontalSizeClass == .regular ? 150 : geometry.size.width * 0.28)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .frame(height: horizontalSizeClass == .regular ? 150 : UIScreen.main.bounds.width * 0.28)
        .sheet(isPresented: horizontalSizeClass == .compact ? Binding(
            get: { activeSheet == .patrick },
            set: { if !$0 { activeSheet = nil } }
        ) : .constant(false)) {
            PatrickView()
                .frame(maxWidth: horizontalSizeClass == .regular ? UIScreen.main.bounds.width * 0.8 : .infinity)
                .environmentObject(userViewModel)
        }
        .fullScreenCover(isPresented: horizontalSizeClass == .regular ? Binding(
            get: { activeSheet == .patrick },
            set: { if !$0 { activeSheet = nil } }
        ) : .constant(false)) {
            PatrickView()
                .frame(maxWidth: horizontalSizeClass == .regular ? UIScreen.main.bounds.width * 0.8 : .infinity)
                .environmentObject(userViewModel)
        }
        .sheet(isPresented: horizontalSizeClass == .compact ? Binding(
            get: { activeSheet == .arty },
            set: { if !$0 { activeSheet = nil } }
        ) : .constant(false)) {
            ArtyView()
                .frame(maxWidth: horizontalSizeClass == .regular ? UIScreen.main.bounds.width * 0.8 : .infinity)
                .environmentObject(userViewModel)
        }
        .fullScreenCover(isPresented: horizontalSizeClass == .regular ? Binding(
            get: { activeSheet == .arty },
            set: { if !$0 { activeSheet = nil } }
        ) : .constant(false)) {
            ArtyView()
                .frame(maxWidth: horizontalSizeClass == .regular ? UIScreen.main.bounds.width * 0.8 : .infinity)
                .environmentObject(userViewModel)
        }
        .sheet(isPresented: horizontalSizeClass == .compact ? Binding(
            get: { activeSheet == .kevin },
            set: { if !$0 { activeSheet = nil } }
        ) : .constant(false)) {
            KevinView()
                .frame(maxWidth: horizontalSizeClass == .regular ? UIScreen.main.bounds.width * 0.8 : .infinity)
                .environmentObject(userViewModel)
        }
        .fullScreenCover(isPresented: horizontalSizeClass == .regular ? Binding(
            get: { activeSheet == .kevin },
            set: { if !$0 { activeSheet = nil } }
        ) : .constant(false)) {
            KevinView()
                .frame(maxWidth: horizontalSizeClass == .regular ? UIScreen.main.bounds.width * 0.8 : .infinity)
                .environmentObject(userViewModel)
        }

    }
}

struct ChannelView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
        GradientBackgroundView()
        ChannelView(showingCatCallCrisis: .constant(false))
        }
    }
}
