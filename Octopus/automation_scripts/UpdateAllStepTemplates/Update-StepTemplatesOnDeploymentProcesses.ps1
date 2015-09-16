<#
.Synopsis
   Updates the Step Templates used on Deployment Processes to the latest versions
.DESCRIPTION
   Step templates can be updated from the library on Octopus, but that doesnt mean that the Deployment processes using that template will start using the latest version right away. Normally, the user would have to update the step template on each deployment process manually. This script takes care of that.
.EXAMPLE
   Update-StepTemplatesOnDeploymentProcesses -ActionTemplateID "ActionTemplates-3" -OctopusURI "http://localhost" -APIKey "API-RLMWLZBPMX5DRPLCRNZETFS4HA"
.EXAMPLE
   Update-StepTemplatesOnDeploymentProcesses -AllActionTemplates -OctopusURI "http://Octopusdeploy.MyCompany.com" -APIKey "API-TSET42BPMX5DRPLCRNZETFS4HA"
.LINK
   Github project: https://github.com/Dalmirog/OctopusSnippets
#>
Function Update-StepTemplatesOnDeploymentProcesses
{
    [CmdletBinding()]        
    Param
    (
        # Action Template ID. Use when you only want to update the deployment processes that only use this Action Template.
        [Parameter(Mandatory=$true,ParameterSetName= "SingleActionTemplate")]
        [string]$ActionTemplateID,

        # If used, all the action templates will be updated on all the deployment processes.
        [Parameter(Mandatory=$true, ParameterSetName= "AllActionTemplates")]
        [switch]$AllActionTemplates,

        # Octopus instance URL
        [Parameter(Mandatory=$true)]
        [string]$OctopusURI,

        # Octopus API Key. How to create an API Key = http://docs.octopusdeploy.com/display/OD/How+to+create+an+API+key
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        # Tentacle Installation Directory
        [Parameter(Mandatory=$false)]
        $TentacleInstallDir = "C:\Program Files\Octopus Deploy\Tentacle" #Default Tentacle install dir
    )

    Begin
    {
        #Loading Octopus.client assemblies. If octopus was installed on another drive, you will have the adjust these paths
        #If the script gets popular enough, i'll go the extra mile and read the registry to resolve this path
        
        if(!(Test-Path "$TentacleInstallDir\octopus.client.dll")){

            Write-Warning "Octopus Tentacle doesnt seem to be insalled on '$TentacleInstallDir'. Please use the parameter -TentacleInstallDir to specify the path where the Octopus Tentacle was installed. `nTIP - This path should be the parent directory of:`n`t-Newtonsoft.Json.dll`n`t-Octopus.Client.dll`n`t-Octopus.Platform.dll"             
            break 
        }
        Add-Type -Path (join-path $TentacleInstallDir "Newtonsoft.Json.dll")
        Add-Type -Path (join-path $TentacleInstallDir  "Octopus.Client.dll")
        Add-Type -Path (join-path $TentacleInstallDir  "Octopus.Platform.dll")

        #Connection Data
        $headers = @{"X-Octopus-ApiKey"="$($apikey)";}

        #Create endpoint connection
        $endpoint = new-object Octopus.Client.OctopusServerEndpoint "$($OctopusURI)","$($apikey)"
        $repository = new-object Octopus.Client.OctopusRepository $endpoint


    }
    Process
    {
        If($PSCmdlet.ParameterSetName -eq "SingleActionTemplate"){
            $templates = Invoke-WebRequest -Uri "$($OctopusURI)/api/actiontemplates/$ActionTemplateID" -Method Get -Headers $headers | select -ExpandProperty content| ConvertFrom-Json
        }
        
        Else{$templates = Invoke-WebRequest -Uri "$($OctopusURI)/api/actiontemplates/All" -Method Get -Headers $headers | select -ExpandProperty content| ConvertFrom-Json}
        
        Foreach ($template in $templates){

            $usage = Invoke-WebRequest -Uri "$($OctopusURI)/api/actiontemplates/$($template.ID)/usage" -Method Get -Headers $headers | select -ExpandProperty content | ConvertFrom-Json
        
            #Getting all the DeploymentProcesses that need to be updated
            $deploymentprocesstoupdate = $usage | ? {$_.version -ne $template.Version}

            write-host "Template: $($template.name)" -ForegroundColor Magenta

            If($deploymentprocesstoupdate -eq $null){

                Write-host "`t--All deployment processes up to date" -ForegroundColor Green

            }

            Else{

                Foreach($d in $deploymentprocesstoupdate){

                    Write-host "`t--Updating project: $($d.projectname)" -ForegroundColor Yellow
                                   
                    #Getting DeploymentProcess obj
                    $process = $repository.DeploymentProcesses.Get($d.DeploymentProcessId)

                    #Finding the step that uses the step template
                    $step = $process.Steps | ?{$_.actions.properties.values -eq $template.Id}

                    try{

                        foreach($prop in $step.Actions.properties.keys){

                            $step.Actions.properties.$prop = $template.Properties.$prop
                
                            #Updating the Template.Version property to the latest
                            $step.Actions.properties.'Octopus.Action.Template.version' = $template.Version

                            If($repository.DeploymentProcesses.Modify($process))
                            {
                                Write-host "`t--Project updated: $($d.projectname)" -ForegroundColor Green
                            }

                        }
                    }

                    catch [System.InvalidOperationException]{
                        #Catching and error caused by modifying the same collection evaluated on the foreach
                        #Feel free to add a comment proposing a cleaner fix            
                    }

                    catch{
                        Write-Error "Error updating Process template for Octopus project: $($d.projectname)"
                        write-error $_.Exception.message
            
                    }#>        
        
                }
           
            }
        }########
        
    }
    End
    {
    }
}

