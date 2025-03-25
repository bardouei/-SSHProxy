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
        guard isSshpassInstalled() else {
            outputLog += "❌ sshpass is not installed. Trying to install it via Homebrew...\n"
            installSshpass()
            return
        }
        
        guard !isRunning else {
            outputLog += "Proxy already running.\n"
            return
        }
        if let pid = getPIDUsingPort(8443) {
            killProcess(pid: pid)
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
        outputLog += "Starting SSH proxy with sshpass...\n"
        
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
            outputLog += "Error starting sshpass: \(error.localizedDescription)\n"
            isRunning = false
            statusIconUpdater?(false)
        }
    }
    
    func stopProxy() {
        sshTask?.terminate()
        sshTask = nil
        isRunning = false
        outputLog += "Proxy stopped by user.\n"
        unsetSystemSocksProxy(interfaceName: "Wi-Fi")
        statusIconUpdater?(false)
    }
    
    func installSshpass() {
        let task = Process()
        task.launchPath = "/opt/homebrew/bin/brew"
        task.arguments = ["install", "sshpass"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                outputLog += output
            }
        } catch {
            outputLog += "Error installing sshpass: \(error.localizedDescription)\n"
        }
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
    
    func getPIDUsingPort(_ port: Int) -> Int? {
        let task = Process()
        task.launchPath = "/usr/sbin/lsof"
        task.arguments = ["-i", ":\(port)", "-sTCP:LISTEN", "-t"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8),
               let pid = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return pid
            }
        } catch {
            print("Error finding PID: \(error)")
        }
        
        return nil
    }
    
    func killProcess(pid: Int) {
        let task = Process()
        task.launchPath = "/bin/kill"
        task.arguments = ["-9", "\(pid)"]
        
        do {
            try task.run()
            task.waitUntilExit()
            print("✅ Killed process with PID \(pid)")
        } catch {
            print("❌ Failed to kill process: \(error)")
        }
    }
    
    func isSshpassInstalled() -> Bool {
        let fileManager = FileManager.default
        let possiblePaths = [
            "/opt/homebrew/bin/sshpass",
            "/usr/local/bin/sshpass",
            "/usr/bin/sshpass"
        ]
        
        for path in possiblePaths {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        
        return false
    }
}

extension Notification.Name {
    static let showSettingsDueToEmptyFields = Notification.Name("showSettingsDueToEmptyFields")
}
