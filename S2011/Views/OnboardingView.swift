//
//  OnboardingView.swift
//  S2011
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appData: AppData
    @State private var currentPage = 0
    @State private var animationOffset: CGFloat = 0
    @State private var eggRotation: Double = 0
    @State private var bubbleOpacity: Double = 0
    @State private var panOffset: CGFloat = 0
    
    private let onboardingPages = [
        OnboardingPage(
            title: "Master patience through the art of cooking",
            description: "Learn discipline and focus by perfecting the simple art of cooking eggs",
            animationType: .boiling
        ),
        OnboardingPage(
            title: "Small daily rituals build great discipline",
            description: "Transform everyday moments into opportunities for growth and mindfulness",
            animationType: .frying
        ),
        OnboardingPage(
            title: "Control your process — from raw to perfect",
            description: "Develop self-control and precision through mindful cooking practices",
            animationType: .cracking
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Animation Area
                ZStack {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        if index == currentPage {
                            animationView(for: onboardingPages[index].animationType)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                }
                .frame(height: 300)
                .padding(.bottom, 40)
                
                // Content
                VStack(spacing: 24) {
                    Text(onboardingPages[currentPage].title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Text(onboardingPages[currentPage].description)
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineLimit(nil)
                }
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                Spacer()
                
                // Page Indicator
                HStack(spacing: 12) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? AppColors.primary : AppColors.accent.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 40)
                
                // Action Button
                if currentPage == onboardingPages.count - 1 {
                    Button(action: {
                        SoundManager.shared.playSound(.buttonTap)
                        SoundManager.shared.playHapticFeedback(.medium)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appData.completeOnboarding()
                        }
                    }) {
                        HStack {
                            Text("Start Now")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
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
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Button(action: {
                        SoundManager.shared.playSound(.buttonTap)
                        SoundManager.shared.playHapticFeedback(.light)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentPage += 1
                        }
                    }) {
                        HStack {
                            Text("Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
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
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: currentPage) { _ in
            startAnimations()
        }
    }
    
    @ViewBuilder
    private func animationView(for type: AnimationType) -> some View {
        switch type {
        case .boiling:
            boilingEggAnimation()
        case .frying:
            fryingEggAnimation()
        case .cracking:
            crackingEggAnimation()
        }
    }
    
    private func boilingEggAnimation() -> some View {
        ZStack {
            // Pot
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.accent)
                .frame(width: 120, height: 80)
                .offset(y: 40)
            
            // Water bubbles
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: CGFloat.random(in: 8...16))
                    .offset(
                        x: CGFloat.random(in: -40...40),
                        y: 20 + CGFloat(index * 8)
                    )
                    .opacity(bubbleOpacity)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: bubbleOpacity
                    )
            }
            
            // Egg
            Ellipse()
                .fill(Color.white)
                .frame(width: 40, height: 50)
                .rotationEffect(.degrees(eggRotation))
                .offset(y: 10)
        }
    }
    
    private func fryingEggAnimation() -> some View {
        ZStack {
            // Pan
            Circle()
                .fill(AppColors.accent)
                .frame(width: 140, height: 140)
                .offset(x: panOffset)
            
            // Handle
            RoundedRectangle(cornerRadius: 4)
                .fill(AppColors.accent)
                .frame(width: 60, height: 8)
                .offset(x: 100 + panOffset, y: 0)
            
            // Fried egg
            ZStack {
                // Egg white
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                
                // Egg yolk
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 30, height: 30)
            }
            .offset(x: panOffset)
        }
    }
    
    private func crackingEggAnimation() -> some View {
        ZStack {
            // Whole egg
            Ellipse()
                .fill(Color.white)
                .frame(width: 60, height: 80)
                .rotationEffect(.degrees(eggRotation))
            
            // Crack line
            Rectangle()
                .fill(AppColors.textPrimary)
                .frame(width: 2, height: 40)
                .opacity(eggRotation > 180 ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: eggRotation)
        }
    }
    
    private func startAnimations() {
        // Reset animations
        eggRotation = 0
        bubbleOpacity = 0
        panOffset = 0
        
        // Start new animations based on current page
        switch onboardingPages[currentPage].animationType {
        case .boiling:
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                eggRotation = 10
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                bubbleOpacity = 1
            }
            
        case .frying:
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                panOffset = 10
            }
            
        case .cracking:
            withAnimation(.easeInOut(duration: 2.0).repeatForever()) {
                eggRotation = 360
            }
        }
    }
}

// MARK: - Supporting Types

struct OnboardingPage {
    let title: String
    let description: String
    let animationType: AnimationType
}

enum AnimationType {
    case boiling
    case frying
    case cracking
}

#Preview {
    OnboardingView()
        .environmentObject(AppData())
}
