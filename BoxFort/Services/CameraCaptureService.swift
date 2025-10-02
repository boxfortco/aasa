#if false  // COMPLETELY DISABLE THIS FILE DUE TO DYLD CRASH
import Foundation
import AVFoundation
import UIKit
import SwiftUI

// MARK: - Camera Capture Service
@MainActor
class CameraCaptureService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthorized = false
    @Published var isRecording = false
    @Published var recordingProgress: Double = 0.0
    @Published var capturedVideoURL: URL?
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var frontCamera: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var recordingTimer: Timer?
    private let maxRecordingDuration: TimeInterval = 30.0
    private var recordingStartTime: Date?
    
    // Overlay rendering
    private var overlayRenderer: OverlayRenderer?
    private var compositionSession: CompositionSession?
    
    override init() {
        super.init()
        // Only check camera authorization when actually needed to avoid crashes
        print("CameraCaptureService initialized")
    }
    
    // MARK: - Authorization
    
    func checkCameraAuthorization() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            isAuthorized = true
            await setupCaptureSession()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            isAuthorized = granted
            if granted {
                await setupCaptureSession()
            }
        case .denied, .restricted:
            isAuthorized = false
            errorMessage = "Camera access is required to capture celebration videos. Please enable camera access in Settings."
        @unknown default:
            isAuthorized = false
            errorMessage = "Unknown camera authorization status."
        }
    }
    
    // MARK: - Capture Session Setup
    
    private func setupCaptureSession() async {
        guard captureSession == nil else { return }
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720
        
        do {
            // Configure front camera
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                throw CameraCaptureError.deviceNotFound
            }
            
            let videoInput = try AVCaptureDeviceInput(device: frontCamera)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                self.videoInput = videoInput
                self.frontCamera = frontCamera
            } else {
                throw CameraCaptureError.inputConfiguration
            }
            
            // Configure video output
            let videoOutput = AVCaptureMovieFileOutput()
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                self.videoOutput = videoOutput
                
                // Configure output settings
                if let connection = videoOutput.connection(with: .video) {
                    if connection.isVideoMirroringSupported {
                        connection.isVideoMirrored = true
                    }
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                }
            } else {
                throw CameraCaptureError.outputConfiguration
            }
            
            // Create preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer = previewLayer
            
            captureSession = session
            
            // Initialize overlay renderer
            overlayRenderer = OverlayRenderer()
            
        } catch {
            errorMessage = "Failed to setup camera: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Recording Control
    
    func startRecording(with metadata: CelebrationMetadata) {
        guard let captureSession = captureSession,
              let videoOutput = videoOutput,
              !isRecording else { return }
        
        // Start capture session if not running
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
        
        // Create temporary file URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoFileName = "celebration_\(UUID().uuidString).mp4"
        let videoURL = documentsPath.appendingPathComponent(videoFileName)
        
        // Start recording
        videoOutput.startRecording(to: videoURL, recordingDelegate: self)
        
        isRecording = true
        recordingProgress = 0.0
        recordingStartTime = Date()
        capturedVideoURL = nil
        
        // Start progress timer
        startProgressTimer()
        
        // Setup overlay rendering for post-processing
        setupOverlayRendering(metadata: metadata)
    }
    
    func stopRecording() {
        guard isRecording,
              let videoOutput = videoOutput else { return }
        
        videoOutput.stopRecording()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    private func startProgressTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let startTime = self.recordingStartTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            self.recordingProgress = min(elapsed / self.maxRecordingDuration, 1.0)
            
            // Auto-stop at max duration
            if elapsed >= self.maxRecordingDuration {
                self.stopRecording()
            }
        }
    }
    
    // MARK: - Overlay Rendering Setup
    
    private func setupOverlayRendering(metadata: CelebrationMetadata) {
        compositionSession = CompositionSession(metadata: metadata)
    }
    
    // MARK: - Video Processing
    
    func processVideoWithOverlay(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let capturedVideoURL = capturedVideoURL,
              let compositionSession = compositionSession else {
            completion(.failure(CameraCaptureError.noVideoToProcess))
            return
        }
        
        Task {
            do {
                let processedURL = try await overlayRenderer?.processVideo(
                    videoURL: capturedVideoURL,
                    with: compositionSession
                )
                
                guard let processedURL = processedURL else {
                    completion(.failure(CameraCaptureError.processingFailed))
                    return
                }
                
                completion(.success(processedURL))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        captureSession?.stopRunning()
        
        // Clean up temporary files
        if let videoURL = capturedVideoURL {
            try? FileManager.default.removeItem(at: videoURL)
        }
    }
    
    deinit {
        Task { @MainActor in
            cleanup()
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraCaptureService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let error = error {
            errorMessage = "Recording failed: \(error.localizedDescription)"
            isRecording = false
        } else {
            capturedVideoURL = outputFileURL
        }
        
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
}

// MARK: - Overlay Renderer
class OverlayRenderer {
    
    func processVideo(videoURL: URL, with session: CompositionSession) async throws -> URL {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()
        
        // Add video track
        guard let videoTrack = asset.tracks(withMediaType: .video).first,
              let compositionVideoTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
              ) else {
            throw CameraCaptureError.processingFailed
        }
        
        let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
        
        // Create video composition with overlay
        let videoComposition = try await createVideoComposition(
            for: composition,
            with: session,
            videoTrack: videoTrack
        )
        
        // Export with overlay
        return try await exportVideo(
            composition: composition,
            videoComposition: videoComposition
        )
    }
    
    private func createVideoComposition(
        for composition: AVMutableComposition,
        with session: CompositionSession,
        videoTrack: AVAssetTrack
    ) async throws -> AVMutableVideoComposition {
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30 FPS
        videoComposition.renderSize = videoTrack.naturalSize
        
        // Create instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        
        // Create layer instruction
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        instruction.layerInstructions = [layerInstruction]
        
        videoComposition.instructions = [instruction]
        
        // Add overlay rendering
        videoComposition.animationTool = try createOverlayAnimationTool(with: session)
        
        return videoComposition
    }
    
    private func createOverlayAnimationTool(with session: CompositionSession) throws -> AVVideoCompositionCoreAnimationTool {
        let overlayLayer = CALayer()
        let videoLayer = CALayer()
        let parentLayer = CALayer()
        
        // Configure layers
        let size = CGSize(width: 720, height: 1280) // Match video resolution
        parentLayer.frame = CGRect(origin: .zero, size: size)
        videoLayer.frame = CGRect(origin: .zero, size: size)
        overlayLayer.frame = CGRect(origin: .zero, size: size)
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        // Add celebration overlay elements
        addCelebrationElements(to: overlayLayer, metadata: session.metadata, size: size)
        
        return AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parentLayer
        )
    }
    
    private func addCelebrationElements(to layer: CALayer, metadata: CelebrationMetadata, size: CGSize) {
        // Character sticker
        let characterLayer = createCharacterLayer(metadata: metadata, size: size)
        layer.addSublayer(characterLayer)
        
        // Text overlay
        let textLayer = createTextLayer(metadata: metadata, size: size)
        layer.addSublayer(textLayer)
        
        // Milestone badge if applicable
        if let milestoneLayer = createMilestoneLayer(metadata: metadata, size: size) {
            layer.addSublayer(milestoneLayer)
        }
        
        // Decorative frame
        let frameLayer = createFrameLayer(metadata: metadata, size: size)
        layer.addSublayer(frameLayer)
    }
    
    private func createCharacterLayer(metadata: CelebrationMetadata, size: CGSize) -> CALayer {
        let layer = CALayer()
        
        // Position in top-right corner
        let characterSize = CGSize(width: size.width * 0.3, height: size.width * 0.3)
        layer.frame = CGRect(
            x: size.width - characterSize.width - 20,
            y: 60,
            width: characterSize.width,
            height: characterSize.height
        )
        
        // Try to load animated GIF first, then fallback to static
        if metadata.overlay.isAnimated {
            if let gifLayer = createAnimatedGifLayer(
                assetName: metadata.overlay.assetName,
                size: characterSize
            ) {
                layer.addSublayer(gifLayer)
            } else {
                // Fallback to static image
                addStaticCharacterImage(to: layer, metadata: metadata, size: characterSize)
            }
        } else {
            addStaticCharacterImage(to: layer, metadata: metadata, size: characterSize)
        }
        
        // Add bounce animation for extra delight
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.2, 1.0, 1.1, 1.0]
        bounceAnimation.keyTimes = [0, 0.2, 0.4, 0.6, 1.0]
        bounceAnimation.duration = 2.0
        bounceAnimation.repeatCount = .infinity
        layer.add(bounceAnimation, forKey: "bounce")
        
        return layer
    }
    
    private func createAnimatedGifLayer(assetName: String, size: CGSize) -> CALayer? {
        // Try to load GIF data from asset catalog
        guard let asset = NSDataAsset(name: assetName),
              let gifImage = UIImage.gifImageWithData(asset.data) else {
            return nil
        }
        
        let gifLayer = CALayer()
        gifLayer.frame = CGRect(origin: .zero, size: size)
        gifLayer.contents = gifImage.cgImage
        gifLayer.contentsGravity = .resizeAspect
        
        // For video overlay, we'll use the first frame of the GIF
        // The actual animation will be handled by the GIF itself when rendered
        if let images = gifImage.images {
            // Create animation from GIF frames
            let animation = CAKeyframeAnimation(keyPath: "contents")
            animation.values = images.compactMap { $0.cgImage }
            animation.duration = gifImage.duration
            animation.repeatCount = .infinity
            animation.calculationMode = .discrete
            gifLayer.add(animation, forKey: "gifAnimation")
        }
        
        return gifLayer
    }
    
    private func addStaticCharacterImage(to layer: CALayer, metadata: CelebrationMetadata, size: CGSize) {
        if let characterImage = UIImage(named: metadata.overlay.assetName) {
            layer.contents = characterImage.cgImage
            layer.contentsGravity = .resizeAspect
        } else {
            // Fallback placeholder with character's color
            layer.backgroundColor = metadata.overlay.colorScheme.primaryColor.cgColor
            layer.cornerRadius = size.width / 2
            
            // Add character initial as sublayer
            let textLayer = CATextLayer()
            textLayer.string = String(metadata.overlay.character.displayName.prefix(1))
            textLayer.font = UIFont.boldSystemFont(ofSize: size.width * 0.4)
            textLayer.fontSize = size.width * 0.4
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.alignmentMode = .center
            textLayer.frame = CGRect(
                x: 0,
                y: (size.height - size.width * 0.4) / 2,
                width: size.width,
                height: size.width * 0.4
            )
            layer.addSublayer(textLayer)
        }
    }
    
    private func createTextLayer(metadata: CelebrationMetadata, size: CGSize) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.string = metadata.celebrationText
        textLayer.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textLayer.fontSize = 24
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .center
        textLayer.isWrapped = true
        
        // Add text shadow
        textLayer.shadowColor = UIColor.black.cgColor
        textLayer.shadowOffset = CGSize(width: 0, height: 2)
        textLayer.shadowOpacity = 0.8
        textLayer.shadowRadius = 4
        
        // Position at bottom
        let textHeight: CGFloat = 80
        textLayer.frame = CGRect(
            x: 20,
            y: size.height - 150,
            width: size.width - 40,
            height: textHeight
        )
        
        return textLayer
    }
    
    private func createMilestoneLayer(metadata: CelebrationMetadata, size: CGSize) -> CALayer? {
        guard let milestoneText = metadata.milestoneText else { return nil }
        
        let layer = CALayer()
        let badgeSize = CGSize(width: size.width * 0.6, height: 50)
        
        layer.frame = CGRect(
            x: (size.width - badgeSize.width) / 2,
            y: 120,
            width: badgeSize.width,
            height: badgeSize.height
        )
        
        // Background badge
        layer.backgroundColor = metadata.overlay.colorScheme.primaryColor.cgColor
        layer.cornerRadius = badgeSize.height / 2
        
        // Milestone text
        let textLayer = CATextLayer()
        textLayer.string = milestoneText
        textLayer.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        textLayer.fontSize = 18
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .center
        textLayer.frame = layer.bounds
        
        layer.addSublayer(textLayer)
        
        // Pulse animation
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 1.0
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        layer.add(pulseAnimation, forKey: "pulse")
        
        return layer
    }
    
    private func createFrameLayer(metadata: CelebrationMetadata, size: CGSize) -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(origin: .zero, size: size)
        
        // Create decorative frame based on style
        switch metadata.overlay.frameStyle {
        case .stars:
            addStarDecorations(to: layer, size: size)
        case .sunshine:
            addSunshineDecorations(to: layer, size: size)
        case .snowflakes:
            addSnowflakeDecorations(to: layer, size: size)
        case .flowers:
            addFlowerDecorations(to: layer, size: size)
        case .leaves:
            addLeafDecorations(to: layer, size: size)
        default:
            break
        }
        
        return layer
    }
    
    private func addStarDecorations(to layer: CALayer, size: CGSize) {
        for _ in 0..<8 {
            let starLayer = createStarLayer()
            starLayer.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            layer.addSublayer(starLayer)
        }
    }
    
    private func createStarLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        let size: CGFloat = 20
        
        // Create star shape
        path.move(to: CGPoint(x: size/2, y: 0))
        path.addLine(to: CGPoint(x: size*0.6, y: size*0.4))
        path.addLine(to: CGPoint(x: size, y: size*0.4))
        path.addLine(to: CGPoint(x: size*0.7, y: size*0.65))
        path.addLine(to: CGPoint(x: size*0.8, y: size))
        path.addLine(to: CGPoint(x: size/2, y: size*0.8))
        path.addLine(to: CGPoint(x: size*0.2, y: size))
        path.addLine(to: CGPoint(x: size*0.3, y: size*0.65))
        path.addLine(to: CGPoint(x: 0, y: size*0.4))
        path.addLine(to: CGPoint(x: size*0.4, y: size*0.4))
        path.close()
        
        layer.path = path.cgPath
        layer.fillColor = UIColor.yellow.cgColor
        layer.strokeColor = UIColor.orange.cgColor
        layer.lineWidth = 1
        
        // Twinkle animation
        let twinkleAnimation = CABasicAnimation(keyPath: "opacity")
        twinkleAnimation.fromValue = 0.3
        twinkleAnimation.toValue = 1.0
        twinkleAnimation.duration = Double.random(in: 0.5...1.5)
        twinkleAnimation.autoreverses = true
        twinkleAnimation.repeatCount = .infinity
        layer.add(twinkleAnimation, forKey: "twinkle")
        
        return layer
    }
    
    // Placeholder methods for other decorations
    private func addSunshineDecorations(to layer: CALayer, size: CGSize) {
        // Implementation for sunshine decorations
    }
    
    private func addSnowflakeDecorations(to layer: CALayer, size: CGSize) {
        // Implementation for snowflake decorations
    }
    
    private func addFlowerDecorations(to layer: CALayer, size: CGSize) {
        // Implementation for flower decorations
    }
    
    private func addLeafDecorations(to layer: CALayer, size: CGSize) {
        // Implementation for leaf decorations
    }
    
    private func exportVideo(
        composition: AVMutableComposition,
        videoComposition: AVMutableVideoComposition
    ) async throws -> URL {
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("celebration_final_\(UUID().uuidString).mp4")
        
        // Remove file if it exists
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPreset1280x720
        ) else {
            throw CameraCaptureError.exportFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.videoComposition = videoComposition
        
        await exportSession.export()
        
        if let error = exportSession.error {
            throw error
        }
        
        return outputURL
    }
}

// MARK: - Composition Session
class CompositionSession {
    let metadata: CelebrationMetadata
    
    init(metadata: CelebrationMetadata) {
        self.metadata = metadata
    }
}

// MARK: - Errors
enum CameraCaptureError: LocalizedError {
    case deviceNotFound
    case inputConfiguration
    case outputConfiguration
    case noVideoToProcess
    case processingFailed
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .deviceNotFound:
            return "Camera device not found"
        case .inputConfiguration:
            return "Failed to configure camera input"
        case .outputConfiguration:
            return "Failed to configure video output"
        case .noVideoToProcess:
            return "No video available to process"
        case .processingFailed:
            return "Video processing failed"
        case .exportFailed:
            return "Video export failed"
        }
    }
}
#endif  // End of disabled UGC file
