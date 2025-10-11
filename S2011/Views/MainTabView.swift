//
//  MainTabView.swift
//  S2011
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        TabView {
            EggStudioView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Studio")
                }
                .tag(0)
            
            MiniGameView()
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Game")
                }
                .tag(1)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .tag(2)
        }
        .accentColor(AppColors.primary)
        .background(AppColors.background.ignoresSafeArea())
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppData())
}
