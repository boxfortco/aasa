//
//  DynamicBorderView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  DynamicBorderView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 3/6/24.
//


import SwiftUI
import UIKit


struct DynamicBorderView: View {
    var book: Book
    @State private var rotation: CGFloat = 0.0
    
    // Define constants for width and height
    private let width: CGFloat = 220 // 220
    private let height: CGFloat = 330 // 330
    
    class EmitterView: UIView {
        private var emitterLayer: CAEmitterLayer?

        override func layoutSubviews() {
            super.layoutSubviews()
            if emitterLayer == nil {
                setupEmitter()
            }
            emitterLayer?.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
        private func setupEmitter() {
            let layer = CAEmitterLayer()
            let colors: [UIColor] = [ColorConstants.particleOne.uiColor, ColorConstants.particleTwo.uiColor, ColorConstants.particleThree.uiColor]
            layer.emitterShape = .point
            layer.emitterSize = CGSize(width: 1, height: 1)
            layer.beginTime = CACurrentMediaTime()
            layer.emitterCells = colors.map { color in
                createEmitterCell(color: color)
            }
            self.layer.addSublayer(layer)
            self.emitterLayer = layer
        }

        private func createEmitterCell(color: UIColor) -> CAEmitterCell {
            let cell = CAEmitterCell()
            cell.birthRate = 100
            cell.lifetime = 2.0
            cell.velocity = 120
            cell.velocityRange = 50
            cell.emissionRange = CGFloat.pi * 2
            cell.scale = 0.5
            cell.scaleRange = 0.1
            cell.color = color.cgColor
            cell.contents = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16)).image { _ in
                color.setFill()
                UIBezierPath(rect: CGRect(x: 0, y: 0, width: 16, height: 16)).fill()
            }.cgImage
            return cell
        }
    }

    struct ParticleEmitterView: UIViewRepresentable {
        var width: CGFloat
        var height: CGFloat
        
        func makeUIView(context: Context) -> UIView {
            EmitterView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
    }
    
    class EmitterViewUltra: UIView {
        private var emitterLayerUltra: CAEmitterLayer?

        override func layoutSubviews() {
            super.layoutSubviews()
            if emitterLayerUltra == nil {
                setupEmitterUltra()
            }
            emitterLayerUltra?.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        }

        private func setupEmitterUltra() {
            let layer = CAEmitterLayer()
            let colors: [UIColor] = [ColorConstants.borderUltraOne.uiColor, ColorConstants.borderUltraTwo.uiColor]
            layer.emitterShape = .point
            layer.emitterSize = CGSize(width: 1, height: 1)
            layer.beginTime = CACurrentMediaTime()
            layer.emitterCells = colors.map { color in
                createEmitterCellUltra(color: color)
            }
            self.layer.addSublayer(layer)
            self.emitterLayerUltra = layer
        }

        private func createEmitterCellUltra(color: UIColor) -> CAEmitterCell {
            let cell = CAEmitterCell()
            cell.birthRate = 100
            cell.lifetime = 2.0
            cell.velocity = 120
            cell.velocityRange = 50
            cell.emissionRange = CGFloat.pi * 2
            cell.scale = 0.5
            cell.scaleRange = 0.1
            cell.color = color.cgColor
            cell.contents = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20)).image { _ in
                color.setFill()
                UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 20, height: 20)).fill()
            }.cgImage
            return cell
        }
    }

    struct ParticleEmitterUltraView: UIViewRepresentable {
        var width: CGFloat
        var height: CGFloat
        
        func makeUIView(context: Context) -> UIView {
            EmitterViewUltra(frame: CGRect(x: 0, y: 0, width: width, height: height))
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
    }
    
    private func borderStyle(forOpenCount openCount: Int) -> some View {
        switch openCount {
        case 10..<20:
           
            
            return AnyView(ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: height)
                    .opacity(0.8)

                    
                    .mask(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(lineWidth: 8)
                            .frame(width: width - 8, height: height - 8)
                    )
            })
             
        case 20..<40:
            return AnyView(ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: height)
                    .opacity(0.8)

                    .mask(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(lineWidth: 8)
                            .frame(width: width - 8, height: height - 8)
                    )
            })
        case 40..<60:
            return AnyView(ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.yellow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: width, height: height)

                    .mask(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(lineWidth: 8)
                            .frame(width: width - 8, height: height - 8)
                    )
            })
        case 60..<80:
            return AnyView(ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.white, .orange, .yellow, .green, .blue, .purple, .pink]), startPoint: .top, endPoint: .bottom))
                    .rotationEffect(.degrees(rotation))
                    .frame(width: width * 2, height: height * 2)
                    .mask(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(lineWidth: 8)
                            .frame(width: width - 8, height: height - 8)
                    )
            }.onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            })
        case 80..<120:
            return AnyView(ParticleEmitterView(width: width, height: height)
                .mask(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(lineWidth: 8)
                        .frame(width: width - 8, height: height - 8)
                ))
           
        case 120...:
            return AnyView(ParticleEmitterUltraView(width: width, height: height)
                .mask(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(lineWidth: 8)
                        .frame(width: width - 8, height: height - 8)
                ))
        default:
            return AnyView(EmptyView())
        }
    }

    
    var body: some View {
        let openCount = UserDefaults.standard.integer(forKey: "openCount_\(book.id)")
        
        return ZStack {
                Image(book.posterImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .frame(width: width, height: height)
                
            /*
                borderStyle(forOpenCount: openCount)
                    .frame(width: width, height: height)
             */
        }
    }

    private func incrementOpenCount() {
        let openCount = UserDefaults.standard.integer(forKey: "openCount_\(book.id)")
        UserDefaults.standard.set(openCount + 1, forKey: "openCount_\(book.id)")
    }
}


extension Color {
    // Convert SwiftUI Color to UIColor
    var uiColor: UIColor {
        UIColor(self)
    }
}
 

