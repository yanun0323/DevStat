import SwiftUI
import SwiftData

#if DEBUG
#Preview {
    TotpView()
        .modelContainer(for: OTP.self, inMemory: true, isAutosaveEnabled: true, isUndoEnabled: true)
        .frame(width: 200, height: 400)
}
#endif

struct TotpView: View {
    @Query(animation: .easeInOut(duration: 0.2)) private var items: [OTP]
    @Environment(\.modelContext) private var context: ModelContext
    @State private var secrete: String = ""
    @State private var timer: Timer? = nil
    @State private var password: String = "-"
    @State private var leftSeconds: Double = 0
    
    var otp: OTP? { items.first }
    
    var body: some View {
        ZStack {
            if let otp = otp {
                Button {
                    copy(password)
                } label: {
                    VStack(spacing: 5) {
                        HStack {
                            Text("OTP")
                                .kerning(1)
                            Spacer()
                        }
                        
                        HStack {
                            Text("\(password)")
                                .font(.system(size: 30, weight: .medium))
                                .monospacedDigit()
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 5)
                                Circle()
                                    .trim(from: 0, to: leftSeconds/29.0)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .butt))
                                    .rotationEffect(.degrees(-90))
                            }
                            .frame(width: 22, alignment: .leading)
                            .padding(.trailing, 4)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.secondary.opacity(0.3))
                    }
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button("Delete", role: .destructive) {
                        context.delete(otp)
                        try? context.save()
                    }
                }
            } else {
                GlassEffectContainer {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("OTP")
                                .kerning(1)
                                .padding(.bottom, 1)
                            Spacer()
                            Button("Create") {
                                if secrete.isEmpty {
                                    return
                                }
                                
                                let sec = secrete
                                secrete = ""
                                context.insert(OTP(secrete: sec))
                                try? context.save()
                            }
                            .disabled(secrete.isEmpty)
                        }
                        
                        TextField("SECRETE", text: $secrete)
                            .textFieldStyle(.plain)
                            .padding(.vertical, 5)
                    }
                }
                .padding(.top, 7)
                .padding(.bottom, 12)
                .padding(.horizontal, 15)
                .glassEffect(
                    .regular.tint(.clear),
                    in: RoundedRectangle(cornerRadius: 15),
                    isEnabled: true,
                )
            }
        }
        .padding(5)
        .glassEffectTransition(.matchedGeometry, isEnabled: true)
        .onAppear {
            if let otp = otp {
                password = genTOTP(otp.secrete)
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
                if let otp = otp {
                    password = genTOTP(otp.secrete)
                }
                var seconds = Calendar.current.component(.second, from: Date())
                if seconds >= 30 { seconds -= 30 }
                withAnimation(leftSeconds.isZero ? .linear(duration: 0) : .linear(duration: 1)) {
                    leftSeconds = Double(29-seconds)
                }
            })
        }
    }
    
    func copy(_ stringToCopy: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(stringToCopy, forType: .string)
    }
}
    
