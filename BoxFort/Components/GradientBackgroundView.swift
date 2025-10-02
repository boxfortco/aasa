//
//  GradientBackgroundView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  GradientBackgroundView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import SwiftUI

struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [ColorConstants.darkGrayColor, ColorConstants.darkBluishGrayColor]), startPoint: .bottomTrailing, endPoint: .topLeading)
            .edgesIgnoringSafeArea(.all)
    }
}

struct GradientBackgroundViewAlt: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [ColorConstants.borderUltraOne, ColorConstants.accessColor]), startPoint: .bottomTrailing, endPoint: .topLeading)
            .edgesIgnoringSafeArea(.all)
    }
}

struct GradientBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        GradientBackgroundView()
    }
}
