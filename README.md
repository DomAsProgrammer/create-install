WHAT IS create-install.pl ?
===========================
This intractive script builds files of your explicit installed
Archlinux' pacman's packages. This files are two scripts and
one textfile.
The scripts can be executed directly after reboot of your fresh
system for reinstalling your pre-decided packages.
This way you haven't to remember every of your wished packages.
Helpful for multible installations.


FEATURES
========
Ready to use scripts for reinstallation.
No base packages will be installed. I experienced
reinstallation of base packages can cause big issues.


SOFTWARE REQUIREMENTS
=====================
Perl
- Perl 5.22.2 or higher


DOCUMENTATION
=============
Just execute create_install.pl . There are no options or
arguments. After execution it will need some time to collect
informations about your installed packages. After this you will
be asked what to do:
	yes	=> opens vim where you can edit the list of programms
	No	=> continues with the complete list
	quit	=> exits this program and removes all temp files
	help	=> prints this help
"No" will create the scripts with collected informations. Default by ENTER
"quit" will exit program without creating anything.
"yes" will give you a list with two columns: 
    [PACKAGE NAME]	- [DESCRIPTION]
 - delete a line to omit package
 - change package name, if you want a special version (e.g. vi → vim)
 - create a new line and write package name in to add this to scripts
After execution (and not quitting) you'll find one to three new files in
the same directory like create_install.pl :

- instpacman_yourhost_YYYY-MM-DD.sh
	All packets, which can be installed via pacman will be
	collected as runable script in the first script.

- instyaourt_yourhost_YYYY-MM-DD.sh
	Packets, which can be installt from AUR via yaourt,
	will be collected as runable script in the second
	script like the first. (This script will only be created
	if yaourt is available.)

- instnot_yourhost_YYYY-MM-DD.txt
	Any manually compiled (and via pacman installed) packets
	will be listed in the third textfile. (This script will
	only be created if there are any packages, which are not
	found in yaourt or pacman.)


LICENSE
=======
It is distributed under the GNU General Public License
version 3 - see the accompanying file "LICENSE" or
http://www.gnu.org/licenses/gpl.html for more details.


GET SOURCE
==========
You can find package files on
https://github.com/DomAsProgrammer/create-install


REPORTING BUGS
==============
I would be glad to hear positive respone, also you can report
bugs, errors or proposal to DomAsProgrammer@gmail.com or on
https://github.com/DomAsProgrammer


AUTHORS
=======
- Dominik Bernhardt
	DomAsProgrammer@gmail.com ; https://github.com/DomAsProgrammer
