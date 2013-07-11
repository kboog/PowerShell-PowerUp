<#
$Metadata = @{
    Title = "Report SharePoint Securable Object Permissions"
	Filename = "Report-SPSecurableObjectPermissions.ps1"
	Description = ""
	Tags = ""powershell, sharepoint, function, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-11"
	LastEditDate = "2013-07-11"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Report-SPSecurableObjectPermissions{

<#

.SYNOPSIS
    Report permissions on SharePoint securable objects.

.DESCRIPTION
	Report permissions on SharePoint securable objects.

.EXAMPLE
	PS C:\> Report-SPSecurableObjectPermissions

#>

    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    if ((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null) {
        Add-PSSnapin “Microsoft.SharePoint.PowerShell”
    }

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    $SPSecurableObjectPermissionReport = @()
    
    # Get all Webapplictons
    $SPWebApp = Get-SPWebApplication
    
    # Get all sites
    $SPSites = $SPWebApp | Get-SPsite -Limit all 

    foreach($SPSite in $SPSites){

        # Get all websites
        $SPWebs = $SPSite | Get-SPWeb -Limit all

        #Loop through each subsite and write permissions
        foreach ($SPWeb in $SPWebs){

            Write-Progress -Activity "Read permissions" -status $SPWeb -percentComplete ([int]([array]::IndexOf($SPWebs, $SPWeb)/$SPWebs.Count*100))
                
            if (($SPWeb.permissions -ne $null) -and  ($SPWeb.HasUniqueRoleAssignments)){  
                    
                foreach ($RoleAssignment in $SPWeb.RoleAssignments){
                
                    # get member
                    $Member =  $RoleAssignment.Member.UserLogin -replace ".*\\",""
                    if($Member -eq ""){
    					 $Member =  $RoleAssignment.Member.LoginName
    				}
                    
                    # get permission definition
                    $Permission = $RoleAssignment.roledefinitionbindings[0].Name

                    # add to report
                    $SPSecurableObjectPermissionReport += New-ObjectSPReportItem -Name $SPWeb -Url $SPWeb.url -Member $Member -Permission $Permission -Type "Website"
                }        
            }
            
            foreach ($SPlist in $SPWeb.lists){
                
                if (($SPlist.permissions -ne $null) -and ($SPlist.HasUniqueRoleAssignments)){  
                      
                    foreach ($RoleAssignment in $SPlist.RoleAssignments){
                    
                        # set list url
                        $SPListUrl = $SPWeb.url + "/" + $SPlist.Title 
                        
                        # get member
                        $Member =  $RoleAssignment.Member.UserLogin -replace ".*?\\",""
                        if($Member -eq ""){
                            $Member =  $RoleAssignment.Member.LoginName
                        }
                        
                        # get permission definition
                        $Permission = $RoleAssignment.roledefinitionbindings[0].Name
                        
                        # add to report
                        $SPSecurableObjectPermissionReport += New-ObjectSPReportItem -Name $SPlist.Title -Url $SPListUrl -Member $Member -Permission $Permission -Type "List"
                    }
                }
            }
        }
    }

    return $SPSecurableObjectPermissionReport

}