import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var profiles: [BabyProfile]
    @Environment(\.modelContext) private var ctx
    @State private var showEdit = false

    var body: some View {
        Form {
            if let p = profiles.first {
                Section("宝宝信息") {
                    InfoRow(label: "姓名", value: p.name)
                    InfoRow(label: "性别", value: p.gender)
                    InfoRow(label: "月龄", value: p.ageString)
                    if !p.allergyNotes.isEmpty {
                        InfoRow(label: "忌口", value: p.allergyNotes)
                    }
                    if !p.doctorName.isEmpty {
                        InfoRow(label: "医生", value: p.doctorName)
                    }
                    Button("编辑宝宝信息") { showEdit = true }
                        .foregroundColor(.btPink)
                }
            }

            Section("使用说明") {
                Label("每次喂养后及时记录", systemImage: "checkmark.circle")
                Label("排便有血丝请务必标记", systemImage: "exclamationmark.circle")
                Label("新食物添加后观察24-48小时", systemImage: "clock.circle")
                Label("每周导出报告供医生参考", systemImage: "doc.circle")
            }.font(.footnote)

            Section("关于") {
                HStack { Text("版本"); Spacer(); Text("1.0.0").foregroundColor(.secondary) }
                HStack { Text("适用系统"); Spacer(); Text("iOS 17.0+").foregroundColor(.secondary) }
            }
        }
        .navigationTitle("设置")
        .sheet(isPresented: $showEdit) {
            if let p = profiles.first { EditProfileView(profile: p) }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    let profile: BabyProfile

    @State private var name: String
    @State private var birthDate: Date
    @State private var allergyNotes: String
    @State private var doctorName: String

    init(profile: BabyProfile) {
        self.profile = profile
        _name = State(initialValue: profile.name)
        _birthDate = State(initialValue: profile.birthDate)
        _allergyNotes = State(initialValue: profile.allergyNotes)
        _doctorName = State(initialValue: profile.doctorName)
    }

    /// 根据所选出生日期实时计算月龄预览
    private var agePreview: String {
        let c = Calendar.current.dateComponents([.month, .day], from: birthDate, to: Date())
        let m = c.month ?? 0, d = c.day ?? 0
        return m > 0 ? "\(m)个月\(d)天" : "\(d)天"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("姓名", text: $name)
                }

                Section("出生日期 / 月龄") {
                    DatePicker("出生日期", selection: $birthDate, in: ...Date(),
                               displayedComponents: .date)
                    HStack {
                        Text("当前月龄").foregroundColor(.secondary)
                        Spacer()
                        Text(agePreview)
                            .foregroundColor(.btPink)
                            .fontWeight(.medium)
                    }
                }

                Section("忌口/过敏食物") {
                    TextField("如：牛奶蛋白、花生", text: $allergyNotes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section("主治医生") {
                    TextField("医生姓名", text: $doctorName)
                }
            }
            .navigationTitle("编辑信息")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        profile.name = name
                        profile.birthDate = birthDate
                        profile.allergyNotes = allergyNotes
                        profile.doctorName = doctorName
                        dismiss()
                    }.foregroundColor(.btPink)
                }
            }
        }
    }
}