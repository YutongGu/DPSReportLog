 #Function for downloading a .pdf from a DPS link and converting it into a .txt file for storage
#Parameters: 
#link- link to DPS .pdf file
#path- path for storing the final .txt file
Function convertpdf{
    [CmdletBinding(DefaultParameterSetName='ByUserName')]
    param(
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [string]$link,
        [Alias("projectpath")]
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [string]$path,
        [switch]$quiet
    )
    $output=new-object System.Collections.ArrayList
    #extracting file name from link and changing its extention to .txt
    $txtname=$link -split "/"
    $txtname=$txtname[$txtname.length-1]
    Write-Verbose "Extracted file name $txtname"
    $txtname=$txtname -replace ".pdf",".txt"
    Write-Verbose "File name converted to $txtname"

    #Call upon a website to convert the .pdf for us by passing it our link to convert and retreiving the link to the .txt
    $site= Invoke-WebRequest http://document.online-convert.com/convert-to-txt -SessionVariable sesh
    write-verbose "getting form" 
    $Form=$site.Forms[1]
    write-verbose "got form"
    $Form.Fields["external_url"]=$link
    try{
        #posting to the website our filled out form containing the link and retreiving it's response
        $site= Invoke-WebRequest $form.Action -WebSession $sesh -Body $Form -Method Post
    }
    catch{
        Write-Error "Error has occured at Invoke-WebRequest Post Method: $_"
        return
    }

    #the link for our .txt file is located at this index and key in the site that we requested
    $downloadlink= $site.links[25].href 
    Write-Verbose "Attempting to pull .txt from $downloadlink"
    $WebClient = New-Object System.Net.WebClient
    $month=$txtname.substring(0,2)
    $year=$txtname.substring(4,2)

    #implementing a loop to try to repeatedly query for the .txt until success (conversion takes a while with this site)
    $success=1
    while($success -eq 1){
        try{
            Start-sleep -Seconds 5   
            $WebClient.DownloadFile("$downloadlink","$path\dpsreports\20$year\$month\$txtname")
        }
        catch{
            Write-Verbose "No server response from server."
            Write-Verbose "Trying again."
            continue
        }
       
        Write-Verbose "Successfully created $txtname"
        $success=0
    }
    if(-not $quiet){
        return "$path\dpsreports\20$year\$month\$txtname"
    }
    
}