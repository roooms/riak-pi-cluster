

## Procedures

In this section we give step by step procedures on how to setup a Riak cluster on a set of Raspberry PIs;

				
### ii. Network configuration

1. Each Raspberry PI board needs to be assigned a static IP address for addressing and communication. This is carried out by editing the **interfaces** configuration file using a suitable text editor, like **vim** for example;

		$> sudo vim /etc/network/interfacest
		
2. After updating the interfaces configuration file, it should look similar to the following;

		iface eth0 inet static
		
		address   10.151.0.113
		netmask   255.255.255.0
		network   10.151.0.0
		broadcast 10.151.0.255
		gateway   10.151.0.1
		
		iface default inet static
	
	Each Raspberry Pi must have a unique IP address.	
		
3. Set the IP values for each parameter in accordance your network specifications, save the file and execute the following commands;


		$>  sudo ifconfig eth0 down
		$>  sudo ifconfig eth0 up
		
	or simply reboot the system.


4. Verify that the network settings were successfully applied by executing the following command ;

		$> ifconfig
		
	
	
### vii. Shortcut scripts (optional)

This procedure is optional but very useful when carrying out operation and maintance tasks. Create a folder in the  home directory, in this case **init_db**. Change into this directory and execute the following commands;

1. Network configuration shortcut

		$> vi configure_ip
		 
	Insert the following text
	
		sudo vi /etc/network/interefaces
		
	Make the script executable.
	
		chmod +x configure_ip
	
2. Riak configuration shortcut

		$> vi configure_riak
		 
	Insert the following text and save the file.
	
		sudo vi /home/pi/riak-2.0.1/rel/riak/etc/riak.conf
	
	Make the script executable.
	
		chmod +x configure_riak
		
	
3. Clear Riak DB shortcut

		$> vi clear_db		
		 
	Insert the following text and save the file.
	
		rm -rf /home/pi/riak-2.0.1/rel/riak/data/cluster_meta
		rm -rf /home/pi/riak-2.0.1/rel/riak/data/generated.configs
		rm -rf /home/pi/riak-2.0.1/rel/riak/data/leveldb
		rm -rf /home/pi/riak-2.0.1/rel/riak/data/kv_vnode
	
	Make the script executable.
	
		chmod +x clear_db	
	
3. Reset Riak DB shortcut

		$> vi reset_cluster		
		 
	Insert the following text and save the file.
	
		rm -rf /home/pi/riak-2.0.1/rel/riak/data
	
	Make the script executable.
	
		chmod +x reset_cluster		
		
4. Start Riak DB shortcut

		$> vi start_riak		
		 
	Insert the following text and save the file.
	
		/home/pi/riak-2.0.1/rel/riak/bin/riak start

	Make the script executable.
	
		chmod +x start_riak

5. Stop Riak DB shortcut

		$> vi stop_riak		
		 
	Insert the following text and save the file.
	
		/home/pi/riak-2.0.1/rel/riak/bin/riak stop

	Make the script executable.
	
		chmod +x stop_riak
