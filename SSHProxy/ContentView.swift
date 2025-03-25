//
//  ContentView.swift
//  SSHProxy
//
//  Created by baner on 3/22/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var ssh: SSHManager
    @State private var showingSettings = false
    @State private var showingLogs = false

    var body: some View {
        VStack(spacing: 20) {
            
            HStack(spacing: 12) {
                Button(action: {
                    showingLogs.toggle()
                }) {
                    Image(systemName: "doc.plaintext")
                        .font(.system(size: 18, weight: .bold))
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showingLogs) {
                    LogsView()
                        .environmentObject(ssh)
                }

                Button(action: {
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .bold))
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                        .environmentObject(ssh)
                }

                Spacer()
                
                Button(action: {
                    ssh.stopProxy()
                    NSApp.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Exit App")
            }
            .padding(.top, 40)
            .padding(.horizontal, 10)

            Spacer()

            Text("ssh proxy")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.red)

            Toggle("", isOn: Binding(
                get: { ssh.isRunning },
                set: { newValue in
                    if newValue {
                        ssh.startProxy()
                    } else {
                        ssh.stopProxy()
                    }
                })
            )
            .toggleStyle(SwitchToggleStyle(tint: .red))
            .scaleEffect(2.0)
            .padding(.vertical, 20)

            Text(ssh.isRunning ? "Connected" : "Disconnected")
                .font(.headline)
                .foregroundColor(.primary)

            Text(ssh.isRunning ? "Your Internet is private." : "Your Internet is not private.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSettingsDueToEmptyFields)) { _ in
            showingSettings = true
        }
        .padding()
        .frame(width: 300, height: 350)
    }
}
