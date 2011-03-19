
Welcome to Lipi core toolkit 3.0.0
--------------------------------

README for Lipi core toolkit 3.0.0

Introduction
----------------

The Lipi core toolkit provides a set of components which can be used for the
construction, evaluation and packaging of handwritten shape recognizers for
isolated shapes such as handwritten gestures and characters. 

The supported platforms
-----------------------------
Windows XP Professional
Redhat Enterprise Linux 4.0 
Ubuntu Gutsy Gibbon 7.10
windows mobile 6.0

TABLE OF CONTENTS
----------------------------------
1. Installing lipi-core-toolkit 3.0.0
2. User Manual
3. Known Issues / Limitations


1. Installing lipi-core-toolkit 3.0.0
------------------------------
a. lipi-core-toolkit 3.0.0 Packages : 

lipi-core-toolkit3.0.0-winvc6.0.cab - Binary package for Windows XP professional edition for VC6.0

lipi-core-toolkit3.0.0-winvc2005.cab - Binary package for Windows XP professional edition for
VC2005

lipi-core-toolkit3.0.0-winvc2008.cab - Binary package for Windows XP professional edition for
VC2008

lipi-core-toolkit3.0.0-wm.cab - Binary package for Windows mobile 6.0 

lipi-core-toolkit3.0.0-src.win.cab - Source package for Windows [VC6.0/VC2005/VC2008/Wm6.0] 

lipi-core-toolkit3.0.0-linux.tar.gz - Binary package for Linux

lipi-core-toolkit3.0.0-src.linux.tar.gz - Source package for Linux

b. Unpacking / Extracting the package:
 
	On Linux platform use the following command to extract
	              	tar -xzvf  lipi-core-toolkit2.3-linux.tar.gz

	On Windows use the cabarc.exe to extract
		cabarc.exe -p x lipi-core-toolkit3.0.0-winvc6.0.cab
		cabarc.exe -p x lipi-core-toolkit3.0.0-winvc2005.cab
		cabarc.exe -p x lipi-core-toolkit3.0.0-wm.cab

	Note: You can also unzip this cab using WinZip. 

2. User Manual
---------------------
The detailed user manual can be found at doc/lipi-core-toolkit_3_0_0_User_Manual.pdf

3. Known Issues / Limitations
-----------------------------------------
1. Spaces in file paths in training/test list files
Issue:
In list files for training or testing, if the file path contains spaces, then runshaperec.exe reports an error, and training or testing fails. 

Workaround: 
Do not use directory or files names with spaces in them, or (for Windows platforms) use the DOS path instead (e.g. for C:\program files, use “C:\progra~1”).
