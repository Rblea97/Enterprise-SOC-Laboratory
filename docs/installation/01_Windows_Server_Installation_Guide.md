# Windows Server 2022 Domain Controller Installation Guide

## Overview
This guide walks through installing Windows Server 2022 and configuring it as a Domain Controller for your SOC Lab.

## VM Configuration
- **Name**: DC01-WinServer2022
- **RAM**: 4GB
- **Storage**: 25GB
- **Network**: Internal network "SOC_Lab_Network"
- **Planned IP**: 192.168.100.10
- **RDP Port**: 5001

---

## Phase 1: Windows Server 2022 Installation

### Step 1: Initial Boot and Setup
1. **VM should boot from the Windows Server ISO**
2. **Language Selection**: English (United States) - Click "Next"
3. **Install Now**: Click "Install now"
4. **Product Key**: Click "I don't have a product key" (evaluation version)

### Step 2: Operating System Selection
**IMPORTANT**: Choose **"Windows Server 2022 Standard Evaluation (Desktop Experience)"**
- This provides the GUI interface
- Easier for beginners
- Required for many management tasks

### Step 3: License Terms
- Accept the license terms
- Click "Next"

### Step 4: Installation Type
- Select **"Custom: Install Windows only (advanced)"**
- This is a clean installation

### Step 5: Disk Configuration
- Select the 25GB disk (should be Drive 0 Unallocated Space)
- Click "Next"
- Windows will create partitions automatically

### Step 6: Installation Process
- Wait for installation (15-20 minutes)
- VM will reboot automatically
- **Do NOT press any key when prompted** - let it boot from hard disk

---

## Phase 2: Initial Windows Configuration

### Step 7: Administrator Password
**Create a strong password and DOCUMENT IT:**
```
Username: Administrator
Password: [Choose a strong password - suggestion: SOC_Lab_Admin123!]
```
**Write this down - you'll need it throughout the lab!**

### Step 8: First Login
- Press Ctrl+Alt+Del to unlock
- Login with Administrator account

### Step 9: Initial Configuration Tasks
When Server Manager opens:
1. **Skip** Windows Admin Center setup (for now)
2. **Skip** feedback popup
3. Leave Server Manager open - we'll use it next

---

## Phase 3: Network Configuration

### Step 10: Configure Static IP Address
1. **Open Network Settings**:
   - Click the network icon in system tray
   - Click "Network & Internet settings"
   - Click "Ethernet" in left panel
   - Click "Change adapter options"

2. **Configure Ethernet Adapter**:
   - Right-click "Ethernet" → Properties
   - Double-click "Internet Protocol Version 4 (TCP/IPv4)"
   - Select "Use the following IP address"

3. **Enter Network Settings**:
   ```
   IP Address: 192.168.100.10
   Subnet Mask: 255.255.255.0
   Default Gateway: [Leave blank for now]
   Preferred DNS: 127.0.0.1 (localhost - this server will be DNS)
   Alternate DNS: [Leave blank]
   ```
   
4. **Apply and Close**
   - Click OK on all dialogs
   - Close Network Connections window

### Step 11: Test Network Configuration
1. **Open Command Prompt as Administrator**
2. **Test IP configuration**:
   ```cmd
   ipconfig /all
   ```
   Verify IP address is 192.168.100.10

---

## Phase 4: Domain Controller Promotion

### Step 12: Install Active Directory Domain Services
1. **In Server Manager**:
   - Click "Add roles and features"
   - Click "Next" (Before You Begin)
   - Select "Role-based or feature-based installation"
   - Click "Next"

2. **Server Selection**:
   - Your server should be selected (DC01-WINSERVER2022)
   - Click "Next"

3. **Server Roles**:
   - Check **"Active Directory Domain Services"**
   - Click "Add Features" when prompted
   - Click "Next"

4. **Features**:
   - Leave defaults
   - Click "Next"

5. **AD DS Information**:
   - Read the information
   - Click "Next"

6. **Confirmation**:
   - Click "Install"
   - **Wait for installation** (5-10 minutes)
   - **Do NOT close** when finished

### Step 13: Promote Server to Domain Controller
1. **In Server Manager**, look for yellow warning flag
2. **Click the flag** → "Promote this server to a domain controller"

3. **Deployment Configuration**:
   - Select **"Add a new forest"**
   - Root domain name: `soclab.local`
   - Click "Next"

4. **Domain Controller Options**:
   - Forest/Domain functional level: Windows Server 2016 (or higher)
   - Check both "Domain Name System (DNS) server" and "Global Catalog (GC)"
   - **DSRM Password**: Use same as Administrator password
   - Click "Next"

5. **DNS Options**:
   - **Ignore the warning** about DNS delegation
   - Click "Next"

6. **Additional Options**:
   - NetBIOS name should be "SOCLAB"
   - Click "Next"

7. **Paths**:
   - Leave default paths
   - Click "Next"

8. **Review Options**:
   - Review configuration
   - Click "Next"

9. **Prerequisites Check**:
   - **Wait for checks** to complete
   - **Ignore warnings** about DNS and network adapter
   - Click "Install"

10. **Installation and Reboot**:
    - Wait for installation (10-15 minutes)
    - Server will **automatically reboot**

---

## Phase 5: Post-Promotion Configuration

### Step 14: Login to Domain Controller
1. **After reboot**, you'll see domain login screen
2. **Login as**: `SOCLAB\Administrator`
3. **Password**: Your administrator password

### Step 15: Verify Domain Controller Installation
1. **Open Server Manager**
2. **Check Services**: Should show "AD DS" and "DNS" roles installed
3. **Open Command Prompt**:
   ```cmd
   dcdiag /v
   ```
   Should show all tests passing

### Step 16: Configure DNS Forwarders
1. **Open DNS Manager**:
   - Server Manager → Tools → DNS
2. **Configure Forwarders**:
   - Right-click your server name → Properties
   - Click "Forwarders" tab
   - Click "Edit"
   - Add: 8.8.8.8 and 1.1.1.1
   - Click OK

---

## Phase 6: DHCP Server Installation

### Step 17: Install DHCP Server Role
1. **Server Manager** → "Add roles and features"
2. **Follow wizard**:
   - Role-based installation
   - Select your server
   - Check **"DHCP Server"**
   - Add Features when prompted
   - Install

### Step 18: Configure DHCP Scope
1. **Complete DHCP Post-Install**:
   - Click yellow flag in Server Manager
   - "Complete DHCP configuration"
   - Use SOCLAB\Administrator credentials
   - Commit

2. **Configure DHCP Scope**:
   - Tools → DHCP
   - Expand your server → IPv4
   - Right-click "IPv4" → New Scope
   
3. **Scope Configuration**:
   - Name: SOC_Lab_Network
   - IP Range: 192.168.100.100 to 192.168.100.200
   - Subnet: 255.255.255.0
   - Exclude: 192.168.100.1 to 192.168.100.99 (for servers)
   - Lease: 8 hours
   - Router: 192.168.100.10 (this server)
   - DNS: 192.168.100.10 (this server)
   - Activate scope: Yes

---

## Success Criteria Checklist

- [ ] Windows Server 2022 installed successfully
- [ ] Static IP configured (192.168.100.10)
- [ ] Domain Controller promoted (soclab.local)
- [ ] DNS services running
- [ ] DHCP services running and configured
- [ ] Server accessible via RDP on port 5001
- [ ] Server Manager shows AD DS and DNS roles

## Troubleshooting Tips

### Network Issues
- Ensure VM is on "SOC_Lab_Network" internal network
- Verify IP configuration with `ipconfig /all`

### Domain Controller Issues
- Check Event Viewer for errors
- Run `dcdiag` command for diagnostics
- Verify DNS is pointing to 127.0.0.1

### DHCP Issues
- Verify DHCP scope is active
- Check DHCP console for leases
- Ensure scope range doesn't conflict with static IPs

---

## Next Steps
Once this installation is complete, we'll:
1. Create Windows 10 client VM
2. Join client to domain
3. Set up Active Directory users and groups
4. Configure security policies

**Estimated Time**: 45-60 minutes for complete installation