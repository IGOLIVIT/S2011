//
//  AppData.swift
//  S2011
//
//  Created by IGOR on 09/10/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Data Models

enum EggType: String, CaseIterable, Codable {
    case softBoiled = "soft_boiled"
    case mediumBoiled = "medium_boiled"
    case hardBoiled = "hard_boiled"
    case fried = "fried"
    
    var displayName: String {
        switch self {
        case .softBoiled: return "Soft-boiled"
        case .mediumBoiled: return "Medium-boiled"
        case .hardBoiled: return "Hard-boiled"
        case .fried: return "Fried egg"
        }
    }
    
    var cookingTime: Int {
        switch self {
        case .softBoiled: return 300 // 5 minutes
        case .mediumBoiled: return 420 // 7 minutes
        case .hardBoiled: return 540 // 9 minutes
        case .fried: return 180 // 3 minutes default
        }
    }
    
    var emoji: String {
        switch self {
        case .softBoiled: return "🥚"
        case .mediumBoiled: return "🥚"
        case .hardBoiled: return "🥚"
        case .fried: return "🍳"
        }
    }
}

// MARK: - App State Management

class AppData: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var totalSessions: Int = 0
    @Published var totalFocusPoints: Int = 0
    @Published var bestStreak: Int = 0
    @Published var currentStreak: Int = 0
    @Published var averageAccuracy: Double = 0.0
    @Published var completedSessions: [CookingSession] = []
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadData()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveData()
    }
    
    func addCookingSession(_ session: CookingSession) {
        completedSessions.append(session)
        totalSessions += 1
        currentStreak += 1
        
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
        
        updateAverageAccuracy()
        saveData()
    }
    
    func addFocusPoints(_ points: Int) {
        totalFocusPoints += points
        saveData()
    }
    
    func resetProgress() {
        totalSessions = 0
        totalFocusPoints = 0
        bestStreak = 0
        currentStreak = 0
        averageAccuracy = 0.0
        completedSessions.removeAll()
        saveData()
    }
    
    private func updateAverageAccuracy() {
        if completedSessions.isEmpty {
            averageAccuracy = 0.0
            return
        }
        
        let totalAccuracy = completedSessions.reduce(0.0) { $0 + $1.accuracy }
        averageAccuracy = totalAccuracy / Double(completedSessions.count)
    }
    
    private func saveData() {
        userDefaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        userDefaults.set(totalSessions, forKey: "totalSessions")
        userDefaults.set(totalFocusPoints, forKey: "totalFocusPoints")
        userDefaults.set(bestStreak, forKey: "bestStreak")
        userDefaults.set(currentStreak, forKey: "currentStreak")
        userDefaults.set(averageAccuracy, forKey: "averageAccuracy")
        
        if let encoded = try? JSONEncoder().encode(completedSessions) {
            userDefaults.set(encoded, forKey: "completedSessions")
        }
    }
    
    private func loadData() {
        hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
        totalSessions = userDefaults.integer(forKey: "totalSessions")
        totalFocusPoints = userDefaults.integer(forKey: "totalFocusPoints")
        bestStreak = userDefaults.integer(forKey: "bestStreak")
        currentStreak = userDefaults.integer(forKey: "currentStreak")
        averageAccuracy = userDefaults.double(forKey: "averageAccuracy")
        
        if let data = userDefaults.data(forKey: "completedSessions"),
           let sessions = try? JSONDecoder().decode([CookingSession].self, from: data) {
            completedSessions = sessions
        }
    }
}

// MARK: - Cooking Session Model

struct CookingSession: Codable, Identifiable {
    let id = UUID()
    let eggType: EggType
    let targetTime: Int
    let actualTime: Int
    let accuracy: Double
    let date: Date
    
    init(eggType: EggType, targetTime: Int, actualTime: Int) {
        self.eggType = eggType
        self.targetTime = targetTime
        self.actualTime = actualTime
        self.date = Date()
        
        // Calculate accuracy based on how close actual time was to target
        let timeDifference = abs(targetTime - actualTime)
        let maxDifference = max(targetTime / 4, 30) // Allow 25% variance or 30 seconds
        self.accuracy = max(0.0, 1.0 - (Double(timeDifference) / Double(maxDifference)))
    }
}

// MARK: - Color Theme

struct AppColors {
    static let background = Color(hex: "#FFF6E1")
    static let primary = Color(hex: "#F9B20F")
    static let accent = Color(hex: "#8B5E3C")
    static let textPrimary = Color(hex: "#2C1810")
    static let textSecondary = Color(hex: "#6B4423")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Motivational Quotes

struct MotivationalQuotes {
    static let quotes = [
        "Discipline tastes like success",
        "Master patience through the art of cooking",
        "Small daily rituals build great discipline",
        "Control your process — from raw to perfect",
        "Excellence is a habit, not an act",
        "Focus transforms the ordinary into extraordinary",
        "Every perfect egg is a victory over impatience",
        "Precision in small things leads to mastery in all things",
        "The art of cooking mirrors the art of living",
        "Patience is the secret ingredient to perfection"
    ]
    
    static func random() -> String {
        quotes.randomElement() ?? quotes[0]
    }
}
