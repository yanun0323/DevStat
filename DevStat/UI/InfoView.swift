import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            Rectangle().fill(Color.red).frame(width: 50, height: 50)
            HStack(spacing: 0) {
                Spacer()
                Text("Hello, World!")
                    .frame(width: 50, height: 50)
                    .background(Color.red.opacity(0.5))
                    .border(Color.red)
                    .frame(width: 70, height: 70)
                    .background(Color.green.opacity(0.5))
                    .border(Color.green)
                    .frame(width: 200, height: 200)
                    .padding()
                    .background(Color.blue.opacity(0.5))
                    .border(Color.blue)
                Spacer()
            }
            .background(Color.brown)
            Rectangle().fill(Color.green).frame(width: 50, height: 50)
            Spacer(minLength: 0)
        }
        .background(Color.gray)
//        .frame(width: 100, height: 100)
//        .border(Color.red)
//        .padding(100)
//        .border(Color.red)
//        .background(Color.black)
    }
}

#if DEBUG
#Preview {
    InfoView()
        .frame(width: 400, height: 400)
}
#endif
