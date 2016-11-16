[string] $filepath=$MyInvocation.MyCommand.Path
$filepath=$filepath.substring(0,$filepath.lastIndexOf("\"))

. $filepath\PDFConverter.ps1

$option=1
if($links){
    $links.clear()
}
[System.Collections.ArrayList] $links = new-object System.Collections.ArrayList

if($option -eq 1){
    $site = Invoke-WebRequest http://dps.usc.edu/alerts/log/ -sessionvariable sesh 
    $links = $site.Content | grep "http://dps.usc.edu/files" | %{$_.split('"')[1]} | grep "http://dps.usc.edu/files"
}
$index=0
if($option -eq 2){
    
    [int[]] $daysinthemonth = 31,29,31,30,31,30,31,31,30,31,30,31
    [int[]] $startdate= 11,1,15
    [int[]] $enddate= 2,1,16
    

    $daycounthelper= Get-Date -Month $startdate[0] -Day $startdate[1] -Year (2000+$startdate[2])
    $daycount=$daycounthelper.DayOfWeek.value__-1 #0=monday, 6=sunday

    while (($startdate[0] -ne $enddate[0]) -or ($startdate[1] -ne $enddate[1])){
        
        if($daycount -ne 5 -and $daycount -ne 6){
            $month=$startdate[0]
            $day=$startdate[1]
            $year=$startdate[2]
            $linkstring="http://dps.usc.edu/files/20{2}/{0}/{0}{1}{2}.pdf" -f $month.tostring("00"), $day.tostring("00"), $year.toString("00")
            
            $index= $links.add($linkstring) 
        }
        $daycount=$daycount+1
        if($daycount -eq 7){
            $daycount=0
        }
        $startdate[1]=$startdate[1]+1
        if($startdate[1] -gt $daysinthemonth[$startdate[0]-1]){
            $startdate[1]=1
            $startdate[0]+=1
            if($startdate[0] -gt 12){
                $startdate[0]=1
                $startdate[2]+=1
            }
        }
    }  
}
foreach ($link in $links){
    $txtname=$link -split "/"
    $txtname=$txtname[$txtname.length-1]
    $txtname=$txtname -replace ".pdf",".txt"
    $month=$txtname.substring(0,2)
    $year=$txtname.substring(4,2)
    if(-Not (Test-Path $filepath\dpsreports\20$year)){
            Write-output "20$year year folder does not exist. Creating folder"
            mkdir $filepath\dpsreports\20$year
        }
    if(-Not (Test-Path $filepath\dpsreports\20$year\$month)){
        Write-output "$month month folder does not exist. Creating folder"
        mkdir $filepath\dpsreports\20$year\$month
    }
    if (-Not (Test-Path $filepath\dpsreports\20$year\$month\$txtname)){
        
        Write-Output "$txtname does not exist"
        Write-Output "Pulling data from $link"
        try{
            $site=Invoke-WebRequest $link
            convertpdf -link $link -path $filepath -verbose
        }
        catch{
            Write-Error "An error has occured"
            Write-Error $_.Exception.Message
        }
        
    }
}
exit