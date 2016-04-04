
Function Get-RDCMServer {
    Param(
    $File

    )

    [xml]$Rdp = Get-Content -Path $File 
    $Servers = $rdp.RDCMan.file.group | % { if ($_.properties.name -eq "My lab"){$_.server.properties.name}}

    Return $Servers
}

Function Get-RDCMGroup {

   Param(
    $File,
    $GroupName
    )

    [xml]$Rdp = Gc -Path $File 
    $Group = $rdp.RDCMan.file.group | ? { $_.properties.name -eq $GroupName}

    return $Group

}

Function New-RDCMFile {
    [cmdletBinding()]
    Param(

        $Name,
        $Comment,
        [Switch]$Expanded

    )

[xml]$Structure = @"
<?xml version="1.0" encoding="utf-8"?>
<RDCMan programVersion="2.7" schemaVersion="3">
  <file>
    <credentialsProfiles />
    <properties>
      <name>$Name</name>
      <comment>$Comment</comment>
      <expanded>$Expanded</expanded>
    </properties>
  </file>
  <connected />
  <favorites />
  <recentlyUsed />
</RDCMan>
"@

return $Structure
}

Function New-RDCMGroup {

[cmdletBinding()]
Param(

    [Parameter(MAndatory=$true)]
    [System.Xml.XmlDocument]$MainStructure,

    [Parameter(Mandatory=$true)]
    $Name,
    
    [Parameter(Mandatory=$false)]
    $Comment,

    [Parameter(Mandatory=$false)]
    [switch]$Expanded
)



#Creating Group Element
        $SectionGroup=$MainStructure.CreateElement('group')
        #Creating Properties of group element and adding as child to Group EL
            $Properties = $MainStructure.CreateElement('properties')
            $PropertiesGroup = $SectionGroup.AppendChild($Properties)

    #Creating Name Element
        $ELPROP_Name = $MainStructure.CreateElement('name')
        $ELPROP_Name.innerText = $Name
        $PropertiesGroup.AppendChild($ELPROP_Name) | Out-Null

    #Creating Comment Element
        $ELPROP_Comment = $MainStructure.CreateElement('comment')
        $ELPROP_Comment.InnerText = $Comment
        $PropertiesGroup.AppendChild($ELPROP_Comment) | Out-Null

    #Creating Expanded Element
        $ELPROP_Expanded = $MainStructure.CreateElement('expanded')
        $ELPROP_Expanded.InnerText = $Expanded.ToString()
        $PropertiesGroup.AppendChild($ELPROP_Expanded) | Out-Null

        $MainStructure.RDCMan.file.AppendChild($SectionGroup) | Out-Null
        
return [xml]$MainStructure
}

Function New-RDCMServer {

[cmdletBinding()]
Param(

    [Parameter(MAndatory=$true)]
    [System.Xml.XmlDocument]$MainStructure,

    [Parameter(Mandatory=$true)]
    $Name,

    [Parameter(Mandatory=$false)]
    $DisplayName,
    
    [Parameter(Mandatory=$true)]
    $Group,

    [Parameter(Mandatory=$false)]
    $Comment,

    [Parameter(Mandatory=$false)]
    [switch]$Expanded
)


if (!($DisplayName)){
    $DisplayName = $Name
}

#Creating Group Element
        $SectionGroup=$MainStructure.CreateElement('server')
        #Creating Properties of group element and adding as child to Group EL
            $Properties = $MainStructure.CreateElement('properties')
            $PropertiesGroup = $SectionGroup.AppendChild($Properties)

    #Creating Name Element
        $ELPROP_DisplayName = $MainStructure.CreateElement('displayName')
        $ELPROP_DisplayName.innerText = $DisplayName
        $PropertiesGroup.AppendChild($ELPROP_DisplayName) | Out-Null

    #Creating Name Element
        $ELPROP_Name = $MainStructure.CreateElement('name')
        $ELPROP_Name.innerText = $Name
        $PropertiesGroup.AppendChild($ELPROP_Name) | Out-Null

    #Creating Comment Element
        $ELPROP_Comment = $MainStructure.CreateElement('comment')
        $ELPROP_Comment.InnerText = $Comment
        $PropertiesGroup.AppendChild($ELPROP_Comment) | Out-Null

        if ($Group){
            
            $GroupQuery = $MainStructure.RDCMan.file.group |  ? {$_.properties.name -eq "$group"}

            if ($GroupQuery){
                $GroupQuery.appendChild($SectionGroup) | out-null
            }else{
                write-warning "Group $($Group) not found. Adding to root."
                $MainStructure.RDCMan.file.AppendChild($SectionGroup) | Out-Null
            }
        }
        
        
return [xml]$MainStructure
}