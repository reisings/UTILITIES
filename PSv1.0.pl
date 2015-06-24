#!/usr/bin/perl
#
$true=1;
#Change debugOutput to equal 1 to see a lot more screen output. Keeping it at 0 is cleaner.
$debugOutput=0;
#change Matrix to 1 to see cool matrix quotes spread through the program. YES it is totally relevant!
$Matrix=1;
#&notice;
sub notice () {
	&clearScreen;
	print "#####################################################################################################################\n";
	print "# Artistic Copyright (c) 2014 by Scott Reisinger.\n";
	print "# Author: Scott E. Reisinger\n";
	print "# Email: scott.reisinger.usa@gmail.com\n";
	print "# Phone: 618.537.5711\n";
	print "#####################################################################################################################\n";
	print "# Created by:   Scott Reisinger\n";
	print "# Purpose:      Used to ping sweep specific network ranges and run snmpv2 and snmpv3 sweep against hosts that reported back on pings\n";
	print "# Date:         5 June 2015\n";
	print "# Updates:\n";
	print "#####################################################################################################################\n";
	sleep 3;
	&clearScreen;
}


while ($true eq 1) {
	&init;
	&start;
	&awesome if $Matrix;
	&prompt;
	&trinity if $Matrix;
	&getOctets;
	&smith if $Matrix;
	&createIP;
	&startTime;	
	&pingIT;
	&endTime;
	&snmpv2;
	&snmpv3;
	&public;
	&getAlive;
	&end;
}

sub start () {
	print "**********************************   SERIAL PING SWEEP SCRIPT  **********************************\n";
	print "\nThis script will prompt for the start and end range of IP address you want to scan\n";
	print "Once verified the script will perform a single ping across all of the devices\n";
	print "NOTE: the pings are limited to under a second so it can take around 3 to 4 minutes to sweep an entire class C\n";
	print "NOTE: this script assumes that if you cross class C boundaries or octet boundaries that all 255 addresses will be pinged\n";
	print "\n***********************************************************************************************\n";
}

sub prompt() {

	print "\n\nEnter the starting IP address (i.e 192.168.1.1): ";
	$startIP=<STDIN>;
	chomp($startIP);

	print "\n\nEnter the ending IP address (i.e 192.168.1.255): ";
	$endIP=<STDIN>;
	chomp($endIP);

	print "\n\nPlease enter the SNMPv2 Community string used for your network: ";
	$v2comm=<STDIN>;
	chomp($v2comm);

}

sub clearScreen() {
	$clear=`clear`;
	print "$clear\n";
}

sub getOctets() {
	@SOCTETS=split(/\./,$startIP);
	$startIP1=@SOCTETS[0];
	$startIP2=@SOCTETS[1];
	$startIP3=@SOCTETS[2];
	$startIP4=@SOCTETS[3];
	if ($startIP1 > 255 || $startIP2 > 255 || $startIP3 > 255 || $startIP4 > 255) {
		&clearScreen;
		print "\n\n\n\t\t*****\n";
		print "\n\n\nTHE IP ADDRESS YOU ENTERED  - $startIP -  DOES NOT MEET IPV4 STANDARDS\n\n\n";
		&morpheus if $Matrix;
		print "\n\t\t*****\n\n\n";
		&end;
	}
	if ($startIP1 == "" || $startIP2 == "" || $startIP3 == "" || $startIP4 == "") {
		&clearScreen;
		print "\n\n\n\t\t*****\n";
		print "\n\n\nTHE IP ADDRESS YOU ENTERED  - $startIP -  DOES NOT MEET IPV4 STANDARDS\n";
		print "One or more octets was missing\n\n\n";
		&spoon;
		print "\n\t\t*****\n\n\n";
		&end;
	}
	

	@EOCTETS=split(/\./,$endIP);
	$endIP1=@EOCTETS[0];
	$endIP2=@EOCTETS[1];
	$endIP3=@EOCTETS[2];
	$endIP4=@EOCTETS[3];
	if ($endIP1 > 255 || $endIP2 > 255 || $endIP3 > 255 || $endIP4 > 255) {
		&clearScreen;
		print "\n\n\n\t\t*****\n";
		print "\n\n\nTHE IP ADDRESS YOU ENTERED - $endIP -  DOES NOT MEET IPV4 STANDARDS\n\n\n";
		&spoon;
		print "\n\t\t*****\n\n\n";
		&end;
	}

	if ($endIP1 == "" || $endIP2 == "" || $endIP3 == "" || $endIP4 == "") {
		&clearScreen;
		print "\n\n\n\t\t*****\n";
		print "\n\n\nTHE IP ADDRESS YOU ENTERED  - $endIP -  DOES NOT MEET IPV4 STANDARDS\n";
		print "One or more octets was missing\n\n\n";
		&morpheus;
		print "\n\t\t*****\n\n\n";
		&end;
	}

	print "START 1: $startIP1 2: $startIP2 3: $startIP3 4: $startIP4\n" if $debugOutput;
	print "END   1: $endIP1   2: $endIP2   3: $endIP3   4: $endIP4\n" if $debugOutput;

}


sub createIP() {
	@IPS=();
	$count=0;
	$j=0;
	$k=0;
	$l=0;
	$i=0;
	if ($startIP1 == $endIP1) {
		if($startIP2 == $endIP2) {
			# First and Second octets are good so lets check 3
			# If they are equal then we have a class C and count to 255
			if($startIP3 == $endIP3) {
				for($i=$startIP4; $i<=$endIP4; $i++){ 
					print "$endIP1.$endIP2.$endIP3.$i\n" if $debugOutput; 
					$thisIP=$endIP1 . "." . $endIP2 . "." . $endIP3 . "." . $i;
					print "THIS IP $thisIP\n" if $debugOutput;
					push(@IPS,$thisIP);
					$count++;
				}
			#If they are NOT equal then we need to count from where we are to the ending IP provided
			#This may be the easiest way for multiple class C's
			} else {
				for($l=$startIP3; $l<=$endIP3; $l++) { 
					for($i=1; $i<=255; $i++){ 
						print "$endIP1.$endIP2.$l.$i\n" if $debugOutput; 
						$thisIP=$endIP1.$endIP2.$l.$i;
						push(@IPS,$thisIP);
						$count++;
					} 
				}
			}#end if IP3 Same

		#If the second Octet is not the same we start running into some logic issues
		#we can still count to the endOctet but then we need to address the 3rd octet boundary to 255 and then to the end octet provided
		#e.g. 10.20.30.1 to 10.30.30.255 will see 30=30!
		#so we need to say count from startIP3 to 255 and THEN from the NEXT higher octet which would be 0 to the endIP3

		} else {
			for($k=$startIP2; $k<=$endIP2; $k++) {
				for($l=$startIP3; $l<=255; $l++) { 
					for($i=1; $i<255; $i++){ 
						print "$endIP1.$k.$l.$i\n" if $debugOutput; 
						$thisIP=$endIP1.$k.$l.$i;
						push(@IPS,$thisIP);
						$count++;
					} 
				}
				for($l=0; $l<=$startIP3; $l++) { 
					for($i=1; $i<255; $i++){ 
						print "$endIP1.$k.$l.$i\n" if $debugOutput; 
						$thisIP=$endIP1.$k.$l.$i;
						push(@IPS,$thisIP);
						$count++;
					} 
				}
			}
		}##end if IP2 same

	#I think this would be rare but we need to account for it anyway
	#assuming startIP1 is not the same as endIP1 we need to account for ip2 and IP3 both crossing the 255 boundary
	#using same logic as above should prove useful

	} else {

		#Assuming 1-255 will have to account for tard input

		for($j=$startIP1; $j<=$endIP1; $j++) {
			for($k=$startIP2; $k<=255; $k++) {
				for($l=$startIP3; $l<=255; $l++) {
					for($i=1; $i<=255; $i++) {
						print "$j.$k.$l.$i\n" if $debugOutput;
						$thisIP=$j.$k.$l.$i;
						push(@IPS,$thisIP);
						$count++;
					}
				}
			}
			for($k=0; $k<=$endIP2; $k++) {
				for($l=$startIP3; $l<=255; $l++) {
					for($i=1; $i<=255; $i++) {
						print "$j.$k.$l.$i\n" if $debugOutput;
						$thisIP=$j.$k.$l.$i;
						push(@IPS,$thisIP);
						$count++;
					}
				}
			}
		}
			

	}#end if IP1 same

	print "TOTAL NUMBER OF IP ADDRESSES BETWEEN $startIP and $endIP is: $count \n";
	$minutes=($count/60);
	print "\n\nThis sweep could take as long as $minutes minutes if there are a lot of dead addresses\n";

}#end sub

sub startTime () {
	$startTime=`date +'%m%d%y%H%M%S'`;
	chomp($startTime);
	print "START TIME: $startTime\n";
}

sub pingIT () {
	#depending on the platform we need to make sure that we are getting quality pings
	#might ask for max latencey and use 1000 byte pings
	#only ping once or twice?

	@RESULTS=();
	foreach $ip (@IPS) {
		chomp($ip);
		print "Pinging $ip 1 time\n" if $debugOutput;
		$grepPing=`ping -o -c 1 -s 100 -W .2 $ip | grep -i transmitted | awk -F" " '{print $4}'`; 
		chomp($grepPing);
		@PING=split(/ /,$grepPing);
		$result=@PING[3];
		if ($result =~ /1/) {
			$alive="$ip ALIVE";
			push (@RESULTS, $alive);
		} else {
			$dead="$ip DEAD";
			push (@RESULTS, $dead);
		}
		print "$grepPing\n" if $debugOutput;
		print " $ip\!";

	}
}

sub endTime () {
	$endTime=`date +'%m%d%y%H%M%S'`;
	chomp($endTime);
	print "\n\nEND TIME: $endTime\n";
	$delta=$endTime-$startTime;
	print "DELTA: $delta\n";
}

sub snmpv2() {
	$file="discovery_$startTime.csv";
	open(OUTFILE,">>$file") or die "cannot open < $file: $!";
	print OUTFILE "IP,PING STATUS,SNMP\n";
	foreach $result (@RESULTS) {
		chomp ($result);
		@INFO=split(/ /,$result);
		$IP=@INFO[0];
		chomp($IP);
		$STATUS=@INFO[1];
		chomp($STATUS);
		print "RESULTS: $result\n" if $debugOutput;
		&clearScreen;
		print "\n\n\nAt this point we will perform an SNMPWALK on all the IP's that reported alive\n\n\n";
		if ($STATUS =~ /ALIVE/) {
			# If the IP reported ALIVE we want to try and walk it
			# ideally we could check the mac table somewhere and get the IP to mac association
			# then we could look at the oid to see if it is just a host or a network device - ideally
			# hard times call for hard measures
			print "^^";

			$grepSNMPv2=`snmpwalk -r 0 -t 1 -v 2c -c $v2comm $IP sysDescr`;	
			@SYS=split(/,/,$grepSNMPv2);

			#get rid of those nasty commas so we can properly create a csv file
			$sysInfo="SNMPv2: @SYS[0] @SYS[1] @SYS[2] @SYS[3] @SYS[4]";
			chomp($sysInfo);

			print "$sysInfo\n" if $debugOutput;
			print OUTFILE "$IP,$STATUS,$sysInfo,\n";

		} else {
			#print OUTFILE "$IP,$STATUS,NO-SNMP-ATTEMPT\n";
		}
		
	}
	print "^>>\n\n";
	#close(OUTFILE);

}

sub snmpv3 () {

	print "\n\n\n\nDo you want to try SNMPv3? (Y/N): ";
	$v3ans=<STDIN>;
	chomp($v3ans);

	&clearScreen;

	if ($v3ans eq "Y" || $v3ans eq "y") {	
	
		print "Please select an SNMPv3 security level from the following menu:\n";
		print "********* SNMPv3 Security levels under USM ***********\n";
		print "1.  noauthpriv – No authentication, no privacy\n";
		print "2.  authnopriv – Authentication with no privacy\n"; 
		print "3.  authpriv – Authentication with privacy\n";
		print "Select your option then press enter or Q to quit: ";
		$secLvl=<stdin>;
		chomp($secLvl);

		while ($secUser eq "") {
			print "\nPlease enter the security user name for SNMPv3 (e.g. Nebuchadnezzar): ";
			$secUser=<STDIN>;
			chomp($secUser);
			print "You entered: $secUser is that correct (Y/N): ";
			$suans=<STDIN>;
			chomp($suans);
			if ($suans eq "N" || $suans eq "n") {
				print "\n\nOK Well then lets try this again!\n";
				print "Just so you understand SNMPv3 requires a security user so far the information you have provided looks like this\n";
				print "\t\t\tsnmpwalk -O qv -v 3 -u $IP sysDescr \n";
				print "but we need to get to \n";
				print "\t\t\tsnmpwalk -O qv -v 3 -u noauth -c v3test $IP sysDescr \n";
				print "\nwhere noauth is the username v3test is the community for NOAUTH access\n";
				print "\n\nThere are more examples and explanation but I don't have the time or will power to type it all here\n";
				print "please go to http://kb.juniper.net/InfoCenter/index?page=content&id=KB22048&smlogin=true to review the KB article\n\n\n";
				$suans="";
				$secUser="";
			} 
		}#end while

		while ($v3comm eq "") {
			print "\nPlease enter the community string for SNMPv3 (e.g. v3Test): ";
			$v3comm=<STDIN>;
			chomp($v3comm);
			print "You entered: $v3comm is that correct (Y/N): ";
			$csans=<STDIN>;
			chomp($csans);
			if ($csans eq "N" || $csans eq "n") {
				print "\n\nOK Well then lets try this again!\n";
				print "please go to http://kb.juniper.net/InfoCenter/index?page=content&id=KB22048&smlogin=true to review the KB article\n\n\n";
				$csans="";
				$v3comm="";
			} 
		}#end while

		#open(OUTFILE,">>$file") or die "cannot open < $file: $!";

		foreach $result (@RESULTS) {
			chomp ($result);
			@INFO=split(/ /,$result);
			$IP=@INFO[0];
			chomp($IP);
			$STATUS=@INFO[1];
			chomp($STATUS);
			print "RESULTS: $result\n" if $debugOutput;
			&clearScreen;
			if ($STATUS =~ /ALIVE/) {
				# If the IP reported ALIVE we want to try and walk it
				# ideally we could check the mac table somewhere and get the IP to mac association
				# then we could look at the oid to see if it is just a host or a network device - ideally
				# unfortunately hard times call for hard measures

				if ($secLvl eq "1") {
					$type="noauthpriv";
					print "$IP,$STATUS,TRYING NOAUTH SNMPv3\n";
					$grepSNMPv3=`snmpwalk -r 0 -t 1 -O qv -v 3 -u noauth -c $v3comm $IP sysDescr`;
					chomp($grepSNMPv3);
				} elsif ($secLvl eq "2") {
					$type="authnopriv";
					while ($apans eq "") {
						print "\n\nSelect the authentication protocol\n";
						print "1. MD5 (Message Digest 5)\n";
						print "2. SHA (Secure Hash Algorithm)\n";
						print "Select 1 or 2: ";
						$ap=<STDIN>;
						chomp($ap); 
						if ($ap eq "1" || $ap eq "2") {
							if ($ap eq "1") { 
								$apans="MD5"; 
								chomp($apans);
								print "\n$apans it is!!\n";
							}
							if ($ap eq "2") { 
								$apans="SHA"; 
								chomp($apans);
								print "\n$apans it is!!\n";
							}
						} else {
							print "You have to select an authentication protocol\n";
							$apans="";
						}
					}

					print "WOW THIS SNMPv3 STUFF IS COMPLICATED!!! We are almost there just another question\n";
					print "\nDoes your SNMPv3 authNoPriv configuration have a passphrase? (Y/N): ";
					$ppans=<STDIN>;
					chomp($ppans);

					if ($ppans eq "Y" || $ppans eq "y") {
						print "Please provide your passphrase : ";
						$phrase=<STDIN>;
						chomp($phrase);


						print "$IP,$STATUS,TRYING AUTHNOPRIV SNMPv3\n";
						print "authNoPriv command:  snmpwalk -r 0 -t 1 -O qv -v 3 -u $secUser -a $apans -A testtest -c $v3comm $IP sysDescr\n";
						$grepSNMPv3=`snmpwalk -r 0 -t 1 -O qv -v 3 -u $secUser -a $apans -A $phrase -c $v3comm $IP sysDescr`;
						chomp($grepSNMPv3);
					} else {
						print "$IP,$STATUS,TRYING AUTHNOPRIV SNMPv3\n";
						print "authNoPriv command:  snmpwalk -r 0 -t 1 -O qv -v 3 -u $secUser -a $apans -c $v3comm $IP sysDescr\n";
						$grepSNMPv3=`snmpwalk -r 0 -t 1 -O qv -v 3 -u $secUser -a $apans -c $v3comm $IP sysDescr`;
						chomp($grepSNMPv3);
					}

				} elsif ($secLvl eq "3") {
					$type="authpriv";
					while ($apans eq "") {
						print "\n\nSelect the authentication protocol\n";
						print "1. MD5 (Message Digest 5)\n";
						print "2. SHA (Secure Hash Algorithm)\n";
						print "Select 1 or 2: ";
						$ap=<STDIN>;
						chomp($ap); 
						if ($ap eq "1" || $ap eq "2") {
							if ($ap eq "1") { 
								$apans="MD5"; 
								chomp($apans);
								print "\n$apans it is!!\n";
							}
							if ($ap eq "2") { 
								$apans="SHA"; 
								chomp($apans);
								print "\n$apans it is!!\n";
							}
						} else {
							print "You have to select an authentication protocol\n";
							$apans="";
						}
					}

					print "WOW THIS SNMPv3 STUFF IS COMPLICATED!!! We are almost there just another question errr... or two\n";
					print "\nDoes your SNMPv3 authPriv configuration have an authentication protocol passphrase? (Y/N): ";
					$ppans=<STDIN>;
					chomp($ppans);

					print "\nAre you using privacy protocol (i.e. DES|AES) (Y/N): ";
					$ppeans=<STDIN>;
					chomp($ppeans);

					if ($ppans eq "Y" || $ppans eq "y") {
						print "Please provide your passphrase : ";
						$phrase=<STDIN>;
						chomp($phrase);
					}
					
					print "\n\n\t\t\t BTW - DID I MENTION THIS SNMPv3 SECURITY STUFF IS TEDIOUS?\n\n";

					if ($ppeans eq "Y" || $ppeans eq "y") {
						print "\nPlease select your Privacy Protocol encryption level\n";
						print "1. DES\n";
						print "2. AES\n";
						print "Select a valid answer (1|2): ";
						$ppe=<STDIN>;
						#chomp($ppe);

						if ($ppe !=  "1" || $ppe != "2") {
							
							print "\nREALLY? its 1 or 2 how hard can it be?\n";
							print "You entered: $ppe\n";
							print "can you tell I am tired of error correction yet?\n";
							print "im just going to go with AES for now.. i might come back and prompt you again but don't hold your breath\n";
							$ppecrypt="AES";
						} elsif ($ppe eq "1") {
							$ppecrypt="DES";
						} elsif ($ppe eq "2") {
							$ppecrypt-"AES";
						} else {
							print "Well i really do not know what to say at this point...sigh...\n";
						}
						
						print "\nDoes your SNMPv3 authPriv configuration have a privacy protocol passphrase? (Y/N): ";
						$pppans=<STDIN>;
						chomp($pppans);
				
						if ($pppans eq "Y" || $pppans eq "y") {
							print "Please enter your privacy protocol passphrase: ";
							$ppp=<STDIN>;
							chomp($ppp);
						}
					}

					if (($ppeans eq "Y" || $ppeans eq "y") && ($pppans eq "Y" || $pppans eq "y")) {
						print "$IP,$STATUS,TRYING AUTHPRIV SNMPv3\n";
						print "AuthPriv command: snmpwalk -r 0 -t 1 -O qv -v 3 -u $secUser -a $apans -A $phrase -x $ppecrypt -X $phrase -c $v3comm $IP sysDescr\n";
						$grepSNMPv3=`snmpwalk -r 0 -t 1 -O qv -v 3 -u $secUser -a $apans -A $phrase -x $ppecrypt -X $phrase -c $v3comm $IP sysDescr`;
						chomp($grepSNMPv3);
					} elsif (($ppeans eq "Y" || $ppeans eq "y") && ($pppans eq "N" || $pppans eq "n")) {
						print "$IP,$STATUS,TRYING AUTHPRIV SNMPv3\n";
						print "AuthPriv command: snmpwalk -r 0 -t 1 -O qv -v 3 -u $secUser -a $apans -x DES -c $v3comm $IP sysDescr\n";
						$grepSNMPv3=`snmpwalk -r 0 -t 1 -O qv -v 3 -u $secUser -a $apans -x $ppecrypt -c $v3comm $IP sysDescr`;
						chomp($grepSNMPv3);
					} else {
						print "\nYou have a weird config\n";
						print "Lets discuss the configuration and see if we need to update the script\n";
						print "Call me: Scott Reisinger, 618.537.5711\n";
					}
				} else {
					print "\nYou entered an incorrect option. Valid options are 1-3\n";
					print "Did you want to exit and start over? (Y/N)";
					$bail=<STDIN>;
					chomp($bail);
					if ($bail !~ "N" || $bail !~ "n") {
						&end;
					} else {
						&clearScreen;
						print "I am going to assume noAuth option 1 and press on otherwise\n";
						print "I will have to write a lot of code to account for you not being able to choose :)\n";
						print "Unfortunately I am under a time constraint\n";
						print "$IP,$STATUS,TRYING NOAUTH SNMPv3\n";
						$grepSNMPv3=`snmpwalk -r 0 -t 1 -O qv -v 3 -u noauth -c $v3comm $IP sysDescr`;
						chomp($grepSNMPv3);
					}
				}

				print "$grepSNMPv3\n" if $debugOutput;
				@SYS=split(/,/,$grepSNMPv3);
	
				#get rid of those nasty commas so we can properly create a csv file
				$sysInfo="SNMPv3: $type: : : @SYS[0] @SYS[1] @SYS[2] @SYS[3] @SYS[4]";
				chomp($sysInfo);
	
				print "$sysInfo\n" if $debugOutput;
				if ($SYS[0] ne "") {
					print OUTFILE "$IP,$STATUS,$sysInfo,\n";
				}
	
			} else {
				#print OUTFILE "$IP,$STATUS,NO-SNMP-ATTEMPT\n";
			}#end if ALIVE
		}#end foreach
	}#end if YES
	#close(OUTFILE);
}#end sub snmpv3

sub end () {
	print "\n\n\n\n\n\n";
	exit;
}

sub morpheus () {
	print "This is your last chance. After this, there is no turning back.\n";
	print "You take the blue pill - the story ends, you wake up in your bed\n";
	print "and believe whatever you want to believe. You take the red pill - \n";
	print "you stay in Wonderland and I show you how deep the rabbit-hole goes.\n";
	print "\t\t\t\t -morpheus\n\n\n";
}

sub spoon () {
	print "Do not try and bend the spoon. That's impossible.\n";
	print "Instead... only try to realize the truth.\n";
	print "\t\t\t\t -spoon boy\n\n\n";
}

sub smith () {
	&clearScreen;
	print "\n\n\nNever send a human to do a machine's job.\n";
	print "\t\t\t\t -agent smith\n\n\n\n";
	sleep 2;
}

sub trinity () {
	&clearScreen;
	print "\n\n\nThe answer is out there, Neo, and it's looking for you, and it will find you if you want it to.\n";
	print "\t\t\t\t - trinity\n\n\n\n";
	&clearScreen;
}

sub init () {

	$date=`date +'%m%d%y%H%M'`;
	$clear=`clear`;
	print "$clear\n";
	$startIP="";
	$startIP1="";
	$startIP2="";
	$startIP3="";
	$startIP4="";
	$endIP="";
	$endIP1="";
	$endIP2="";
	$endIP3="";
	$endIP4="";
	$secUser="";
	$v3comm="";
	$apans="";
}

sub awesome () {
	sleep 1;
	print "\n\n";
	print "\t\t\tTrinity: Neo... nobody has ever done this before. \n";
	print "\t\t\tNeo: I know. That's why it's going to work. \n\n\n\n";
	sleep 1;
}

sub public () {
	#open(OUTFILE,">>$file") or die "cannot open < $file: $!";
	foreach $result (@RESULTS) {
		chomp ($result);
		@INFO=split(/ /,$result);
		$IP=@INFO[0];
		chomp($IP);
		$STATUS=@INFO[1];
		chomp($STATUS);
		print "RESULTS: $result\n" if $debugOutput;
		&clearScreen;
		print "\n\n\nAt this point we will perform a PUBLIC community walk on IP's that reported alive\n\n\n";
		if ($STATUS =~ /ALIVE/) {
			# If the IP reported ALIVE we want to try and walk it
			# ideally we could check the mac table somewhere and get the IP to mac association
			# then we could look at the oid to see if it is just a host or a network device - ideally
			# hard times call for hard measures
			print "^^";

			$grepSNMPv2=`snmpwalk -r 0 -t 1 -v 2c -c public $IP sysDescr`;	
			@SYS=split(/,/,$grepSNMPv2);

			#get rid of those nasty commas so we can properly create a csv file
			if (@SYS[0]) {
				$sysInfo="SNMPv2 public: @SYS[0] @SYS[1] @SYS[2] @SYS[3] @SYS[4]";
				chomp($sysInfo);

				print "$sysInfo\n" if $debugOutput;
				print OUTFILE "$IP,$STATUS,$sysInfo,\n";
			}

		} else {
			#print OUTFILE "$IP,$STATUS,NO-SNMP-ATTEMPT\n";
		}
		
	}
	print "^>>\n\n";
	close(OUTFILE);


}

sub getAlive () {

	$IPJ="JUNIPERIPS.txt";
	$IPC="CISCOIPS.txt";
	$IPB="BROCADEIPS.txt";
	$IPH="HPIPS.txt";
	$IPN="NORTELIPS.txt";

	@grepAlive=`grep ALIVE $file`;
	chomp(@grepAlive);
	print "\n\nSURVEY SAYS!!\n\n";
	foreach $address (@grepAlive) {
		@rinfo=split(/,/,$address);
		$rip=@rinfo[0];
		$ractive=@rinfo[1];
		$rsnmp=@rinfo[2];
		@DEV=split(/:/,$rsnmp);
		$rver=@DEV[0];
		chomp($rver);
		$foundSNMP=@DEV[4];
		if ($foundSNMP) {
			print "$rip is active and we found $rver $foundSNMP\n";
		} else {
			print "$rip is active but no SNMP response\n";
		}
		if ($foundSNMP =~ /Juniper/) {
			open(JUNIPER,">>$IPJ") or die "cannot open < $IPJ: $!";
			print JUNIPER "$rip\n";
		}
		if ($foundSNMP =~ /Cisco/) {
			open(CISCO,">>$IPC") or die "cannot open < $IPC: $!";
			print CISCO "$rip\n";
		}
		if ($foundSNMP =~ /Brocade/) {
			open(BROCADE,">>$IPB") or die "cannot open < $IPB: $!";
			print BROCADE "$rip\n";
		}
		if ($foundSNMP =~ /HP/) {
			open(HP,">>$IPH") or die "cannot open < $IPH: $!";
			print HP "$rip\n";
		}
		if ($foundSNMP =~ /Nortel/) {
			open(NORTEL,">>$IPN") or die "cannot open < $IPN: $!";
			print NORTEL "$rip\n";
		}
	
			
	}

	close(JUNIPER);
	close(CISCO);
	close(BROCADE);
	close(HP);
	close(NORTEL);

}
