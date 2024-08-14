import SwiftUI

extension Color {
//    static let blood = Color("Blood")
//    static let background = Color("Background")
//    static let background2 = Color("Background2")
    static let link = Color.blue
//    static let dark = Color("Dark")
    static let clean = Color.black.opacity(0.0101)
    static let main: [Color] = [.blue, .glue]
    static let glue = Color(red: 0, green: 0.5, blue: 1)
}

extension Color {
    // primary
    public static let primaryFull: Self = .primary
    public static let primaryHalf: Self = .primary.opacity(0.5)
    public static let primaryQuarter: Self = .primary.opacity(0.25)
    
    // white
    public static let transparent: Self = .white.opacity(0.1).opacity(0.0101)
    
    // black
    public static let shadow: Self = .black.opacity(0.3)
    public static let stone: Self = .black.opacity(0.2)
    public static let section: Self = .black.opacity(0.1)
}
