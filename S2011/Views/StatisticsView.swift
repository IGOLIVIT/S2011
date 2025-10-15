//
//  StatisticsView.swift
//  S2011
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var appData: AppData
    @State private var showingResetAlert = false
    @State private var eggRotation: Double = 0
    @State private var glowOpacity: Double = 0.3
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Your Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Track your journey to mastery")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                // Animated Background Element
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColors.primary.opacity(glowOpacity), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowOpacity)
                    
                    Text("🥚")
                        .font(.system(size: 60))
                        .rotationEffect(.degrees(eggRotation))
                        .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: eggRotation)
                }
                .frame(height: 120)
                
                // Statistics Cards
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 20) {
                    StatCard(
                        title: "Total Sessions",
                        value: "\(appData.totalSessions)",
                        icon: "flame.fill",
                        color: AppColors.primary
                    )
                    
                    StatCard(
                        title: "Focus Points",
                        value: "\(appData.totalFocusPoints)",
                        icon: "star.fill",
                        color: AppColors.accent
                    )
                    
                    StatCard(
                        title: "Best Streak",
                        value: "\(appData.bestStreak)",
                        icon: "bolt.fill",
                        color: AppColors.primary
                    )
                    
                    StatCard(
                        title: "Avg. Accuracy",
                        value: String(format: "%.0f%%", appData.averageAccuracy * 100),
                        icon: "target",
                        color: AppColors.accent
                    )
                }
                .padding(.horizontal, 20)
                
                // Recent Sessions
                if !appData.completedSessions.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Sessions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal, 20)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(Array(appData.completedSessions.suffix(5).reversed()), id: \.id) { session in
                                SessionCard(session: session)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Motivational Section
                VStack(spacing: 16) {
                    Text("💪")
                        .font(.system(size: 40))
                    
                    Text(getMotivationalMessage())
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: AppColors.accent.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                
                // Reset Progress Button
                Button(action: {
                    showingResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                        
                        Text("Reset Progress")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppColors.accent)
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
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100) // Space for tab bar
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            startAnimations()
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appData.resetProgress()
            }
        } message: {
            Text("Are you sure you want to reset all your progress? This action cannot be undone.")
        }
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            eggRotation = 360
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }
    }
    
    private func getMotivationalMessage() -> String {
        let sessions = appData.totalSessions
        let points = appData.totalFocusPoints
        
        if sessions == 0 {
            return "Start your journey to mastery! Every expert was once a beginner."
        } else if sessions < 5 {
            return "Great start! You're building the foundation of discipline."
        } else if sessions < 20 {
            return "You're developing consistency! Keep up the excellent work."
        } else if points > 100 {
            return "Incredible focus! You're becoming a true master of patience."
        } else {
            return "Your dedication is inspiring! You've mastered the art of discipline."
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: AppColors.accent.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Session Card

struct SessionCard: View {
    let session: CookingSession
    
    var body: some View {
        HStack(spacing: 16) {
            // Egg Type Icon
            Text(session.eggType.emoji)
                .font(.title2)
            
            // Session Details
            VStack(alignment: .leading, spacing: 4) {
                Text(session.eggType.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack {
                    Text("Target: \(timeString(from: session.targetTime))")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Actual: \(timeString(from: session.actualTime))")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Accuracy
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0f%%", session.accuracy * 100))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(accuracyColor(session.accuracy))
                
                Text(formatDate(session.date))
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .shadow(color: AppColors.accent.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.8 {
            return .green
        } else if accuracy >= 0.6 {
            return AppColors.primary
        } else {
            return AppColors.accent
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(AppData())
}

