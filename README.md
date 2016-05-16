Wellcome!

This script builds files out of your explicit installed Archlinux' pacman's packets.

This will allow you, after a base installation fastly install all your wanted packets, without remembering of any of these.
This means: Programms of the base and base-devel groups were NOT inclouded!

1 instpacman_yourhost_YYYY-MM-DD.sh
2 instyaourt_yourhost_YYYY-MM-DD.sh
3 instnot_yourhost_YYYY-MM-DD.txt

1 All packets, which can be installed via pacman will be collected as runable script in the first script.
2 Packets, which can be installt from AUR via yaourt, will be collected as runable script in the second script like the first.
3 Any manually compiled (and via pacman installed) packets will be listed in the third textfile.

Readme and script is protected by GPLv3 (see license file or http://www.gnu.org/licenses/gpl.html)

Script is written in Perl

If you have issues, bugs, or ideas you can write me at domasprogrammer@gmail.com or visit me at https://github.com/DomAsProgrammer

I hope you find my little script as helpful as I do.

Dominik
