//
//  MiniGameView.swift
//  S2011
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct MiniGameView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var missedEggs = 0
    @State private var panPosition: CGFloat = 0
    @State private var fallingEggs: [FallingEgg] = []
    @State private var gameTimer: Timer?
    @State private var eggSpawnTimer: Timer?
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    @State private var gameTime = 0
    @State private var showingGameOver = false
    @State private var finalScore = 0
    
    private let maxMissedEggs = 3
    
    // Adaptive sizing based on device
    private var panWidth: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80
    }
    
    private var eggSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 45 : 30
    }
    
    private var gameAreaHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 700 : 500
    }
    
    private var controlButtonSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 80 : 60
    }
    
    private var controlSpacing: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        // Show close button only when game is playing
                        if gameState == .playing {
                            Button(action: {
                                stopGame()
                                resetGame()
                                dismiss()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AppColors.accent)
                            }
                        } else {
                            // Invisible spacer for layout consistency
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.clear)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Catch the Eggs!")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Spacer()
                        
                        // Score and missed eggs
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(AppColors.primary)
                                Text("\(score)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("\(missedEggs)/\(maxMissedEggs)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Game Area
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: gameAreaHeight)
                        
                        // Falling Eggs
                        ForEach(fallingEggs) { egg in
                            Text("🥚")
                                .font(.system(size: eggSize))
                                .position(x: egg.x, y: egg.y)
                                .animation(.none, value: egg.y)
                        }
                        
                        // Pan
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                Text("🍳")
                                    .font(.system(size: panWidth))
                                    .offset(x: panPosition)
                                
                                Spacer()
                            }
                        }
                    }
                    .clipped()
                    
                    Spacer()
                    
                    // Game Controls
                    if gameState == .ready {
                        VStack(spacing: 24) {
                            VStack(spacing: 12) {
                                Text("Ready to catch some eggs?")
                                    .font(UIDevice.current.userInterfaceIdiom == .pad ? .largeTitle : .title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Use the buttons below to move your pan and catch falling eggs. Don't let 3 eggs fall!")
                                    .font(UIDevice.current.userInterfaceIdiom == .pad ? .title3 : .body)
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40)
                            }
                            
                            Button(action: startGame) {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .headline)
                                    
                                    Text("Start Game")
                                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 56)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40)
                            .padding(.bottom, 60)
                        }
                    } else if gameState == .playing {
                        // Movement Controls - Adaptive for iPad
                        HStack(spacing: controlSpacing) {
                            Button(action: movePanLeft) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.system(size: controlButtonSize))
                                    .foregroundColor(AppColors.primary)
                            }
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.1), value: panPosition)
                            
                            Spacer()
                            
                            Button(action: movePanRight) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: controlButtonSize))
                                    .foregroundColor(AppColors.primary)
                            }
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.1), value: panPosition)
                        }
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 100 : 60)
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                screenWidth = geometry.size.width
                // Reset game state when view appears
                if gameState == .gameOver {
                    resetGame()
                }
            }
        }
        .sheet(isPresented: $showingGameOver) {
            GameOverView(score: finalScore) {
                resetGame()
                showingGameOver = false
            } onPlayAgain: {
                resetGame()
                showingGameOver = false
                startGame()
            }
        }
    }
    
    private func startGame() {
        gameState = .playing
        score = 0
        missedEggs = 0
        gameTime = 0
        fallingEggs.removeAll()
        panPosition = 0
        
        // Play game start sound
        SoundManager.shared.playSound(.gameStart)
        SoundManager.shared.playHapticFeedback(.medium)
        SoundManager.shared.startBackgroundMusic()
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateGame()
        }
        
        // Start egg spawning
        eggSpawnTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            spawnEgg()
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        eggSpawnTimer?.invalidate()
        gameTimer = nil
        eggSpawnTimer = nil
        gameState = .gameOver
    }
    
    private func resetGame() {
        gameState = .ready
        score = 0
        missedEggs = 0
        gameTime = 0
        fallingEggs.removeAll()
        panPosition = 0
    }
    
    private func updateGame() {
        gameTime += 1
        
        // Update falling eggs
        for i in fallingEggs.indices.reversed() {
            fallingEggs[i].y += fallingEggs[i].speed
            
            // Check if egg reached the bottom
            if fallingEggs[i].y > gameAreaHeight - 50 {
                // Check if caught by pan
                let panCenterX = screenWidth / 2 + panPosition
                let eggX = fallingEggs[i].x
                
                                if abs(eggX - panCenterX) < panWidth / 2 {
                                    // Caught!
                                    score += 1
                                    SoundManager.shared.playSound(.eggCatch)
                                    SoundManager.shared.playHapticFeedback(.light)
                                    fallingEggs.remove(at: i)
                                } else {
                                    // Missed
                                    missedEggs += 1
                                    SoundManager.shared.playSound(.eggMiss)
                                    SoundManager.shared.playHapticFeedback(.medium)
                                    fallingEggs.remove(at: i)
                    
                    if missedEggs >= maxMissedEggs {
                        endGame()
                        return
                    }
                }
            }
        }
    }
    
    private func spawnEgg() {
        let randomX = CGFloat.random(in: 50...(screenWidth - 50))
        let speed = CGFloat.random(in: 2...4)
        
        let newEgg = FallingEgg(
            x: randomX,
            y: 0,
            speed: speed
        )
        
        fallingEggs.append(newEgg)
    }
    
    private func movePanLeft() {
        let moveDistance: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30
        let newPosition = max(panPosition - moveDistance, -(screenWidth / 2 - panWidth / 2))
        withAnimation(.easeOut(duration: 0.1)) {
            panPosition = newPosition
        }
    }
    
    private func movePanRight() {
        let moveDistance: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30
        let newPosition = min(panPosition + moveDistance, (screenWidth / 2 - panWidth / 2))
        withAnimation(.easeOut(duration: 0.1)) {
            panPosition = newPosition
        }
    }
    
    private func endGame() {
        stopGame()
        finalScore = score
        appData.addFocusPoints(score)
        
        // Stop background music and play end sound
        SoundManager.shared.stopBackgroundMusic()
        if score > 10 {
            SoundManager.shared.playHapticFeedback(.success)
        } else {
            SoundManager.shared.playHapticFeedback(.error)
        }
        
        showingGameOver = true
    }
}

// MARK: - Supporting Types

enum GameState {
    case ready
    case playing
    case gameOver
}

struct FallingEgg: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
}

// MARK: - Game Over View

struct GameOverView: View {
    let score: Int
    let onDismiss: () -> Void
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Game Over Animation
            VStack(spacing: 20) {
                Text(score > 10 ? "🏆" : score > 5 ? "🎉" : "💪")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80))
                
                Text("Game Over!")
                    .font(UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 48, weight: .bold) : .largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                VStack(spacing: 8) {
                    Text("Focus Points Earned")
                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .headline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(score)")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 64 : 48, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
                
                Text(getEncouragementMessage(for: score))
                    .font(UIDevice.current.userInterfaceIdiom == .pad ? .title3 : .body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: onPlayAgain) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .headline)
                        
                        Text("Play Again")
                            .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 56)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: onDismiss) {
                    Text("Back to Studio")
                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .headline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.accent.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 32)
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 80 : 50)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
    
    private func getEncouragementMessage(for score: Int) -> String {
        switch score {
        case 0...2:
            return "Every master was once a beginner. Keep practicing!"
        case 3...5:
            return "Good focus! Your concentration is improving."
        case 6...10:
            return "Excellent reflexes! You're developing great focus."
        case 11...15:
            return "Outstanding performance! Your discipline is showing."
        default:
            return "Incredible mastery! You've achieved perfect focus."
        }
    }
}

#Preview {
    MiniGameView()
        .environmentObject(AppData())
}
