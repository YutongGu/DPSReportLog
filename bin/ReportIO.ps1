function write-Reports{
    [CmdletBinding(DefaultParameterSetName='ByUserName')]
    param(
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [System.Collections.ArrayList]$array,
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [string]$path,
        [switch]$append
    )
    
    [string]$line
    $index=0
    $size=$array.count
    [string]$stringOutput=""
    $stringOutput=""
    if($append){
        if(Test-path $path){
            $reader = [System.IO.File]::OpenText("$path")
            while(-not ($reader.EndOfStream)){
                $line=$reader.readLine()
                if($line -like "*Size:*"){
                    $line=$line.split(':')
                    $size+=$line[1]
                    break
                }
            }
            
            $reader.close()
            $content= Get-Content $path
            $content[0]="Size:$size"
            $content | Set-Content $path
        }
    }

    if(-not ($path -like "*.dps")){
        $path+="\output.dps"
    }

    if($append){
        $index+=$size-$array.count
	}
    else{
        $stringOutput="Size:"+$size+"`n"
    }
	$i=0
	$sw= New-Object System.IO.StreamWriter($path,$append)
	foreach ($case in $array)
	{
        foreach($key in $case.keys){
            if($key -ne "Index"){
                $stringOutput += $key + "|" + $case.$key + "`n"   
            }
            if($key -eq "File"){
				if ($index % 500 -eq 0)
				{
					$sw.write($stringOutput)
					$stringOutput = ""
				}
			}
		}
		$stringOutput += "Index|" + $index + "`n"
		$index += 1
	}
	$sw.write($stringOutput)
	$sw.close()
	<#
    if($index -ne $array.count){
        $content= Get-Content $path
        $content[0]="Size:$index"
        $content | Set-Content $path
    }#>
}
function read-Reports{
    [CmdletBinding(DefaultParameterSetName='ByUserName')]
    param(
        [ValidateNotNull()]
        [System.Collections.ArrayList]$array,
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [string]$path
    )
    $output = 1
    if (-not ($array)){
        $output=1
    }
    $reader = [System.IO.File]::OpenText("$path")
    [string] $key=""
    [string] $value=""
    $report=@{"Index"=""; "Report #"="";"Incident"="";"Location"="";"Occurred"="";"Reported"="";"Disposition"="";"Summary"="";"File"=""}
    $checklist=@{"Index"=0; "Report #"=0;"Incident"=0;"Location"=0;"Occurred"=0;"Reported"=0;"Disposition"=0;"Summary"=0;"File"=0}
    $complete=0
    $output=$false
    if ($array -eq $null){
        $output=
        $array=new-object System.Collections.Arraylist
    }
    else{
        $array.clear()
    }
    try {
        for() {
            
            $line = $reader.ReadLine()
            if ($line -eq $null) { break }
            if($line -ne "" -and $line -like "*|*"){
                $line=$line.split('|')
                $key=$line[0]
                $value=$line[1]
            }
            else{
                continue
            }
            #$key
            $report.$key=$value.trim()
            $checklist.$key=1
            foreach ($item in $checklist.values){
                if ($item -eq 0){
                    $complete=0
                    break
                }
                $complete=1
            }
            if($complete -eq 1){
                [void]$array.add($report.clone())
                $checklist=@{"Index"=0; "Report #"=0;"Incident"=0;"Location"=0;"Occurred"=0;"Reported"=0;"Disposition"=0;"Summary"=0;"File"=0}
            }
        }
        
    }
    finally {
        $reader.Close()
    }
}
<#under construction#>
function write-Reports2{
    [CmdletBinding(DefaultParameterSetName='ByUserName')]
    param(
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [System.Collections.ArrayList]$array,
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [string]$path,
        [switch]$append
    )
    $changemade = $false
    [string]$line
    $index=0
    $size=$array.count
    [string]$stringOutput=""
    $stringOutput=""
    if($append){
        $dataset= new-object System.Collections.ArrayList
        read-reports -array $dataset -path $path
       
    }

    if(-not ($path -like "*.dps")){
        $path+="\output.dps"
    }
    
	$i=0
    if($append){
	    foreach ($case in $array)
	    {
            [int]$i=$dataset.count-1
            $x = $case."Report #"
            if (-not ($x -match "\D"))
		    {	
                if($dataset."Report #" -notcontains $x){
			        [int]$newReportNum = [convert]::ToInt32($x)
			        [int]$lower = 0
			        [int]$upper = $dataset.count - 1
			        $i = ($lower + $upper)/2
			        [int]$currReportNum = 0
			        while ($dataset[$i]."Report #" -match "\D") { $i++ }
                    
			        while ($newReportNum -ne $currReportNum -and $upper -ne $lower)
			        {
                        write-verbose "$i, $lower, $upper"
				        $currReportNum = $dataset[$i]."Report #"
				        if ($newReportNum -eq $currReportNum) { break }
                        while ($dataset[$i]."Report #" -match "\D") { $i++ }
				        if ($newReportNum -gt $currReportNum) { $lower = $i }
				        if ($newReportNum -lt $currReportNum) { $upper = $i }
				        $i = ($lower + $upper)/2
				        if ($i -eq $lower -or $i -eq $upper) { break }
                        
			        }
			        if ($i -eq $lower -or $i -eq $upper)
			        {
				        while ($i -lt $dataset.count -and $dataset[$i] -ne $null -and $newReportNum -gt $dataset[$i]."Report #") { $i++ }
			        }
                }
                else{
                    write-verbose "ignored report # $x"
                    continue
                }
            }
            else{
                continue
            }
            $case."Index" = $i+1
            write-verbose "Inserted $case at $i"
            $changemade= $true
		    [void]$dataset.insert($i, $case.clone())
            $i++
		    for ($i; $i -lt $dataset.count; $i++)
		    {
                if($dataset[$i] -ne $null){
			        $dataset[$i]."Index" = [System.Convert]::ToInt32($dataset[$i]."Index") + 1
                }
		    }
	    }
        if($changemade){
            $sw= New-Object System.IO.StreamWriter($path,$false)
            $size= $dataset.count
            write-verbose "generated dataset of size $size"
            $stringOutput="Size:"+$size+"`n"

            write-verbose "done inserting "
            foreach ($case in $dataset){
                foreach($key in $case.keys){
                    if($key -ne "Index"){
                        $stringOutput += $key + "|" + $case.$key + "`n"   
                    }
                    if($key -eq "File"){
				        if ($index % 500 -eq 0)
				        {
					        $sw.write($stringOutput)
					        $stringOutput = ""
				        }
			        }
		        }
		        $stringOutput += "Index|" + $index + "`n"
		        $index += 1
            }
	        $sw.write($stringOutput)
	        $sw.close()
            return 1
        }
        else{
            write-verbose "No changes made."
            return 0
        }
    }
    else{
        $sw= New-Object System.IO.StreamWriter($path,$false)
        foreach ($case in $array){
            foreach($key in $case.keys){
                if($key -ne "Index"){
                    $stringOutput += $key + "|" + $case.$key + "`n"   
                }
                if($key -eq "File"){
				    if ($index % 500 -eq 0)
				    {
					    $sw.write($stringOutput)
					    $stringOutput = ""
				    }
			    }
		    }
		    $stringOutput += "Index|" + $index + "`n"
		    $index += 1
        }
	    $sw.write($stringOutput)
	    $sw.close()
        return 1
    }

	<#
    if($index -ne $array.count){
        $content= Get-Content $path
        $content[0]="Size:$index"
        $content | Set-Content $path
    }#>
}