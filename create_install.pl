#!/usr/bin/perl

# License:		GPLv3 - see license file or http://www.gnu.org/licenses/gpl.html
# Program-version:	1.1, (16th June 2016)
# Description:		Create install scripts out of the runnnig system
# Contact:		Dominik Bernhardt - domasprogrammer@gmail.com or https://github.com/DomAsProgrammer

use strict;
use warnings;
use File::Basename;
use Cwd qw(realpath);
use File::Path;
use Env;
use POSIX;

### Systemtest
chomp(my $pacm = qx(which perl 2> /dev/null));
if ( ! ( $pacm ) ) {
	print STDERR "Can't find pacman. Is this a Archlinux?\n\n";
	exit(3);
	}
else {
	my @list = ();
	foreach my $file ( glob("/etc/*-release") ) {
		open(RH, "<", $file);
			@list = ( @list, grep(/arch\s*linux/i, <RH>) );
		close(RH);
		}
	if ( scalar(@list) < 2 ) {
		print STDERR "This Linux seems to be no Archlinux!\n\n";
		exit(4);
		}
	}
		

### Declarations
print "\nCreate workspace...\n";
my @date		= ( localtime ); #sec,min,h,d,M,Y,W,...
my $maindir		= dirname(realpath($0));
my $editor		= ( defined($ENV{EDITOR}) ) ? $ENV{EDITOR} : "vi";
my @pacman		= ();
my @yaourt		= ();
my @none		= ();
my %installed		= (); # will be build later for more informations
my $maxlength		= 0;
my $maxtabulator	= 0;
chomp(my $shell		= qx(which sh));
chomp(my $yp		= qx(which yaourt 2> /dev/null));
chomp(my $hostn		= qx(hostname));
chomp(my @allpacman	= (grep(/^.*\/.*\ .*$/, qx(pacman -Ss))));
my $tmp			= "$maindir/.createin_$hostn";

# Build path to pacmans install file
my $pacmanfile	= "$maindir/instpacman_${hostn}_"
	. ( $date[5] + 1900 ) . "-" . sprintf("%02d", ( $date[4] + 1 )) . "-" . sprintf("%02d", $date[3]) . ".sh";
# Build path to yaourts install file
my $yaourtfile	= "$maindir/instyaourt_${hostn}_"
	. ( $date[5] + 1900 ) . "-" . sprintf("%02d", ( $date[4] + 1 )) . "-" . sprintf("%02d", $date[3]) . ".sh";
# Build path to file for not found packages
my $nonefile	= "$maindir/instnot_${hostn}_"
	. ( $date[5] + 1900 ) . "-" . sprintf("%02d", ( $date[4] + 1 )) . "-" . sprintf("%02d", $date[3]) . ".info";

# Use tmp folder as lock
if ( -d $tmp ) {
	print STDERR "Script is already running...\n",
		"(If it isn't, you can delete \"$tmp\" manually.)\n";
	exit(2);
	}
else {
	mkdir($tmp) || die "No permission to create \"$tmp\"!";
	}

# Get installed packages
print "Opening databases...\nThis may need some time...\n\n";
chomp(my @installed = qx(pacman -Qe));
chomp(my @basepacks = qx(pacman -Qg base base-devel));
foreach ( @installed ) {
	$_ = (split("\ ", $_))[0];
	}
foreach ( @basepacks ) {
	$_ = (split("\ ", $_))[1];
	$_ =~ s/\\|\||\/|\+|\*|\?|\./\\$&/g;
	}

my $basepacks	= join('|', @basepacks);
@installed	= grep(!/^($basepacks)$/, @installed);

# Get some info about the packs
my $total = scalar(@installed);
my $round = 1;
print "Collecting informations about packages...\nPlease be patient!\nCollecting ";
foreach my $pack ( @installed ) {
	my $search	= $pack;
	print "\rCollecting [",
		"=" x ceil(&get100(23) * ($round / $total)),
		"<",
		sprintf("%6.2f", $round / $total * 100),
		"%>",
		"-" x floor(&get100(23) * (1 - $round / $total)),
		"]";
	$round++;
	$search		=~ s/\\|\||\/|\+|\*|\?|\./\\$&/g;
	if ( grep(/^.*\/$search\ .*$/, @allpacman) ) {
		my $text = (split(":", (split("\n", qx(pacman -Si $pack)))[3]))[1];
		$text =~ s/^\s+//;
		$installed{$pack} = [ "pacman", $text, length($pack) ];
		}
	elsif ( $yp && grep(/^.*\/$search\ .*$/, qx(yaourt -Ss $pack)) ) {
		chomp(my $text = qx(yaourt -Ss $pack | grep -A 1 "^.*\/$pack\ .*\$" | tail -1));
		$text =~ s/^\s+//;
		$installed{$pack} = [ "yaourt", $text, length($pack) ];
		}
	else {
		$installed{$pack} = [ "none", "Is no longer able to be installed via internet! (Try downgrade!)", length($pack) ];
		}
	}
print "\n\n";

# Maximal string length
foreach my $len ( sort(keys(%installed)) ) {
	if ( ${$installed{$len}}[2] > $maxlength ) {
		$maxlength = ${$installed{$len}}[2];
		}
	}
if ( $maxlength % 8 ) {
	$maxtabulator = ceil($maxlength / 8);
	}
else  {
	$maxtabulator = $maxlength / 8 + 1;
	}

# Some user choices
YN: while ( 1 ) {
	print "Do you want to check the list of programms?\n",
		"You can delete programms by removing the line. [y|N|q|h] ";
	chomp(my $yn = <STDIN>); $yn =~ s/\s+//g;
	if ( $yn eq '' || $yn =~ m/^N|NO/i ) {
		print "Creating files...\n";
		last(YN);
		}
	elsif ( $yn =~ m/^[qe]|quit|exit/i ) { stop_program(2); }
	elsif ( $yn =~ m/^h|help/i ) {
		print "yes\t=> opens $editor where you can edit the list of programms\n",
			"No\t=> continues with the complete list\n",
			"quit\t=> exits this program and removes all temp files (nothing will be created)\n",
			"help\t=> prints this help\n";
		}
	elsif ( $yn =~ m/^y|yes/i ) {
		open(FH, ">", "$tmp/installed.tmp");
			foreach my $line ( sort(keys(%installed)) ) {
				print FH "$line",
					"\t" x ( $maxtabulator - floor(${$installed{$line}}[2] / 8) ),
					"- ${$installed{$line}}[1]\n";
				}
		close(FH);
		my $cmd = "$editor \"$tmp/installed.tmp\"";
		system($cmd);
		open(HF, "<", "$tmp/installed.tmp");
			chomp(@installed = <HF>);
		close(HF);
		last(YN);
		}
	}

# clear out the list
foreach my $getshort ( @installed ) {
	$getshort =~ s/\s+-\s+.*$//g;
	}

# Sort for files
foreach my $sort ( @installed ) {
	if ( defined(${$installed{$sort}}[0]) && ${$installed{$sort}}[0] eq "pacman" ) {
		push(@pacman, $sort);
		}
	elsif ( $yp && defined(${$installed{$sort}}[0]) && ${$installed{$sort}}[0] eq "yaourt" ) {
		push(@yaourt, $sort);
		}
	elsif ( defined(${$installed{$sort}}[0]) && ${$installed{$sort}}[0] eq "none" ) {
		push(@none, $sort);
		}
	else {
		my $search = $sort;
		$search =~ s/\\|\||\/|\+|\*|\?|\./\\$&/g;
		if ( grep(/^.*\/$search\ .*$/, @allpacman) ) {
			push(@pacman, $sort);
			}
		elsif ( $yp && grep(/^.*\/$search\ .*$/, qx(yaourt -Ss $sort)) ) {
			push(@yaourt, $sort);
			}
		else {
			push(@none, $sort);
			}
		}
	}

# Write files
if ( @pacman ) {
	open(PAC, ">", $pacmanfile);
		print PAC "#!$shell\n\nsudo pacman -Sy @pacman --needed\n";
	close(PAC);
	chmod(0750, $pacmanfile);
	}

if ( @yaourt ) {
	open(YAO, ">", $yaourtfile);
		print YAO "#!$shell\n\nyaourt -Sy @yaourt --needed\n";
	close(YAO);
	chmod(0750, $yaourtfile);
	}

if ( @none ) {
	open(NON, ">", $nonefile);
		print NON "These packages can't be found online:\n\n";
		foreach ( @none ) {
			print NON "$_\n";
			}
	close(NON);
	chmod(0640, $nonefile);
	}

# Clear up
rmtree($tmp);
print "Done.\n";
exit(0);

### Subfunctions

sub stop_program {
	my $exitreason = shift;
	rmtree($tmp);
	print "Quit.\n";
	exit($exitreason);
	}

sub get100 {
	my $used		= shift; # lenght of still used charakters
	chomp(my $length	= qx(stty -a));
	$length			= (split(" ", (split(";", (split("\n", $length))[0]))[2]))[1];
	$length			= $length - $used + 1;
	if ( $length < 0 ) {
		$length = 0;
		}
	return($length);
	}
#EOF
