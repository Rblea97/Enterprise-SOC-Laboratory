# Active Directory Structure Setup Script
# SOC Analyst Home Lab - Automated AD Configuration
# Run this script on the Domain Controller (DC01) as Administrator

Write-Host "=== SOC Lab Active Directory Structure Setup ===" -ForegroundColor Cyan
Write-Host "Domain: soclab.local" -ForegroundColor Yellow
Write-Host "Starting AD structure creation..." -ForegroundColor Green
Write-Host ""

# Import Active Directory module
Import-Module ActiveDirectory

# Get domain DN
$Domain = Get-ADDomain
$DomainDN = $Domain.DistinguishedName
Write-Host "Domain DN: $DomainDN" -ForegroundColor Yellow

# Phase 1: Create Organizational Units
Write-Host "Phase 1: Creating Organizational Units..." -ForegroundColor Cyan

$OUs = @(
    @{Name="Departments"; Description="Corporate Departments"},
    @{Name="Servers"; Description="Server Computer Accounts"},
    @{Name="Workstations"; Description="Client Computer Accounts"},
    @{Name="Service_Accounts"; Description="Service Account Storage"}
)

foreach ($OU in $OUs) {
    try {
        New-ADOrganizationalUnit -Name $OU.Name -Description $OU.Description -Path $DomainDN -PassThru
        Write-Host "Created OU: $($OU.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "OU $($OU.Name) may already exist: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Create Department Sub-OUs
$DepartmentOUs = @(
    @{Name="IT_Department"; Description="Information Technology Department"},
    @{Name="HR_Department"; Description="Human Resources Department"},
    @{Name="Finance_Department"; Description="Finance Department"},
    @{Name="Executive_Department"; Description="Executive Leadership"},
    @{Name="Operations_Department"; Description="Daily Operations Staff"}
)

$DepartmentsPath = "OU=Departments,$DomainDN"
foreach ($DeptOU in $DepartmentOUs) {
    try {
        New-ADOrganizationalUnit -Name $DeptOU.Name -Description $DeptOU.Description -Path $DepartmentsPath -PassThru
        Write-Host "Created Department OU: $($DeptOU.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Department OU $($DeptOU.Name) may already exist: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Start-Sleep -Seconds 2

# Phase 2: Create Security Groups
Write-Host "`nPhase 2: Creating Security Groups..." -ForegroundColor Cyan

$SecurityGroups = @(
    # IT Groups
    @{Name="IT_Staff"; Path="OU=IT_Department,OU=Departments,$DomainDN"; Description="IT Department Staff Members"},
    @{Name="IT_Administrators"; Path="OU=IT_Department,OU=Departments,$DomainDN"; Description="IT Administrators with elevated privileges"},
    @{Name="Server_Administrators"; Path="OU=IT_Department,OU=Departments,$DomainDN"; Description="Server management and maintenance"},
    
    # HR Groups
    @{Name="HR_Staff"; Path="OU=HR_Department,OU=Departments,$DomainDN"; Description="Human Resources Department Staff"},
    @{Name="HR_Managers"; Path="OU=HR_Department,OU=Departments,$DomainDN"; Description="HR Management Team"},
    
    # Finance Groups
    @{Name="Finance_Staff"; Path="OU=Finance_Department,OU=Departments,$DomainDN"; Description="Finance Department Staff"},
    @{Name="Finance_Managers"; Path="OU=Finance_Department,OU=Departments,$DomainDN"; Description="Finance Management Team"},
    
    # Executive Groups
    @{Name="Executives"; Path="OU=Executive_Department,OU=Departments,$DomainDN"; Description="C-Level and VP Executives"},
    @{Name="Board_Members"; Path="OU=Executive_Department,OU=Departments,$DomainDN"; Description="Board of Directors"},
    
    # Operations Groups
    @{Name="Operations_Staff"; Path="OU=Operations_Department,OU=Departments,$DomainDN"; Description="Daily Operations Staff"}
)

foreach ($Group in $SecurityGroups) {
    try {
        New-ADGroup -Name $Group.Name -GroupCategory Security -GroupScope Global -Path $Group.Path -Description $Group.Description
        Write-Host "Created Security Group: $($Group.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Security Group $($Group.Name) may already exist: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Start-Sleep -Seconds 2

# Phase 3: Create User Accounts
Write-Host "`nPhase 3: Creating User Accounts..." -ForegroundColor Cyan

$Users = @(
    # IT Department Users
    @{
        FirstName="John"; LastName="Doe"; Username="john.doe"; 
        Password="ITAdmin2024!"; Department="IT_Department"; 
        Description="Senior IT Administrator"; Title="IT Administrator"
    },
    @{
        FirstName="Mike"; LastName="Johnson"; Username="mike.johnson"; 
        Password="ITSupport2024!"; Department="IT_Department"; 
        Description="IT Support Specialist"; Title="IT Support"
    },
    @{
        FirstName="Sarah"; LastName="Wilson"; Username="sarah.wilson"; 
        Password="NetAdmin2024!"; Department="IT_Department"; 
        Description="Network Administrator"; Title="Network Administrator"
    },
    
    # HR Department Users
    @{
        FirstName="Jane"; LastName="Smith"; Username="jane.smith"; 
        Password="HRManager2024!"; Department="HR_Department"; 
        Description="Human Resources Manager"; Title="HR Manager"
    },
    @{
        FirstName="Lisa"; LastName="Brown"; Username="lisa.brown"; 
        Password="HRRecruiter2024!"; Department="HR_Department"; 
        Description="HR Recruitment Specialist"; Title="HR Recruiter"
    },
    
    # Finance Department Users
    @{
        FirstName="Bob"; LastName="Wilson"; Username="bob.wilson"; 
        Password="FinManager2024!"; Department="Finance_Department"; 
        Description="Finance Department Manager"; Title="Finance Manager"
    },
    @{
        FirstName="Carol"; LastName="Davis"; Username="carol.davis"; 
        Password="Accountant2024!"; Department="Finance_Department"; 
        Description="Senior Accountant"; Title="Senior Accountant"
    },
    
    # Executive Users
    @{
        FirstName="Alice"; LastName="Johnson"; Username="alice.johnson"; 
        Password="CEO2024!"; Department="Executive_Department"; 
        Description="Chief Executive Officer"; Title="CEO"
    },
    @{
        FirstName="David"; LastName="Martinez"; Username="david.martinez"; 
        Password="CTO2024!"; Department="Executive_Department"; 
        Description="Chief Technology Officer"; Title="CTO"
    },
    
    # Operations Users
    @{
        FirstName="Tom"; LastName="Anderson"; Username="tom.anderson"; 
        Password="OpsManager2024!"; Department="Operations_Department"; 
        Description="Operations Manager"; Title="Operations Manager"
    },
    @{
        FirstName="Test"; LastName="User"; Username="test.user"; 
        Password="Password123!"; Department="Operations_Department"; 
        Description="Standard Operations User - Testing Account"; Title="Operations Staff"
    }
)

foreach ($User in $Users) {
    $SecurePassword = ConvertTo-SecureString $User.Password -AsPlainText -Force
    $UserPath = "OU=$($User.Department),OU=Departments,$DomainDN"
    
    try {
        New-ADUser -GivenName $User.FirstName -Surname $User.LastName -Name "$($User.FirstName) $($User.LastName)" `
                   -SamAccountName $User.Username -UserPrincipalName "$($User.Username)@$($Domain.DNSRoot)" `
                   -Path $UserPath -AccountPassword $SecurePassword -Description $User.Description `
                   -Title $User.Title -Department $User.Department.Replace("_Department", "") `
                   -Enabled $true -PasswordNeverExpires $true -CannotChangePassword $false
        Write-Host "Created User: $($User.Username) ($($User.FirstName) $($User.LastName))" -ForegroundColor Green
    }
    catch {
        Write-Host "User $($User.Username) may already exist: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Create Service Accounts
Write-Host "`nCreating Service Accounts..." -ForegroundColor Cyan
$ServiceAccounts = @(
    @{
        FirstName="SQL"; LastName="Service"; Username="sqlservice"; 
        Password="SQLService2024!"; Description="SQL Server Service Account"
    },
    @{
        FirstName="Backup"; LastName="Service"; Username="backupservice"; 
        Password="BackupSvc2024!"; Description="Backup Service Account"
    }
)

$ServiceAccountPath = "OU=Service_Accounts,$DomainDN"
foreach ($ServiceAccount in $ServiceAccounts) {
    $SecurePassword = ConvertTo-SecureString $ServiceAccount.Password -AsPlainText -Force
    
    try {
        New-ADUser -GivenName $ServiceAccount.FirstName -Surname $ServiceAccount.LastName `
                   -Name "$($ServiceAccount.FirstName) $($ServiceAccount.LastName)" `
                   -SamAccountName $ServiceAccount.Username `
                   -UserPrincipalName "$($ServiceAccount.Username)@$($Domain.DNSRoot)" `
                   -Path $ServiceAccountPath -AccountPassword $SecurePassword `
                   -Description $ServiceAccount.Description -Enabled $true `
                   -PasswordNeverExpires $true -CannotChangePassword $true
        Write-Host "Created Service Account: $($ServiceAccount.Username)" -ForegroundColor Green
    }
    catch {
        Write-Host "Service Account $($ServiceAccount.Username) may already exist: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Start-Sleep -Seconds 2

# Phase 4: Assign Group Memberships
Write-Host "`nPhase 4: Assigning Group Memberships..." -ForegroundColor Cyan

$GroupMemberships = @(
    # IT Groups
    @{Group="IT_Administrators"; Members=@("john.doe", "sarah.wilson")},
    @{Group="IT_Staff"; Members=@("john.doe", "mike.johnson", "sarah.wilson")},
    @{Group="Server_Administrators"; Members=@("john.doe", "sarah.wilson")},
    
    # HR Groups
    @{Group="HR_Managers"; Members=@("jane.smith")},
    @{Group="HR_Staff"; Members=@("jane.smith", "lisa.brown")},
    
    # Finance Groups
    @{Group="Finance_Managers"; Members=@("bob.wilson")},
    @{Group="Finance_Staff"; Members=@("bob.wilson", "carol.davis")},
    
    # Executive Groups
    @{Group="Executives"; Members=@("alice.johnson", "david.martinez")},
    
    # Operations Groups
    @{Group="Operations_Staff"; Members=@("tom.anderson", "test.user")}
)

foreach ($GroupMembership in $GroupMemberships) {
    try {
        Add-ADGroupMember -Identity $GroupMembership.Group -Members $GroupMembership.Members
        Write-Host "Added members to $($GroupMembership.Group): $($GroupMembership.Members -join ', ')" -ForegroundColor Green
    }
    catch {
        Write-Host "Error adding members to $($GroupMembership.Group): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Add john.doe to Domain Admins
Write-Host "`nGranting Domain Admin privileges..." -ForegroundColor Cyan
try {
    Add-ADGroupMember -Identity "Domain Admins" -Members "john.doe"
    Write-Host "Added john.doe to Domain Admins group" -ForegroundColor Green
}
catch {
    Write-Host "Error adding john.doe to Domain Admins: $($_.Exception.Message)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# Phase 5: Move Computer Accounts
Write-Host "`nPhase 5: Organizing Computer Accounts..." -ForegroundColor Cyan

$ServerOU = "OU=Servers,$DomainDN"
$WorkstationOU = "OU=Workstations,$DomainDN"

# Move Domain Controller to Servers OU
try {
    $DCComputer = Get-ADComputer -Identity "DC01-WINSERVER2022"
    Move-ADObject -Identity $DCComputer.DistinguishedName -TargetPath $ServerOU
    Write-Host "Moved DC01-WINSERVER2022 to Servers OU" -ForegroundColor Green
}
catch {
    Write-Host "Could not move DC01-WINSERVER2022: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Move Windows 10 client to Workstations OU
try {
    $ClientComputer = Get-ADComputer -Identity "WS01-WIN10ENTERPRISE"
    Move-ADObject -Identity $ClientComputer.DistinguishedName -TargetPath $WorkstationOU
    Write-Host "Moved WS01-WIN10ENTERPRISE to Workstations OU" -ForegroundColor Green
}
catch {
    Write-Host "Could not move WS01-WIN10ENTERPRISE: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Display Summary
Write-Host "`n=== Active Directory Setup Complete ===" -ForegroundColor Cyan
Write-Host "Created:" -ForegroundColor Yellow
Write-Host "- 9 Organizational Units" -ForegroundColor White
Write-Host "- 10 Security Groups" -ForegroundColor White
Write-Host "- 11 User Accounts (including service accounts)" -ForegroundColor White
Write-Host "- Group memberships assigned" -ForegroundColor White
Write-Host "- Computer accounts organized" -ForegroundColor White

Write-Host "`nKey Test Accounts:" -ForegroundColor Yellow
Write-Host "- SOCLAB\john.doe (Domain Admin)" -ForegroundColor White
Write-Host "- SOCLAB\test.user (Standard User - weak password)" -ForegroundColor White
Write-Host "- SOCLAB\jane.smith (HR Manager)" -ForegroundColor White
Write-Host "- SOCLAB\alice.johnson (CEO)" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Test user logins from Windows 10 client" -ForegroundColor White
Write-Host "2. Configure Windows Event Forwarding" -ForegroundColor White
Write-Host "3. Set up Splunk SIEM event collection" -ForegroundColor White
Write-Host "4. Create attack scenarios for testing" -ForegroundColor White

Write-Host "`nScript completed successfully!" -ForegroundColor Green