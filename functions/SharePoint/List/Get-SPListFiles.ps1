<#
$Metadata = @{
	Title = "Get SharePoint List Files"
	Filename = "Get-SPListFiles.ps1"
	Description = ""
	Tags = "sharepoint, powershell, list, files"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-11"
	LastEditDate = "2013-10-11"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPListFiles{

<#
.SYNOPSIS
    Report SharePoint files.

.DESCRIPTION
	Report all SharePoint files and their metadata.

.EXAMPLE
	PS C:\> Get-SPListFiles | Out-GridView

.EXAMPLE
	PS C:\> Get-SPListFiles | Export-Csv "Report.csv" -Delimiter ";" -Encoding "UTF8" -NoTypeInformation
#>

	param(
	)

    $SPWebs = Get-SPWebs
    $SPWebs | %{

        $SPWeb = $_   
        
        $SPSite = $_.site.url
            
        Get-SPLists -Url $_.Url -OnlyDocumentLibraries | %{
        
            $SPList = $_
            
            $SPListUrl = (Get-SPUrl $SPList).url
            
            Write-Progress -Activity "Crawl list on website" -status "$($SPWeb.Title): $($SPList.Title)" -percentComplete ([Int32](([Array]::IndexOf($SPWebs, $SPWeb)/($SPWebs.count))*100))
                            
            Get-SPListItems $_.ParentWeb.Url -FilterListName $_.title | %{
                
                $ItemUrl = (Get-SPUrl $_).Url
                
                # files
                New-Object PSObject -Property @{
                    ParentWebsite = $SPWeb.ParentWeb.title
                    ParentWebsiteUrl = $SPWeb.ParentWeb.Url
                    Website = $SPWeb.title
                    WebsiteUrl = $SPWeb.Url
                    List = $SPList.title
                    ListUrl = $SPListUrl
                    FileExtension = [System.IO.Path]::GetExtension($_.Url)
                    IsCheckedOut = $false
                    IsASubversion = $false                
                    Item = $_.Name                
                    ItemUrl = $ItemUrl
                    Folder = $ItemUrl -replace "[^/]+$",""      
                    FileSize = $_.file.Length / 1000000    
                }
                
                $SPItem = $_
                
                # file subversions            
                $_.file.versions | %{
                
                    $ItemUrl = (Get-SPUrl $SPItem).Url  
                
                    New-Object PSObject -Property @{
                        ParentWebsite = $SPWeb.ParentWeb.title
                        ParentWebsiteUrl = $SPWeb.ParentWeb.Url
                        Website = $SPWeb.title
                        WebsiteUrl = $SPWeb.Url                    
                        List = $SPList.title
                        ListUrl = $SPListUrl
                        FileExtension = [System.IO.Path]::GetExtension($_.Url)
                        IsCheckedOut = $false
                        IsASubversion = $true                                 
                        Item = $SPItem.Name                    
                        ItemUrl = $ItemUrl 
                        Folder = $ItemUrl -replace "[^/]+$",""                               
                        FileSize = $_.Size / 1000000
                    }
                }            
            }
            
            # checked out files
            Get-SPListItems $_.ParentWeb.Url -FilterListName $_.title -OnlyCheckedOutFiles | %{
            
                $ItemUrl = $SPSite + "/" + $_.Url 
            
                New-Object PSObject -Property @{
                    ParentWebsite = $SPWeb.ParentWeb.title
                    ParentWebsiteUrl = $SPWeb.ParentWeb.Url
                    Website = $SPWeb.title
                    WebsiteUrl = $SPWeb.Url
                    List = $SPList.title
                    ListUrl = $SPListUrl
                    FileExtension = [System.IO.Path]::GetExtension($_.Url)
                    IsCheckedOut = $true
                    IsASubversion = $false                              
                    Item = $_.LeafName                
                    ItemUrl = $ItemUrl  
                    Folder = $ItemUrl -replace "[^/]+$",""          
                    FileSize = $_.Length / 1000000
                } 
            
            }   
        }
    }
}