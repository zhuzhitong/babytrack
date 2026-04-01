import SwiftUI

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a,r,g,b) = (255,(int>>8)*17,(int>>4&0xF)*17,(int&0xF)*17)
        case 6: (a,r,g,b) = (255,int>>16,int>>8&0xFF,int&0xFF)
        case 8: (a,r,g,b) = (int>>24,int>>16&0xFF,int>>8&0xFF,int&0xFF)
        default:(a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red:Double(r)/255, green:Double(g)/255, blue:Double(b)/255, opacity:Double(a)/255)
    }
}

// MARK: - Brand Colors
extension Color {
    static let btPink   = Color(hex: "F48FB1")
    static let btTeal   = Color(hex: "00838F")
    static let btPurple = Color(hex: "7B1FA2")
    static let btOrange = Color(hex: "E65100")
    static let btBlue   = Color(hex: "1565C0")
    static let btBg     = Color(hex: "FFF8FA")
}

// MARK: - Date Helpers
extension Date {
    var dateString: String {
        let f = DateFormatter(); f.dateFormat = "M月d日 (EEE)"; f.locale = Locale(identifier: "zh_CN")
        return f.string(from: self)
    }
    var timeString: String {
        let f = DateFormatter(); f.timeStyle = .short
        return f.string(from: self)
    }
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}

// MARK: - Reusable Components

struct StatCard: View {
    let title: String; let value: String; let unit: String
    let color: Color; let icon: String
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(color).font(.title3)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value).font(.title2).fontWeight(.bold).foregroundColor(color)
                Text(unit).font(.caption).foregroundColor(.secondary)
            }
            Text(title).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(12)
        .background(color.opacity(0.1)).cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String; let color: Color
    var body: some View {
        Text(title).font(.headline).foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

struct InfoRow: View {
    let label: String; let value: String
    var body: some View {
        HStack {
            Text(label).foregroundColor(.secondary).frame(width: 80, alignment: .leading)
            Text(value).fontWeight(.medium)
            Spacer()
        }
    }
}

struct TagView: View {
    let text: String; let color: Color
    var body: some View {
        Text(text).font(.caption2).padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15)).foregroundColor(color).cornerRadius(8)
    }
}

struct AlertBanner: View {
    let message: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
            Text(message).font(.footnote).foregroundColor(.primary)
            Spacer()
        }
        .padding(12).background(Color.orange.opacity(0.1)).cornerRadius(10)
        .padding(.horizontal)
    }
}

struct EmptyStateView: View {
    let icon: String; let title: String; let subtitle: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 48)).foregroundColor(.secondary)
            Text(title).font(.headline).foregroundColor(.secondary)
            Text(subtitle).font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .padding(40).frame(maxWidth: .infinity)
    }
}