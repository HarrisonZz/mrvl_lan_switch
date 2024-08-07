HOWTO INSTALL THE SOFTWARE FOR THE MARVELL USB-JTAG INTERFACE
=============================================================

Windows 8, 8.1 and 10 may NOT require this driver to be installed,
but will correctly detect the hardware and install the appropriate driver.
If not you need to install this driver supplied by Microsoft for the USB stack 
will also allow the USB-JTAG interface to be connected to an USB 3.0 port.

NOTE: ONLY FOR Windows 7 

The Marvell USB-JTAG interface requires the installation of the 
appropriate driver and a DLL.

IMPORTANT:
Perform a software first installation of the driver. 
DO NOT plug in the USB-JTAG interface before the driver is installed.
Otherwise Windows will either unsuccessfully search for a driver or
probably install the wrong one.

Installation:
-------------
Invoke the driver installer CDM21228_Setup.exe. 
The setup program will install the driver according to your system (32/64 bit).

After successful installation of the software plug the Marvell USB-JTAG 
interface into a free USB 2.0 port.

NOTE: Please DO NOT use a USB 3.0 port, because the driver is known to have 
problems with USB 3.0 ports (Error message: "...device in use")

Windows should detect the Marvell USB-JTAG interface and bind the drivers.
After that the device is ready to use.

NOTE: The FTCJTAG_200.zip archive is here for reference, the necessary DLL
is already unpacked in the JTAG directory.

 
