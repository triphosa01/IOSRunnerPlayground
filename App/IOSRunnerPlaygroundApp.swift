import SwiftUI

@main
struct IOSRunnerPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("iOS Runner Playground")
                .font(.title2.bold())

            Text("Your SwiftUI app is ready to build on a GitHub-hosted macOS runner.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }
}
