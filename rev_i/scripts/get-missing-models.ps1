function Get-FileName {
	
	Param(
		[Parameter(Position = 0, Mandatory = $true)]
		[System.String]
		$initialDirectory,
		[Parameter(Position = 1, Mandatory = $false)]
		[System.String]
		$title="Select File...."
	) 
	
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

	 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	 $OpenFileDialog.initialDirectory = $initialDirectory
	 $OpenFileDialog.title = $title
	 $OpenFileDialog.filter = "Synergee Models (*.MDB)| *.MDB"
	 $OpenFileDialog.ShowDialog() | Out-Null
	 $OpenFileDialog.filename

} #end function Get-FileName

$log = "S:\TEST AREA\ac00418\reconversion\rev_i\logs\get-missing-models.log"


$np_db = "S:\TEST AREA\scripting\model_db\ModelDatabase.mdb"
$QRYDB = "S:\TEST AREA\ac00418\reconversion\rev_i\scripts\query-database.ps1" 
set-alias query-database $QRYDB

$msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tDataBase: $($np_db)"
$msg | Out-File $log

try { 

    # Get missing FY1s
    $query = "SELECT FY1MODELS.FOLDER, FY1MODELS.ID, NETWORKS.TITLE FROM FY1MODELS INNER JOIN NETWORKS ON FY1MODELS.ID = NETWORKS.ID WHERE NETWORKS.FY1 = 'NO' "
    $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tGet missing FY1"
    $msg | Out-File $log -Append
    $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($query)"
    $msg | Out-File $log -append
    $fy1_models = query-database $np_db $query

    if ( $fy1_models.count -eq 0 ) {

        Write-Host "NO MISSING FY1"
        $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tNO MISSING FY1"
        $msg | Out-File $log -append

    } else { 

        Write-Host "MODELS MISSING: $($fy1_models.count)"
        $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tMODELS MISSING: $($fy1_models.count)"
        $msg | Out-File $log -append

        foreach ( $m in $fy1_models ) {

            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tMODEL: $($m.TITLE)"
            $msg | Out-File $log -append

	        if ( Test-Path $m.FOLDER ) { 
		
		        $fy1_path = Get-FileName $m.FOLDER ($m.TITLE+ "`t FY1")
        
            } else { 
    	
                $fy1_path = Get-FileName "S:\" ($m.TITLE+ "`t FY1")        	
                $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tMODEL FOLDER NOT FOUND: $($m.TITLE)"
                $msg | Out-File $log -append
            }
    
    
	        $FOLDER = (Split-Path $fy1_path)+ "\"
	        $MODEL = Split-Path $fy1_path -leaf
	        $qry = "UPDATE FY1MODELS SET FY1MODELS.FOLDER = '$($FOLDER)' WHERE FY1MODELS.ID = $($m.ID) "	
            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($qry)"
            $msg | Out-File $log -append
		        $result = query-database $np_db $qry
            $qry = "UPDATE FY1MODELS SET FY1MODELS.MODEL = '$($MODEL)' WHERE FY1MODELS.ID = $($m.ID) "	
            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($qry)"
            $msg | Out-File $log -append
            $result = query-database $np_db $qry
            $qry = "UPDATE FY1MODELS SET FY1MODELS.PATH = '$($fy1_path)' WHERE FY1MODELS.ID = $($m.ID) "	
            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($qry)"
            $msg | Out-File $log -append
            $result = query-database $np_db $qry
            # VALID 
            $qry = "UPDATE NETWORKS SET NETWORKS.FY1 = 'YES' WHERE NETWORKS.ID = $($m.ID) "	
            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($qry)"
            $msg | Out-File $log -append
            $result = query-database $np_db $qry
        		
	
	        # same again for fy5
        }

    }
} catch { 

    Write-Host "FAILED RETRIEVING FY1"
    $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tFAILED RETRIEVING FY1"
    $msg | Out-File $log -append

}

try {

    # Get missing FY5s
    $query = "SELECT FY5MODELS.FOLDER, FY5MODELS.ID, NETWORKS.TITLE FROM FY5MODELS INNER JOIN NETWORKS ON FY5MODELS.ID = NETWORKS.ID WHERE NETWORKS.FY5 = 'NO' "
    $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tGet missing FY5"
    $msg | Out-File $log -Append
    $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($query)"
    $msg | Out-File $log -append
    $fy5_models = query-database $np_db $query

    if ( $fy5_models.count -eq 0 ) {

        Write-Host "NO MISSING FY5"
        $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tNO MISSING FY5"
        $msg | Out-File $log -append

    } else { 

        Write-Host "MODELS MISSING: $($fy5_models.count)"
        $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tMODELS MISSING: $($fy5_models.count)"
        $msg | Out-File $log -append

        foreach ( $m in $fy5_models ) {

            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tMODEL: $($m.TITLE)"
            $msg | Out-File $log -append

	        if ( Test-Path $m.FOLDER ) { 
		
		        $fy5_path = Get-FileName $m.FOLDER ($m.TITLE+ "`t FY5")  
        
            } else { 
    	
                $fy5_path = Get-FileName "S:\" ($m.TITLE+ "`t FY5")       	
                $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tMODEL FOLDER NOT FOUND: $($m.TITLE)"
                $msg | Out-File $log -append
            }
    
    
	        $FOLDER = (Split-Path $fy5_path)+ "\"
	        $MODEL = Split-Path $fy5_path -leaf
	        $qry = "UPDATE FY5MODELS SET FY5MODELS.FOLDER = '$($FOLDER)' WHERE FY5MODELS.ID = $($m.ID) "	
            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($qry)"
            $msg | Out-File $log -append
	        $result = query-database $np_db $qry
            $qry = "UPDATE FY5MODELS SET FY5MODELS.MODEL = '$($MODEL)' WHERE FY5MODELS.ID = $($m.ID) "	
            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($qry)"
            $msg | Out-File $log -append
            $result = query-database $np_db $qry
            $qry = "UPDATE FY5MODELS SET FY5MODELS.PATH = '$($fy5_path)' WHERE FY5MODELS.ID = $($m.ID) "	
            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($qry)"
            $msg | Out-File $log -append
            $result = query-database $np_db $qry
            # VALID 
            $qry = "UPDATE NETWORKS SET NETWORKS.FY5 = 'YES' WHERE NETWORKS.ID = $($m.ID) "	
            $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tQuery: $($qry)"
            $msg | Out-File $log -append
            $result = query-database $np_db $qry
        		
        }
    }

} catch { 

    Write-Host "FAILED RETRIEVING FY1"
    $msg = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")+ "`tFAILED RETRIEVING FY1"
    $msg | Out-File $log -append

}
		
