import SwiftUI

struct TTSButton: View {
    let content: String
    @StateObject private var ttsManager = TTSManager()
    
    var body: some View {
        Button(action: {
            if ttsManager.isSpeaking {
                ttsManager.stopSpeaking()
            } else {
                ttsManager.speak(content)
            }
        }) {
            Image(systemName: ttsManager.isSpeaking ? "speaker.slash" : "speaker.2")
                .font(.builderCaption)
                .foregroundColor(.builderPrimary)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(ttsManager.isSpeaking ? "Stop reading" : "Read message aloud")
        .accessibilityHint("Uses text-to-speech to read the message")
    }
}