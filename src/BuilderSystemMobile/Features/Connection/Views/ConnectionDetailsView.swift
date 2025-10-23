import SwiftUI

struct ConnectionDetailsView: View {
    @EnvironmentObject var sshService: SSHService
    @Environment(\.presentationMode) var presentationMode
    @State private var host = "localhost"
    @State private var port = "22"
    @State private var username = ""
    @State private var password = ""
    @State private var showingConnectionForm = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Current Status
                VStack(spacing: 12) {
                    Text("Connection Status")
                        .font(.builderHeadline)
                    
                    HStack {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 16, height: 16)
                        
                        Text(sshService.connectionState.statusText)
                            .font(.builderBody)
                    }
                    
                    if case .error(let message) = sshService.connectionState {
                        Text(message)
                            .font(.builderCaption)
                            .foregroundColor(.errorRed)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.adaptiveSecondaryBackground)
                .cornerRadius(12)
                
                // Connection Actions
                VStack(spacing: 16) {
                    if sshService.connectionState.isConnected {
                        Button("Disconnect") {
                            sshService.disconnect()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    } else {
                        Button("Connect to Builder System") {
                            showingConnectionForm = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                
                Spacer()
                
                // Connection Help
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connection Help")
                        .font(.builderHeadline)
                    
                    Text("To connect to your Builder System:")
                        .font(.builderBody)
                    
                    Text("1. Ensure SSH is enabled on your server")
                    Text("2. Have your server's IP address or hostname")
                    Text("3. Know your username and authentication method")
                    Text("4. Make sure the Builder System is running")
                    
                    Text("\nFor security, consider using SSH keys instead of passwords.")
                        .font(.builderCaption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.adaptiveTertiaryBackground)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Connection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .sheet(isPresented: $showingConnectionForm) {
            ConnectionFormView(
                host: $host,
                port: $port,
                username: $username,
                password: $password
            ) { config in
                Task {
                    try await sshService.connect(configuration: config)
                }
                showingConnectionForm = false
            }
        }
    }
    
    private var statusColor: Color {
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

struct ConnectionFormView: View {
    @Binding var host: String
    @Binding var port: String
    @Binding var username: String
    @Binding var password: String
    
    let onConnect: (SSHConfiguration) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Details")) {
                    TextField("Host", text: $host)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                    
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Authentication")) {
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }
                
                Section(footer: Text("SSH key authentication will be supported in a future update.")) {
                    Button("Connect") {
                        let portInt = Int(port) ?? 22
                        let config = SSHConfiguration(
                            host: host,
                            port: portInt,
                            username: username,
                            password: password.isEmpty ? nil : password
                        )
                        onConnect(config)
                    }
                    .disabled(host.isEmpty || username.isEmpty)
                }
            }
            .navigationTitle("SSH Connection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}