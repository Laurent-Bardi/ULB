#!/usr/bin/perl -w
# examples: 
# GC active directory -> perl  create_farm.pl -n gc -d 10.56.64.28:3268 -p T -c 10.64.200.61:3268,10.64.200.71:3268
# ldap active directory -> perl  create_farm.pl -n ldap -d 10.56.64.28:389 -p T -c 10.64.200.61:389,10.64.200.71:389
# dns tcp active directory -> perl  create_farm.pl -n dns_tcp -d 10.56.64.28:53 -p T -c 10.64.200.61:53,10.64.200.71:53
# dns udp active directoryperl  create_farm.pl -n dns_udp -d 10.56.64.28:53 -p U -c 10.64.200.61:53,10.64.200.71:53

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


sub menu_help
{	
	println("");
	println(" $::NOM_PROGRAMME $::REVISION usage :");
	println(" $::NOM_PROGRAMME -h");
	println(" => help");
	println(" $::NOM_PROGRAMME -n name -p protocole -d ip:port -c ip:port:nbc[,ip:port:nbc ]");
	println(" => creates service farm that listen on -d param and redirect on -c params");
	println(" => 			name : farm's name");	
    println(" => 			ip : ip destination");	
    println(" => 			port : port destination");	
    println(" => 			nbc : max numbers of connections");	
    println(" => 			p : protocole => U=udp T=tcp");	
	println(" => 			c parameters are destination");	
	println(" => 			d parameters are listener");	
	println(" Example : perl  create_farm.pl -n ldap -d 10.56.64.28:390 -p T -c 10.64.200.61:389,10.64.200.71:389");
	println(" create a TCP listener on 10.56.64.28 port 390 wich redirects to TCP ports 389 on ip 10.64.200.61 and 10.64.200.71");
}
sub process_args
{
	my %opts;
	my $arga = (!(@ARGV));
	getopts('hn:p:c:d:', \%opts);
	if (($opts{"h"} eq 1) or  $arga)
	{
		  menu_help;
		  exit;
	}
	return %opts;
}

sub get_ctrl_port
{
	my $file_ctrl_port = shift;
	my $file_ctrl_name = "$::ULB_etc/ctrl_port";
	if (-f $file_ctrl_name)
	{
		my @lines = Std::readfile($file_ctrl_name);
		$file_ctrl_port=$lines[0];
	}
	$file_ctrl_port++;
	Std::writefile($file_ctrl_name,($file_ctrl_port));
	return $file_ctrl_port;
}

#
# Main
#
my %opts = process_args();

if (!$opts{'n'})
{
	println("--- missing name");
	die(1);
}
if (!$opts{'p'})
{
	println("--- missing protocol");
	die(1);
}
if (!$opts{'c'})
{
	println("--- missing farm server");
	die(1);
}
if (!$opts{'d'})
{
	println("--- missing listener server");
	die(1);
}
my %H;
$H{'server'}=$opts{'d'};
$H{'name'}=$opts{'n'};
my @farm = split(/,/,$opts{'c'});
my $index=0;
foreach my $f (@farm)
{
    $H{"server_$index"}=$f;
    $index++;
}
$H{'proto'}=$opts{'p'};
my $farm_file = "$::ULB_var/".$opts{'n'}.".farm";
if (! (-f $farm_file ))
{
	$H{'ctrl'}=get_ctrl_port($::port_ctrl_run++);
	Std::write_hash_2_xml_file($farm_file,%H);
	Std::println("+++ Name $farm_file Ctrl $::port_ctrl_run Farm ".$opts{'c'}." Proto".$opts{'p'});
}
else
{
	Std::println("--- Name $farm_file Ctrl $::port_ctrl_run Farm ".$opts{'c'}." Proto".$opts{'p'});
}