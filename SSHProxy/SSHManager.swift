//
//  SSHManager.swift
//  SSHProxy
//
//  Created by baner on 3/22/25.
//

import SwiftUI

class SSHManager: ObservableObject {
    @AppStorage("username") var username: String = ""
    @AppStorage("ip") var ip: String = ""
    @AppStorage("port") var port: String = ""
    @AppStorage("password") var password: String = ""
    @AppStorage("localHost") var localHost: String = "127.0.0.1"
    @AppStorage("localPort") var localPort: String = "8443"
    
    @Published var isRunning: Bool = false
    @Published var outputLog: String = ""
    
    var statusIconUpdater: ((Bool) -> Void)?
    var sshTask: Process?
    
    func startProxy() {
        guard !isRunning else {
            outputLog += "Proxy already running.\n"
            return
        }
        
        guard findSSHPassPath() != nil else {
            outputLog += "❌ 'sshpass' is not installed or not found in common paths.\nPlease install it using Homebrew:\n    brew install sshpass\n"
            return
        }
        
        if isPortInUse(Int(localPort) ?? 8443) {
            outputLog += "⚠️ Cannot start proxy: Port \(localPort) is already in use by another process.\nPlease stop it first or use a different port in Settings.\n"
            return
        }
        
        if username.isEmpty || ip.isEmpty || port.isEmpty || password.isEmpty || localHost.isEmpty || localPort.isEmpty {
            outputLog += "⚠️ Please fill all fields.\n"
            NotificationCenter.default.post(name: .showSettingsDueToEmptyFields, object: nil)
            return
        }
        
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        task.launchPath = "/opt/homebrew/bin/sshpass"
        task.arguments = [
            "-p", password,
            "ssh",
            "-D", "\(localHost):\(localPort)",
            "-N",
            "\(username)@\(ip)",
            "-p", port
        ]
        
        self.sshTask = task
        outputLog += "Starting SSH proxy process...\n"
        
        task.terminationHandler = { _ in
            DispatchQueue.main.async {
                self.outputLog += "\nSSH process terminated.\n"
                self.isRunning = false
            }
        }
        
        do {
            try task.run()
            setSystemSocksProxy(interfaceName: "Wi-Fi", host: localHost, port: localPort)
            statusIconUpdater?(true)
            isRunning = true
            
            outputPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let str = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.outputLog += "OUT: \(str)"
                    }
                }
            }
            
            errorPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let str = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.outputLog += "ERR: \(str)"
                    }
                }
            }
            
        } catch {
            outputLog += "Error starting : \(error.localizedDescription)\n"
            isRunning = false
            statusIconUpdater?(false)
        }
    }
    
    func findSSHPassPath() -> String? {
        let paths = [
            "/opt/homebrew/bin/sshpass", // Apple Silicon
            "/usr/local/bin/sshpass",    // Intel Macs
            "/usr/bin/sshpass"           // Rare cases
        ]
        
        let fileManager = FileManager.default
        for path in paths {
            if fileManager.isExecutableFile(atPath: path) {
                return path
            }
        }
        return nil
    }
    
    func stopProxy() {
        sshTask?.terminate()
        sshTask = nil
        isRunning = false
        outputLog += "Proxy stopped by user.\n"
        unsetSystemSocksProxy(interfaceName: "Wi-Fi")
        statusIconUpdater?(false)
    }
    
    func setSystemSocksProxy(interfaceName: String = "Wi-Fi", host: String = "127.0.0.1", port: String = "8443") {
        let setProxyTask = Process()
        setProxyTask.launchPath = "/usr/sbin/networksetup"
        setProxyTask.arguments = ["-setsocksfirewallproxy", interfaceName, host, port]
        
        let turnOnProxyTask = Process()
        turnOnProxyTask.launchPath = "/usr/sbin/networksetup"
        turnOnProxyTask.arguments = ["-setsocksfirewallproxystate", interfaceName, "on"]
        
        do {
            try setProxyTask.run()
            setProxyTask.waitUntilExit()
            
            try turnOnProxyTask.run()
            turnOnProxyTask.waitUntilExit()
            
            print("✅ System SOCKS proxy set to \(host):\(port)")
        } catch {
            print("❌ Failed to set system proxy: \(error)")
        }
    }
    
    func unsetSystemSocksProxy(interfaceName: String = "Wi-Fi") {
        let turnOffProxyTask = Process()
        turnOffProxyTask.launchPath = "/usr/sbin/networksetup"
        turnOffProxyTask.arguments = ["-setsocksfirewallproxystate", interfaceName, "off"]
        
        do {
            try turnOffProxyTask.run()
            turnOffProxyTask.waitUntilExit()
            
            print("✅ System SOCKS proxy turned off")
        } catch {
            print("❌ Failed to unset system proxy: \(error)")
        }
    }
    
    func isPortInUse(_ port: Int) -> Bool {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "netstat -an | grep LISTEN | grep :\(port)"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                return true
            }
        } catch {
            print("Error checking port status: \(error)")
        }
        
        return false
    }
}

extension Notification.Name {
    static let showSettingsDueToEmptyFields = Notification.Name("showSettingsDueToEmptyFields")
}
