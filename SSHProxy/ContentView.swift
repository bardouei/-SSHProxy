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
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        
        let backgroundGradient = colorScheme == .dark
        ? LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.5)]),
                         startPoint: .top,
                         endPoint: .bottom)
        : LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                         startPoint: .top,
                         endPoint: .bottom)

        ZStack {
            backgroundGradient
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                
                HStack {
                    Button(action: {
                        showingLogs.toggle()
                    }) {
                        Image(systemName: "doc.plaintext")
                            .font(.title2)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .sheet(isPresented: $showingLogs) {
                        LogsView()
                            .environmentObject(ssh)
                    }
                    
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
                    .buttonStyle(BorderlessButtonStyle())
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
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Exit App")
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                Text("SSH Proxy")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.red)
                    .shadow(color: .gray.opacity(0.4), radius: 1, x: 1, y: 1)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(NSColor.windowBackgroundColor))
                        .shadow(radius: 5)
                    
                    VStack(spacing: 16) {
                        Toggle(isOn: Binding(
                            get: { ssh.isRunning },
                            set: { newValue in
                                if newValue {
                                    ssh.startProxy()
                                } else {
                                    ssh.stopProxy()
                                }
                            }
                        )) {
                            Text("Proxy Status")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .red))
                        .padding(.horizontal)

                        Text(ssh.isRunning ? "Connected" : "Disconnected")
                            .font(.subheadline)
                            .foregroundColor(ssh.isRunning ? .green : .secondary)

                        Text(ssh.isRunning ? "Your Internet is private." : "Your Internet is not private.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .frame(height: 150)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSettingsDueToEmptyFields)) { _ in
            showingSettings = true
        }
        .frame(width: 300, height: 350)
    }
}
