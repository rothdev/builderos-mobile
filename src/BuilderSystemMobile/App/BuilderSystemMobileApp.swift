import SwiftUI
import Speech
import AVFoundation

// NOTE: @main entry point is defined in BuilderOSApp.swift
// This file contains the legacy implementation for reference
// The app now uses a unified 4-tab architecture in MainContentView.swift

struct ContentView: View {
    @State private var messages: [String] = [
        "Welcome to Builder System Mobile!",
        "This is a terminal/chat interface.",
        "Type commands below to interact with the system."
    ]
    @State private var inputText = ""
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "terminal")
                        .foregroundColor(.blue)
                    Text("Builder Terminal")
                        .font(.headline)
                    Spacer()
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Connected")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Messages
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                            HStack {
                                if index == 0 {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                Text(message)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(.vertical, 4)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .background(Color(.systemBackground))
                
                // Input area
                HStack {
                    Image(systemName: "terminal")
                        .foregroundColor(.blue)
                    
                    TextField("Type command...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.body, design: .monospaced))
                        .onSubmit {
                            sendCommand()
                        }
                    
                    // Microphone button
                    Button(action: toggleRecording) {
                        Image(systemName: isRecording ? "mic.fill" : "mic")
                            .font(.title2)
                            .foregroundColor(isRecording ? .red : .gray)
                            .background(
                                Circle()
                                    .fill(isRecording ? Color.red.opacity(0.1) : Color.clear)
                                    .frame(width: 32, height: 32)
                            )
                            .scaleEffect(isRecording ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isRecording)
                    }
                    
                    Button(action: sendCommand) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle("Builder System")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            requestSpeechPermission()
        }
    }
    
    private func sendCommand() {
        let command = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        
        messages.append("$ " + command)
        inputText = ""
        
        // Simulate command response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if command.lowercased().contains("status") {
                messages.append("✅ Builder System Status: Online")
                messages.append("📦 Active Capsules: 7")
                messages.append("🔧 Test Capsules: 18")
            } else if command.lowercased().contains("help") {
                messages.append("Available commands:")
                messages.append("  status - Show system status")
                messages.append("  capsules - List all capsules")
                messages.append("  help - Show this help")
            } else {
                messages.append("Command executed: \(command)")
                messages.append("Output: Hello from Builder System!")
            }
        }
    }
    
    // MARK: - Speech Recognition Functions
    
    private func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition denied")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        // Cancel previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session configuration failed: \(error)")
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start failed: \(error)")
            return
        }
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            DispatchQueue.main.async {
                if let result = result {
                    inputText = result.bestTranscription.formattedString
                }
                
                if error != nil || result?.isFinal == true {
                    stopRecording()
                }
            }
        }
        
        isRecording = true
        messages.append("🎤 Listening...")
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        
        // Remove "Listening..." message if it's the last one
        if messages.last == "🎤 Listening..." {
            messages.removeLast()
        }
        
        // Add voice input indicator if we got text
        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            messages.append("🎙️ Voice input: \(inputText)")
        }
    }
}