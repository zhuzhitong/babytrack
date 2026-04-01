import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var profiles: [BabyProfile]
    var body: some View {
        if profiles.isEmpty { SetupView() } else { MainTabView() }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("首页", systemImage: "house.fill") }
            FeedingView()
                .tabItem { Label("喂养", systemImage: "drop.fill") }
            BowelView()
                .tabItem { Label("排便", systemImage: "waveform.path.ecg") }
            SupplementView()
                .tabItem { Label("补充剂", systemImage: "pills.fill") }
            GrowthView()
                .tabItem { Label("生长", systemImage: "chart.line.uptrend.xyaxis") }
            ReportView()
                .tabItem { Label("报告", systemImage: "doc.text.fill") }
        }
        .tint(.btPink)
    }
}