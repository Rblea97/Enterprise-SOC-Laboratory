@echo off
echo ====================================
echo Creating SIEM01-Ubuntu VM for SOC Lab
echo ====================================
echo.

REM Set variables
set VM_NAME=SIEM01-Ubuntu
set VM_RAM=6144
set VM_VRAM=256
set VM_DISK_SIZE=25600
set VM_PATH=C:\Users\Owner\Documents\Projects\Home_lab\SOC_Lab\VMs\%VM_NAME%
set ISO_PATH=C:\Users\Owner\Documents\Projects\Home_lab\SOC_Lab\ISOs\ubuntu-24.04.3-desktop-amd64.iso
set VBOX_PATH="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

echo Creating VM directory...
if not exist "%VM_PATH%" mkdir "%VM_PATH%"

echo.
echo Creating virtual machine: %VM_NAME%
%VBOX_PATH% createvm --name "%VM_NAME%" --ostype "Ubuntu_64" --register --basefolder "%VM_PATH%\.."

echo.
echo Configuring VM settings...
%VBOX_PATH% modifyvm "%VM_NAME%" --memory %VM_RAM%
%VBOX_PATH% modifyvm "%VM_NAME%" --vram %VM_VRAM%
%VBOX_PATH% modifyvm "%VM_NAME%" --cpus 2
%VBOX_PATH% modifyvm "%VM_NAME%" --boot1 dvd --boot2 disk --boot3 none --boot4 none
%VBOX_PATH% modifyvm "%VM_NAME%" --acpi on --ioapic on
%VBOX_PATH% modifyvm "%VM_NAME%" --rtcuseutc on

echo.
echo Creating virtual hard disk...
%VBOX_PATH% createhd --filename "%VM_PATH%\%VM_NAME%.vdi" --size %VM_DISK_SIZE% --format VDI

echo.
echo Adding SATA controller...
%VBOX_PATH% storagectl "%VM_NAME%" --name "SATA Controller" --add sata --controller IntelAhci

echo.
echo Attaching hard disk...
%VBOX_PATH% storageattach "%VM_NAME%" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "%VM_PATH%\%VM_NAME%.vdi"

echo.
echo Adding IDE controller for DVD...
%VBOX_PATH% storagectl "%VM_NAME%" --name "IDE Controller" --add ide --controller PIIX4

echo.
echo Attaching Ubuntu ISO...
%VBOX_PATH% storageattach "%VM_NAME%" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "%ISO_PATH%"

echo.
echo Configuring network adapter...
%VBOX_PATH% modifyvm "%VM_NAME%" --nic1 intnet --intnet1 "SOC_Lab_Network"
%VBOX_PATH% modifyvm "%VM_NAME%" --nictype1 82540EM
%VBOX_PATH% modifyvm "%VM_NAME%" --cableconnected1 on

echo.
echo Configuring audio and USB...
%VBOX_PATH% modifyvm "%VM_NAME%" --audio none
%VBOX_PATH% modifyvm "%VM_NAME%" --usb on --usbehci off --usbxhci off

echo.
echo Enabling clipboard and drag-and-drop...
%VBOX_PATH% modifyvm "%VM_NAME%" --clipboard-mode bidirectional
%VBOX_PATH% modifyvm "%VM_NAME%" --draganddrop bidirectional

echo.
echo ====================================
echo SIEM01-Ubuntu VM created successfully!
echo ====================================
echo.
echo VM Configuration:
echo - Name: %VM_NAME%
echo - RAM: %VM_RAM% MB (6GB)
echo - Disk: %VM_DISK_SIZE% MB (25GB)
echo - Network: Internal "SOC_Lab_Network"
echo - Expected IP: 192.168.100.30 (Static)
echo.
echo Next steps:
echo 1. Start the VM: %VBOX_PATH% startvm "%VM_NAME%"
echo 2. Follow Ubuntu Desktop installation guide
echo 3. Configure static IP: 192.168.100.30/24
echo 4. Gateway: 192.168.100.10 (DC01)
echo 5. DNS: 192.168.100.10
echo.
echo The VM is ready for Ubuntu Server installation!
echo ====================================
pause