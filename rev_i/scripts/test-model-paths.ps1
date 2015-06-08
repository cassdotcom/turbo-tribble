

Process { 

	# LOGFILE
	$LOG = "S:\TEST AREA\ac00418\reconversion\rev_i\logs\log.txt"
	"$($(get-timestamp -reporting))`tSTART SCRIPT" | Out-File $LOG
			
	# DATABASE
	$np_db = "S:\TEST AREA\ac00418\CBM\model_data\db\ModelDatabase.mdb"
	"$($(get-timestamp -reporting))`tDB: $($np_db)" | Out-File $LOG -append


	# SCRIPT
	$QRYDB = "S:\TEST AREA\ac00418\reconversion\rev_i\scripts\query-database.ps1" 	
	# ALIAS SCRIPT (OPTIONAL)
	set-alias query-database $QRYDB
	"$($(get-timestamp -reporting))`tALIAS: query-database" | Out-File $LOG -append

	# GET ALL SETUP
	$REGION_LIST, $LDZ_LIST = setup-synergee_structure
	
	# FY1	
	$msg = "Begin work on FY1"
	write-host $msg
	"$($(get-timestamp -reporting))`t$($msg)" | Out-File $LOG -append		
	
	# GET PATHS FOR FY1 MODELS
	foreach ( $reg in $REGION_LIST ) {
		
		$qry = "SELECT FY1MODELS.PATH, [NETWORKS].TITLE FROM FY1MODELS INNER JOIN NETWORKS ON FY1MODELS.ID = NETWORKS.ID WHERE NETWORKS.REGION2 = '$($reg)' "
		$msg = "Processing: $($reg)"
		write-host $msg
		"$($(get-timestamp -reporting))`t$($msg)" | Out-File $LOG -append		
		
		# query the database
		$results = query-database $np_db $qry
		
		# count the number of paths returned
		$n_of_networks = $results.count
		$msg = "$($n_of_networks) FOUND"
		write-host $msg
		"$($(get-timestamp -reporting))`t$($msg)" | Out-File $LOG -append
		
		# loop
		foreach ( $m in $results ) {
		
			# ADDITIONAL - ONLY FOR Y DRIVE!!!!
			$four_three = '\\\\scotia.sgngroup.net\\dfs\\shared\\Syn4.2.3'
			$m.PATH = $m.PATH -replace $four_three, "Y:"
			
			write-host "`rTesting: $($m.TITLE)" -NoNewLine
			$exists = Test-Path $m.PATH
			
			# Assume it doesn't exist
			$valid = 'NO'
			
			if ( $exists ) { $valid = 'YES' }
			write-host "`t`t$($valid)" -NoNewLine
			
			$qry = "UPDATE NETWORKS SET NETWORKS.FY1 = '$($valid)' WHERE NETWORKS.TITLE = '$($m.TITLE)' "			
			$results = query-database $np_db $qry
			
			"$($(get-timestamp -reporting))`t$($m.PATH)`t`t$($valid)" | Out-File $LOG -append
			start-sleep 1
			
		}
		
		
		write-host " . . . . . . DONE"
		
		$msg = "-----------------------------------------------------------"
		"$($(get-timestamp -reporting))`t$($msg)" | Out-File $LOG -append
	}
	
}


Begin {

#----------------------------------------------------------
# .function_GET-TIMESTAMP
#----------------------------------------------------------
function get-timestamp {

	Param(
		[Switch]
		$extension,
		[Switch]
		$reporting,
		[Switch]
		$readable
	)

	if ( $extension ) { $timestamp = Get-Date -UFormat "%d%b_%H-%M-%S" } 

	if ( $reporting ) { $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"	}

	if ( $readable ) { $timestamp = Get-Date -UFormat "%A%e %B %Y, %R" }
		
	return $timestamp
		
}
	<# 
#----------------------------------------------------------
# .function_GET-LOGFILE
#----------------------------------------------------------
function get-logfile {

	Param(
		[Parameter(Position=0, Mandatory=$true)]
		[System.string]
		$log_dir
	)
	
	# Find what is in this directory	
	$log_files = gci $log_dir
	
	# Move everything into 'old' directory so our log is the only file available here
	foreach ( $log in $log_files ) {
		if ( -Not $log.PSIsContainer ) {
			$dest = $log_dir + "\old\" + $log.name
			Move-Item -Path $log.FullName -Destination $dest
		}
	}
	$log_ext = get_timestamp -extension
	$PSHELL_LOG_FILE = $log_dir + "cbm-create-log." + $log_ext
		
	return $PSHELL_LOG_FILE
	
} #>


#----------------------------------------------------------
# .function_SETUP-SYNERGEE-STRUCTURE
#----------------------------------------------------------
	function setup-synergee_structure {
			
 		$REGION_LIST = @(
			'N1';
			'N2';
			'N3';
			'S0';
			'S1';
			'S2';
			'S6';
			'S7';
			'S8';
			'S9')
			
		$LDZ_LIST = @(
			'Scotland Networks';
			'Southern Networks')
			
		return $REGION_LIST, $LDZ_LIST
	} # END setup-synergee_structure
	
}


End {

	$msg = " "
	"$($(get-timestamp -reporting))`t$($msg)" | Out-File $LOG -append
	$msg = "DONE"
	"$($(get-timestamp -reporting))`t$($msg)" | Out-File $LOG -append
	$msg = "-----------------------------------------------------------"
	"$($(get-timestamp -reporting))`t$($msg)" | Out-File $LOG -append
	return 0

}
