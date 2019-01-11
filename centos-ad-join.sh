#!/bin/bash
#I normally save this as config.sh on the server and run as root.

#Join CentOS 7 servers to domain and configure sudoers as IT group. Add hyper-v services and configure
#run as root

#install necessary dependencies
yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python -y

#install hyper-v integration tools
yum install hyperv-daemons -y

#update packages now that they are all installed
yum update -y

#configure hyper-v integration tools to start as a service
systemctl enable hypervvssd
systemctl enable hypervkvpd

#enable hyper-v VSS full access through SELinux
semanage permissive -a hypervvssd_t

#join the domain
#EDIT THIS TO YOUR DOMAIN!
realm join --user=administrator >domain.tld>
#user will be asked for the domain admin pw at this time

#modify sssd conf to not use FQDN to login
sed -i -e 's|use_fully_qualified_names = True|use_fully_qualified_names = False|' /etc/sssd/sssd.conf
sed -i -e 's|fallback_homedir = /home/%u@%d|fallback_homedir = /home/%u|' /etc/sssd/sssd.conf
#restart service so changes take effect
systemctl restart sssd.service

#allow IT group to have sudo access. replace with whatever AD group you want, or comment the thang out

echo "%IT ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers.d/sudoers > /dev/null



#Allow SSSD apps through SElinux
setsebool -P allow_ypbind=1



echo "Success!"
