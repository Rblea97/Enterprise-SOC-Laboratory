# Active Directory Structure Setup Guide

## Overview
This guide creates a realistic corporate Active Directory structure for SOC analyst training, including Organizational Units (OUs), security groups, and test users that generate authentic security events.

## Prerequisites
- Domain Controller (DC01) running and accessible
- Domain: soclab.local
- Administrator access to Domain Controller

## ⚠️ Security Notice
**This guide contains placeholder password fields that must be replaced with secure passwords.**
- All passwords must be documented in a secure location (password manager recommended)
- Never use default or example passwords in production environments
- Refer to [SECURITY-NOTICE.md](../SECURITY-NOTICE.md) for complete security guidelines

---

## Phase 1: Create Organizational Unit Structure

### Step 1: Open Active Directory Users and Computers
1. **On Domain Controller VM**, open **Server Manager**
2. **Tools** → **Active Directory Users and Computers**
3. **Expand** `soclab.local` domain

### Step 2: Create Department OUs
**Right-click** `soclab.local` → **New** → **Organizational Unit**

Create these OUs in order:
1. **Name**: `Departments`
   - **Description**: Corporate Departments
2. **Name**: `Servers`
   - **Description**: Server Computer Accounts
3. **Name**: `Workstations`
   - **Description**: Client Computer Accounts
4. **Name**: `Service_Accounts`
   - **Description**: Service Account Storage

### Step 3: Create Sub-Department OUs
**Right-click** `Departments` OU → **New** → **Organizational Unit**

Create these sub-OUs:
1. **Name**: `IT_Department`
2. **Name**: `HR_Department`
3. **Name**: `Finance_Department`
4. **Name**: `Executive_Department`
5. **Name**: `Operations_Department`

---

## Phase 2: Create Security Groups

### Step 4: Create IT Security Groups
**Right-click** `IT_Department` OU → **New** → **Group**

**Group 1**: IT Staff
- **Group name**: `IT_Staff`
- **Group scope**: Global
- **Group type**: Security
- **Description**: IT Department Staff Members

**Group 2**: IT Administrators
- **Group name**: `IT_Administrators`
- **Group scope**: Global
- **Group type**: Security
- **Description**: IT Administrators with elevated privileges

**Group 3**: Server Administrators
- **Group name**: `Server_Administrators`
- **Group scope**: Global
- **Group type**: Security
- **Description**: Server management and maintenance

### Step 5: Create HR Security Groups
**Right-click** `HR_Department` OU → **New** → **Group**

**Group 1**: HR Staff
- **Group name**: `HR_Staff`
- **Group scope**: Global
- **Group type**: Security
- **Description**: Human Resources Department Staff

**Group 2**: HR Managers
- **Group name**: `HR_Managers`
- **Group scope**: Global
- **Group type**: Security
- **Description**: HR Management Team

### Step 6: Create Finance Security Groups
**Right-click** `Finance_Department` OU → **New** → **Group**

**Group 1**: Finance Staff
- **Group name**: `Finance_Staff`
- **Group scope**: Global
- **Group type**: Security
- **Description**: Finance Department Staff

**Group 2**: Finance Managers
- **Group name**: `Finance_Managers`
- **Group scope**: Global
- **Group type**: Security
- **Description**: Finance Management Team

### Step 7: Create Executive Security Groups
**Right-click** `Executive_Department` OU → **New** → **Group**

**Group 1**: Executives
- **Group name**: `Executives`
- **Group scope**: Global
- **Group type**: Security
- **Description**: C-Level and VP Executives

**Group 2**: Board Members
- **Group name**: `Board_Members`
- **Group scope**: Global
- **Group type**: Security
- **Description**: Board of Directors

### Step 8: Create Operations Security Groups
**Right-click** `Operations_Department` OU → **New** → **Group**

**Group 1**: Operations Staff
- **Group name**: `Operations_Staff`
- **Group scope**: Global
- **Group type**: Security
- **Description**: Daily Operations Staff

---

## Phase 3: Create User Accounts

### Step 9: Create IT Department Users
**Right-click** `IT_Department` OU → **New** → **User**

**User 1**: IT Administrator
- **First name**: John
- **Last name**: Doe  
- **User logon name**: `john.doe`
- **Password**: [Choose a strong IT admin password - document securely]
- **☑️ User must change password at next logon**: UNCHECKED
- **☑️ Password never expires**: CHECKED
- **Description**: Senior IT Administrator

**User 2**: IT Support
- **First name**: Mike
- **Last name**: Johnson
- **User logon name**: `mike.johnson`
- **Password**: [Choose a strong support password - document securely]
- **☑️ User must change password at next logon**: UNCHECKED
- **☑️ Password never expires**: CHECKED
- **Description**: IT Support Specialist

**User 3**: Network Admin
- **First name**: Sarah
- **Last name**: Wilson
- **User logon name**: `sarah.wilson`
- **Password**: [Choose a strong network admin password - document securely]
- **☑️ User must change password at next logon**: UNCHECKED
- **☑️ Password never expires**: CHECKED
- **Description**: Network Administrator

### Step 10: Create HR Department Users
**Right-click** `HR_Department` OU → **New** → **User**

**User 1**: HR Manager
- **First name**: Jane
- **Last name**: Smith
- **User logon name**: `jane.smith`
- **Password**: [Choose a strong HR manager password - document securely]
- **Description**: Human Resources Manager

**User 2**: HR Recruiter
- **First name**: Lisa
- **Last name**: Brown
- **User logon name**: `lisa.brown`
- **Password**: [Choose a strong HR recruiter password - document securely]
- **Description**: HR Recruitment Specialist

### Step 11: Create Finance Department Users
**Right-click** `Finance_Department` OU → **New** → **User**

**User 1**: Finance Manager
- **First name**: Bob
- **Last name**: Wilson
- **User logon name**: `bob.wilson`
- **Password**: [Choose a strong finance manager password - document securely]
- **Description**: Finance Department Manager

**User 2**: Accountant
- **First name**: Carol
- **Last name**: Davis
- **User logon name**: `carol.davis`
- **Password**: [Choose a strong accountant password - document securely]
- **Description**: Senior Accountant

### Step 12: Create Executive Users
**Right-click** `Executive_Department` OU → **New** → **User**

**User 1**: CEO
- **First name**: Alice
- **Last name**: Johnson
- **User logon name**: `alice.johnson`
- **Password**: [Choose a strong CEO password - document securely]
- **Description**: Chief Executive Officer

**User 2**: CTO  
- **First name**: David
- **Last name**: Martinez
- **User logon name**: `david.martinez`
- **Password**: [Choose a strong CTO password - document securely]
- **Description**: Chief Technology Officer

### Step 13: Create Operations Users
**Right-click** `Operations_Department` OU → **New** → **User**

**User 1**: Operations Manager
- **First name**: Tom
- **Last name**: Anderson
- **User logon name**: `tom.anderson`
- **Password**: [Choose a strong operations manager password - document securely]
- **Description**: Operations Manager

**User 2**: Regular User (Target for attacks)
- **First name**: Test
- **Last name**: User
- **User logon name**: `test.user`
- **Password**: [Choose a weak password for testing - document securely]
- **Description**: Standard Operations User

### Step 14: Create Service Accounts
**Right-click** `Service_Accounts` OU → **New** → **User**

**Service Account 1**: SQL Service
- **First name**: SQL
- **Last name**: Service
- **User logon name**: `sqlservice`
- **Password**: [Choose a strong SQL service password - document securely]
- **☑️ Password never expires**: CHECKED
- **Description**: SQL Server Service Account

**Service Account 2**: Backup Service
- **First name**: Backup
- **Last name**: Service  
- **User logon name**: `backupservice`
- **Password**: [Choose a strong backup service password - document securely]
- **☑️ Password never expires**: CHECKED
- **Description**: Backup Service Account

---

## Phase 4: Assign Group Memberships

### Step 15: Add Users to Security Groups

**IT_Administrators Group:**
1. **Right-click** `IT_Administrators` group → **Properties**
2. **Members** tab → **Add**
3. **Add these users**:
   - john.doe
   - sarah.wilson
4. **Click OK**

**IT_Staff Group:**
1. **Right-click** `IT_Staff` group → **Properties**  
2. **Members** tab → **Add**
3. **Add these users**:
   - john.doe
   - mike.johnson
   - sarah.wilson

**Server_Administrators Group:**
1. **Add**: john.doe, sarah.wilson

**HR_Managers Group:**
1. **Add**: jane.smith

**HR_Staff Group:**
1. **Add**: jane.smith, lisa.brown

**Finance_Managers Group:**
1. **Add**: bob.wilson

**Finance_Staff Group:**
1. **Add**: bob.wilson, carol.davis

**Executives Group:**
1. **Add**: alice.johnson, david.martinez

**Operations_Staff Group:**
1. **Add**: tom.anderson, test.user

### Step 16: Grant Administrative Privileges
**Add john.doe to Domain Admins:**
1. **Right-click** `Domain Admins` group (in Users container)
2. **Properties** → **Members** → **Add**
3. **Add**: john.doe
4. **Click OK**

---

## Phase 5: Configure Group Policies (Optional)

### Step 17: Create Basic Security Policies
1. **Server Manager** → **Tools** → **Group Policy Management**
2. **Right-click** `soclab.local` → **Create a GPO in this domain**
3. **Name**: `SOC_Lab_Security_Policy`
4. **Right-click** new GPO → **Edit**

**Configure these settings:**
- **Computer Configuration** → **Windows Settings** → **Security Settings** → **Account Policies** → **Password Policy**
  - Minimum password length: 8 characters
  - Password must meet complexity requirements: Enabled
  - Maximum password age: 90 days

---

## Phase 6: Move Computer Accounts

### Step 18: Organize Computer Accounts
1. **Find your computers** in the **Computers** container
2. **Right-click** `DC01-WINSERVER2022` → **Move**
3. **Select** `Servers` OU → **OK**
4. **Right-click** `WS01-WIN10ENTERPRISE` → **Move**  
5. **Select** `Workstations` OU → **OK**

---

## Verification and Testing

### Step 19: Test User Accounts
1. **On Windows 10 client**, try logging in with different users:
   ```
   SOCLAB\john.doe
   SOCLAB\jane.smith  
   SOCLAB\test.user
   ```

2. **Verify group memberships**:
   ```cmd
   whoami /groups
   ```

### Step 20: Generate Test Events
**Create some security events:**
1. **Failed login attempts** (wrong passwords)
2. **Successful logins** with different accounts
3. **File access** attempts  
4. **Administrative actions**

---

## Security Event Generation Ideas

### Common SOC Scenarios to Test:
1. **Failed Login Attempts**: Try wrong passwords for test.user
2. **Privilege Escalation**: Login as regular user, try admin tasks
3. **Account Lockouts**: Multiple failed attempts
4. **Off-hours Access**: Login during unusual times
5. **Service Account Usage**: Monitor service account activities

---

## Summary

### Created Structure:
- **5 Organizational Units**: Departments, Servers, Workstations, Service_Accounts + 5 sub-departments
- **12 Security Groups**: Department-based with management tiers
- **10 User Accounts**: Realistic corporate users with varying privileges  
- **2 Service Accounts**: For system services
- **1 Group Policy**: Basic security settings

### User Account Summary:
| Username | Department | Role | Admin Rights |
|----------|------------|------|--------------|
| john.doe | IT | Senior Admin | Domain Admin |
| mike.johnson | IT | Support | Local Admin |
| sarah.wilson | IT | Network Admin | Server Admin |
| jane.smith | HR | Manager | None |
| lisa.brown | HR | Recruiter | None |
| bob.wilson | Finance | Manager | None |
| carol.davis | Finance | Accountant | None |
| alice.johnson | Executive | CEO | None |  
| david.martinez | Executive | CTO | None |
| tom.anderson | Operations | Manager | None |
| test.user | Operations | User | None |

---

## Next Steps
After completing this AD structure:
1. **Test all user logins** from Windows 10 client
2. **Generate security events** for SIEM analysis
3. **Set up Ubuntu Server** for Splunk SIEM
4. **Configure event forwarding** to SIEM
5. **Create attack scenarios** using Kali Linux

**Estimated Time**: 60-90 minutes to complete all steps