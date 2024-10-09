#######################################################################
#
#######################################################################
BEGIN{
	# Set Output File Name
	Output_Path 	= "" ;		# Output Path Name
	Output_CPU		= "" ;		# CPU Performance File Name
	Output_Paging	= "" ;		# Paging Performance File Name
	Output_IO		= "" ;		# I/O and transfer Performance File Name

	# Header Flag
	Header_CPU		= "OFF" ;	# CPU Information Header
	Header_Paging	= "OFF" ;	# Paging Information Header
	Header_IO		= "OFF" ;	# I/O and transfer Information Header

	# Control Flag
	CPU_Flag		= 0.0 ;		# CPU Conrol Flag
	Paging_Flag		= 0.0 ;		# Paging Conrol Flag
	IO_Flag			= 0.0 ;		# I/O and transfer Conrol Flag

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
		Output_Paging = Output_Path "sar_Paging.csv" ;

	}
}

#######################################################################
#
#######################################################################
/^$/ || /^平均値:/ || /^Average:/ {

	# Reset value
	time		= "" ;
	CPU_Flag	= 0.0 ;
	Paging_Flag	= 0.0 ;

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

#######################################################################
#	Report paging statistics.(-B)
#		time		:
#		pgpgin/s	:
#					Total number of kilobytes the system paged in from
#					disk per second.
#		pgpgout/s	:
#					Total number of kilobytes the system paged out
#					to disk per second.
#		fault/s		:
#					Number of page faults (major+minor) made by the
#					system per second.
#		majflt/s	:
#					Number of major faults the system has mde 
#					per second.
#		pgfree/s	:
#					Number of pages placed on the free list by the 
#					system per second.
#		pgscank/s	:
#					Number of pages scanned by the kswapd daemon 
#					per second.
#		pgscand/s	:
#					Number of pages scanned directly per second.
#		pgsteal/s	:
#					Number of pages the system has reclaimed from
#					cache (pagecache and swapcache) per second to
#					satisfy its memory demands.
#		%vmeff		:
#					Calculated as pgsteal / pgscan, this is a metric
#					of the efficiency of page reclaim.
#######################################################################
##### Paging Information Check
$2 ~ /^pgpgin\/s/ {

	Paging_Flag = 1.0 ;

	# Next Line
	next ;

}

##### Get Value
Paging_Flag == 1.0 {

	time		= $1 ;
	pgpgin		= $2 ;
	pgpgout		= $3 ;
	fault		= $4 ;
	majflt		= $5 ;
	pgfree		= $6 ;
	pgscank		= $7 ;
	pgscand		= $8 ;
	pgsteal		= $9 ;
	vmeff		= $10 ;

	Paging_Flag = 2.0 ;

}

##### Set Header
Paging_Flag == 2.0 {

	if( Header_Paging != "ON" ) {
		print \
			"time," \
			"pgpgin/s," \
			"pgpgout/s," \
			"fault/s," \
			"majflt/s," \
			"pgfree/s," \
			"pgscank/s," \
			"pgscand/s," \
			"pgsteal/s," \
			"%vmeff," \
			> Output_Paging ;

		Header_Paging = "ON" ;

	}

	printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n",
		time,
		pgpgin,
		pgpgout,
		fault,
		majflt,
		pgfree,
		pgscank,
		pgscand,
		pgsteal,
		vmeff \
		>> Output_Paging ;

	Paging_Flag = 1.0 ;

	next ;

}

#######################################################################
#	Report I/O and transfer rate statistics.(-b)
#		time	:
#		tps		:
#				Total number of transfer per second that were issued
#				to physical devices.
#		rtps	:
#				Total number of read requests per second issued to 
#				physical devices.
#		wtps	:
#				Total number of write requests per second issued to
#				physical devices.
#		dtps	:
#				Total number of discard requests per second issued to
#				physical devices.
#		bread/s	:
#				Total amount of data read from the devices in blocks 
#				per second.
#		bwrtn/s	:
#				Total amount of data written to devices in blocks
#				per seconds.
#		bdscd/s	:
#				Total amount of data discarded for devices in blocks
#				per second.
#######################################################################
##### I/O and transfer rate Information Check
$2 ~ /^tps/ {

	IO_Flag = 1.0 ;

	# Next Line
	next ;

}

##### Get Value
IO_Flag == 1.0 {

	time	= $1 ;
	tps		= $2 ;
	rtps	= $3 ;
	wtps	= $4 ;
	dtps	= $5 ;
	bread	= $6 ;
	bwrtn	= $7 ;
	bdscd	= $8 ;

	IO_Flag = 2.0 ;

}

##### Set Header
IO_Flag == 2.0 {

	if( Header_IO != "ON" ) {
		print \
			"time," \
			"tps," \
			"rtps," \
			"wtps," \
			"dtps," \
			"bread/s," \
			"bwrtn/s," \
			"bdscd/s," \
			> Output_IO ;

		Header_IO = "ON" ;

	}

	printf "%s,%s,%s,%s,%s,%s,%s,%s,\n",
		time,
		tps,
		rtps,
		wtps,
		dtps,
		bread,
		bwrtn,
		bdscd \
		>> Output_IO ;

	Paging_IO = 1.0 ;

	next ;

}
