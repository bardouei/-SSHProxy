
🧭 SSHProxy – Simple macOS Menu Bar App for SSH SOCKS Proxy

SSHProxy is a lightweight macOS menu bar app that allows you to easily create a secure SOCKS5 proxy over SSH using sshpass. It's ideal for developers, remote workers, and privacy-minded users who want to tunnel traffic through a secure SSH connection with a single click.

✨ Features
✅ SSH over SOCKS proxy (ssh -D) using sshpass
🖥️ macOS-native UI built with Swift and SwiftUI
🧦 SOCKS5 proxy tunnel auto-configures networksetup on macOS
⚙️ User settings stored with @AppStorage (persistent between app launches)
📋 Real-time output logs with auto-scroll and copyable logs
🛠️ Auto-install sshpass via Homebrew if not already installed
🚫 Port conflict detection – Kills previous processes using the same port
🔐 Minimalistic toggle UI for proxy on/off, with a settings panel
🚀 How It Works
This app runs the equivalent of:

sshpass -p [password] ssh -D 127.0.0.1:8443 -N [username]@[host] -p [port]
It then activates the SOCKS5 proxy in your macOS network settings using networksetup.

🛠 Requirements
macOS 12+
Homebrew installed (/opt/homebrew/bin/brew)
sshpass (auto-installed if missing)
🧪 Development
Clone the repo and open in Xcode:

git clone https://github.com/yourusername/SSHProxy.git
cd SSHProxy
open SSHProxy.xcodeproj
