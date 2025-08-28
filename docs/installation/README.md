# SOC Lab Installation Guides

Complete step-by-step installation documentation for building the Enterprise SOC Laboratory environment.

## 📋 **Installation Order**

Follow these guides in sequence to build the complete lab environment:

### Phase 1: Infrastructure Foundation

1. **[Windows Server 2022 Domain Controller](01_Windows_Server_Installation_Guide.md)**
   - Base server installation and configuration
   - Active Directory domain services setup
   - DNS and DHCP configuration
   - **Estimated Time:** 2-3 hours

2. **[Windows 10 Enterprise Client](02_Windows_10_Client_Installation_Guide.md)**  
   - Client workstation installation
   - Domain join procedures
   - User account configuration
   - **Estimated Time:** 1-2 hours

3. **[Active Directory Structure](03_Active_Directory_Structure_Setup.md)**
   - Organizational unit creation
   - User and group management
   - Group policy configuration
   - **Estimated Time:** 1-2 hours

### Phase 2: SIEM Platform Deployment

4. **[Ubuntu SIEM Platform](04_Ubuntu_Desktop_SIEM_Installation_Guide.md)**
   - Ubuntu Linux installation with desktop environment
   - Splunk Enterprise installation and configuration
   - Network configuration and testing
   - **Estimated Time:** 2-3 hours

5. **[Windows Event Forwarding](05_Windows_Event_Forwarding_Setup.md)**
   - WEF configuration on Windows systems
   - Splunk Universal Forwarder deployment
   - Log ingestion testing and verification
   - **Estimated Time:** 1-2 hours

## 🛠️ **Prerequisites & Requirements**

### Hardware Requirements
- **Minimum:** 16GB RAM, 500GB available disk space
- **Recommended:** 32GB RAM, 1TB available disk space
- **Processor:** Intel VT-x or AMD-V virtualization support required

### Software Requirements
- **VirtualBox 7.0+** with Extension Pack
- **Operating System ISOs:**
  - Windows Server 2022 (Evaluation edition available)
  - Windows 10 Enterprise (Evaluation edition available)  
  - Ubuntu 22.04 LTS Desktop
  - Kali Linux (optional for red team scenarios)

### Network Configuration
- **Isolated Virtual Network:** Prevents interference with host networking
- **Static IP Assignments:** Domain controller and SIEM platform
- **DHCP Range:** 192.168.100.100-200 for dynamic client assignment

## 📊 **Deployment Validation**

After completing all installation guides, verify these capabilities:

### ✅ **System Connectivity**
- [ ] All VMs can communicate on internal network
- [ ] DNS resolution working for domain names
- [ ] DHCP providing IP addresses to clients

### ✅ **Domain Services**  
- [ ] Windows client successfully joined to domain
- [ ] Domain user authentication functional
- [ ] Active Directory users and computers accessible

### ✅ **SIEM Operations**
- [ ] Splunk web interface accessible
- [ ] Windows Event Logs flowing to Splunk
- [ ] Basic searches returning security events
- [ ] Authentication events visible in logs

### ✅ **Security Monitoring**
- [ ] Failed login attempts detected in Splunk
- [ ] Administrative activity logged and searchable
- [ ] System events flowing from both Windows systems

## 🔧 **Troubleshooting Resources**

### Common Issues
- **VM Networking Problems:** Check virtual network adapter settings
- **Domain Join Failures:** Verify DNS resolution and time synchronization
- **Splunk Connection Issues:** Check firewall settings and network connectivity
- **Log Forwarding Problems:** Verify WEF configuration and forwarder installation

### Support Documentation
- Detailed troubleshooting steps included in each installation guide
- Network configuration validation procedures
- Performance optimization recommendations

## 📈 **Post-Installation Development**

### Immediate Next Steps
1. **Create Security Dashboards** - Build SOC operations interface
2. **Configure Alert Rules** - Set up automated threat detection
3. **Test Attack Scenarios** - Validate monitoring effectiveness
4. **Document Procedures** - Create investigation and response playbooks

### Advanced Enhancements
1. **Red Team Integration** - Deploy Kali Linux attack platform
2. **Advanced Analytics** - Implement correlation rules and behavioral detection
3. **External Integration** - Connect threat intelligence feeds
4. **Compliance Reporting** - Automate security metrics collection

---

**Total Installation Time:** 8-12 hours for complete lab environment  
**Skill Level:** Intermediate (basic Windows/Linux administration knowledge helpful)  
**Result:** Fully functional enterprise SOC laboratory ready for security operations training