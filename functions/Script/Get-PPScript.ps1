<#
$Metadata = @{
	Title = "Get PowerShell PowerUp Script"
	Filename = "Get-PPScript.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-09"
	LastEditDate = "2014-01-09"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-PPScript{

<#
.SYNOPSIS
    Get PowerShell PowerUp scripts from the script folder.

.DESCRIPTION
	Get PowerShell PowerUp scripts from the script folder. Based on these information it's possible to create a script shortcut.
    Only scripts that have an unique name inside the script folder can be used.

.PARAMETER Name
	Name of the scripts or name of the script shortcut or shortcut key.

.PARAMETER Shortcut
	Return only script shortcuts.

.PARAMETER All
	Get all available scripts.
    
.EXAMPLE
	PS C:\> Get-PPScript -Name "Run-ThisScript*" -Shortcut
#>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$false)]
		[String]
		$Name,       
        
        [Switch]
		$Shortcut
	)
  
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
	    
    # get script shortcut data file content
    $ScriptShortcuts = Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.ScriptShortcut.DataFile -Recurse | %{[xml](Get-Content $_.Fullname)} | %{$_.Content.ScriptShortcut}
    
    if(-not $Name -and $Shortcut){
    
        $ScriptShortcuts
    
    }elseif($Name -and $Shortcut){
    
        $ScriptShortcuts | where{
            $_.Key -eq $Name -or
            $_.Name -eq $Name -or
            $_.Filename -eq $Name          
        }
    
    }else{
    
        Get-Childitem -Path $PSscripts.Path -Filter * -Recurse | where{(-not $_.PSIsContainer) -and ($PSscripts.Extensions -contains $_.Extension)} | Group-Object Name | where{$_.count -eq 1} | %{
        
            if(-not $Name){
            
                $_.Group
            
            }elseif($Name){
            
                $_ | where{$_.Name -like $Name} | %{$_.Group}
            }    
        }
    }
}