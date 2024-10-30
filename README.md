<h2>
Ultra Load Balancer Ever wanted to have always-responding DNS or LDAP server : ULB is for you!
</h2>
<h3>
Prereq
</h3>
<ul>
<li>	
Only tested on Debian 12 Bookworm.
	</li>
<li>
Only in IPv4
	</li>
</ul>
You need 2 machines (physical,vm or container) with at least 2 network interfaces. The first interface is the management of the machine, the second will be the load-balanced redirector.<br><br>

![shema3](https://github.com/user-attachments/assets/c7e71cb1-362d-48b9-bfa4-503e78702928)

In my example i will use 2 machines with each two interfaces. So on each machine you will have :
<ul>
<li>
	ens19 the interface in data lan that speaks to servers and clients
</li>
<li>
	ens18 the interface in managment lan for managing ULB.
</li>
</ul>
<h3>
So let's start the install : 
</h3>
On each machine do 
<code>
 git clone https://github.com/Laurent-Bardi/ULB.git
cd ULB
</code>

Here the install script is 
<code>
install_ulb.pl v1.00 usage :
 install_ulb.pl -h
 => help
 install_ulb.pl -p path -i interface_name -a real_ip_for_carp -b virtual_ip_for_carp -n vhid [-m] 
 => install ULB 
 => 			-p path : where to install
 => 			-i interface_name name of the interface that will received carp process
 => 			-a real ip 
 => 			-b virtual ip 
 => 			-m if present will be the ucarp master
 => 			-n vhid identifier [1..255]
 => 	master example install_ulb.pl -p /usr/local/ULB -i ens19 -a 10.56.64.18 -b 10.56.65.8 -n 8-m 
 => 	slave example install_ulb.pl -p /usr/local/ULB -i ens19 -a 10.56.64.19 -b 10.56.65.8  -n 8 
</code>
some explanations : regarding the schema 
<ul>
<li>
	-p the path where all the ULB files (scripts, data, config) should stay (generally /opt/ULB or /usr/local/ULB )
</li>

<li>
	-a parameter stands for IP<sub>rb1</sub> for the first machine and IP<sub>rb2</sub> for the second. It will be the real load-blancer IP on the data subnet
</li>
<li>
	-b parameter stands for IP<sub>rb1-rb2</sub> it is the virtual IP that will float between the interface on the machines (on ens19 in my case)
</li>
<li>
	-n is the vhid parameter, between 1 and 255 it must be UNIQUE on the network (otherwise ucarp would mix theirs configurations )
</li>
<li>
	-m is master (the one who will own, at first, the virtual  IP<sub>rb1-rb2</sub>) . 
MUST BE ON ONLY ON ONE OF THE TWO MACHINES
</li>
</ul>
<h4>
first machine 
</h4>
<code>
perl install_ulb.pl -p /usr/local/ULB -i ens19 -a 10.56.64.18 -b 10.56.65.8 -n 8 -m
</code>
<h4>
second machine 
</h4>
<code>
 perl install_ulb.pl -p /usr/local/ULB -i ens19 -a 10.56.64.19 -b 10.56.65.8  -n 8
</code>

Here you see that the first machine will became the master. Feel free to test by rebooting /making shutdown-restart of the machine that virtual  IP<sub>rb1-rb2</sub> move from one machine to the other.

<h3>
Redirectors
</h3>
Now we are going to define waht redirectors we want. Each must be run on the two machines (otherwise they will not makes the same redirections).

<h4>
Example 1 DNS
</h4>
Suppose we have three DNS servers (can be the number you want) 
<ul>
<li> 10.64.200.61</li>
<li> 10.64.200.71</li>
<li> 10.64.200.81</li>
</ul>
The virtual IP (IP<sub>rb1-rb2</sub>) is 10.56.65.8 .<br>
Then the code will be
<code>
# get in the ULB path
cd /usr/local/ULB
# get in the prog 
cd sbin
# create a TCP farm 
perl  create_farm.pl -n dns_udp -d 10.56.65.8:53 -p U -c 10.64.200.61:53,10.64.200.71:53,10.64.200.81:53
#then  an UDP farm
perl  create_farm.pl -n dns_udp -d 10.56.65.8:53 -p T -c 10.64.200.61:53,10.64.200.71:53,10.64.200.81:53
</code>
do the same on the second machine (same command lines)

And then launch on the master 
<code>
perl launch_all_farm.pl 
</code>

<h4>
Example 2 Global Catalog MS Active Directory
</h4>
Suppose we have three AD  servers (can be the number you want) 
<ul>
<li> 10.64.200.61</li>
<li> 10.64.200.71</li>
<li> 10.64.200.81</li>
</ul>
The virtual IP (IP<sub>rb1-rb2</sub>) is 10.56.65.8 .<br>
Then the code will be
<code>
# get in the ULB path
cd /usr/local/ULB
# get in the prog 
cd sbin
# create a TCP farm 
perl  create_farm.pl -n dns_udp -d 10.56.65.8:3268 -p U -c 10.64.200.61:3268,10.64.200.71:3268,10.64.200.81:3268
</code>
do the same on the second machine (same command lines)

And then launch on the master 
<code>
perl launch_all_farm.pl 
</code>

<h4>
Example 3 LDAP
</h4>
Suppose we have three LDAP  servers (can be the number you want) 
<ul>
<li> 10.64.200.61</li>
<li> 10.64.200.71</li>
<li> 10.64.200.81</li>
</ul>
The virtual IP (IP<sub>rb1-rb2</sub>) is 10.56.65.8 .<br>
Then the code will be
<code>
# get in the ULB path
cd /usr/local/ULB
# get in the prog 
cd sbin
# create a TCP farm 
perl  create_farm.pl -n dns_udp -d 10.56.65.8:389 -p U -c 10.64.200.61:389,10.64.200.71:389,10.64.200.81:389
</code>
do the same on the second machine (same command lines)

And then launch on the master 
<code>
perl launch_all_farm.pl 
</code>

<h3>
Some explanations
</h3>
<ul>
<li>in $ULB_installed_PATH/sbin you have the scripts/programs</li>
<li>in $ULB_installed_PATH/bin you have the wrappers that bind/unbind farms on the virtual IP</li>
<li>in $ULB_installed_PATH/etc you have the first free control port for redirectors</li>
<li>in $ULB_installed_PATH/var you have a file for each farm you've defined</li>
</ul>
