#menu
#parameters comp=computer name, numberofitems= length of array
Function Show-Menu($comp, $numberOfItems, $arrayOfApplications){
    Write-Host -fore Cyan "PC Name: $($comp.ToUpper())"
    Write-Host "----------------MENU------------------"
    Write-Host "*       Choose What to Install       *"
    #print out the entire list of titles
    for($i =0; $i -lt $numberOfItems; $i++){
        Write-Host $i $arrayOfApplications[$i]
    }
    #manually add host and printer options to the menu
    $hostNumber = $arrayOfApplications.Count-1
    $printerNumber = $arrayOfApplications.Count
    Write-Host "$hostNumber HOST"
    Write-Host "$printerNumber PRINTER"
    Write-Host "*  (q) TO QUIT                       *"
    Write-Host "--------------------------------------`n"
}

#sleeping function for added effect(sp?)
Function Sleep-For-Bit($seconds){
    Start-Sleep -s $seconds
}

#generic printer script for the time being
Function Add-Printer($comp) {
    #path to the startup folder in the computer
    $pathToStartup = "\\$comp\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\"
    #path to where script is kept on your coputer
    $pathToScript = "C:\Users\big1surg\"

    #copy to destination computer
    Write-Host -fore Green "Adding generic printer script to $comp"
    copy-item -path $pathToScript -Destination $pathToStartup

    #add line to file
    $pathToNewScript = "\\$comp\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\GenericPrinter.vbs"
    $defaultPrinter = Read-Host "Enter full name of default printer"
    #adds empty line to script if non-default printers are selected
    $otherPrinters = (Read-Host "Enter non-default printers separated by comma").Split(",") | ForEach-Object{$_.trim()}
    #content added to end of script, only one default printer
    Add-Content $pathToNewScript "objNet.AddWindowsPrinterConnection ""$defaultPrinter"""
    Add-Content $pathToNewScript "objNet.SetDefaultPrinter ""$defaultPrinter"""
    foreach ($printer in $otherPrinters){
        Write-Host -fore Green "$printer added..."
        Add-Content $pathToNewScript "objNet.AddWindowsPrinterConnection ""$printer"""
    }
    #allow you to check and make sure printer file is correct
    Write-Host "Copy this address to check file \\$comp\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\"

}

#not working, not calling function
Function Get-OOB($comp){
    $department = Read-Host "Enter 3 letter department name"
    Write-Host -fore Green "Installing OOB for $department"
    psexec \\$comp -i -s -d "" -start _$department?start
}

#read the text file with all titles and links
$applications = Get-Content "itweblinks.txt" | Where-Object {$_}
$totalItems =  $applications.count
#half of the lines are titles, other half are links
$arrayOfTitles = 0..($totalItems/2)
$arrayOfLinks = 0..($totalItems/2)

#create two arrays, one with title and the other with the psexec link
$countLines = 0 #number of lines in file
$countTitles = 0 #number of titles
$countLinks = 0 #number of links for said titles
#loop, if even or 0 then it is a title, otherwise it is a link
foreach($line in $applications){
    if($countLines -eq 0 -Or $countLines%2 -eq 0){
        $arrayOfTitles[$countTitles] = $line
        $countTitles = $countTitles+1
    }elseif($countLines -eq 1 -Or $countLines%2 -ne 0){
        $arrayOfLinks[$countLinks] = $line
        $countLinks = $countLinks+1
    }
    $countLines = $countLines+1
}

#***************************************************
#VARIABLE CHANGE THIS TO WHERE YOU KEEP IT, not used at this time
#$pathToHost = "C:\Users\sgarcia033\Desktop\Files\Useful Files\hosts"

#ask for computers
$compArray = (Read-Host "Enter computer name(s) separated by comma").split(",") | ForEach-Object{$_.trim()}
$count = 1 #readability, marks number of printers

#create hostNumber
$hostNum = $arrayOfTitles.Count-1 #manually add host
$printNum = $arrayOfTitles.Count #manually add printer option to switch
$allNum = $arrayOfTitles.Count+1 #unused but meant to select all common options

#loops through all computers
foreach ($compName in $compArray) {
    #logic for switch and for selecting what to add to computer
    do{
        Write-Host "`n"
        Write-Host "$($count) of $($compArray.Count)" #prints x of x
        Show-Menu $compName $countTitles $arrayOfTitles
        #enter options
        $choiceArray = (Read-Host "Make Selection(s) separated by comma").Split(",") | ForEach-Object{$_.trim()}
        #loops through all options
        foreach ($choice in $choiceArray){
                switch($choice){
                    #this will be selected if entry is <= number of items in text file
                    {$choice -lt $hostNum}{
                        #any option in text file
                        Write-Host -for Green "Adding $($arrayOfTitles[$choice])..."
                        #call to psexec
                        psexec \\$compName $arrayOfLinks[$choice]
                        Sleep-For-Bit(5)
                    }$hostNum{
                        #host file
                        Write-Host -fore Green 'Adding Host File...'
                        remove-item \\$compName\c$\Windows\System32\drivers\etc\hosts
                        copy-item -path "C:\Users\big1surg\" -Destination \\$compName\c$\Windows\System32\drivers\etc\ 
                        Sleep-For-Bit(5)
                    }$printNum{
                        #call printer script
                        Write-Host -fore Green 'Adding Printer File...'
                        Sleep-For-Bit(5)
                        Add-Printer($compName)
                        Sleep-For-Bit(5)
                    }$allNum{
                        #add all files
                        Write-Host -fore Green 'Adding All Files...'
                        Sleep-For-Bit(5)
                    }'q'{
                        if ($count -eq $compArray.Count) {
                            Write-Host -fore Green 'Exiting Program'
                        }else{
                            return
                            break
                        }
                    }default{
                        Write-Host -fore Red 'That is not an option.'
                        Sleep-For-Bit(5)
                    }
                } #end switch
        } #end foreach
    } until($choice -eq 'q')
    Clear-Host
    $count = $count + 1 #increments x of x
}#end foreach

