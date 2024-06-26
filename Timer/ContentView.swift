import SwiftUI
import AppKit
import AVFoundation

struct AlwaysOnTopView: NSViewRepresentable {
    let window: NSWindow
    let isAlwaysOnTop: Bool
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if isAlwaysOnTop {
            window.level = .floating
        } else {
            window.level = .normal
        }
    }
}

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Beep", withExtension: "mov") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("재생하는데 오류가 발생했습니다. \(error.localizedDescription)")
        }
    }
}


struct ContentView: View {
    @State private var timeInMinutes = ""
    @State private var timeRemaining = 0
    @State private var isTimerRunning = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: CGFloat(timeRemaining) / (30 * 60))
                    .stroke(Color.red, lineWidth: 10)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Button {
                        switch timeRemaining {
                        case 0..<180:
                            timeRemaining = 180
                        case 180..<300:
                            timeRemaining = 300
                        case 300..<420:
                            timeRemaining = 420
                        case 300..<600:
                            timeRemaining = 600
                        case 600..<900:
                            timeRemaining = 900
                        case 900..<1200:
                            timeRemaining = 1200
                        case 1200..<1500:
                            timeRemaining = 1500
                        case 1500..<1800:
                            timeRemaining = 1800
                        default:
                            timeRemaining = 0
                        }
                    } label: {
                        Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button {
                        self.isTimerRunning.toggle()
                    } label: {
                        Image(systemName: isTimerRunning ? "pause" : "play.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 100, height: 100)
            .padding()
            .background(AlwaysOnTopView(window: NSApplication.shared.windows.first!, isAlwaysOnTop: true))
        }
        .onReceive(timer) { _ in
            if self.timeRemaining > 0 && self.isTimerRunning {
                self.timeRemaining -= 1
                if self.timeRemaining <= 10 {
                    NSSound.beep()
                }
            } else if self.timeRemaining == 0 && self.isTimerRunning {
                self.isTimerRunning = false
                SoundManager.instance.playSound()
            }
        }
    }
    
    func playSystemSound() {
        NSSound.beep()
    }
}

#Preview {
    ContentView()
}
