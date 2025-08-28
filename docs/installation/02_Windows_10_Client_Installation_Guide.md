# Windows 10 Enterprise Client Installation Guide

## Overview
This guide walks through installing Windows 10 Enterprise and joining it to your SOC Lab domain.

## VM Configuration
- **Name**: WS01-Win10Enterprise
- **RAM**: 3GB
- **Storage**: 20GB
- **Network**: Internal network "SOC_Lab_Network"
- **Expected IP**: DHCP assigned (192.168.100.100-200 range)
- **RDP Port**: 5002

---

## Phase 1: Windows 10 Installation

### Step 1: Initial Boot and Setup
1. **VM should boot from Windows 10 ISO**
2. **Language Selection**: English (United States) - Click "Next"
3. **Install Now**: Click "Install now"
4. **Product Key**: Click "I don't have a product key"

### Step 2: Operating System Selection
**Choose**: **"Windows 10 Enterprise"** (not Pro, not Home)
- This edition supports domain joining
- Provides enterprise security features

### Step 3: License Terms
- Accept the license terms
- Click "Next"

### Step 4: Installation Type
- Select **"Custom: Install Windows only (advanced)"**
- Clean installation on empty disk

### Step 5: Disk Configuration
- Select the 20GB disk (Drive 0 Unallocated Space)
- Click "Next"
- Windows will create partitions automatically

### Step 6: Installation Process
- Wait for installation (10-15 minutes)
- VM will reboot automatically
- Do NOT press any key when prompted

---

## Phase 2: Windows 10 Initial Setup (OOBE)

### Step 7: Out-of-Box Experience
1. **Region**: United States
2. **Keyboard**: US
3. **Second keyboard**: Skip
4. **Network**: Skip for now (we'll configure manually)

### Step 8: Account Setup
**IMPORTANT**: Choose **"Set up for an organization"**
- This allows easier domain joining later
- **Don't sign in with Microsoft account**

### Step 9: Local Account Creation
1. **Name**: `localadmin`
2. **Password**: [Choose a secure password - document separately]
3. **Security Questions**: Answer all three
4. **Privacy Settings**: Turn off all options for security

### Step 10: Skip Microsoft Services
- **Cortana**: No
- **Activity History**: No
- Skip all optional services

---

## Phase 3: Network Configuration

### Step 11: Configure Network Settings
1. **Click network icon** in system tray
2. **Click "Network & Internet settings"**
3. **Click "Ethernet"** in left panel
4. **Click "Change adapter options"**

### Step 12: Verify DHCP Configuration
1. **Right-click "Ethernet"** → Properties
2. **Double-click "Internet Protocol Version 4 (TCP/IPv4)"**
3. **Verify settings**:
   ```
   ☑️ Obtain an IP address automatically
   ☑️ Obtain DNS server address automatically
   ```

### Step 13: Test Network Connectivity
1. **Open Command Prompt**
2. **Test DHCP assignment**:
   ```cmd
   ipconfig /all
   ```
   **Expected Results**:
   - IP Address: 192.168.100.100-200 range
   - Subnet Mask: 255.255.255.0
   - Default Gateway: 192.168.100.10
   - DNS Servers: 192.168.100.10

3. **Test Domain Controller connectivity**:
   ```cmd
   ping 192.168.100.10
   nslookup soclab.local
   ```

---

## Phase 4: Domain Join Process

### Step 14: Join Computer to Domain
1. **Right-click "This PC"** → Properties
2. **Click "Change settings"** (under Computer name, domain, and workgroup settings)
3. **Click "Change"**

### Step 15: Domain Configuration
1. **Select "Domain"**
2. **Enter domain name**: `soclab.local`
3. **Click "OK"**

### Step 16: Domain Credentials
**Enter Domain Admin credentials**:
- **Username**: `Administrator`
- **Password**: [Your Domain Controller password]
- **Click "OK"**

### Step 17: Welcome Message
You should see: **"Welcome to the soclab.local domain"**
- **Click "OK"**
- **Click "OK"** on restart message
- **Click "Restart Now"**

---

## Phase 5: Post-Domain Join Configuration

### Step 18: Domain Login
**After restart**:
1. **Click "Other user"** on login screen
2. **Username**: `SOCLAB\Administrator`
3. **Password**: [Your Domain Controller password]

### Step 19: Verify Domain Join
1. **Open Command Prompt**
2. **Verify domain membership**:
   ```cmd
   whoami
   echo %COMPUTERNAME%
   echo %USERDOMAIN%
   ```

### Step 20: Windows Updates
1. **Settings** → **Update & Security**
2. **Check for updates**
3. **Install all available updates**
4. **Restart if required**

---

## Phase 6: Security Configuration

### Step 21: Enable Windows Defender
1. **Settings** → **Update & Security** → **Windows Security**
2. **Virus & threat protection**: Ensure enabled
3. **Firewall & network protection**: Ensure enabled
4. **App & browser control**: Leave defaults

### Step 22: Configure Event Logging
1. **Right-click Start** → **Event Viewer**
2. **Expand Windows Logs**
3. **Verify these logs exist**:
   - Application
   - Security
   - System
   - Setup

### Step 23: Create Local Users (Testing)
1. **Settings** → **Accounts** → **Family & other users**
2. **Add someone else to this PC**
3. **"I don't have this person's sign-in information"**
4. **"Add a user without a Microsoft account"**
5. **Create test user**:
   - Username: `testuser`
   - Password: [Choose a test password]

---

## Success Criteria Checklist

- [ ] Windows 10 Enterprise installed successfully
- [ ] Network configured via DHCP
- [ ] Successfully joined to soclab.local domain
- [ ] Can login with domain administrator account
- [ ] DNS resolution working for domain
- [ ] Event logs generating properly
- [ ] Windows Defender enabled
- [ ] Local test user created

---

## Troubleshooting

### Network Issues
```cmd
ipconfig /release
ipconfig /renew
ipconfig /flushdns
```

### Domain Join Issues
- Ensure Domain Controller is running
- Verify time synchronization: `w32tm /resync`
- Check DNS: `nslookup soclab.local`

### Login Issues
- Use format: `SOCLAB\username`
- Verify caps lock is off
- Try local login first: `.\localadmin`

---

## Next Steps
After completing Windows 10 setup:
1. Set up Active Directory users and groups
2. Configure security policies
3. Install SIEM monitoring
4. Create Ubuntu Server for Splunk

**Estimated Time**: 30-45 minutes