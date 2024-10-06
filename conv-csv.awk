#######################################################################
#
#######################################################################
BEGIN{
	# Set Output File Name
	Output_Path = "" ;		# Output Path Name
	Output_CPU	= "" ;		# CPU Performance File Name

	# Header Flag
	Header_CPU	= "OFF" ;	# CPU Information Header

	# Control Flag
	CPU_Flag	= 0.0 ;		# CPU Conrol Flag

}

#######################################################################
#
#######################################################################
END{
	printf( "\rInput-File Read Record : " NR ) ;
	print "" ;
}


#######################################################################
#
#######################################################################
{
	# Check Line:1
	if( FNR == 1 ) {
		Output_Path = "" ;
		iPosition = 0 ;

		# Get Path Name
		for( count = length( FILENAME ) ; count > 1 ; --count ) {
			if( substr( FILENAME, count, 1 ) == "/" ) {
				iPosition = count ;
				break ;
			}
		}

		# Set Output Path
		if( iPosition != 0 ) {
			Output_Path = substr( FILENAME, 1, iPosition ) ;
		}

		# Set Output File Name
		Output_CPU = Output_Path "sar_CPU.csv" ;

	}
}

#######################################################################
#
#######################################################################
/^$/ || /^平均値:/ || /^Average:/ {

	# Reset value
	time		= "" ;
	CPU_Flag	= 0.0 ;

	# Next Line
	next ;

}


#######################################################################
#	Report CPU utilization.(-u ALL)
#		time	:
#		%user	:
#				Percentage of CPU utilization that occured while 
#				executing at the user level (application).
#		%usr	:
#				Percentage of CPU utilization that occured while 
#				executing at the user level (application).
#		%nice	:
#				Percentage of CPU utilization that occurred while
#				executing at the user level with nice priority.
#		%system	:
#				Percentage of CPU utilization that occured while
#				executing at the system level (kernel).
#		%sys	:
#				Percentage of CPU utilization that occured while
#				executing at the system level (kernel).
#		%iowait	:
#				Percentage of time that the CPU or CPUs were idle
#				during which the system had on outstanding disk
#				I/O request.
#		%steal	:
#				Percentage of time spent in involuntary wait by the
#				virtual CPU or CPUs while the hypervisor was
#				servicing another virtual processor.
#		%irq	:
#				Percentage of time spent by the CPU or CPUs to
#				service hardware interrupts.
#		%soft	:
#				Percentage of time spent by the CPU or CPUs to
#				service software interrupts.
#		%guest	:
#				Percentage of time spent by the CPU or CPUs to run
#				a virtual processor.
#		%gnice	:
#				Percentage of time spent by the CPU or CPUs to run
#				a niced guest.
#		%idle	:
#				Percentage of time that the CPU or CPUs were idle
#				and the system did not have an outstanding disk
#				I/O request.
#######################################################################
##### CPU Information Check
$2 ~ /^CPU/ {

	# Check virtual processor
	if( $3 == "%usr" ) {
		CPU_Flag = 1.0 ;
	}

	# Next Line
	next ;

}

##### Get Value
CPU_Flag == 1.0 {

	time		= $1 ;
	CPU			= $2 ;
	usr			= $3 ;
	nice		= $4 ;
	sys			= $5 ;
	iowait		= $6 ;
	steal		= $7 ;
	irq			= $8 ;
	soft		= $9 ;
	guest		= $10 ;
	gnice		= $11 ;
	idle		= $12 ;
	usr_total	= usr + guest + gnice ;
	sys_total	= sys + irq + soft ;
	total		= usr_total + nice + sys_total ;

	CPU_Flag = 2.0 ;

}

##### Set Header
CPU_Flag == 2.0 {

	if( Header_CPU != "ON" ) {
		print \
			"time," \
			"CPU," \
			"%usr," \
			"%nice," \
			"%sys," \
			"%iowait," \
			"%steal," \
			"%irq," \
			"%soft," \
			"%guest," \
			"%gnice," \
			"%idle," \
			"usr_total," \
			"sys_total," \
			"total," \
			> Output_CPU ;

		Header_CPU = "ON" ;

	}

	printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n",
		time,
		CPU,
		usr,
		nice,
		sys,
		iowait,
		steal,
		irq,
		soft,
		guest,
		gnice,
		idle,
		usr_total,
		sys_total,
		total \
		>> Output_CPU ;

	CPU_Flag = 1.0 ;

	next ;

}
