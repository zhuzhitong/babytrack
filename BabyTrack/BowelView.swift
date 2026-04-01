import SwiftUI
import SwiftData

struct BowelView: View {
    @Query(sort: \BowelRecord.time, order: .reverse) private var records: [BowelRecord]
    @State private var showAdd = false
    @State private var selectedDate = Date()

    private var filtered: [BowelRecord] {
        records.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("日期", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact).padding(.horizontal).labelsHidden()

                if filtered.isEmpty {
                    EmptyStateView(icon: "waveform.path.ecg", title: "暂无排便记录",
                                   subtitle: "点击右上角＋添加记录")
                } else {
                    List {
                        ForEach(filtered) { r in BowelRow(record: r) }
                    }.listStyle(.insetGrouped)
                }
            }
            .navigationTitle("排便记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill").foregroundColor(.btTeal).font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddBowelView(date: selectedDate) }
        }
    }
}

struct BowelRow: View {
    let record: BowelRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TagView(text: record.color, color: .btTeal)
                TagView(text: record.texture, color: .btBlue)
                Spacer()
                Text(record.time.timeString).font(.caption).foregroundColor(.secondary)
            }
            HStack(spacing: 8) {
                Text("量: \(record.amount)").font(.caption)
                if record.hasBloodStreak { TagView(text: "⚠️ 血丝", color: .red) }
                if record.hasMucus { TagView(text: "黏液", color: .btOrange) }
            }
            if !record.notes.isEmpty {
                Text(record.notes).font(.caption).foregroundColor(.secondary)
            }
        }.padding(.vertical, 4)
    }
}

struct AddBowelView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    let date: Date

    @State private var time = Date()
    @State private var color = "黄色"
    @State private var texture = "糊状"
    @State private var amount = "中量"
    @State private var hasBloodStreak = false
    @State private var hasMucus = false
    @State private var notes = ""

    let colors = ["黄色", "绿色", "棕色", "黑色", "其他"]
    let textures = ["稀水样", "糊状", "软", "正常", "硬"]
    let amounts = ["少量", "中量", "大量"]

    var body: some View {
        NavigationStack {
            Form {
                Section("时间") {
                    DatePicker("时间", selection: $time, displayedComponents: .hourAndMinute)
                }
                Section("颜色") {
                    Picker("颜色", selection: $color) {
                        ForEach(colors, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section("性状") {
                    Picker("性状", selection: $texture) {
                        ForEach(textures, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section("量") {
                    Picker("量", selection: $amount) {
                        ForEach(amounts, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section("异常情况") {
                    Toggle("有血丝", isOn: $hasBloodStreak).tint(.red)
                    Toggle("有黏液", isOn: $hasMucus).tint(.btOrange)
                }
                Section("备注") {
                    TextField("备注", text: $notes, axis: .vertical).lineLimit(2, reservesSpace: true)
                }
            }
            .navigationTitle("添加排便记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }.foregroundColor(.btTeal)
                }
            }
        }
    }

    private func save() {
        let r = BowelRecord(date: date, time: time, color: color, texture: texture,
                             amount: amount, hasBloodStreak: hasBloodStreak,
                             hasMucus: hasMucus, notes: notes)
        ctx.insert(r)
        dismiss()
    }
}