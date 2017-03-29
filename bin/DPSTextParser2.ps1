#This script reads the .txt files from your folder and stores them into an arraylist of dictionaries called global:reportArray
#There are four options to run this script:
#option=1: read all .txt files
#option=2: read all .txt files in a given year
#option=3: read all .txt files in a given month
#option=4: read a specific .txt file
#option=5: read a user given array of .txt files
function parseReports2{
    [OutputType([System.collections.Arraylist])]
    [CmdletBinding(DefaultParameterSetName='ByUserName')]

    param(
         [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
         [int] $option,
         [Alias("projectpath")]
         [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
         [string] $filepath,
         [ValidateNotNull()]
         [string] $file,
         [string] $year,
         [string] $month,
         $txtnames,
         [switch] $generateDataset,
         [string] $dataset,
         [switch] $append,
         [switch] $suppress
    )
	
    $incompletereports=0
    #Generates the dictionary of .txt files based on which option you picked
    if($option -eq 1){
        $txtlist= dir -recurse $filepath\dpsreports\*txt
    }
    elseif($option -eq 2){
        if(-not ($year)){
            $year = Read-host "Year"
        }
        $txtlist= dir -recurse $filepath\dpsreports\$year\*txt
    }
    elseif($option -eq 3){
        if(-not ($year)){
            $year = Read-host "Year"
        }
        if(-not ($month)){
            $month = Read-host "Month"
        }
        if($month.length -eq 1){
            $month="0"+$month
        }
        $txtlist= dir $filepath\dpsreports\$year\$month\*txt
    }
    elseif($option -eq 4){
        if(-not ($file)){
            $txtinput = Read-host "File"
        }
        else{
            $txtinput=$file
        }
        $month=$txtinput.substring(0,2)
        $year=$txtinput.substring(4,2)
        $txtlist= dir $filepath\dpsreports\20$year\$month\$txtinput
    }
    
    if($option -eq 5){
        #in the case we've provided a list of names already
        $textlist=$txtnames
    }
    else{
        #extracting the name of each .txt file from txtlist 
        $txtlist= $txtlist.name
    }

    

    #count keeps track of what index we are currently on when adding to our array
    $count=0

    #summary is the summary field of each report
    $summary=""

    #report is the dictionary that we will fill out as we iterate through the file and add to our array
    $report=@{"Report #"="";"Incident"="";"Location"="";"Occurred"="";"Reported"="";"Disposition"="";"Summary"=""}

    #finally, our array is where we will add all of our reports into
    [System.Collections.ArrayList] $array=new-object System.Collections.ArrayList

    $reportnums= @{}
     [System.Collections.ArrayList] $reportFactory=new-object System.Collections.ArrayList

    #-------------------------------------------------Text parsing---------------------------------------------------------#
    #This is where the juicy txt parsing happens. I won't go into much detail but essentially we are using a state machine to
    #keep track of what fields we have already gotten and what we're looking for next. This is important because the pdf to txt
    #conversion doesn't happen very neatly. Regardless, this method works very well and is able to successfully parse through and
    #read about 95% of reports. Successful reads are determined by no empty fields and no junk text in the summaries.
    $state=0
    foreach ($txt in $txtlist){
        write-verbose "***************************Beginning $txt**********************************"
        $unmatchedreportnums = New-Object System.Collections.Queue
        $state=0
        $summary=""
        $month=$txt.substring(0,2)
        $year=$txt.substring(4,2)
        $reader = [System.IO.File]::OpenText("$filepath\dpsreports\20$year\$month\$txt")
        $report=@{"Report #"="";"Incident"="";"Location"="";"Occurred"="";"Reported"="";"Disposition"="";"Summary"="";"File"=""}
        $dispositions= @("Open","CLOSED","Unfounded","Hold Over","Void","Cleared Arrest","Cleared by Exceptional Means","Inactive Investigation")
        $readnextline=$true
        
        try {
            for() {
                $complete=$true
                if($readnextline){
                    $line = $reader.ReadLine()
                }
                else{
                    $readnextline = $true
                }
                if($line -ne $null){
                    write-debug $line 
                }
                if($line -eq $null){
                    break
                }
                $incidentline= $line -replace "Incident: "
                if($line -eq "University of Southern California"){
                    write-debug "Got title... skipping next 3 lines"
                    $line = $reader.ReadLine()
                    $line = $reader.ReadLine()
                    $line = $reader.ReadLine()
                    $line = $reader.ReadLine()
                }
                if($line -notmatch "\w"){
                    write-debug "skipping line"
                    continue
                }
                if($line -match "Re ported:*$|Occurred:*$|Incident:*$|Summary:*$|^cc:"){
                    continue
                }
                if($line -match "Location:"){
                    $report."File"= $txt
                    $values = $line -split "Location: |Re *port *#:|Reported: "
                    if($line -notmatch "Reported:"){
                        write-debug "no reported found"
                        $report."Reported" = $values[0]
                        $report."Location" = $values[1]
                        if($values[2] -ne $null -and $values[2] -ne ""){
                            $report."Report #" = $values[2].trim()
                        }
                        
                    }
                    else{
                        write-debug "reported found"
                        $report."Reported" = $values[1]
                        $report."Location" = $values[2]
                        if($values[3] -ne $null -and $values[3] -ne ""){
                            $report."Report #" = $values[3].trim()
                        }
                    }
                }
                elseif($line -notmatch "\D"){
                    write-debug "adding to unmatched report #"
                    [void]$unmatchedreportnums.Enqueue($line)
                }
                elseif ($line -match "Re *port *#:"){
                    write-debug "report # found"
                    write-debug "adding to unmatched report #"
                    [void]$unmatchedreportnums.Enqueue($line -replace "Re *port *#: *")
                }
                elseif($line -match "Disposition:"){
                    $values = $line -split "Disposition:|Occurred: "
                    if($line -notmatch "Occurred:"){
                        write-debug "no occurred found"
                        $report."Occurred"= $values[0]
                        if($values[1] -ne $null -and $values[1] -ne ""){
                           $report."Disposition"=$values[1].trim()
                        }
                    }
                    else{
                        write-debug "occurred found"
                        $report."Occurred"= $values[1]
                        if($values[2] -ne $null -and $values[2] -ne ""){
                           $report."Disposition"=$values[2].trim()
                        }
                    }
                }
                elseif($dispositions -contains $line){
                    write-debug "adding to disposition"
                    $report."Disposition"= $line
                }
                elseif($line -cnotmatch "[a-z]"){
                    write-debug "adding to location"
                    $report."Location" += $line
                }
                elseif ($incidentline -cmatch "^[A-Z]{2}"){
                    write-debug "adding to Incident"
                    $report."Incident" = $incidentline
                }
                else{
                    write-debug "adding to summary"
                    $report."Summary"+=$line -replace "Summary: "
                    while($report."Summary" -notmatch "\.$"){
                        $line = $reader.ReadLine()
                        if($line -match "location:|reported:|disposition:|re *port *#:|re ported:|occurred:#"){
                            $report."summary"+="." 
                            $readnextline=$false
                            write-debug "No period was found; exiting loop"
                            break
                        }
                        if($line -ne $null){
                            write-debug $line
                        }
                        else{
                            break
                        }
                        write-debug "adding to summary while there is no ."
                        $report."Summary" += " "+$line
                        
                    }
                }
                
               #$report                
                
                foreach ($key in $report.Keys){
                    
                    if($key -ne "Report #" -and ($report.$key -eq "" -or $report.$key -eq $null)){
                        $complete = $false
                    }
                   
                }
                if($complete){
                    write-verbose "adding report"
                    if($report."Report #" -eq "" -or $array.$report."Report #" -eq $null -or $array."Report #" -notcontains $report."Report #"){
                        [void]$array.add($report)
                    }
                    if($report."Report #" -eq "" -or $report."Report #" -eq $null){
                        $incompletereports++
                    }
                    $report=@{"Report #"="";"Incident"="";"Location"="";"Occurred"="";"Reported"="";"Disposition"="";"Summary"="";"File"=""}
                }
                write-verbose "Number of incomplete reports: $incompletereports"
                $output = "Number of unmatched report #s: " + [convert]::ToString( $unmatchedreportnums.count)
                write-verbose $output
            }
            
        }
        finally {
            foreach($reports in $array){
                
                if($reports."Report #" -eq "" -or $reports."Report #" -eq $null -and $unmatchedreportnums.count -ne 0){
                    
                    $num = $unmatchedreportnums.Dequeue()
                    write-verbose "Adding missing report #$num"
                    $reports."Report #" = $num
                }
            }
            $reader.Close()
        }
        write-verbose "***************************Completed $txt**********************************"
       
    }
    
    cleanup([ref] $array)
	write-verbose "Cleaning up array"
    sortReports([ref]$array)
	write-verbose "Sorting array"
    $retval=0
    if($generateDataset){
        if($filepath -like "*bin*"){
            . $filepath\ReportIO.ps1
        }
        else {
            . $filepath\bin\ReportIO.ps1
        }
		if (-not ($dataset)){
            $dataset="output.dps"
        }
        if(-not ($dataset -like "*.dps")){
            $dataset+= ".dps"
        }
        if($append){
            $retval = write-Reports2 -array $array -path "$filepath\data\$dataset" -append -verbose
        }
        else{
            $retval = write-Reports2 -array $array -path "$filepath\data\$dataset" -verbose 
        }
    }
	
    if(-not $suppress){
        return $array
    }
    else{
        return $retval
    }

}


function cleanup([ref]$reportList){
    $array = $reportList.Value
    foreach($case in $array){
        if($case."Location" -match " :$"){
            $case."Location" = $case."Location" -replace " :$",""
        }
        if($case."Location" -match "VW"){
            $case."Location" = $case."Location" -replace "VW","WY"
        }
        if($case."Incident" -match "PIain"){
             $case."Incident" = $case."Incident" -replace "PIain","Plain"
        }
        if($case."Location" -match "\|"){
             $case."Location" = $case."Location" -replace "\|","I"
        }
        if($case."Incident" -match "V\\ﬁ|V\\ﬂ"){
             $case."Incident" = $case."Incident" -replace "V\\ﬁ|V\\ﬂ","Wi"
        }
        if($case."Incident" -match "ﬁ|ﬂ"){
             $case."Incident" = $case."Incident" -replace "ﬁ|ﬂ","fi"
        }
        if($case."Incident" -match "VW"){
             $case."Incident" = $case."Incident" -replace "VW","Wi"
        }
        if($case."Incident" -match "ofa"){
             $case."Incident" = $case."Incident" -replace "ofa","of a"
        }
        if($case."Incident" -match "AWeapon"){
             $case."Incident" = $case."Incident" -replace "AWeapon","A Weapon"
        }
        if($case."Incident" -match "MotorVehicle|MotorVehicIe"){
             $case."Incident" = $case."Incident" -replace "MotorVehicle|MotorVehicIe","Motor Vehicle"
        }
        if($case."Incident" -match "Theftfrom"){
             $case."Incident" = $case."Incident" -replace "Theftfrom","Theft From"
        }
        if($case."Incident" -match "VAN DALISM"){
             $case."Incident" = $case."Incident" -replace "VAN DALISM","VANDALISM"
        }
        if($case."Reported" -match "—"){
             $case."Reported" = $case."Reported" -replace "—","-"
        }
        if($case."Occurred" -match "—"){
             $case."Occurred" = $case."Occurred" -replace "—","-"
        }
        
    }
    
}
function sortReports ([ref]$arrayref){
    $inputArray= $arrayref.Value
    if($inputArray.count -gt 1){
        $swapped=0;
        [System.Collections.Hashtable] $tempReport=@{}
        while($swapped-eq 0){
           
            $swapped=1
            for($i=1; $i -lt $inputArray.Count; $i++){
                if($inputArray[$i]."Report #" -eq $null -or $inputArray[$i-1]."Report #" -eq $null){
                   
                    continue
                }
                if($inputArray[$i]."Report #" -lt $inputArray[$i-1]."Report #"){
                   
                    $tempReport=$inputArray[$i]
                    $inputArray[$i]=$inputArray[$i-1]
                    $inputArray[$i-1]=$tempReport
                    $swapped = 0
                }
            }
        }
    }
    
}
