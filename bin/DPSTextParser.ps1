#This script reads the .txt files from your folder and stores them into an arraylist of dictionaries called global:reportArray
#There are four options to run this script:
#option=1: read all .txt files
#option=2: read all .txt files in a given year
#option=3: read all .txt files in a given month
#option=4: read a specific .txt file
function parseReports{
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
         [switch] $generateDataset,
         [string] $dataset,
         [switch] $append,
         [switch] $suppress
    )
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

    #extracting the name of each .txt file from txtlist 
    $txtlist= $txtlist.name

    #count keeps track of what index we are currently on when adding to our array
    $count=0

    #summary is the summary field of each report
    $summary=""

    #report is the dictionary that we will fill out as we iterate through the file and add to our array
    $report=@{"Report #"="";"Incident"="";"Location"="";"Occurred"="";"Reported"="";"Disposition"="";"Summary"=""}

    #finally, our array is where we will add all of our reports into
    [System.Collections.ArrayList] $array=new-object System.Collections.ArrayList

    $reportnums= @{}

    #-------------------------------------------------Text parsing---------------------------------------------------------#
    #This is where the juicy txt parsing happens. I won't go into much detail but essentially we are using a state machine to
    #keep track of what fields we have already gotten and what we're looking for next. This is important because the pdf to txt
    #conversion doesn't happen very neatly. Regardless, this method works very well and is able to successfully parse through and
    #read about 95% of reports. Successful reads are determined by no empty fields and no junk text in the summaries.
    $state=0
    foreach ($txt in $txtlist){
        $state=0
        $summary=""
        $month=$txt.substring(0,2)
        $year=$txt.substring(4,2)
        $reader = [System.IO.File]::OpenText("$filepath\dpsreports\20$year\$month\$txt")
        $nextline = $reader.ReadLine()
        try {
            for() {
                $line=$nextline
                $nextline = $reader.ReadLine()
                 
                #

                if ($line -eq $null) { break }
            
                if($state -eq 0){
                    if($line -like "*#*"){
                        $state=1
                        $line= $line -replace "Reported: "
                        $line= $line -replace "Location"
                        $line= $line -replace "Report.*#"
                        $line=$line -split ": "
                        $report["Reported"]=$line[0]
                        $report["Location"]=$line[1]
                        $report["Report #"]=$line[2]
                    }
                }
                elseif($state -eq 1){
                    if($line -split " " | %{$_ -cmatch “^[A-Z]*$”} | select-object -index 0){
                        $report["Location"]+=$line
                    } 
                    if($line -like "*Disposition*"){
                        $state=2
                        $line= $line -replace "Occurred: "
                        $line= $line -replace "Disposition"
                        $line=$line -split ": "
                        $report["Disposition"]=$line[1]
                        $report["Occurred"]=$line[0]
                    }
                    if($nextline -like "*#*"){
                        #write-output "State Reset"
                        $state=0
                    }
                }
                elseif($state -eq 2){
                    if($line -like "*Incident:*" -and $line.length -gt 10){
                   
                        $line= $line -replace ".*Incident: "
                        $report["Incident"]=$line
                        $state=3
                    }
                    elseif($line -ne "" -and ($line -split " " -split "-" -split "&" | %{$_ -cmatch “^[A-Z]*$”} | select-object -index 0)){
                        $line= $line -replace ".*Incident: "
                        $report["Incident"]=$line
                        $state=3
                    }
                }
                elseif($state -eq 3){
                    if($line -like "*#*"){

                        $reportnum=$report["Report #"]
                        if($summary -like "*$reportnum*"){ 
                            $lowerIndex=$summary.indexof("$reportnum")+$reportnum.length
                            $upperIndex=$summary.lastindexOf(".")
                            if($upperIndex-$lowerIndex+1 -gt 0){
                                $summary=$summary.substring($lowerIndex, $upperIndex-$lowerIndex+1)
                            }
                        }
                        if($summary -like "*Summary*"){
                        
                            $lowerIndex=$summary.lastindexof("Summary")+9
                            $upperIndex=$summary.lastindexOf(".")
                            if($upperIndex -gt 0){
                                $summary=$summary.substring($lowerIndex)   
                            }
                        }
                        $regEx = [regex]'\w'
                        $match=$regEx.Match($summary)
                        $summary=$summary.substring($match.index)
                        if($summary.length -gt 10){
                            if($summary.substring(0,10).equals("University")){
                                $regEx = [regex] '\s{2,}'
                                $match=$regEx.Match($summary)
                                $summary=$summary.substring($match.index)
                                $regEx = [regex]'\w'
                                $match=$regEx.Match($summary)
                                $summary=$summary.substring($match.index)
                            }
                        }

                        $report["Summary"]=$summary
                        $report["File"]=$txt
                        if(-not ($reportnum -match "\w") -or -not ($reportnums.keys -contains $reportnum)){
                            [void]$array.add($report.clone()) #<-------adding to the array
                            if($reportnum -ne $null -and $reportnum -match "\w"){
                                $reportnums[$reportnum]=$count
                            }
                            #write-output "Added "$report["Report #"]
                            $count+=1
                           
                        }
                        else{
                            if($reportnums.keys -contains $reportnum){
                                #write-output "replacement made at index "$reportnums[$reportnum]
                                #Write-output "Before: "$array[$reportnums[$reportnum]]
                                $prevReportIndex=$reportnums[$reportnum]
                                #write-output "Swapped "$report.Index"for "$array[$prevReportIndex].Index
                                $array[$prevReportIndex]=$report.clone()
                                #Write-output "After: "$report
                            }
                        }

                        $state=1
                        $line= $line -replace "Reported: "
                        $line= $line -replace "Location"
                        $line= $line -replace "Report.*#"
                        $line=$line -split ": "
                        try{
                            $report["Reported"]=$line[0]
                            $report["Location"]=$line[1]
                            $report["Report #"]=$line[2]
                        }
                        catch{}
                        $summary=""
                    }
                    if($line -ne ""){
                        $summary+=$line+" "
                    }
                }
                #write-output $output": "$state
            }
            
        }
        finally {
            $reader.Close()
        }
        if($state -eq 3){
            $reportnum=$report["Report #"]
            if($summary -like "*$reportnum*"){ 
                $lowerIndex=$summary.indexof("$reportnum")+$reportnum.length
                $upperIndex=$summary.lastindexOf(".")
                if($upperIndex-$lowerIndex+1 -gt 0){
                    $summary=$summary.substring($lowerIndex, $upperIndex-$lowerIndex+1)
                }
            }
            if($summary -like "*Summary*"){
                        
                $lowerIndex=$summary.lastindexof("Summary")+9
                $upperIndex=$summary.lastindexOf(".")
                if($upperIndex -gt 0){
                    $summary=$summary.substring($lowerIndex)   
                }
            }
            $regEx = [regex]'\w'
            $match=$regEx.Match($summary)
            $summary=$summary.substring($match.index)
            if($summary.length -gt 10){
                if($summary.substring(0,10).equals("University")){
                    $regEx = [regex] '\s{2,}'
                    $match=$regEx.Match($summary)
                    $summary=$summary.substring($match.index)
                    $regEx = [regex]'\w'
                    $match=$regEx.Match($summary)
                    $summary=$summary.substring($match.index)
                }
            }

            $report["Summary"]=$summary
            $report["File"]=$txt
            $count+=1
            [void]$array.add($report.clone()) #<-------adding to the array
             
             #write-output "Added "$report["Report #"]
        }
    }
    cleanup([ref] $array)
    sortReports([ref]$array)
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
            $retval = write-Reports2 -array $array -path "$filepath\data\$dataset" -append
        }
        else{
            $retval = write-Reports2 -array $array -path "$filepath\data\$dataset" 
        }
    }
    if(-not $suppress){
        return $array
    }
    else{
        return $retval
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

function cleanup([ref]$reportList){
    $array = $reportList.Value
    foreach($case in $array){
        if($case."Location" -match " :$"){
            $case."Location" = $case."Location" -replace " :$",""
        }
        if($case."Location" -match "VW"){
            $case."Location" = $case."Location" -replace "VW","WY"
        }
        if($case."Location" -match "PIain"){
             $case."Location" = $case."Location" -replace "PIAIN","PLAIN"
        }
        if($case."Location" -match "\|"){
             $case."Location" = $case."Location" -replace "\|","I"
        }
        if($case."Incident" -match "V\\ﬁ"){
             $case."Location" = $case."Location" -replace "V\\ﬁ","WI"
        }
        if($case."Incident" -match "ﬁ"){
             $case."Location" = $case."Location" -replace "ﬁ","fi"
        }
        if($case."Incident" -match "ofa"){
             $case."Location" = $case."Location" -replace "ofa","of a"
        }
        if($case."Incident" -match "—"){
             $case."Location" = $case."Location" -replace "—","-"
        }
        
        if($case."Summary" -match ":"){
            write-output $case.summary
            $case."Summary"= $case."Summary".substring($case."Summary".lastindexOf(":")+1).trim()
        }
    }

}