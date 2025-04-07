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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Logs")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button("Clear") {
                    ssh.outputLog = ""
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.bottom, 5)
            
            ScrollView {
                Text(ssh.outputLog)
                    .font(.system(size: 12, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                    .textSelection(.enabled)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
