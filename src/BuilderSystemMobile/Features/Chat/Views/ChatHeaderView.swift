import SwiftUI

struct ChatHeaderView: View {
    @StateObject private var sshService = SSHService()
    @State private var showingConnectionDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Builder System")
                        .font(.builderHeadline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(connectionStatusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(sshService.connectionState.statusText)
                            .font(.builderCaption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: { showingConnectionDetails = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.builderPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
        }
        .background(Color.adaptiveBackground)
        .sheet(isPresented: $showingConnectionDetails) {
            ConnectionDetailsView()
                .environmentObject(sshService)
        }
    }
    
    private var connectionStatusColor: Color {
        switch sshService.connectionState {
        case .connected:
            return .successGreen
        case .connecting:
            return .warningOrange
        case .disconnected:
            return .secondary
        case .error:
            return .errorRed
        }
    }
}