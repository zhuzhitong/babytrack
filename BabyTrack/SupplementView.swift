import SwiftUI
import SwiftData

struct SupplementView: View {
    @Query(sort: \SupplementRecord.date, order: .reverse) private var records: [SupplementRecord]
    @State private var showAdd = false
    @State private var selectedDate = Date()

    private var filtered: [SupplementRecord] {
        records.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("日期", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact).padding(.horizontal).labelsHidden()

                if filtered.isEmpty {
                    EmptyStateView(icon: "pills", title: "暂无补充剂记录",
                                   subtitle: "点击＋记录维生素D、益生菌等")
                } else {
                    List {
                        ForEach(filtered) { r in SupplementRow(record: r) }
                    }.listStyle(.insetGrouped)
                }
            }
            .navigationTitle("补充剂记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill").foregroundColor(.btPurple).font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddSupplementView(date: selectedDate) }
        }
    }
}

struct SupplementRow: View {
    let record: SupplementRecord
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "pills.fill").foregroundColor(.btPurple).font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(record.name).font(.subheadline).fontWeight(.medium)
                Text("\(record.amount)\(record.unit)\(record.brand.isEmpty ? "" : " · \(record.brand)")")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }.padding(.vertical, 4)
    }
}

struct AddSupplementView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    let date: Date

    @State private var name = "维生素D"
    @State private var amount = ""
    @State private var unit = "IU"
    @State private var brand = ""
    @State private var notes = ""
    @State private var customName = ""

    let presets = ["维生素D", "益生菌", "铁剂", "钙剂", "DHA", "其他"]
    let units = ["IU", "滴", "mg", "g", "ml", "粒"]

    var body: some View {
        NavigationStack {
            Form {
                Section("补充剂名称") {
                    Picker("名称", selection: $name) {
                        ForEach(presets, id: \.self) { Text($0).tag($0) }
                    }
                    if name == "其他" {
                        TextField("请输入名称", text: $customName)
                    }
                }
                Section("用量") {
                    HStack {
                        TextField("数量", text: $amount).keyboardType(.decimalPad)
                        Picker("单位", selection: $unit) {
                            ForEach(units, id: \.self) { Text($0).tag($0) }
                        }.pickerStyle(.menu)
                    }
                }
                Section("品牌（选填）") {
                    TextField("品牌名称", text: $brand)
                }
                Section("备注") {
                    TextField("备注", text: $notes, axis: .vertical).lineLimit(2, reservesSpace: true)
                }
            }
            .navigationTitle("添加补充剂")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }.foregroundColor(.btPurple)
                }
            }
        }
    }

    private func save() {
        let finalName = name == "其他" ? customName : name
        let r = SupplementRecord(date: date, name: finalName,
                                  amount: amount, unit: unit, brand: brand, notes: notes)
        ctx.insert(r)
        dismiss()
    }
}