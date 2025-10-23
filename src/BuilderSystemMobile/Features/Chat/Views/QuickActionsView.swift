import SwiftUI

struct QuickActionsView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let quickCommands = [
        QuickCommand(title: "System Status", command: "~/Documents/Builder/tools/daily_audit.sh", icon: "info.circle"),
        QuickCommand(title: "List Capsules", command: "ls ~/Documents/Builder/capsules", icon: "list.bullet"),
        QuickCommand(title: "Health Check", command: "~/Documents/Builder/tools/memory_status.sh", icon: "heart.circle"),
        QuickCommand(title: "Recent Logs", command: "tail -n 20 ~/Documents/Builder/global/events.log", icon: "doc.text"),
        QuickCommand(title: "Agent Status", command: "ps aux | grep claude", icon: "person.3"),
        QuickCommand(title: "Disk Usage", command: "df -h ~/Documents/Builder", icon: "internaldrive")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Quick Commands")
                    .font(.builderHeadline)
                    .padding()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(quickCommands, id: \.command) { command in
                        QuickActionButton(command: command) {
                            chatViewModel.sendCommand(command.command)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Manual command input
                VStack(spacing: 12) {
                    Text("Custom Command")
                        .font(.builderHeadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ManualCommandInput { command in
                        chatViewModel.sendCommand(command)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .background(Color.adaptiveBackground)
    }
}

struct QuickActionButton: View {
    let command: QuickCommand
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: command.icon)
                    .font(.title2)
                    .foregroundColor(.builderPrimary)
                
                Text(command.title)
                    .font(.builderCaption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ManualCommandInput: View {
    let onSubmit: (String) -> Void
    @State private var commandText = ""
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Enter command...", text: $commandText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.builderBody)
            
            Button("Send") {
                if !commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSubmit(commandText)
                    commandText = ""
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}