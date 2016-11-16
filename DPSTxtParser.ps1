#Finding your current directory
[string] $filepath=$MyInvocation.MyCommand.Path
$filepath=$filepath.substring(0,$filepath.lastIndexOf("\"))

#This script reads the .txt files from your folder and stores them into an arraylist of dictionaries called reportArray
#There are four options to run this script:
#option=1: read all .txt files
#option=2: read all .txt files in a given year
#option=3: read all .txt files in a given month
#option=4: read a specific .txt file

$option=1

#Generates the dictionary of .txt files based on which option you picked
if($option -eq 1){
    $txtlist= dir -recurse $filepath\dpsreports\*txt
}
elseif($option -eq 2){
    $year = Read-host "Year"
    $txtlist= dir -recurse $filepath\dps$reports\$year\*txt
}
elseif($option -eq 3){
    $year = Read-host "Year"
    $month = Read-host "Month"
    if($month.length -eq 1){
        $month="0"+$month
    }
    $txtlist= dir $filepath\dpsreports\$year\$month\*txt
}
elseif($option -eq 4){
    $txtinput = Read-host "File"
    $month=$txtinput.substring(0,2)
    $year=$txtinput.substring(4,2)
    $txtlist= dir $filepath\dpsreports\20$year\$month\$txtinput
}

#extracting the name of each .txt file from txtlist 
$txtlist= $txtlist.name

#count keeps track of what index we are currently on when adding to our reportArray 
$count=0

#summary is the summary field of each report
$summary=""

#report is the dictionary that we will fill out as we iterate through the file and add to our reportArray
$report=@{"Report #"="";"Incident"="";"Location"="";"Occurred"="";"Reported"="";"Disposition"="";"Summary"=""}

#finally, our reportArray is where we will add all of our reports into
[System.Collections.ArrayList] $reportArray=new-object System.Collections.ArrayList

#errorlist is the arraylist that contains the index of all reports that failed to be parsed correctly
[System.Collections.ArrayList] $errorList=new-object System.Collections.ArrayList


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
    try {
        for() {
            $line = $reader.ReadLine()
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
                    $state=1
                    $line= $line -replace "Reported: "
                    $line= $line -replace "Location"
                    $line= $line -replace "Report.*#"
                    $line=$line -split ": "
                    $report["File"]=$txt
                    if($report.Disposition -ne "Void"){
                        $count=$reportArray.add($report.clone())
                        if($report.Summary -like "*:*" -and ($report.Summary -like "*cc:*" -eq $False)){
                            [void]$errorList.add($count) 
                        }
                        else{
                            foreach ($value in $report.Values){
                                if($value -match "\w" -eq $False){
                                    if($errorList.contains($value) -eq $False){
                                        [void]$errorList.add($count) 
                                    }
                                    break
                                }
                            }
                        }
                        
                    }
                    $report["Reported"]=$line[0]
                    $report["Location"]=$line[1]
                    $report["Report #"]=$line[2]
                    $summary=""
                }
                if($line -ne ""){
                    $summary+=$line+" "
                }
            }
        }
    }
    finally {
        $reader.Close()
    }
}
