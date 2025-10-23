import Foundation
import AVFoundation
import Combine

@MainActor
class TTSManager: NSObject, ObservableObject {
    @Published var isSpeaking = false
    
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Clean up text for better TTS
        let cleanedText = cleanTextForTTS(text)
        
        let utterance = AVSpeechUtterance(string: cleanedText)
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    private func cleanTextForTTS(_ text: String) -> String {
        var cleaned = text
        
        // Remove common terminal escape sequences
        cleaned = cleaned.replacingOccurrences(of: "\\x1b\\[[0-9;]*m", with: "", options: .regularExpression)
        
        // Replace common symbols with pronounceable text
        cleaned = cleaned.replacingOccurrences(of: "```", with: "code block")
        cleaned = cleaned.replacingOccurrences(of: "#!/", with: "script beginning with")
        cleaned = cleaned.replacingOccurrences(of: "->", with: "arrow")
        cleaned = cleaned.replacingOccurrences(of: "=>", with: "arrow")
        cleaned = cleaned.replacingOccurrences(of: "&&", with: "and")
        cleaned = cleaned.replacingOccurrences(of: "||", with: "or")
        
        // Limit length for better performance
        if cleaned.count > 500 {
            cleaned = String(cleaned.prefix(500)) + "... message truncated for speech"
        }
        
        return cleaned
    }
}

extension TTSManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}