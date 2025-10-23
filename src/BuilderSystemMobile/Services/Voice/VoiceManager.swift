import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
class VoiceManager: ObservableObject {
    @Published var isRecording = false
    @Published var isProcessing = false
    @Published var recordingPulse = false
    @Published var hasPermission = false
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var recordingCompletion: ((String) -> Void)?
    
    init() {
        checkPermissions()
    }
    
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.hasPermission = status == .authorized
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasPermission = self.hasPermission && granted
            }
        }
    }
    
    func startRecording() {
        guard hasPermission else {
            checkPermissions()
            return
        }
        
        stopRecording()
        
        isRecording = true
        recordingPulse = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                // We'll handle the final result when stopping
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    self.stopRecording()
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stopRecording(completion: ((String) -> Void)? = nil) {
        guard isRecording else { return }
        
        isRecording = false
        recordingPulse = false
        isProcessing = true
        
        recordingCompletion = completion
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        
        // Wait a moment for final processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.finishRecognition()
        }
    }
    
    private func finishRecognition() {
        // TODO: Fix - recognitionTask doesn't have direct .result access in iOS 17+
        // Need to track recognized text during speech recognition callback
        let finalText = "" // Placeholder - actual text should be captured during recognition

        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        isProcessing = false

        recordingCompletion?(finalText)
        recordingCompletion = nil
        
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}