import SwiftUI
import SwiftData

struct FeedingView: View {
    @Query(sort: \FeedingRecord.time, order: .reverse) private var records: [FeedingRecord]
    @State private var showAdd = false
    @State private var selectedDate = Date()

    private var filtered: [FeedingRecord] {
        records.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("日期", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact).padding(.horizontal)
                    .labelsHidden()

                if filtered.isEmpty {
                    EmptyStateView(icon: "drop", title: "暂无喂养记录",
                                   subtitle: "点击右上角＋添加今日喂养记录")
                } else {
                    List {
                        ForEach(filtered) { r in
                            FeedingRow(record: r)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("喂养记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill").foregroundColor(.btPink).font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddFeedingView(date: selectedDate) }
        }
    }
}

struct FeedingRow: View {
    let record: FeedingRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TagView(text: record.feedingType, color: .btPink)
                Spacer()
                Text(record.time.timeString).font(.caption).foregroundColor(.secondary)
            }
            Text(record.summary).font(.subheadline).fontWeight(.medium)
            if !record.newFood.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles").foregroundColor(.btOrange)
                    Text("新食物: \(record.newFood)").font(.caption).foregroundColor(.btOrange)
                }
            }
            if !record.reaction.isEmpty {
                Text("反应: \(record.reaction)").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddFeedingView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    let date: Date

    @State private var time = Date()
    @State private var type = "母乳"
    @State private var amountML = ""
    @State private var durationMin = ""
    @State private var newFood = ""
    @State private var reaction = ""
    @State private var notes = ""

    let feedingTypes = ["母乳", "配方奶", "混合"]

    var body: some View {
        NavigationStack {
            Form {
                Section("喂养方式") {
                    Picker("类型", selection: $type) {
                        ForEach(feedingTypes, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.segmented)
                    DatePicker("时间", selection: $time, displayedComponents: .hourAndMinute)
                }

                Section("用量") {
                    if type == "母乳" {
                        TextField("哺乳时长（分钟）", text: $durationMin).keyboardType(.numberPad)
                    } else {
                        TextField("奶量（ml）", text: $amountML).keyboardType(.decimalPad)
                    }
                }

                Section("辅食添加（如有）") {
                    TextField("新添加食物名称", text: $newFood)
                    TextField("宝宝反应观察", text: $reaction, axis: .vertical).lineLimit(2, reservesSpace: true)
                }

                Section("备注") {
                    TextField("其他备注", text: $notes, axis: .vertical).lineLimit(2, reservesSpace: true)
                }
            }
            .navigationTitle("添加喂养记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }.foregroundColor(.btPink)
                }
            }
        }
    }

    private func save() {
        let ml = Double(amountML) ?? 0
        let dur = Int(durationMin) ?? 0
        let r = FeedingRecord(date: date, time: time, feedingType: type,
                               amountML: ml, durationMin: dur,
                               newFood: newFood, reaction: reaction, notes: notes)
        ctx.insert(r)
        dismiss()
    }
}