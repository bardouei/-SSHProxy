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
        VStack(alignment: .leading, spacing: 12) {
            Text("SSH Settings")
                .font(.headline)

            TextField("Username", text: $ssh.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Server IP", text: $ssh.ip)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("SSH Port", text: $ssh.port)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $ssh.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Divider()

            Text("SOCKS Proxy")
                .font(.headline)

            TextField("Local Host", text: $ssh.localHost)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Local Port", text: $ssh.localPort)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
        }
        .padding()
        .frame(width: 300)
    }
}
