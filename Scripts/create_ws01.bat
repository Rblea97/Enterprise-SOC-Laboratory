@echo off
echo Creating Windows 10 Enterprise Client VM...

set VBOX_PATH="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
set VM_NAME=WS01-Win10Enterprise
set VM_PATH=C:\Users\Owner\Documents\Projects\Home_lab\SOC_Lab\VMs
set ISO_PATH=C:\Users\Owner\Documents\Projects\Home_lab\SOC_Lab\ISOs\19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso

echo Step 1: Creating VM...
%VBOX_PATH% createvm --name "%VM_NAME%" --register --basefolder "%VM_PATH%"

echo Step 2: Configuring VM settings...
%VBOX_PATH% modifyvm "%VM_NAME%" --ostype "Windows10_64"
%VBOX_PATH% modifyvm "%VM_NAME%" --memory 3072
%VBOX_PATH% modifyvm "%VM_NAME%" --cpus 2
%VBOX_PATH% modifyvm "%VM_NAME%" --vram 128
%VBOX_PATH% modifyvm "%VM_NAME%" --boot1 dvd --boot2 disk --boot3 none --boot4 none
%VBOX_PATH% modifyvm "%VM_NAME%" --acpi on --ioapic on
%VBOX_PATH% modifyvm "%VM_NAME%" --nic1 intnet --intnet1 "SOC_Lab_Network"
%VBOX_PATH% modifyvm "%VM_NAME%" --nictype1 82540EM
%VBOX_PATH% modifyvm "%VM_NAME%" --cableconnected1 on

echo Step 3: Creating and attaching hard disk...
%VBOX_PATH% createmedium disk --filename "%VM_PATH%\%VM_NAME%\%VM_NAME%.vdi" --size 20480 --format VDI
%VBOX_PATH% storagectl "%VM_NAME%" --name "SATA Controller" --add sata --bootable on
%VBOX_PATH% storageattach "%VM_NAME%" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "%VM_PATH%\%VM_NAME%\%VM_NAME%.vdi"

echo Step 4: Attaching Windows 10 ISO...
%VBOX_PATH% storagectl "%VM_NAME%" --name "IDE Controller" --add ide
%VBOX_PATH% storageattach "%VM_NAME%" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "%ISO_PATH%"

echo Step 5: Enabling RDP for remote access...
%VBOX_PATH% modifyvm "%VM_NAME%" --vrde on --vrdeport 5002

echo VM WS01-Win10Enterprise created successfully!
echo Network: Internal network "SOC_Lab_Network" 
echo Memory: 3GB RAM, 20GB Disk
echo RDP Port: 5002
echo.
echo Ready to start the VM and begin Windows 10 installation.
pause