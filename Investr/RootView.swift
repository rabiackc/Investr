import SwiftUI

struct RootView: View {
    @AppStorage("isOnboarded") private var isOnboarded: Bool = false
    
    var body: some View {
        if isOnboarded {
            // ✅ Onboarding bittiyse ana TabBar'a yönlendir
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            FixedExpensesView()
                .tabItem {
                    Label("Sabit Giderler", systemImage: "list.bullet.rectangle")
                }
            
            DailyExpenseView()
                .tabItem {
                    Label("Harcama", systemImage: "plus.circle")
                }
        }
    }
}

