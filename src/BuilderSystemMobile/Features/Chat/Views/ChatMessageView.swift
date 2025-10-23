import SwiftUI

struct ChatMessageView: View {
    let message: ChatMessage
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer()
                userMessageBubble
            } else {
                systemMessageContent
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var userMessageBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .font(.builderBody)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.userMessageBackground)
                .cornerRadius(20)
                .contextMenu {
                    Button("Copy") { 
                        UIPasteboard.general.string = message.content
                    }
                }
            
            if message.hasVoiceAttachment {
                voiceIndicator
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
    }
    
    private var systemMessageContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Message type indicator
            HStack {
                Image(systemName: message.typeIcon)
                    .foregroundColor(message.typeColor)
                Text(message.type.displayName)
                    .font(.builderCaption)
                    .foregroundColor(.secondary)
                Spacer()
                TTSButton(content: message.content)
            }
            
            // Content with proper formatting
            if message.isCodeBlock {
                codeBlockView
            } else {
                formattedTextView
            }
        }
        .padding(12)
        .background(systemMessageBackground)
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var codeBlockView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(message.content)
                .font(.builderCode)
                .foregroundColor(codeTextColor)
                .padding(12)
                .background(codeBackgroundColor)
                .cornerRadius(8)
        }
    }
    
    private var formattedTextView: some View {
        Text(message.content)
            .font(.builderBody)
            .textSelection(.enabled)
    }
    
    private var voiceIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "mic.fill")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            Text("Voice")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    // Color schemes
    private var systemMessageBackground: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray5)
    }
    
    private var codeBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray4) : Color(.systemGray2)
    }
    
    private var codeTextColor: Color {
        colorScheme == .dark ? Color(.systemGreen) : Color(.systemBlue)
    }
}