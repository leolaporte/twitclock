import SwiftUI

@main
struct TwitClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fixedSize()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1, height: 1)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.level = .floating
                window.isMovableByWindowBackground = true
                window.isOpaque = false
                window.backgroundColor = .clear
                window.hasShadow = false
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
    }
}

struct ContentView: View {
    @State private var secondsRemaining: Int = 15 * 60
    @State private var isContentPhase: Bool = true

    private let contentDuration = 15 * 60
    private let adBreakDuration = 90
    private let snoozeDuration = 2 * 60

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
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text(timeString)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)

                Text(phaseLabel)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    Button(action: { adjustTime(by: 60) }) {
                        Text("+")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)
                    .focusable(false)

                    Divider().frame(height: 12).opacity(0.3)

                    Button(action: { adjustTime(by: -60) }) {
                        Text("\u{2212}")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                }
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(backgroundColor)
                .frame(maxWidth: .infinity, minHeight: 22)
                .background(.white)
                .clipShape(Capsule())

                Button(action: { switchPhase() }) {
                    Text("\u{21C4}")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .focusable(false)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(backgroundColor)
                .frame(maxWidth: .infinity, minHeight: 22)
                .background(.white)
                .clipShape(Capsule())

                Button(action: { NSApp.terminate(nil) }) {
                    Text("\u{2715}")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .focusable(false)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(backgroundColor)
                .frame(maxWidth: .infinity, minHeight: 22)
                .background(.white)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .background(backgroundColor.animation(.easeInOut(duration: 0.5)))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onReceive(timer) { _ in
            tick()
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

    private func adjustTime(by seconds: Int) {
        secondsRemaining = max(0, secondsRemaining + seconds)
    }
}
