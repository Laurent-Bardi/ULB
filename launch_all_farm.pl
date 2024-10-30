#!/usr/bin/perl -w
die($^O) if ($^O !~ /linux/i);
use strict;
no warnings 'uninitialized';
use lib "./";
use lib "../lib";
use Std;
use Getopt::Std;
use ULB;
# a farm is composed of a list of sockets with eventually a maximum number of connection
$::NOM_PROGRAMME = $0;
$::REVISION = "v1.00";

#
# Main
#
my @files_farm = glob("$::ULB_var/*.farm");
Std::printarray(@files_farm);
foreach my $file (@files_farm)
{
    my %P = Std::read_hash_2_xml_file($file);
    my $proto ="";
    $proto=' -U ' if ( lc($P{'proto'}) eq 'u');
    my $farm =" ";
    foreach my $k (keys(%P))
    {
        $farm .= $P{$k}." " if ($k =~ /server_/);
    }
    my $ctrl = $P{'ctrl'}." ";
    my $server = " ".$P{'server'}." ";
    my $cmd = "$::PEN -X -u root -C 127.0.0.1:$ctrl $proto $server  $farm";
    Std::println($cmd);
	Std::println(Std::mexec($cmd));
}