import SwiftUI
import SwiftData

struct SetupView: View {
    @Environment(\.modelContext) private var ctx
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var gender = "女"
    @State private var allergyNotes = ""
    @State private var doctorName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 60)).foregroundColor(.btPink)
                            Text("BabyTrack").font(.title).fontWeight(.bold)
                            Text("过敏宝宝喂养记录").foregroundColor(.secondary)
                        }
                        Spacer()
                    }.listRowBackground(Color.clear)
                }

                Section("宝宝信息") {
                    TextField("宝宝姓名", text: $name)
                    DatePicker("出生日期", selection: $birthDate, displayedComponents: .date)
                    Picker("性别", selection: $gender) {
                        Text("女").tag("女")
                        Text("男").tag("男")
                    }.pickerStyle(.segmented)
                }

                Section("医疗信息") {
                    TextField("过敏/忌口食物（如：牛奶、鸡蛋）", text: $allergyNotes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                    TextField("主治医生（选填）", text: $doctorName)
                }

                Section {
                    Button(action: save) {
                        Text("开始记录").frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.btPink)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("宝宝信息设置")
        }
    }

    private func save() {
        let profile = BabyProfile(name: name.trimmingCharacters(in: .whitespaces),
                                   birthDate: birthDate, gender: gender,
                                   allergyNotes: allergyNotes, doctorName: doctorName)
        ctx.insert(profile)
    }
}