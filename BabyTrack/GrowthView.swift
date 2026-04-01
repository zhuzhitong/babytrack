import SwiftUI
import SwiftData
import Charts

struct GrowthView: View {
    @Query(sort: \GrowthRecord.date, order: .reverse) private var records: [GrowthRecord]
    @State private var showAdd = false
    @State private var selectedMetric = "体重"

    let metrics = ["体重", "身高", "头围"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // ── 图表 ──
                    Picker("指标", selection: $selectedMetric) {
                        ForEach(metrics, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.segmented).padding(.horizontal)

                    if records.count >= 2 {
                        GrowthChart(records: records.reversed(), metric: selectedMetric)
                            .padding(.horizontal)
                    } else {
                        Text("至少添加2条记录后显示趋势图").font(.caption)
                            .foregroundColor(.secondary).padding()
                    }

                    // ── 最新数据 ──
                    if let latest = records.first {
                        SectionHeader(title: "最新数据", color: .btBlue)
                        HStack(spacing: 12) {
                            StatCard(title: "体重", value: String(format: "%.2f", latest.weightKG),
                                     unit: "kg", color: .btPink, icon: "scalemass.fill")
                            StatCard(title: "身高", value: String(format: "%.1f", latest.heightCM),
                                     unit: "cm", color: .btTeal, icon: "ruler.fill")
                            StatCard(title: "头围", value: String(format: "%.1f", latest.headCM),
                                     unit: "cm", color: .btPurple, icon: "circle.dashed")
                        }.padding(.horizontal)
                    }

                    // ── 历史列表 ──
                    SectionHeader(title: "历史记录", color: .btBlue)
                    ForEach(records) { r in
                        GrowthRow(record: r).padding(.horizontal)
                    }
                }.padding(.vertical)
            }
            .navigationTitle("生长记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill").foregroundColor(.btBlue).font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddGrowthView() }
        }
    }
}

struct GrowthChart: View {
    let records: [GrowthRecord]
    let metric: String

    func value(_ r: GrowthRecord) -> Double {
        switch metric {
        case "体重": return r.weightKG
        case "身高": return r.heightCM
        default:    return r.headCM
        }
    }

    var body: some View {
        Chart(records) { r in
            LineMark(x: .value("日期", r.date), y: .value(metric, value(r)))
                .foregroundStyle(Color.btPink)
            PointMark(x: .value("日期", r.date), y: .value(metric, value(r)))
                .foregroundStyle(Color.btPink)
        }
        .frame(height: 180)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct GrowthRow: View {
    let record: GrowthRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(record.date.dateString).font(.caption).foregroundColor(.secondary)
            HStack(spacing: 16) {
                Label(String(format: "%.2fkg", record.weightKG), systemImage: "scalemass.fill")
                    .font(.subheadline)
                Label(String(format: "%.1fcm", record.heightCM), systemImage: "ruler.fill")
                    .font(.subheadline)
                Label(String(format: "%.1fcm", record.headCM), systemImage: "circle.dashed")
                    .font(.subheadline)
            }
            if !record.specialNote.isEmpty {
                Text("特殊: \(record.specialNote)").font(.caption).foregroundColor(.btOrange)
            }
        }
        .padding(12).background(Color(.systemBackground)).cornerRadius(10)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct AddGrowthView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var weight = ""
    @State private var height = ""
    @State private var head = ""
    @State private var specialNote = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("日期") {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                }
                Section("体格测量") {
                    TextField("体重（kg）", text: $weight).keyboardType(.decimalPad)
                    TextField("身高/身长（cm）", text: $height).keyboardType(.decimalPad)
                    TextField("头围（cm）", text: $head).keyboardType(.decimalPad)
                }
                Section("特殊情况记录") {
                    TextField("过敏反应、就诊记录等", text: $specialNote, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("添加生长记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }.foregroundColor(.btBlue)
                }
            }
        }
    }

    private func save() {
        let r = GrowthRecord(date: date,
                              weightKG: Double(weight) ?? 0,
                              heightCM: Double(height) ?? 0,
                              headCM: Double(head) ?? 0,
                              specialNote: specialNote)
        ctx.insert(r)
        dismiss()
    }
}