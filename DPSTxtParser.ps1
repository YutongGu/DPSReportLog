[string] $filepath=$MyInvocation.MyCommand.Path
$filepath=$filepath.substring(0,$filepath.lastIndexOf("\"))

$option=3
if($option -eq 1){
    $txtlist= dir -recurse $filepath\dpstxt\*txt
}
elseif($option -eq 2){
    $year = Read-host "Year"
    $txtlist= dir -recurse $filepath\reports\$year\*txt
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
$txtlist= $txtlist.name
$count=0
$summary=""
$report=@{"Report #"="";"Incident"="";"Location"="";"Occurred"="";"Reported"="";"Disposition"="";"Summary"=""}
[System.Collections.ArrayList] $reportArray=new-object System.Collections.ArrayList
[System.Collections.ArrayList] $errorList=new-object System.Collections.ArrayList
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
                #$summary=""
                #$line
                if($line -like "*Incident:*" -and $line.length -gt 10){
                    #write-output "true1"
                    $line= $line -replace ".*Incident: "
                    $report["Incident"]=$line
                    $state=3
                }
                elseif($line -ne "" -and ($line -split " " -split "-" -split "&" | %{$_ -cmatch “^[A-Z]*$”} | select-object -index 0)){
                    #write-output "true2"
                    $line= $line -replace ".*Incident: "
                    $report["Incident"]=$line
                    $state=3
                }
            }
            elseif($state -eq 3){
                if($line -like "*#*"){
                    #$count+=1
                    
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
                    #$count
                    #$report
                    #Write-output " "
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
