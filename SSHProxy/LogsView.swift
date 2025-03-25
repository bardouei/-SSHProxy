//
//  LogsView.swift
//  SSHProxy
//
//  Created by baner on 3/22/25.
//

import SwiftUI

struct LogsView: View {
    @EnvironmentObject var ssh: SSHManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Logs")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    ssh.outputLog = ""
                }
                Button("Done") {
                    dismiss()
                }
            }
            .padding(.bottom, 5)

            ScrollView {
                Text(ssh.outputLog)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
