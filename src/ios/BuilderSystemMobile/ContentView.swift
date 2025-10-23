//
//  ContentView.swift
//  BuilderSystemMobile
//
//  Created by Builder System
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var messages: [String] = [
        "Welcome to Builder System Mobile!",
        "This is a terminal/chat interface.",
        "Type commands below to interact with the system."
    ]
    @State private var inputText = ""
    @State private var isTTSEnabled = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
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
                .background(Color(.systemGray6).opacity(0.8))
                
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
                .background(Color(.systemBackground).opacity(0.95))
                
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
                    
                    // TTS Toggle button
                    Button(action: toggleTTS) {
                        Image(systemName: isTTSEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                            .font(.title2)
                            .foregroundColor(isTTSEnabled ? .green : .gray)
                            .scaleEffect(isTTSEnabled ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isTTSEnabled)
                    }
                    
                    // Microphone button (disabled for now)
                    Button(action: {}) {
                        Image(systemName: "mic")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .disabled(true)
                    
                    Button(action: sendCommand) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.8))
            }
            .navigationTitle("Builder System")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendCommand() {
        let command = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        
        messages.append("$ " + command)
        inputText = ""
        
        // Simulate command response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var assistantResponse: String = ""
            
            if command.lowercased().contains("status") {
                messages.append("✅ Builder System Status: Online")
                messages.append("📦 Active Capsules: 7")
                messages.append("🔧 Test Capsules: 18")
                assistantResponse = "Builder System Status: Online. Active Capsules: 7. Test Capsules: 18."
            } else if command.lowercased().contains("help") {
                messages.append("Available commands:")
                messages.append("  status - Show system status")
                messages.append("  capsules - List all capsules")
                messages.append("  help - Show this help")
                assistantResponse = "Available commands: status to show system status, capsules to list all capsules, help to show this help."
            } else {
                messages.append("Command executed: \(command)")
                messages.append("Output: Hello from Builder System!")
                assistantResponse = "Command executed: \(command). Output: Hello from Builder System!"
            }
            
            // Speak the response if TTS is enabled
            if isTTSEnabled && !assistantResponse.isEmpty {
                speakText(assistantResponse)
            }
        }
    }
    
    // MARK: - TTS Functions
    
    private func toggleTTS() {
        isTTSEnabled.toggle()
        
        if isTTSEnabled {
            // Speak a confirmation when enabling
            speakText("Text to speech enabled")
        } else {
            // Stop any current speech when disabling
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    private func speakText(_ text: String) {
        guard isTTSEnabled else { return }
        
        // Stop any current speech
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Clean text for better speech (remove emojis and format)
        let cleanText = text
            .replacingOccurrences(of: "✅", with: "")
            .replacingOccurrences(of: "📦", with: "")
            .replacingOccurrences(of: "🔧", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        let utterance = AVSpeechUtterance(string: cleanText)
        utterance.rate = 0.5 // Slightly slower for better comprehension
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 0.8
        
        speechSynthesizer.speak(utterance)
    }
}

#Preview {
    ContentView()
}
