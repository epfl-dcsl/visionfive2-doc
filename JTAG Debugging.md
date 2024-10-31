# Debugging the VisionFive 2 Board Using JTAG

## Windows Installation Guide

This guide works for the VisionFive2 board (rev. 1.3B) and Oilmex ARM USB Tiny H JTAG-debugger.

### 1. Install FTDI and USB Drivers for Olimex Debugger

- Download the FTDI drivers and USB drivers for the Olimex debugger from the official site:
  - [OLIMEX FTDI Drivers](https://www.olimex.com/Products/ARM/JTAG/_resources/OLIMEX-FTDI-drivers-2-12-04.zip)
  - [libusb-1.2.2.0-CDM20808](https://www.olimex.com/Products/ARM/JTAG/_resources/DRIVERS-(libusb-1.2.2.0-CDM20808).zip)
- Install these drivers via the Device Manager.

### 2. Generate a Debug Version of U-Boot SPL

- Create a [debug](https://github.com/starfive-tech/edk2/wiki/How-to-flash-and-debug-with-JTAG#create-u-boot-spl-for-debugging) version of U-Boot SPL.
- Flash this debug version on the board boot device (for further instructions on how to do that refer to the official [documentation](https://doc-en.rvspace.org/VisionFive2/PDF/VisionFive2_QSG.pdf#page=43)).

### 3. Verify Olimex Debugger Connection

- Ensure that the Olimex OpenOCD JTAG ARM-USB-TINY-H debugger appears in your OS.
- Ideally, it should have a serial number of `OL9DF5D8`, although this might not always be the case.

### 4. Pin Layout Between the Debugger and the Board

Here's a useful table for the pin layout between the debugger and the VisionFive 2 board:

| Pin      | Board Pin | Debugger Pin |
|----------|-----------|--------------|
| TCK      | 37        | 9            |
| TMS      | 35        | 7            |
| TDI      | 38        | 5            |
| TDO      | 40        | 13           |
| RST_N    | 36        | 3            |
| GND      | 39        | 20           |
| VREF     | 1/17      | 1            |

*Note: First pin on the debugger corresponds to a red stripe on the extender.*


### 5. Download OpenOCD with JH7110 Configuration

- Download OpenOCD with a JH7110 configuration:
  - You can find it [here](https://github.com/starfive-tech/edk2/releases/download/REL_VF2_APR2023/debug_tools.zip).
  - Alternatively, install the full [Freedom Studio](https://static.dev.sifive.com/dev-tools/FreedomStudio/2020.06/FreedomStudio-2020-06-3-win64.zip) suite, which includes OpenOCD.

### 6. Modify the OpenOCD Configuration File if needed

- In the `.cfg` file, comment out the line `#ftdi serial "OL9DF5D8"` if the serial doesn't show up in the USB list.

### 7. Verify Debugger Information Using PowerShell

- Run the following command in PowerShell to check the USB devices:

  ```powershell
  Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' } | ForEach-Object {
      $device = $_
      $vidMatch = $device.InstanceId -match 'VID_([0-9A-F]{4})' | Out-Null
      $vidValue = $matches[1]
      $pidMatch = $device.InstanceId -match 'PID_([0-9A-F]{4})' | Out-Null
      $pidValue = $matches[1]
      $serialNumber = (Get-WmiObject Win32_PnPEntity | Where-Object { $_.DeviceID -eq $device.InstanceId }).SerialNumber
      [PSCustomObject]@{
          DeviceDescription = $device.FriendlyName
          VID = $vidValue
          PID = $pidValue
          SerialNumber = $serialNumber
      }
  } 
  ```
### 8. Run OpenOCD

- If everything is set up correctly, run OpenOCD with the .cfg file as an argument:

  ```powershell
  .\openocd.exe -f openocd.cfg
  ```

  **Note**: connecting the debugger in this way ***will halt*** the execution of the program. 

- A successful output should resemble the following:

  ```powershell
  Open On-Chip Debugger 0.10.0+dev (SiFive OpenOCD 0.10.0-2020.04.6)
  ...
  Info : Listening on port 3333 for gdb connections
  Ready for Remote Connections
  Info : Listening on port 6666 for tcl connections
  Info : Listening on port 4444 for telnet connections
  ```

- Now you can run gdb and connect to the board via `target extended-remote :3333`.

