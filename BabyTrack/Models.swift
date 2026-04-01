import Foundation
import SwiftData

// MARK: - BabyProfile
@Model final class BabyProfile {
    var id: UUID
    var name: String
    var birthDate: Date
    var gender: String          // "男" / "女"
    var allergyNotes: String    // 忌口/过敏食物
    var doctorName: String
    var createdAt: Date

    init(name: String, birthDate: Date, gender: String,
         allergyNotes: String = "", doctorName: String = "") {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.allergyNotes = allergyNotes
        self.doctorName = doctorName
        self.createdAt = Date()
    }

    var ageString: String {
        let c = Calendar.current.dateComponents([.month, .day], from: birthDate, to: Date())
        let m = c.month ?? 0, d = c.day ?? 0
        return m > 0 ? "\(m)个月\(d)天" : "\(d)天"
    }
}

// MARK: - FeedingRecord
@Model final class FeedingRecord {
    var id: UUID
    var date: Date
    var time: Date
    var feedingType: String     // "母乳" / "配方奶" / "混合"
    var amountML: Double        // 毫升 (配方/混合)
    var durationMin: Int        // 分钟 (母乳)
    var newFood: String         // 新增辅食
    var reaction: String        // 反应观察
    var notes: String
    var createdAt: Date

    init(date: Date, time: Date, feedingType: String,
         amountML: Double = 0, durationMin: Int = 0,
         newFood: String = "", reaction: String = "", notes: String = "") {
        self.id = UUID()
        self.date = date; self.time = time
        self.feedingType = feedingType
        self.amountML = amountML; self.durationMin = durationMin
        self.newFood = newFood; self.reaction = reaction
        self.notes = notes; self.createdAt = Date()
    }

    var summary: String {
        switch feedingType {
        case "母乳": return "母乳 \(durationMin)min"
        default:    return "\(feedingType) \(Int(amountML))ml"
        }
    }
}

// MARK: - BowelRecord
@Model final class BowelRecord {
    var id: UUID
    var date: Date
    var time: Date
    var color: String           // "黄色"/"绿色"/"棕色"/"黑色"/"其他"
    var texture: String         // "稀水样"/"糊状"/"软"/"正常"/"硬"
    var amount: String          // "少量"/"中量"/"大量"
    var hasBloodStreak: Bool
    var hasMucus: Bool
    var notes: String
    var createdAt: Date

    init(date: Date, time: Date, color: String, texture: String,
         amount: String = "中量", hasBloodStreak: Bool = false,
         hasMucus: Bool = false, notes: String = "") {
        self.id = UUID()
        self.date = date; self.time = time
        self.color = color; self.texture = texture; self.amount = amount
        self.hasBloodStreak = hasBloodStreak; self.hasMucus = hasMucus
        self.notes = notes; self.createdAt = Date()
    }
}

// MARK: - SupplementRecord
@Model final class SupplementRecord {
    var id: UUID
    var date: Date
    var name: String            // "维生素D"/"益生菌"/"铁剂"
    var amount: String
    var unit: String            // "IU"/"滴"/"mg"/"g"
    var brand: String
    var notes: String
    var createdAt: Date

    init(date: Date, name: String, amount: String,
         unit: String, brand: String = "", notes: String = "") {
        self.id = UUID()
        self.date = date; self.name = name
        self.amount = amount; self.unit = unit
        self.brand = brand; self.notes = notes; self.createdAt = Date()
    }
}

// MARK: - GrowthRecord
@Model final class GrowthRecord {
    var id: UUID
    var date: Date
    var weightKG: Double
    var heightCM: Double
    var headCM: Double
    var specialNote: String     // 特殊情况
    var createdAt: Date

    init(date: Date, weightKG: Double = 0, heightCM: Double = 0,
         headCM: Double = 0, specialNote: String = "") {
        self.id = UUID()
        self.date = date
        self.weightKG = weightKG; self.heightCM = heightCM; self.headCM = headCM
        self.specialNote = specialNote; self.createdAt = Date()
    }
}