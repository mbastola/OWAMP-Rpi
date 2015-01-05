-------------To install owamp follow the steps: -------------------
1)Download and install ntp (if not already present) and ntpdate (for server syncronization).eg

	sudo apt-get intall ntp
	sudo apt-get update

2) Find ntp.conf and add appropriate server.

	server xxx.myserver.com

3) Update iptables. Add the following line to iptables and run iptables.

	cd /etc/network/if-up.d/	
	sudo vi iptables

4) Downlaod owamp_setup.sh file to any directory

5) Add root privileges
	chmod u+x owamp_setup.sh

6) Run the script

	./owamp_setup.sh user

------------- Optional: -------------------- 

4) Append these to the iptables (Firewall settings)

	# OWAMP Control (Incoming and Outgoing)
	iptables -A INPUT -m state --state NEW,ESTABLISHED -m tcp -p tcp --dport 861 -j ACCEPT
	iptables -A OUTPUT -m state --state NEW,ESTABLISHED -m tcp -p tcp --sport 861 -j ACCEPT
	iptables -A INPUT -m state --state NEW,ESTABLISHED -m tcp -p tcp --dport 861 -j ACCEPT
	iptables -A OUTPUT -m state --state NEW,ESTABLISHED -m tcp -p tcp --sport 861 -j ACCEPT

	# OWAMP Test (Incoming and Outgoing)
	iptables -A INPUT -m udp -p udp --dport 8760:9960 -j ACCEPT
	iptables -A OUTPUT -m udp -p udp --sport 8760:9960 -j ACCEPT
	iptables -A OUTPUT -m udp -p udp --dport 8760:9960 -j ACCEPT
	iptables -A INPUT -m udp -p udp --sport 8760:9960 -j ACCEPT

5) Execute

	sudo ./iptables
