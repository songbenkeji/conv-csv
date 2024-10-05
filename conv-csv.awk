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
#				Percentage of CPU utilization 
#				executing at the user level (application).
#		%
#
