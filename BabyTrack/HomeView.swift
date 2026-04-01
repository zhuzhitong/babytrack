import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [BabyProfile]
    @Query(sort: \FeedingRecord.time, order: .reverse) private var feedings: [FeedingRecord]
    @Query(sort: \BowelRecord.time, order: .reverse) private var bowels: [BowelRecord]
    @Query(sort: \SupplementRecord.date, order: .reverse) private var supplements: [SupplementRecord]

    private var profile: BabyProfile? { profiles.first }
    private var todayFeedings: [FeedingRecord] { feedings.filter { $0.date.isToday } }
    private var todayBowels: [BowelRecord] { bowels.filter { $0.date.isToday } }
    private var todaySupp: [SupplementRecord] { supplements.filter { $0.date.isToday } }
    private var hasBloodToday: Bool { todayBowels.contains { $0.hasBloodStreak } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // ── 宝宝信息卡 ──
                    if let p = profile { BabyCard(profile: p) }

                    // ── 血丝警告 ──
                    if hasBloodToday {
                        AlertBanner(message: "今日排便有血丝记录，请留意宝宝反应并及时与医生沟通。")
                    }

                    // ── 今日统计 ──
                    SectionHeader(title: "今日记录", color: .btPink)
                    HStack(spacing: 12) {
                        StatCard(title: "喂养", value: "\(todayFeedings.count)", unit: "次",
                                 color: .btPink, icon: "drop.fill")
                        StatCard(title: "排便", value: "\(todayBowels.count)", unit: "次",
                                 color: .btTeal, icon: "waveform.path.ecg")
                        StatCard(title: "补充剂", value: "\(todaySupp.count)", unit: "次",
                                 color: .btPurple, icon: "pills.fill")
                    }.padding(.horizontal)

                    // ── 最近记录 ──
                    if let f = todayFeedings.first {
                        SectionHeader(title: "最近喂养", color: .btPink)
                        RecentRow(icon: "drop.fill", color: .btPink,
                                  title: f.summary, time: f.time,
                                  sub: f.newFood.isEmpty ? nil : "新食物: \(f.newFood)")
                        .padding(.horizontal)
                    }

                    if let b = todayBowels.first {
                        SectionHeader(title: "最近排便", color: .btTeal)
                        RecentRow(icon: "waveform.path.ecg", color: .btTeal,
                                  title: "\(b.color) \(b.texture) \(b.amount)",
                                  time: b.time,
                                  sub: b.hasBloodStreak ? "⚠️ 有血丝" : nil)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.btBg.ignoresSafeArea())
            .navigationTitle("BabyTrack")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape").foregroundColor(.btPink)
                    }
                }
            }
        }
    }
}

struct BabyCard: View {
    let profile: BabyProfile
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.btPink.opacity(0.15)).frame(width: 64, height: 64)
                Text(profile.gender == "女" ? "👧" : "👦").font(.system(size: 36))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name).font(.title2).fontWeight(.semibold)
                Text(profile.ageString).font(.subheadline).foregroundColor(.secondary)
                if !profile.allergyNotes.isEmpty {
                    Text("忌口: \(profile.allergyNotes)").font(.caption)
                        .foregroundColor(.btOrange)
                }
            }
            Spacer()
        }
        .padding().background(Color.btPink.opacity(0.08)).cornerRadius(14)
        .padding(.horizontal)
    }
}

struct RecentRow: View {
    let icon: String; let color: Color
    let title: String; let time: Date; let sub: String?
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(color).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.medium)
                if let s = sub { Text(s).font(.caption).foregroundColor(.btOrange) }
            }
            Spacer()
            Text(time.timeString).font(.caption).foregroundColor(.secondary)
        }
        .padding(12).background(Color(.systemBackground)).cornerRadius(10)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}