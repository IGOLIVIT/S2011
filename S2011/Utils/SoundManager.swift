//
//  SoundManager.swift
//  S2011
//
//  Created by IGOR on 09/10/2025.
//

import AVFoundation
import SwiftUI
import Combine

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var backgroundPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(_ soundType: SoundType) {
        // Generate system sounds for different actions
        switch soundType {
        case .eggComplete:
            // Play a satisfying completion sound
            AudioServicesPlaySystemSound(1057) // Tink sound
            
        case .buttonTap:
            // Play a subtle tap sound
            AudioServicesPlaySystemSound(1104) // Camera shutter
            
        case .eggCatch:
            // Play a catching sound
            AudioServicesPlaySystemSound(1103) // Pop sound
            
        case .eggMiss:
            // Play a miss sound
            AudioServicesPlaySystemSound(1053) // Negative sound
            
        case .gameStart:
            // Play a game start sound
            AudioServicesPlaySystemSound(1054) // Positive sound
            
        case .sizzle:
            // Play a sizzling sound (using system sound)
            AudioServicesPlaySystemSound(1105) // Keyboard tap
        }
    }
    
    func startBackgroundMusic() {
        // For now, we'll use a subtle system sound loop
        // In a real app, you would load an actual audio file
        playSound(.gameStart)
    }
    
    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }
    
    func playHapticFeedback(_ type: HapticType) {
        switch type {
        case .light:
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
        case .medium:
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
        case .heavy:
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
        case .success:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
        case .error:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
        }
    }
}

enum SoundType {
    case eggComplete
    case buttonTap
    case eggCatch
    case eggMiss
    case gameStart
    case sizzle
}

enum HapticType {
    case light
    case medium
    case heavy
    case success
    case error
}

// MARK: - View Extension for Easy Sound Access

extension View {
    func onTapSound() -> some View {
        self.onTapGesture {
            SoundManager.shared.playSound(.buttonTap)
            SoundManager.shared.playHapticFeedback(.light)
        }
    }
    
    func withButtonSound<T>(_ action: @escaping () -> T) -> () -> T {
        return {
            SoundManager.shared.playSound(.buttonTap)
            SoundManager.shared.playHapticFeedback(.light)
            return action()
        }
    }
}
