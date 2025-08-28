# Windows Event Forwarding Setup Guide
## SOC Analyst Home Lab - SIEM Integration

## Overview
This guide configures Windows Event Forwarding (WEF) to send security logs from your Windows machines to the Ubuntu SIEM server for analysis in Splunk.

## Prerequisites
- Domain Controller (DC01) running with AD structure complete
- Windows 10 Client (WS01) domain-joined
- Ubuntu SIEM (SIEM01) with Splunk installed
- All VMs on 192.168.100.x network

---

## Architecture Overview

```
Windows Machines → Windows Event Forwarding → Splunk Universal Forwarder → Ubuntu SIEM (Splunk)
DC01 (192.168.100.10) ──────────────────────────────────────────────→ SIEM01 (192.168.100.30)
WS01 (192.168.100.100+) ─────────────────────────────────────────────→ SIEM01 (192.168.100.30)
```

---

## Phase 1: Configure Domain Controller Event Collection

### Step 1: Enable WinRM on Domain Controller
**On DC01 (Domain Controller):**

```powershell
# Open PowerShell as Administrator
# Enable Windows Remote Management
winrm quickconfig -force

# Configure WinRM for domain authentication
winrm set winrm/config/client '@{TrustedHosts="*"}'
winrm set winrm/config/service/auth '@{Kerberos="true"}'

# Start and configure WinRM service
Start-Service WinRM
Set-Service WinRM -StartupType Automatic

# Check WinRM configuration
winrm get winrm/config
```

### Step 2: Enable Windows Event Collector Service
```powershell
# Enable and start Windows Event Collector service
Enable-PSRemoting -Force
wecutil qc /q

# Start the service
Start-Service Wecsvc
Set-Service Wecsvc -StartupType Automatic

# Verify service status
Get-Service Wecsvc
```

### Step 3: Create Event Subscription
```powershell
# Create subscription configuration file
$SubscriptionConfig = @"
<Subscription xmlns="http://schemas.microsoft.com/2006/03/windows/events/subscription">
    <SubscriptionId>SOCLabSecurityLogs</SubscriptionId>
    <SubscriptionType>SourceInitiated</SubscriptionType>
    <Description>SOC Lab Security Event Collection</Description>
    <Enabled>true</Enabled>
    <Uri>http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog</Uri>
    <ConfigurationMode>Normal</ConfigurationMode>
    <Delivery Mode="Push">
        <Batching>
            <MaxItems>20</MaxItems>
            <MaxLatencyTime>10000</MaxLatencyTime>
        </Batching>
        <PushSettings>
            <Heartbeat Interval="60000" />
        </PushSettings>
    </Delivery>
    <Query>
        <![CDATA[
            <QueryList>
                <Query Id="0">
                    <Select Path="Security">*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]</Select>
                    <Select Path="System">*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]</Select>
                    <Select Path="Application">*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]</Select>
                    <Select Path="Windows PowerShell">*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]</Select>
                </Query>
            </QueryList>
        ]]>
    </Query>
    <ReadExistingEvents>false</ReadExistingEvents>
    <TransportName>HTTP</TransportName>
    <ContentFormat>Events</ContentFormat>
    <Locale Language="en-US"/>
    <LogFile>ForwardedEvents</LogFile>
    <PublisherName>Microsoft-Windows-EventCollector</PublisherName>
    <AllowedSourceNonDomainComputers></AllowedSourceNonDomainComputers>
    <AllowedSourceDomainComputers>O:NSG:NSD:(A;;GA;;;DC)(A;;GA;;;NS)(A;;GA;;;DD)</AllowedSourceDomainComputers>
</Subscription>
"@

# Save configuration to file
$SubscriptionConfig | Out-File -FilePath "C:\SOC_Lab_Subscription.xml" -Encoding UTF8

# Create the subscription
wecutil cs C:\SOC_Lab_Subscription.xml

# Verify subscription
wecutil gs SOCLabSecurityLogs
```

---

## Phase 2: Configure Windows 10 Client Event Forwarding

### Step 4: Configure WS01 Client for Event Forwarding
**On WS01 (Windows 10 Client):**

```powershell
# Open PowerShell as Administrator
# Enable WinRM
winrm quickconfig -force

# Configure client for event forwarding
winrm set winrm/config/client '@{TrustedHosts="DC01.soclab.local"}'

# Add DC01 as event collector
wecutil qc /q

# Configure subscription source
wecutil ss SOCLabSecurityLogs /e:true

# Test connectivity to collector
Test-NetConnection -ComputerName "192.168.100.10" -Port 5985
```

### Step 5: Configure Group Policy for Event Forwarding
**On DC01 (Domain Controller):**

```powershell
# Create GPO for Event Forwarding
New-GPO -Name "SOC Lab Event Forwarding" -Comment "Configure Windows Event Forwarding for SOC Lab"

# Edit the GPO settings (manual configuration required)
```

**Manual GPO Configuration:**
1. **Server Manager** → **Tools** → **Group Policy Management**
2. **Right-click** "SOC Lab Event Forwarding" → **Edit**
3. **Navigate to**: Computer Configuration → Policies → Administrative Templates → Windows Components → Event Forwarding
4. **Enable**: "Configure target Subscription Manager"
5. **Set to**: `Server=http://DC01.soclab.local:5985/wsman/SubscriptionManager/WEC,Refresh=60`

---

## Phase 3: Install Splunk Universal Forwarder on Windows

### Step 6: Download and Install Splunk Universal Forwarder
**On both DC01 and WS01:**

1. **Download Splunk Universal Forwarder** from host:
   - Save to: `SOC_Lab\ISOs\splunkforwarder-9.3.0-win64.msi`

2. **Transfer to VMs via shared folder** or download directly

3. **Install on each Windows VM:**
```cmd
# Run installer with these settings:
# Installation Directory: C:\Program Files\SplunkUniversalForwarder
# Run as Local System: Yes
# Receiving Indexer: 192.168.100.30:9997
# Admin Username: admin
# Admin Password: SplunkForwarder2024!
```

### Step 7: Configure Splunk Universal Forwarder
**On both DC01 and WS01:**

```cmd
# Navigate to Splunk installation
cd "C:\Program Files\SplunkUniversalForwarder\bin"

# Configure deployment server (Ubuntu SIEM)
splunk set deploy-poll 192.168.100.30:8089

# Configure forwarding to indexer
splunk add forward-server 192.168.100.30:9997

# Configure Windows Event Log monitoring
splunk add monitor WinEventLog:Security
splunk add monitor WinEventLog:System  
splunk add monitor WinEventLog:Application
splunk add monitor WinEventLog:ForwardedEvents

# Restart Splunk Universal Forwarder
splunk restart
```

### Step 8: Create Splunk Configuration Files
**Create inputs.conf on both Windows machines:**

```cmd
# Create inputs.conf file
cd "C:\Program Files\SplunkUniversalForwarder\etc\system\local"
notepad inputs.conf
```

**Content for inputs.conf:**
```ini
[WinEventLog:Security]
disabled = false
start_from = oldest
current_only = false
checkpointInterval = 5
index = windows_security

[WinEventLog:System]
disabled = false  
start_from = oldest
current_only = false
index = windows_system

[WinEventLog:Application]
disabled = false
start_from = oldest
current_only = false
index = windows_application

[WinEventLog:ForwardedEvents]
disabled = false
start_from = oldest
current_only = false
index = windows_forwarded

[default]
host = DC01
# Change host value to WS01 on the Windows 10 client

[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = 192.168.100.30:9997

[tcpout-server://192.168.100.30:9997]
```

---

## Phase 4: Configure Ubuntu SIEM to Receive Data

### Step 9: Configure Splunk on Ubuntu SIEM
**On SIEM01 (Ubuntu):**

```bash
# Access Splunk via SSH or desktop terminal
sudo -u splunk /opt/splunk/bin/splunk start

# Enable receiving port
sudo -u splunk /opt/splunk/bin/splunk enable listen 9997 -auth admin:changeme

# Create indexes for Windows events
sudo -u splunk /opt/splunk/bin/splunk add index windows_security -auth admin:changeme
sudo -u splunk /opt/splunk/bin/splunk add index windows_system -auth admin:changeme
sudo -u splunk /opt/splunk/bin/splunk add index windows_application -auth admin:changeme
sudo -u splunk /opt/splunk/bin/splunk add index windows_forwarded -auth admin:changeme

# Configure firewall
sudo ufw allow 9997/tcp
sudo ufw allow 8089/tcp

# Restart Splunk
sudo -u splunk /opt/splunk/bin/splunk restart
```

### Step 10: Configure Splunk Web Interface for Windows Events
**Access Splunk Web Interface:**
1. **Open browser** to: `http://192.168.100.30:8000`
2. **Login**: admin / changeme (change on first login)

**Configure Data Inputs:**
1. **Settings** → **Data Inputs**
2. **TCP** → **9997** → **Enable**
3. **Set Source Type**: Automatic
4. **Set Index**: windows_security (for security events)

---

## Phase 5: Verification and Testing

### Step 11: Verify Event Flow
**On Ubuntu SIEM (Splunk):**

```bash
# Check Splunk logs for incoming connections
sudo -u splunk tail -f /opt/splunk/var/log/splunk/splunkd.log | grep -i connection

# Search for Windows events in Splunk Web
# Go to Search & Reporting app
# Search: index=windows_* earliest=-1h
```

**Search Queries for Testing:**
```spl
# All Windows events from last hour
index=windows_* earliest=-1h

# Security events only
index=windows_security earliest=-1h

# Failed login attempts
index=windows_security EventCode=4625 earliest=-1h

# Successful logins  
index=windows_security EventCode=4624 earliest=-1h

# Administrative activities
index=windows_security EventCode=4672 earliest=-1h
```

### Step 12: Generate Test Events
**Create security events for testing:**

1. **Failed Login Attempts:**
   - Try logging into WS01 with wrong password
   - Use: `SOCLAB\test.user` with incorrect password

2. **Successful Administrative Login:**
   - Login as `SOCLAB\john.doe` on WS01

3. **Service Account Activities:**
   - Start/stop services on DC01

4. **File Access Events:**
   - Enable file auditing and access sensitive files

---

## Troubleshooting Guide

### Common Issues and Solutions

**Issue 1: No events appearing in Splunk**
```bash
# Check Splunk receiving status
sudo -u splunk /opt/splunk/bin/splunk list inputstatus

# Verify network connectivity
telnet 192.168.100.30 9997

# Check Windows forwarder logs
cd "C:\Program Files\SplunkUniversalForwarder\var\log\splunk"
type splunkd.log | findstr ERROR
```

**Issue 2: Windows Event Forwarding not working**
```powershell
# Check WEC subscription status
wecutil gr SOCLabSecurityLogs

# Verify WinRM connectivity
winrm enumerate winrm/config/listener

# Test event forwarding
Get-WinEvent -LogName "ForwardedEvents" | Select-Object -First 10
```

**Issue 3: Splunk Universal Forwarder connection issues**
```cmd
# Check forwarder status
cd "C:\Program Files\SplunkUniversalForwarder\bin"
splunk status

# Test connection to indexer
splunk btool server list | findstr 9997

# Restart forwarder service
net stop SplunkForwarder
net start SplunkForwarder
```

---

## Success Criteria

### Verification Checklist
- [ ] Windows Event Collector service running on DC01
- [ ] Event subscription created and active  
- [ ] WS01 client configured for event forwarding
- [ ] Splunk Universal Forwarder installed on both Windows VMs
- [ ] Forwarders connecting to Ubuntu SIEM on port 9997
- [ ] Security events visible in Splunk web interface
- [ ] All Windows event indexes populated with data
- [ ] Test authentication events captured and searchable

---

## Next Steps

After successful event forwarding:
1. **Create Splunk Dashboards** for security monitoring
2. **Set up Alerting Rules** for suspicious activities  
3. **Install Kali Linux** for attack simulation
4. **Create Investigation Playbooks** for SOC scenarios
5. **Document Attack Scenarios** and detection methods

**Estimated Time for Setup**: 90-120 minutes for complete event forwarding configuration

---

## Important Security Events to Monitor

### Authentication Events
- **4624**: Successful Logon
- **4625**: Failed Logon
- **4634**: Account Logoff
- **4672**: Admin Login

### Account Management
- **4720**: User Account Created
- **4726**: User Account Deleted
- **4728**: User Added to Security Group

### System Events  
- **4697**: Service Installation
- **7034**: Service Crash
- **7035**: Service Start/Stop

### PowerShell Events
- **4103**: PowerShell Script Execution
- **4104**: PowerShell Script Block Logging

These events will provide rich data for SOC analysis and attack detection scenarios.