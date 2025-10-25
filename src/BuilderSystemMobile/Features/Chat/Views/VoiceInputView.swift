import SwiftUI

struct VoiceInputView: View {
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showingTextPreview = false
    @State private var previewText = ""
    @State private var showingQuickActions = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showingTextPreview {
                textPreviewSection
            }
            
            voiceInputSection
        }
    }
    
    private var textPreviewSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Voice Preview")
                    .font(.builderHeadline)
                Spacer()
                Button("Dismiss") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingTextPreview = false
                        previewText = ""
                    }
                }
                .foregroundColor(.builderPrimary)
            }
            
            TextEditor(text: $previewText)
                .frame(minHeight: 100, maxHeight: 200)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .font(.builderBody)
            
            HStack(spacing: 16) {
                Button("Re-record") {
                    voiceManager.startRecording()
                    showingTextPreview = false
                    previewText = ""
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Send") {
                    chatViewModel.sendMessage(previewText, hasVoiceAttachment: true)
                    showingTextPreview = false
                    previewText = ""
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(previewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(Color.adaptiveBackground)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
    
    private var voiceInputSection: some View {
        VStack(spacing: 0) {
            // Text input field
            HStack(spacing: 12) {
                TextField("Type a message...", text: $chatViewModel.messageText)
                    .textFieldStyle(.plain)
                    .font(.builderBody)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .submitLabel(.send)
                    .onSubmit {
                        if !chatViewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            chatViewModel.sendMessage(chatViewModel.messageText, hasVoiceAttachment: false)
                            chatViewModel.messageText = ""
                        }
                    }

                // Send button
                Button(action: {
                    if !chatViewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        chatViewModel.sendMessage(chatViewModel.messageText, hasVoiceAttachment: false)
                        chatViewModel.messageText = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(chatViewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .builderPrimary)
                }
                .disabled(chatViewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Voice and quick actions row
            HStack(spacing: 16) {
                // Voice button with visual feedback
                Button(action: handleVoiceButtonTap) {
                    ZStack {
                        Circle()
                            .fill(voiceButtonBackgroundColor)
                            .frame(width: 44, height: 44)

                        Image(systemName: voiceButtonIcon)
                            .font(.body)
                            .foregroundColor(.white)

                        if voiceManager.isRecording {
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .frame(width: 50, height: 50)
                                .scaleEffect(voiceManager.recordingPulse ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: voiceManager.recordingPulse)
                        }
                    }
                }
                .disabled(voiceManager.isProcessing || !voiceManager.hasPermission)
                .accessibilityLabel(voiceManager.isRecording ? "Stop recording" : "Start voice input")
                .accessibilityHint("Records your voice and converts to text")

                // Quick action button
                Button(action: { showingQuickActions = true }) {
                    Image(systemName: "command")
                        .font(.body)
                        .foregroundColor(.builderPrimary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .cornerRadius(22)
                }
                .accessibilityLabel("Quick commands")
                .accessibilityHint("Show Builder System quick actions")

                Spacer()

                // Recording status
                if voiceManager.isRecording {
                    recordingIndicator
                } else if voiceManager.isProcessing {
                    processingIndicator
                } else if !voiceManager.hasPermission {
                    permissionIndicator
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.adaptiveBackground)
        .sheet(isPresented: $showingQuickActions) {
            QuickActionsView()
                .environmentObject(chatViewModel)
        }
    }
    
    private var voiceButtonBackgroundColor: Color {
        if !voiceManager.hasPermission {
            return .secondary
        } else if voiceManager.isRecording {
            return .errorRed
        } else if voiceManager.isProcessing {
            return .warningOrange
        } else {
            return .builderPrimary
        }
    }
    
    private var voiceButtonIcon: String {
        if !voiceManager.hasPermission {
            return "mic.slash"
        } else if voiceManager.isRecording {
            return "stop.fill"
        } else if voiceManager.isProcessing {
            return "waveform"
        } else {
            return "mic.fill"
        }
    }
    
    private var recordingIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .scaleEffect(voiceManager.recordingPulse ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: voiceManager.recordingPulse)
            
            Text("Recording...")
                .font(.builderCaption)
                .foregroundColor(.errorRed)
        }
    }
    
    private var processingIndicator: some View {
        HStack(spacing: 6) {
            ProgressView()
                .scaleEffect(0.8)
            
            Text("Processing...")
                .font(.builderCaption)
                .foregroundColor(.secondary)
        }
    }
    
    private var permissionIndicator: some View {
        Button("Enable Microphone") {
            voiceManager.checkPermissions()
        }
        .font(.builderCaption)
        .foregroundColor(.builderPrimary)
    }
    
    private func handleVoiceButtonTap() {
        if voiceManager.isRecording {
            voiceManager.stopRecording { transcription in
                previewText = transcription
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingTextPreview = true
                }
            }
        } else {
            voiceManager.startRecording()
        }
    }
}