#----------------------------------------------------------
# .function_ADD-TO-OBJECT
#----------------------------------------------------------
    
    Param (
        [System.Object]
        $this_obj,
        [System.String]
        $NAME,
        [System.String]
        $VALUE
    )

    Try {
        
        $this_obj | Add-Member -MemberType NoteProperty -Name $NAME -Value $VALUE

    } Catch {

        write-to-log "CAN'T ADD MEMBER WITH:" -error
        write-to-log "`t`tNAME $($NAME)`t$($VALUE)" -error
        break

    }
