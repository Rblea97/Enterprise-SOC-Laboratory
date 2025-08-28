# Ubuntu Desktop SIEM Installation Guide

## Overview
This guide installs Ubuntu Desktop 22.04 LTS and prepares it for Splunk SIEM installation. Ubuntu Desktop provides a GUI interface making SIEM configuration and management easier while maintaining all server capabilities.

## VM Configuration
- **Name**: SIEM01-Ubuntu
- **RAM**: 6GB (Desktop requires more resources)
- **VRAM**: 256MB (For GUI acceleration)
- **Storage**: 25GB
- **Network**: Internal network "SOC_Lab_Network"
- **Expected IP**: 192.168.100.30 (Static)
- **Purpose**: Splunk SIEM Server with GUI Management

---

## Phase 1: Ubuntu Desktop Installation

### Step 1: Initial Boot
1. **VM should boot from Ubuntu Desktop ISO**
2. **Select**: "Try or Install Ubuntu" (with GUI installer)
3. **Wait for desktop environment to load** (may take 3-5 minutes)

### Step 2: Installation Welcome Screen
1. **Language**: English
2. **Click**: "Install Ubuntu" button
3. **Keyboard Layout**: English (US)
4. **Continue**

### Step 3: Updates and Software Selection
1. **What apps would you like to install?**
   - Select: "Normal installation" (includes useful GUI tools)
   - ☑️ Check: "Install third-party software" (for hardware drivers)
2. **Continue**

### Step 4: Installation Type
1. **Installation type**: "Erase disk and install Ubuntu"
   - This is safe since it's a new VM
2. **Continue**
3. **Write changes to disks**: Continue

### Step 5: Location and Time Zone
1. **Where are you?**: Select your location for correct timezone
2. **Continue**

### Step 6: User Account Setup
**Create SIEM administrator account:**
```
Your name: SIEM Administrator
Your computer's name: siem01
Pick a username: siem-admin
Choose a password: [Choose a strong password - document securely]
Confirm password: [Confirm your chosen password]
```
- ☑️ Check: "Log in automatically" (for lab convenience)
- **Continue**

### Step 7: Installation Process
1. **Installation begins** - takes 15-20 minutes
2. **Monitor progress** - don't interrupt
3. **When complete**: "Restart Now"
4. **Remove installation medium**: Press Enter when prompted

---

## Phase 2: Initial Desktop Configuration

### Step 8: First Boot and Setup
1. **System boots to desktop automatically**
2. **Skip**: Online accounts setup (click "Skip")
3. **Skip**: Ubuntu Pro (click "Skip")
4. **Skip**: Help improve Ubuntu (optional)
5. **Ready to go**: Click "Done"

### Step 9: Network Configuration (Static IP)
**IMPORTANT**: Configure static IP for SIEM server

**Method 1: GUI Network Settings (Recommended)**
1. **Click**: Network icon (top-right corner)
2. **Select**: "Wired Settings" 
3. **Click**: Gear icon ⚙️ next to wired connection
4. **IPv4 Tab**: 
   - Method: "Manual"
   - Address: `192.168.100.30`
   - Netmask: `255.255.255.0` (or /24)
   - Gateway: `192.168.100.10`
   - DNS: `192.168.100.10`
5. **Apply**
6. **Toggle connection off/on** to apply changes

**Method 2: Command Line (Alternative)**
```bash
# Open terminal (Ctrl+Alt+T)
sudo nano /etc/netplan/01-network-manager-all.yaml

# Add this configuration:
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s3:
      dhcp4: false
      addresses: [192.168.100.30/24]
      gateway4: 192.168.100.10
      nameservers:
        addresses: [192.168.100.10]
        search: [soclab.local]

# Apply changes
sudo netplan apply
```

### Step 10: System Updates
**Open terminal (Ctrl+Alt+T) and update system:**
```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

### Step 11: Network Verification
**After reboot, test connectivity:**
```bash
# Check IP configuration
ip addr show
ip route show

# Test DNS resolution
nslookup soclab.local

# Test connectivity to Domain Controller  
ping 192.168.100.10

# Test internet connectivity (should fail - isolated lab)
ping 8.8.8.8
```

**Expected results:**
- IP: 192.168.100.30/24
- Gateway: 192.168.100.10
- DNS: Can resolve soclab.local
- Can ping Domain Controller
- No internet access (normal for isolated lab)

---

## Phase 3: Desktop Environment Optimization

### Step 12: Install Essential GUI and Server Tools
```bash
# Install server management tools
sudo apt install -y openssh-server curl wget vim htop net-tools tree

# Install GUI system monitoring tools
sudo apt install -y gnome-system-monitor gnome-disk-utility

# Install development and networking tools
sudo apt install -y git build-essential software-properties-common

# Install Java (required for Splunk)
sudo apt install -y openjdk-11-jre-headless openjdk-11-jdk-headless

# Verify installations
java -version
ssh -V
```

### Step 13: Configure SSH for Remote Management
```bash
# Enable and start SSH service
sudo systemctl enable ssh
sudo systemctl start ssh

# Check SSH status
sudo systemctl status ssh

# Configure SSH for security (optional but recommended)
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config
echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh
```

**Test SSH from your Windows host:**
```cmd
# From Windows Command Prompt or PowerShell
ssh siem-admin@192.168.100.30
```

### Step 14: Configure Firewall
```bash
# Install and configure UFW firewall
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (port 22)
sudo ufw allow ssh

# Allow Splunk web interface (port 8000)
sudo ufw allow 8000/tcp

# Allow Splunk receiving ports (for Windows Event Forwarding)
sudo ufw allow 9997/tcp

# Allow Splunk management port
sudo ufw allow 8089/tcp

# Check firewall status
sudo ufw status verbose
```

---

## Phase 4: SIEM User and Directory Setup

### Step 15: Create Splunk User and Directories
```bash
# Create dedicated user for Splunk
sudo useradd -r -m -U -d /opt/splunk -s /bin/bash splunk

# Set password for splunk user
sudo passwd splunk
# Enter secure password when prompted - document separately

# Create necessary directories
sudo mkdir -p /opt/splunk
sudo mkdir -p /opt/splunk/etc
sudo mkdir -p /opt/splunk/var

# Set permissions
sudo chown -R splunk:splunk /opt/splunk
```

### Step 16: System Optimization for SIEM Workload
```bash
# Increase file descriptor limits for SIEM workload
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Configure kernel parameters for better network performance
echo "net.core.rmem_max = 134217728" | sudo tee -a /etc/sysctl.conf
echo "net.core.wmem_max = 134217728" | sudo tee -a /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 5000" | sudo tee -a /etc/sysctl.conf

# Apply changes
sudo sysctl -p

# Create swap file for better performance (optional)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## Phase 5: Prepare for Splunk Installation

### Step 17: Download Splunk Free (Method 1 - If Internet Available)
```bash
# Create download directory
mkdir ~/Downloads/splunk

# If internet becomes available, download Splunk
cd ~/Downloads/splunk
wget -O splunk-free.tgz "https://download.splunk.com/products/splunk/releases/9.3.0/linux/splunk-9.3.0-51ccf43db5bd-linux-2.6-x86_64.tgz"
```

### Step 18: Transfer Splunk from Host (Current Method)
**Since we're in an isolated lab, transfer via VirtualBox shared folders:**

**On Host Windows Machine:**
1. **Download Splunk Free**: https://www.splunk.com/download/splunk-enterprise
2. **Save to**: `SOC_Lab\ISOs\splunk-free.tgz`

**Configure VirtualBox Shared Folder:**
1. **VM Settings** → **Shared Folders**
2. **Add folder**: `SOC_Lab\ISOs` → Mount as `/media/host-isos`
3. **Auto-mount**: ☑️ Yes
4. **Make Permanent**: ☑️ Yes

**In Ubuntu VM:**
```bash
# Install VirtualBox Guest Additions first
sudo apt install -y virtualbox-guest-additions-iso
sudo mkdir /media/host-isos

# Mount shared folder (may need VM restart)
sudo mount -t vboxsf host-isos /media/host-isos

# Copy Splunk to local directory
cp /media/host-isos/splunk-free.tgz ~/Downloads/
```

### Step 19: Desktop Environment Customization (Optional)
```bash
# Install useful GUI tools for SIEM management
sudo apt install -y firefox gnome-terminal gedit gnome-calculator

# Install terminal multiplexer for server management
sudo apt install -y tmux screen

# Create desktop shortcuts for common SIEM tasks
mkdir -p ~/Desktop

# Create Splunk Web shortcut (after Splunk installation)
cat > ~/Desktop/splunk-web.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Splunk Web Interface
Comment=Access Splunk SIEM Web Interface
Exec=firefox http://localhost:8000
Icon=web-browser
Terminal=false
Categories=Network;
EOF

chmod +x ~/Desktop/splunk-web.desktop
```

---

## Phase 6: GUI-Based System Monitoring Setup

### Step 20: Configure Desktop Monitoring Tools
```bash
# Install system monitoring applications
sudo apt install -y gnome-system-monitor htop iotop nethogs

# Install log viewing applications  
sudo apt install -y gnome-logs

# Create monitoring script for SIEM status
cat > ~/siem-status.sh << 'EOF'
#!/bin/bash
echo "=== SIEM Server Status ==="
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo ""
echo "=== Network Status ==="
ip addr show | grep "inet 192.168.100.30"
echo ""
echo "=== Memory Usage ==="
free -h
echo ""
echo "=== Disk Usage ==="
df -h /
echo ""
echo "=== Splunk Service Status ==="
sudo systemctl status Splunkd 2>/dev/null || echo "Splunk not yet installed"
echo ""
EOF

chmod +x ~/siem-status.sh
```

---

## Success Criteria Checklist

### Desktop Installation ✅
- [ ] Ubuntu Desktop 22.04 LTS installed successfully
- [ ] GUI desktop environment working
- [ ] Static IP configured (192.168.100.30)
- [ ] Can resolve soclab.local domain
- [ ] Can communicate with Domain Controller
- [ ] Desktop automatically logs in as siem-admin

### Server Capabilities ✅
- [ ] SSH server running and accessible
- [ ] Firewall configured (ports 8000, 9997, 8089)
- [ ] System optimized for SIEM workload
- [ ] Java installed and working
- [ ] Splunk user account created

### Desktop Tools ✅
- [ ] Firefox browser installed
- [ ] System monitoring tools available
- [ ] Terminal and development tools ready
- [ ] Shared folder configured for file transfer

---

## Troubleshooting Guide

### Network Configuration Issues
```bash
# Check current network settings
nmcli connection show

# Reset network configuration
sudo systemctl restart NetworkManager

# Manual IP configuration
sudo ip addr add 192.168.100.30/24 dev enp0s3
sudo ip route add default via 192.168.100.10
echo "nameserver 192.168.100.10" | sudo tee /etc/resolv.conf
```

### GUI Issues
```bash
# Restart desktop environment
sudo systemctl restart gdm3

# Check graphics driver
lspci | grep VGA
sudo ubuntu-drivers devices

# Reset to default desktop
dconf reset -f /org/gnome/
```

### SSH Connection Issues
```bash
# Check SSH service
sudo systemctl status ssh
sudo journalctl -u ssh

# Reset SSH configuration
sudo systemctl restart ssh

# Test SSH locally
ssh localhost
```

### VirtualBox Shared Folders
```bash
# Add user to vboxsf group
sudo usermod -a -G vboxsf siem-admin

# Manually mount shared folder
sudo mkdir -p /media/host-isos
sudo mount -t vboxsf host-isos /media/host-isos

# Make permanent
echo 'host-isos /media/host-isos vboxsf defaults 0 0' | sudo tee -a /etc/fstab
```

---

## Next Steps After Completion

1. **Install Splunk Free Edition** using GUI installer
2. **Configure Splunk Web Interface** (http://192.168.100.30:8000)
3. **Set up Windows Event Forwarding** from DC01 and WS01
4. **Create security dashboards** using Splunk Web GUI
5. **Configure alerting and monitoring** rules

---

## Advantages of Desktop vs Server

### Desktop Benefits:
- **GUI-based Splunk management** - easier configuration
- **Visual system monitoring** - better resource oversight
- **Browser-based access** - direct web interface access
- **Learning-friendly** - better for SOC training
- **Screenshot capabilities** - better for documentation

### Resource Requirements:
- **RAM**: 6GB (vs 4GB for server)
- **VRAM**: 256MB for GUI acceleration
- **Storage**: Same 25GB
- **CPU**: Same dual-core configuration

---

## Network Architecture After This Step:

```
Domain Controller (DC01)     SIEM Server (SIEM01)         Windows Client (WS01)
192.168.100.10          ←→   192.168.100.30           ←→   192.168.100.100+
- Windows Server 2022        - Ubuntu Desktop 22.04 LTS     - Windows 10 Enterprise  
- Active Directory           - Splunk SIEM + GUI           - Domain Joined
- DNS Server                 - SSH + Web Access            - Event Generation
- DHCP Server               - Desktop Environment          - Web Browser Access
```

**Estimated Total Time**: 60-90 minutes for complete Ubuntu Desktop setup