//
//  Bito.swift
//  Bito Pro Secret
//
//  Created by YanunYang on 2022/7/13.
//

import SwiftUI

enum FocusField: Hashable {
    case date, string, unix, cron, emIDEncode, emIDDecode, imIDEncode, imIDDecode, orderIDEncode, orderIDDecode, orderTypeDecode
}

struct TimestampView: View {
    @Environment(\.injected) private var container
    @Environment(\.openURL) private var openURL
    @FocusState private var focus: FocusField?
    private let block: CGFloat = 10
    private let textFieldHeight: CGFloat = 25
    
    // MARK: Date Transfer
    private static let stringInputFormat = "yyyy-MM-dd HH:mm:ss ZZ"
    private static let tempDateFormat: String = "yyyy-MM-dd HH:mm:ss"
    @State private var timezone: TimeZone = .current
    @State private var stringInput: String = Date.now.string(Self.stringInputFormat)
    @State private var unixInput: String = Date.now.unix.description
    
    @State private var yearInput: String = Date.now.string("yyyy")
    @State private var monthInput: String = Date.now.string("MM")
    @State private var dayInput: String = Date.now.string("dd")
    @State private var hourInput: String = Date.now.string("HH")
    @State private var minuteInput: String = Date.now.string("mm")
    @State private var secondInput: String = Date.now.string("ss")
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                timezonePicker()
                dateTransfer()
            }
            .padding(5)
            Spacer()
        }
        .scrollIndicators(.never)
        .onAppear {
            container.inter.system.fetchTimezone()
        }
        .onReceive(container.state.timezone) { tz in
            withAnimation { timezone = tz }
        }
        .hotkey(key: .kVK_Return) {
            handleDate2All()
            handleUnix2All()
            handleString2All()
        }
    }

    @ViewBuilder
    func textField(_ titleKey: LocalizedStringKey, text: Binding<String>) -> some View {
        TextField(titleKey, text: text)
            .frame(height: textFieldHeight)
            .padding(.horizontal, 7)
            .background(Color.background2, ignoresSafeAreaEdges: [])
            .cornerRadius(7)
    }
    
    @ViewBuilder
    private func timezonePicker() -> some View {
        HStack {
            Text("預設時區")
            Menu {
                Picker(selection: Binding {
                    return timezone
                } set: {
                    container.inter.system.setTimezone($0)
                }) {
                    ForEach(TimeZone.timezones) { tz in
                        Text("\(Date.now.string("ZZZZ", timezone: tz))")
                            .tag(tz)
                    }
                } label: {}
                    .pickerStyle(.inline)
            } label: {
                Text("\(Date.now.string("ZZZZ", timezone: timezone))")
            }
        }
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private func dateTransfer() -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
//                HStack(spacing: 10) {
//                    let symbolColor: Color = .primary.opacity(0.8)
//                    HStack(spacing: 2)  {
//                        dateTextField($yearInput, "2023", digit: 4, max: 9999)
//                        Text("-").foregroundColor(symbolColor)
//                        dateTextField($monthInput, "03", max: 12)
//                        Text("-").foregroundColor(symbolColor)
//                        dateTextField($dayInput, "23", max: 31)
//                    }
//                    HStack(spacing: 2) {
//                        dateTextField($hourInput, "09", max: 24)
//                        Text(":").foregroundColor(symbolColor)
//                        dateTextField($minuteInput, "23")
//                        Text(":").foregroundColor(symbolColor)
//                        dateTextField($secondInput, "30")
//                    }
//                }
//                .frame(height: 35, alignment: .leading)
                
                HStack {
                    textField("1679534610", text: $unixInput)
                        .focused($focus, equals: .unix)
                    
                    Button {
                        unixInput = Date.now.unix.description
                        unix2All()
                    } label: {
                        Text("Now")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 60, height: 25)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .shadow(radius: 10)
                }
                .frame(width: 219, height: 35)
                
                
                HStack {
                    textField("2023-03-23 09:23:30 +0800", text: $stringInput)
                        .focused($focus, equals: .string)
                }
                .frame(width: 219, height: 35)
                
            }
            .textFieldStyle(.plain)
        }
        .onChange(of: yearInput, initial: false) { _, _ in handleDate2All() }
        .onChange(of: monthInput, initial: false) { _, _ in handleDate2All() }
        .onChange(of: dayInput, initial: false) { _, _ in handleDate2All() }
        .onChange(of: hourInput, initial: false) { _, _ in handleDate2All() }
        .onChange(of: minuteInput, initial: false) { _, _ in handleDate2All() }
        .onChange(of: secondInput, initial: false) { _, _ in handleDate2All() }
        .onChange(of: unixInput, initial: false) { _, _ in handleUnix2All() }
        .onChange(of: stringInput, initial: false) { _, _ in handleString2All() }
        .onChange(of: timezone, initial: false) { _, _ in unix2All() }
    }
    
    @ViewBuilder
    private func dateTextField(_ text: Binding<String>, _ title: String, digit: Int = 2, max: Int = 60) -> some View {
        TextField(title, text: limitation(text, limit: digit, max: max))
            .focused($focus, equals: .date)
            .frame(width: CGFloat(digit*8), height: textFieldHeight, alignment: .center)
            .padding(.horizontal, 5)
            .background(Color.background2, ignoresSafeAreaEdges: [])
            .cornerRadius(7)
    }
}

extension TimestampView {
    func limitation(_ text: Binding<String>, limit: Int, max: Int) -> Binding<String> {
        return Binding {
            return text.wrappedValue
        } set: { value in
            if value.count > limit {
                text.wrappedValue = max.description
                return
            }
            if value.count != 0 {
                guard let int = Int(value) else {
                    let temp = text.wrappedValue
                    text.wrappedValue = temp
                    return
                }
                if int > max {
                    text.wrappedValue = max.description
                    return
                }
            }
            text.wrappedValue = value
        }

    }
    
    func handleDate2All() {
        if focus != .date { return }
        #if DEBUG
        print("date invoke - \(Date.now.unix)")
        #endif
        date2All()
    }
    
    func date2All() {
        let temp = "\(yearInput)-\(monthInput)-\(dayInput) \(hourInput):\(minuteInput):\(secondInput)"
        guard let date = Date(from: temp, Self.tempDateFormat, .us, timezone) else {
            unixInput = ""
            stringInput = ""
            return
        }
        unixInput = date.unix.description
        stringInput = date.string(Self.stringInputFormat, timezone: timezone)
    }
    
    func handleString2All() {
        if focus != .string { return }
        #if DEBUG
        print("string invoke - \(Date.now.unix)")
        #endif
        string2All()
    }
    
    func string2All() {
        guard let d = Date(from: stringInput, Self.stringInputFormat, .us, timezone) else {
            unixInput = ""
            yearInput = ""
            monthInput = ""
            dayInput = ""
            hourInput = ""
            minuteInput = ""
            secondInput = ""
            return
        }
        
        unixInput = d.unix.description
        yearInput = d.string("yyyy", timezone: timezone)
        monthInput = d.string("MM", timezone: timezone)
        dayInput = d.string("dd", timezone: timezone)
        hourInput = d.string("HH", timezone: timezone)
        minuteInput = d.string("mm", timezone: timezone)
        secondInput = d.string("ss", timezone: timezone)
    }
    
    func handleUnix2All() {
        if focus != .unix { return }
        #if DEBUG
        print("unix invoke - \(Date.now.unix)")
        #endif
        unix2All()
    }
    
    func unix2All() {
        guard let unix = Int(unixInput) else {
            yearInput = ""
            monthInput = ""
            dayInput = ""
            hourInput = ""
            minuteInput = ""
            secondInput = ""
            stringInput = ""
            return
        }
        let d = Date.init(timeIntervalSince1970: 0).addingTimeInterval(.init(unix))
        stringInput = d.string(Self.stringInputFormat, timezone: timezone)
        yearInput = d.string("yyyy", timezone: timezone)
        monthInput = d.string("MM", timezone: timezone)
        dayInput = d.string("dd", timezone: timezone)
        hourInput = d.string("HH", timezone: timezone)
        minuteInput = d.string("mm", timezone: timezone)
        secondInput = d.string("ss", timezone: timezone)
    }
}


#if DEBUG
#Preview {
    TimestampView()
        .padding()
        .inject(.inMemory)
        .frame(width: 250, height: 250)
}
#endif
