import SwiftUI
import SwiftData

struct TotpTabView: View {
    @Query(sort: \OTP.createdAt, animation: .easeInOut(duration: 0.2)) private var items: [OTP]
    @Environment(\.modelContext) private var context: ModelContext
    @AppStorage("OTP_CURRENT_IDX") private var index: Int?
    @State private var isHoveredIndex: Bool = false
    private let gap: CGFloat = 5
    
    var body: some View {
        GeometryReader { container in
            VStack {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        HStack(spacing: gap) {
                            ForEach(items.indices, id: \.self) { i in
                                TotpView(otp: items[i])
                                    .frame(width: container.size.width - gap*2)
                                    .safeAreaPadding(.horizontal, gap)
                                    .id(i)
                            }
                            
                            TotpCreateView()
                                .frame(width: container.size.width - gap*2)
                                .safeAreaPadding(.horizontal, gap)
                                .id(-1)
                                .onAppear {
                                    print("init index: \(index?.description ?? "nil")")
                                    withAnimation {
                                        if items.isEmpty {
                                            proxy.scrollTo(-1)
                                            index = -1
                                            return
                                        }
                                        
                                        guard let idx = index else {
                                            proxy.scrollTo(0)
                                            index = 0
                                            return
                                        }
                                        
                                        if idx == -1 {
                                            proxy.scrollTo(-1)
                                            return
                                        }
                                        
                                        let toIdx = items.count >= idx ? index : 0
                                        proxy.scrollTo(toIdx)
                                        index = toIdx
                                    }
                                }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $index)
                    .scrollIndicators(.never)
                    .scrollTargetBehavior(.viewAligned)
                    .onChange(of: items.count) {
                        withAnimation {
                            let toIdx = items.isEmpty ? -1 : items.count-1
                            proxy.scrollTo(toIdx)
                            index = toIdx
                        }
                    }
                    .onChange(of: index, initial: true) { oldValue, newValue in
                        print("scroll from \(oldValue?.description ?? "nil") to \(newValue?.description ?? "nil")")
                    }
                    .animation(.default, value: index)
                }
                
                
                HStack(spacing: 5) {
                    ForEach(items.indices, id: \.self) { i in
                        Button {
                            if index == i { return }
                            withAnimation {
                                index = i
                            }
                        } label: {
                            Capsule()
                                .frame(width: index == i ? 7 : 21, height: 7)
                                .opacity(index == i ? 0.9 : 0.2)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    
                    Button {
                        if index == -1 { return }
                        withAnimation {
                            index = -1
                        }
                    } label: {
                        Capsule()
                            .frame(width: index == -1 ? 7 : 21, height: 7)
                            .opacity(index == -1 ? 0.9 : 0.2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 5)
        }
        .frame(height: 100)
    }
}

#if DEBUG
#Preview {
    VStack {
        TotpTabView()
        
        ZStack {
            TotpCreateView().opacity(0.3)
        }
    }
    .modelContainer(for: OTP.self, inMemory: true, isAutosaveEnabled: true, isUndoEnabled: true)
    .frame(width: 200, height: 400)
}
#endif

struct TotpView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State var otp: OTP
    @State private var timer: Timer? = nil
    @State private var password: String = "-"
    @State private var leftSeconds: Double = 0
    @State private var editMode: Bool = false
    @State private var deleteMode: Bool = false
    
    var body: some View {
        ZStack {
            if editMode {
                TotpEditView(otp: $otp) {
                    withAnimation {
                        editMode = false
                    }
                }
            } else if deleteMode {
                deleteViewBody
            } else {
                regularViewBody
            }
        }
        .onAppear {
            password = genTOTP(otp.secrete)
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
                password = genTOTP(otp.secrete)
                var seconds = Calendar.current.component(.second, from: Date())
                if seconds >= 30 { seconds -= 30 }
                withAnimation(leftSeconds.isZero ? .linear(duration: 0) : .linear(duration: 1)) {
                    leftSeconds = Double(29-seconds)
                }
            })
        }
    }
    
    var deleteViewBody: some View {
        HStack {
            Spacer()
            Button("Delete", role: .destructive) {
                do {
                    try context.transaction {
                        context.delete(otp)
                    }
                } catch {
                    print("ERROR delete otp \(otp.title), err: \(error)")
                }
                withAnimation {
                    deleteMode = false
                }
            }
            .buttonStyle(.glass)
            .tint(.red)
            Spacer()
            Button("Cancel", role: .cancel) {
                withAnimation {
                    deleteMode = false
                }
            }
            Spacer()
        }
        .padding(.vertical, 25)
        .glassEffect(
            .regular.tint(.clear),
            in: RoundedRectangle(cornerRadius: 15),
            isEnabled: true,
        )
    }
    
    var regularViewBody: some View {
        Button {
            copy(password)
        } label: {
            VStack(spacing: 5) {
                HStack {
                    Text(otp.title)
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
            Button("Edit") {
                withAnimation {
                    editMode = true
                }
            }
            
            Button("Copy Secrete") {
                copy(otp.secrete)
            }
            
            Button("Delete", role: .destructive) {
                withAnimation {
                    deleteMode = true
                }
            }
            .tint(.red)
        }
    }
    
    func copy(_ stringToCopy: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(stringToCopy, forType: .string)
    }
}
    
struct TotpCreateView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State var title: String = ""
    @State var secrete: String = ""
    
    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading) {
                HStack {
                    TextField(text: $title) {
                        Text("TITLE")
                    }
                    .textFieldStyle(.plain)
                    Spacer()
                    Button("Create") {
                        if title.isEmpty || secrete.isEmpty {
                            return
                        }
                    
                        
                        do {
                            try context.transaction {
                                context.insert(OTP(title: title, secrete: secrete))
                            }
                            title = ""
                            secrete = ""
                        } catch {
                            print("ERROR save otp \(title), err: \(error)")
                        }
                    }
                    .disabled(title.isEmpty || secrete.isEmpty)
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

struct TotpEditView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var title: String = ""
    @State private var secrete: String = ""
    
    @Binding var otp: OTP
    let close: () -> Void
    // X5YEWCBEP5YRWPDQCDLGYXF56NVI5OA2
    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading) {
                HStack {
                    TextField(text: $otp.title) {
                        Text("TITLE")
                    }
                    .textFieldStyle(.plain)
                    Spacer()
                    Button("Save") {
                        if otp.title.isEmpty || otp.secrete.isEmpty {
                            return
                        }
                    
                        do {
                            if context.hasChanges {
                                try context.save()
                            }
                        } catch {
                            print("ERROR save otp \(otp.title), err: \(error)")
                        }
                        close()
                    }
                    .disabled(otp.title.isEmpty || otp.secrete.isEmpty)
                    
                    Button("Cancel") {
                        otp.title = title
                        otp.secrete = secrete
                        close()
                    }
                    .disabled(otp.title.isEmpty || otp.secrete.isEmpty)
                }
                
                TextField("SECRETE", text: $otp.secrete)
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
        .onAppear {
            title = otp.title
            secrete = otp.secrete
        }
    }
}
