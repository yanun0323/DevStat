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
    @State private var timeDigit: TimeDigit = .second
    @State private var stringInput: String = Date.now.string(Self.stringInputFormat)
    @State private var unixInput: String = Date.now.unixString(.second, "")
    
    @State private var milli = Date.now.unixMilli
    @State private var timezoneTag = Date.now.string("ZZZZ")
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                timezonePicker()
                timeDigitPicker()
                dateTransfer()
            }
            .padding(5)
            
            Spacer()
            
            if #available(macOS 14.0, *) {
                EmptyView()
                    .onChange(of: unixInput, initial: false) { _, _ in handleUnix2All() }
                    .onChange(of: stringInput, initial: false) { _, _ in handleString2All() }
                    .onChange(of: timeDigit, initial: false) { _, _ in refreshTime() }
                    .onChange(of: timezone, initial: false) { _, _ in refreshTimezone() }
            } else {
                EmptyView()
                    .onChange(of: unixInput) { _ in handleUnix2All() }
                    .onChange(of: stringInput) { _ in handleString2All() }
                    .onChange(of: timeDigit) { _ in refreshTime() }
                    .onChange(of: timezone) { _ in refreshTimezone() }
            }
        }
        .scrollIndicators(.never)
        .onAppear {
            container.inter.system.fetchTimezone()
            container.inter.system.fetchTimeDigit()
        }
        .onReceive(container.state.timezone) { tz in
            withAnimation { timezone = tz }
        }
        .onReceive(container.state.timeDigit) { td in
            withAnimation { timeDigit = td }
        }
        .hotkey(key: .kVK_Return) {
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
//            Text("時區")
            
            Button {
                container.inter.system.setTimezone(.current)
            } label: {
                Text("Current")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .frame(width: 60, height: 20)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(radius: 10)
            .disabled(isCurrentTimezone(.current))
            
            Button {
                container.inter.system.setTimezone(.UTC)
            } label: {
                Text("UTC")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .frame(width: 40, height: 20)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(radius: 10)
            .disabled(isCurrentTimezone(.UTC))
            
            Menu {
                Picker(selection: Binding {
                    return timezone
                } set: {
                    container.inter.system.setTimezone($0)
                }) {
                    ForEach(TimeZone.timezones) { tz in
                        Text(Date.now.string("ZZZZ", timezone: tz))
                            .tag(tz)
                    }
                } label: {}
                    .pickerStyle(.inline)
            } label: {
                Text(timezoneTag)
            }
        }
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private func timeDigitPicker() -> some View {
        HStack {
            Text("時間單位")
            Menu {
                Picker(selection: Binding {
                    return timeDigit
                } set: {
                    container.inter.system.setTimeDigit($0)
                }) {
                    ForEach(TimeDigit.allCases) { td in
                        Text(td.rawValue)
                            .tag(td)
                    }
                } label: {}
                    .pickerStyle(.inline)
            } label: {
                Text(timeDigit.rawValue)
            }
        }
        .padding(.horizontal, 10)
        
    }
    
    @ViewBuilder
    private func dateTransfer() -> some View {
        HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        textField("1679534610", text: $unixInput)
                            .focused($focus, equals: .unix)
                        
                        Button {
                            refreshTime()
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
    
    func refreshTime() {
        milli = Date.now.unixMilli
        milliToAll()
    }
    
    func milliToAll() {
        let d = Date(milli, .millisecond)
        unixInput = d.unixString(timeDigit, unixInput)
        stringInput = d.string(Self.stringInputFormat, timezone: timezone)
    }
    
    func refreshTimezone() {
        timezoneTag = Date.now.string("ZZZZ", timezone: timezone)
        unix2All(force: true)
        
    }
    
    func handleString2All() {
        if focus != .string { return }
        string2All()
    }
    
    func string2All() {
        if stringInput.isEmpty {
            return
        }
        
        guard let d = Date(from: stringInput, Self.stringInputFormat, .us, timezone) else {
            unixInput = ""
            return
        }
        
        if d.unix == milli.milliToSecond(.millisecond) {
            return
        }
        
        milli = d.unixMilli
        unixInput = d.unixString(timeDigit, unixInput)
    }
    
    func handleUnix2All() {
        if focus != .unix { return }
        unix2All()
    }
    
    func unix2All(force: Bool = false) {
        if  unixInput.isEmpty {
            return
        }
        
        guard let unix = Int64(unixInput) else {
            stringInput = ""
            return
        }
        
        if !force && unix == milli {
            return
        }
        
        let d = Date(unix, timeDigit)
        milli = d.unixMilli
        stringInput = d.string(Self.stringInputFormat, timezone: timezone)
    }
    
    func isCurrentTimezone(_ target: TimeZone) -> Bool {
        let d = Date()
        return d.string("ZZZZ", timezone: target)  == d.string("ZZZZ", timezone: timezone)
    }
}

fileprivate extension TimeZone {
    static let UTC: TimeZone = TimeZone(identifier: "Europe/Dublin")!
}

fileprivate extension Date {
    init(_ unix: Int64, _ d: TimeDigit) {
        self = .init(timeIntervalSince1970: unix.timeInterval(d))
    }
    
    func unixString(_ d: TimeDigit, _ origin: String) -> String {
        switch d {
            case .second:
                return self.unix.description
            case .millisecond:
                return self.unixMilli.description
            case .autoDetect:
                return origin.count >= 13 ? self.unixMilli.description : self.unix.description
        }
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
