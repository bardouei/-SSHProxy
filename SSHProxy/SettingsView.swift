//
//  SettingsView.swift
//  SSHProxy
//
//  Created by baner on 3/22/25.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var ssh: SSHManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SSH Settings")
                .font(.title3)
                .fontWeight(.bold)
            
            Group {
                TextField("Username", text: $ssh.username)
                TextField("Server IP", text: $ssh.ip)
                TextField("SSH Port", text: $ssh.port)
                SecureField("Password", text: $ssh.password)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Divider()
            
            Text("SOCKS Proxy")
                .font(.title3)
                .fontWeight(.bold)
            
            Group {
                TextField("Local Host", text: $ssh.localHost)
                TextField("Local Port", text: $ssh.localPort)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 320)
    }
}
