# 🛠️ Ohmynet - Auto Internet Interface Switcher

**Ohmynet** is a Bash script that continuously monitors internet connectivity and automatically switches to a working network interface if the current one goes offline.

## 🔍 Features

- Checks for internet connectivity every 3 seconds
- Detects the default route interface
- Switches to an alternative connected interface if internet is lost
- Uses `nmcli` to bring connections up/down (safe with NetworkManager)
- Works with multiple interfaces: Ethernet, Wi-Fi, USB NICs, etc.

---

## 🚀 Usage

1. Copy the script to a stable path:

   ```bash
   wget -qO- https://raw.githubusercontent.com/ohmydevops/ohmynet/main/ohmynet.sh | bash
   ```