//
//  EggStudioView.swift
//  S2011
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct EggStudioView: View {
    @EnvironmentObject var appData: AppData
    @State private var selectedEggType: EggType?
    @State private var isTimerRunning = false
    @State private var timeRemaining = 0
    @State private var timerStartTime = Date()
    @State private var showingCompletion = false
    @State private var completionQuote = ""
    @State private var customTime = 180 // 3 minutes default for fried eggs
    @State private var showingCustomTimer = false
    @State private var timer: Timer?
    @State private var cookingProgress: Double = 0
    @State private var eggBounce = false
    @State private var bubbleAnimation = false
    @State private var expandedCard: EggType?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Egg Studio")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Choose your path to mastery")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                if !isTimerRunning {
                    // Egg Selection List
                    LazyVStack(spacing: 20) {
                        ForEach(EggType.allCases, id: \.self) { eggType in
                            EggTypeCard(
                                eggType: eggType,
                                isSelected: selectedEggType == eggType,
                                isExpanded: expandedCard == eggType,
                                onSelect: {
                                    SoundManager.shared.playSound(.buttonTap)
                                    SoundManager.shared.playHapticFeedback(.light)
                                    selectEggType(eggType)
                                },
                                onToggleExpand: {
                                    SoundManager.shared.playSound(.buttonTap)
                                    SoundManager.shared.playHapticFeedback(.light)
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedCard = expandedCard == eggType ? nil : eggType
                                    }
                                },
                                onStartCooking: {
                                    SoundManager.shared.playSound(.gameStart)
                                    SoundManager.shared.playHapticFeedback(.medium)
                                    startCooking()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Custom Timer for Fried Eggs
                    if selectedEggType == .fried {
                        VStack(spacing: 16) {
                            Text("Custom Timer")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack {
                                Button(action: {
                                    if customTime > 60 {
                                        customTime -= 30
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(AppColors.primary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(customTime / 60):\(String(format: "%02d", customTime % 60))")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("minutes")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if customTime < 600 { // Max 10 minutes
                                        customTime += 30
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: AppColors.accent.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                } else {
                    // Timer View
                    VStack(spacing: 32) {
                        // Cooking Animation
                        ZStack {
                            // Progress Ring
                            Circle()
                                .stroke(AppColors.accent.opacity(0.2), lineWidth: 8)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: cookingProgress)
                                .stroke(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: cookingProgress)
                            
                            // Egg Animation
                            VStack {
                                Text(selectedEggType?.emoji ?? "🥚")
                                    .font(.system(size: 60))
                                    .scaleEffect(eggBounce ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: eggBounce)
                                
                                Text(selectedEggType?.displayName ?? "")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                        
                        // Timer Display
                        VStack(spacing: 8) {
                            Text(timeString(from: timeRemaining))
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("remaining")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        // Motivational Text
                        Text("Stay focused and patient...")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Stop Button
                        Button(action: stopCooking) {
                            HStack {
                                Image(systemName: "stop.fill")
                                    .font(.headline)
                                
                                Text("Stop Cooking")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.accent, AppColors.accent.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: AppColors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 100) // Space for tab bar
        }
        .background(AppColors.background.ignoresSafeArea())
        .sheet(isPresented: $showingCompletion) {
            CompletionView(
                eggType: selectedEggType ?? .softBoiled,
                quote: completionQuote
            ) {
                showingCompletion = false
                resetTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func selectEggType(_ eggType: EggType) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedEggType = eggType
            if eggType != .fried {
                customTime = eggType.cookingTime
            }
        }
    }
    
    private func startCooking() {
        guard let eggType = selectedEggType else { return }
        
        let cookingTime = eggType == .fried ? customTime : eggType.cookingTime
        
        // Play start sound and haptic feedback
        SoundManager.shared.playSound(.gameStart)
        SoundManager.shared.playHapticFeedback(.medium)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            isTimerRunning = true
            timeRemaining = cookingTime
            timerStartTime = Date()
            cookingProgress = 0
            eggBounce = true
        }
        
        startTimer(duration: cookingTime)
    }
    
    private func stopCooking() {
        stopTimer()
        
        guard let eggType = selectedEggType else { return }
        
        let targetTime = eggType == .fried ? customTime : eggType.cookingTime
        let actualTime = Int(Date().timeIntervalSince(timerStartTime))
        let session = CookingSession(eggType: eggType, targetTime: targetTime, actualTime: actualTime)
        
        appData.addCookingSession(session)
        
        completionQuote = MotivationalQuotes.random()
        showingCompletion = true
    }
    
    private func startTimer(duration: Int) {
        let totalDuration = Double(duration)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                cookingProgress = 1.0 - (Double(timeRemaining) / totalDuration)
                } else {
                    // Timer completed
                    stopTimer()
                    
                    // Play completion sound and haptic feedback
                    SoundManager.shared.playSound(.eggComplete)
                    SoundManager.shared.playSound(.sizzle)
                    SoundManager.shared.playHapticFeedback(.success)
                    
                    completionQuote = MotivationalQuotes.random()
                    showingCompletion = true
                }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        withAnimation(.easeInOut(duration: 0.5)) {
            isTimerRunning = false
            eggBounce = false
        }
    }
    
    private func resetTimer() {
        selectedEggType = nil
        timeRemaining = 0
        cookingProgress = 0
        customTime = 180
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Egg Type Card

struct EggTypeCard: View {
    let eggType: EggType
    let isSelected: Bool
    let isExpanded: Bool
    let onSelect: () -> Void
    let onToggleExpand: () -> Void
    let onStartCooking: () -> Void
    
    private var instructions: [String] {
        switch eggType {
        case .softBoiled:
            return [
                "1. Remove eggs from fridge 30 min early",
                "2. Boil water to cover eggs by 2-3 cm",
                "3. Lower eggs gently with spoon",
                "4. Cook exactly 5 minutes",
                "5. Transfer to ice water for 2-3 min",
                "6. Peel and serve in egg cups"
            ]
        case .mediumBoiled:
            return [
                "1. Remove eggs from fridge 30 min early",
                "2. Bring water to active boiling",
                "3. Lower eggs carefully and start timer",
                "4. Cook exactly 7 minutes",
                "5. Quick transfer to ice water 3-4 min",
                "6. Peel and cut in half for salads"
            ]
        case .hardBoiled:
            return [
                "1. Use week-old eggs for easier peeling",
                "2. Bring water to vigorous boiling",
                "3. Lower eggs with spoon (don't drop)",
                "4. Cook exactly 9 minutes",
                "5. Ice water bath for 5 minutes",
                "6. Peel under running water"
            ]
        case .fried:
            return [
                "1. Heat pan on medium heat",
                "2. Add butter or oil (should sizzle)",
                "3. Crack eggs into bowl first",
                "4. Pour gently into pan",
                "5. Cook 2-3 min until whites set",
                "6. Flip for firm yolk or serve runny"
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card
            VStack(spacing: 12) {
                // Header
                HStack {
                    VStack(spacing: 8) {
                        Text(eggType.emoji)
                            .font(.system(size: 40))
                        
                        VStack(spacing: 4) {
                            Text(eggType.displayName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            if eggType != .fried {
                                Text("\(eggType.cookingTime / 60) min")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            } else {
                                Text("custom time")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 8) {
                        Button(action: onSelect) {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                Text("Select")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(isSelected ? AppColors.primary : AppColors.accent)
                        }
                        
                        if isSelected {
                            Button(action: onStartCooking) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .font(.footnote)
                                    Text("Start Cooking")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(width: 120, height: 32)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Instructions toggle
                Button(action: onToggleExpand) {
                    HStack {
                        Image(systemName: "book")
                            .font(.footnote)
                        Text(isExpanded ? "Hide Instructions" : "Show Instructions")
                            .font(.footnote)
                            .fontWeight(.medium)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(AppColors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.primary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // Expanded instructions
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cooking Instructions:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal, 16)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(instructions, id: \.self) { instruction in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(AppColors.primary)
                                        .font(.caption)
                                    
                                    Text(instruction)
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? AppColors.primary : 
                                isExpanded ? AppColors.accent.opacity(0.5) : Color.clear,
                                lineWidth: isSelected ? 2 : isExpanded ? 1 : 0
                            )
                    )
                    .shadow(
                        color: isExpanded ? AppColors.accent.opacity(0.2) : AppColors.accent.opacity(0.1), 
                        radius: isExpanded ? 12 : 8, 
                        x: 0, 
                        y: isExpanded ? 6 : 4
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

// MARK: - Completion View

struct CompletionView: View {
    let eggType: EggType
    let quote: String
    let onDismiss: () -> Void
    @EnvironmentObject var appData: AppData
    @State private var showingNextChallenge = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Animation
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 80))
                
                Text("Well done!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(quote)
                    .font(.title3)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: {
                    onDismiss()
                    showingNextChallenge = true
                }) {
                    HStack {
                        Text("Next Challenge")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "gamecontroller.fill")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
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
                    Text("Continue Cooking")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
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
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(AppColors.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showingNextChallenge) {
            MiniGameView()
                .environmentObject(appData)
        }
    }
}

#Preview {
    EggStudioView()
        .environmentObject(AppData())
}
