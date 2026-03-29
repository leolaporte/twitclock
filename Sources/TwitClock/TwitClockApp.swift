import SwiftUI

@main
struct TwitClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, @unchecked Sendable {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
            window.isMovableByWindowBackground = true
            window.backgroundColor = .clear
        }
    }
}

struct ContentView: View {
    @State private var secondsRemaining: Int = 15 * 60
    @State private var isContentPhase: Bool = true

    private let contentDuration = 15 * 60  // 15 minutes
    private let adBreakDuration = 90       // 90 seconds
    private let snoozeDuration = 2 * 60    // 2 minutes

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var backgroundColor: Color {
        isContentPhase ? Color(red: 0.13, green: 0.77, blue: 0.37) : Color(red: 0.94, green: 0.27, blue: 0.27)
    }

    private var phaseLabel: String {
        isContentPhase ? "CONTENT" : "AD BREAK"
    }

    private var timeString: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(timeString)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)

            Text(phaseLabel)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 24)
        .frame(minWidth: 240)
        .background(backgroundColor.animation(.easeInOut(duration: 0.5)))
        .onReceive(timer) { _ in
            tick()
        }
        .onKeyPress(.space) {
            snooze()
            return .handled
        }
    }

    private func tick() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        } else {
            switchPhase()
        }
    }

    private func switchPhase() {
        isContentPhase.toggle()
        secondsRemaining = isContentPhase ? contentDuration : adBreakDuration
    }

    private func snooze() {
        secondsRemaining += snoozeDuration
    }
}
