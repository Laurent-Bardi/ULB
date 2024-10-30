package Std;
# Title: Std.pm
# package: paquetage Std
use strict;
no warnings 'uninitialized';
use base 'Exporter';
our @EXPORT = qw(
						println
                        printarray
						mexec
						writefile
						readfile
						write_hash_2_xml_file
						read_hash_2_xml_file
						genere_password
);
sub println
{
# Sub: println()
# write with a carriage return 
#
# Usage: 
# println($b)
#
# Parameter: 
# *$b* string to display
#
# Return: 
# NONE
# 
# Action: 
# display a string (in fact a perl var, could be an int a float, ...) followed by a carriage return
# If  $::Response is defined the we are in web apache-asp mode and use  $response->write()
# If  $::Response and $::WEB_BUFFERING are defined then we store in $::WEB_BUFFER for late displaying
#
	my $cmd = shift;
	if ($::Response)
	{
		if ($::WEB_BUFFERING)
		{
			$::WEB_BUFFER.=$cmd."<BR>";
		}
		else
		{
			$::Response->Write($cmd."<BR>");
		}
	}
	else
	{
		print $cmd."\n" if ($cmd);
	}
}
sub printarray(@)
{
# Sub: printarray()
# print an array
#
# Usage: 
# printarray(@b)
#
# Parameter: 
# *@b* the array to print
#
# Return: 
# NONE
# 
# Action: 
# print each item of the array followed by a carriage return
#
   my(@array)=@_;
   my($t);
   foreach $t (@array)
   {
      println($t);
   }
}

sub mexec
{
# Sub: mexec()
# execute a command
#
# Usage: 
# $a = mexec($cmd)
#
# Parameter: 
# *$cmd* command line to execute
#
# Return: 
# *$a* what command produce on STDOUT (not STDERR)
# 
# Action: 
# print the command (if global var $::QUIET is not defined) execute and print the results
#
	my $cmd = shift;
	println("\t".$cmd) if (!$::QUIET);
	my $res = `$cmd 2>&1`;
	return $res;
}
sub writefile($@)
{
# Sub: writefile()
# print in a file
#
# Usage: 
# writefile($filename,@text)
#
# Parameter: 
# *$filename* filename
#
# *@text* text to write (multiple line in an array)
#
# Return: 
# NONE
# 
# Action: 
# Write @text in $filename file
#
   my $file=shift;
   my @message = @_;
   open(FILEIN,'>'.$file) || die ("---openning  $file is impossible! $!");
   print FILEIN @message;
   close(FILEIN);
}
sub readfile($)
{
# Sub: readfile()
# read from a file 
#
# Usage: 
# @text = readfile($filename)
#
# Parameter: 
# *$filename* filename to read
#
# Return: 
# *@text* the text in the file, each line is an item of the array returned
# 
# Action: 
# Read a file $filename and return the text @text
#
   my $file=shift;
   my @message = shift;
   open(FILEIN,"<$file") || die ("---openning  $file is impossible! $!");
   @message = <FILEIN>;
   close(FILEIN);
   return @message;
}

sub write_hash_2_xml_file
{
# sub: write_hash_2_xml_file()  
# write a hash in an xml file (SimpleXML is used)
#
# Usage:
#
# write_hash_2_xml_file($filename,%H)  
#
# Parameter: 
# *$filename* filename where to store
# *%H* the hash to store
#
# Return: 
# *none* 
# 
# Action: 
# write a hash in an xml file (SimpleXML)
#
# Note: 
# 
#

    my $fname = shift;
    my %H = @_;
	use XML::Simple;
    open(FOUT,">$fname");
    print FOUT XML::Simple::XMLout(\%H);
    close(FOUT);
}

sub read_hash_2_xml_file
{
# sub: read_hash_2_xml_file()  
# read a hash from an xml file (SimpleXML)
#
# Usage:
#
# my %H = read_hash_2_xml_file($filename)  
#
# Parameter: 
# *$filename* filename where is stored the hash
#
# Return: 
# *%H* the hash to load
# 
# Action: 
# read a hash in an xml file (SimpleXML)
#
# Note: 
# 
#
    my $fname = shift;
	 use XML::Simple;
    my $h_ptr = XML::Simple::XMLin($fname);
    return %{$h_ptr};
}

sub genere_password
{
# Sub: genere_password($len)
# generate a password with length $len
#
# Usage: 
# print genere_password(15)
#
# Parameter: 
# *$len* the length
#
# Return: 
# NONE
# 
# Action: 
# genere un password de longeur $len 
#
    my $len=shift();
    my @consones = ('z','r','t','p','q','s','d','f','g','h','j','k','l','m','w','x','c','v','b','n','Z','R','T','P','Q','S','D','F','G','H','J','K','L','M','W','X','C','V','B','N');    
    my @voyelles =	('a','e','y','u','i','o','A','E','Y','U','I','O');    
    my @chiffre = ('0','1','2','3','4','5','6','7','8','9');
    my @specialcars = ('&','#','{','[','(','-','|','_',')',']','}','=','+','/','*','$','%',';',':','*');
    my $pass='';
    for (my $i=0;$i<=$len;$i++)
    {
        my $typec = int(rand(4));
        $pass.=$consones[int(rand($#consones+1))] if($typec eq 0);
        $pass.=$voyelles[int(rand($#voyelles+1))] if($typec eq 1);
        $pass.=$specialcars[int(rand($#specialcars+1))] if($typec eq 2);
        $pass.=$chiffre[int(rand($#chiffre+1))] if($typec eq 3);
    }    
    return $pass;
}
1;
