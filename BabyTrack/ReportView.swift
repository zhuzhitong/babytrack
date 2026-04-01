import SwiftUI
import SwiftData

struct ReportView: View {
    @Query(sort: \FeedingRecord.date, order: .reverse) private var feedings: [FeedingRecord]
    @Query(sort: \BowelRecord.date, order: .reverse) private var bowels: [BowelRecord]
    @Query(sort: \SupplementRecord.date, order: .reverse) private var supplements: [SupplementRecord]
    @Query(sort: \GrowthRecord.date, order: .reverse) private var growths: [GrowthRecord]
    @Query private var profiles: [BabyProfile]

    @State private var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showShareSheet = false
    @State private var reportText = ""

    private var profile: BabyProfile? { profiles.first }

    private var rangeFeedings: [FeedingRecord] {
        feedings.filter { $0.date >= startDate && $0.date <= endDate }
    }
    private var rangeBowels: [BowelRecord] {
        bowels.filter { $0.date >= startDate && $0.date <= endDate }
    }
    private var bloodDays: [Date] {
        let days = rangeBowels.filter { $0.hasBloodStreak }.map { $0.date }
        return Array(Set(days.map { Calendar.current.startOfDay(for: $0) })).sorted()
    }
    private var newFoods: [String] {
        Array(Set(rangeFeedings.compactMap { $0.newFood.isEmpty ? nil : $0.newFood })).sorted()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // ── 日期范围 ──
                    GroupBox {
                        DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                        DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
                    }.padding(.horizontal)

                    // ── 摘要统计 ──
                    SectionHeader(title: "区间摘要", color: .btPink)
                    HStack(spacing: 12) {
                        StatCard(title: "喂养次数", value: "\(rangeFeedings.count)", unit: "次",
                                 color: .btPink, icon: "drop.fill")
                        StatCard(title: "排便次数", value: "\(rangeBowels.count)", unit: "次",
                                 color: .btTeal, icon: "waveform.path.ecg")
                    }.padding(.horizontal)

                    // ── 血丝日期 ──
                    if !bloodDays.isEmpty {
                        SectionHeader(title: "⚠️ 血丝出现日期", color: .red)
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(bloodDays, id: \.self) { d in
                                HStack {
                                    Circle().fill(Color.red).frame(width: 6, height: 6)
                                    Text(d.dateString).font(.subheadline)
                                }
                            }
                        }
                        .padding().frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.05)).cornerRadius(10).padding(.horizontal)
                    }

                    // ── 新食物 ──
                    if !newFoods.isEmpty {
                        SectionHeader(title: "新添加食物", color: .btOrange)
                        FlowTagView(tags: newFoods, color: .btOrange).padding(.horizontal)
                    }

                    // ── 导出按钮 ──
                    Button {
                        reportText = generateReport()
                        showShareSheet = true
                    } label: {
                        Label("导出文字报告", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.btPink).foregroundColor(.white).cornerRadius(12)
                    }.padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("数据报告")
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(text: reportText)
            }
        }
    }

    private func generateReport() -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        let babyName = profile?.name ?? "宝宝"
        let age = profile?.ageString ?? ""
        var txt = """
        BabyTrack 喂养报告
        宝宝：\(babyName) (\(age))
        区间：\(df.string(from: startDate)) 至 \(df.string(from: endDate))

        【喂养统计】
        总次数：\(rangeFeedings.count) 次
        """
        if !newFoods.isEmpty {
            txt += "\n新增食物：\(newFoods.joined(separator: "、"))"
        }
        txt += "\n\n【排便统计】\n总次数：\(rangeBowels.count) 次"
        if !bloodDays.isEmpty {
            let days = bloodDays.map { df.string(from: $0) }.joined(separator: ", ")
            txt += "\n⚠️ 有血丝日期：\(days)"
        }
        return txt
    }
}

struct FlowTagView: View {
    let tags: [String]; let color: Color
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
            ForEach(tags, id: \.self) { TagView(text: $0, color: color) }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}