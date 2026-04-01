import SwiftUI
import SwiftData

@main
struct BabyTrackApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BabyProfile.self,
            FeedingRecord.self,
            BowelRecord.self,
            SupplementRecord.self,
            GrowthRecord.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer 初始化失败: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}