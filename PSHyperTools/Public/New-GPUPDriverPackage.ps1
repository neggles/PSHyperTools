<#
.SYNOPSIS
    Create a GPU-P Guest driver package.
.DESCRIPTION
    Gathers the necessary files for a GPU-P enabled Windows guest to run.
.EXAMPLE
    New-GPUPDriverPackage -DestinationPath '.'
.EXAMPLE
    New-GPUPDriverPackage -Filter 'nvidia' -DestinationPath '.'
.INPUTS
    None.
.OUTPUTS
    A driver package .zip
.NOTES
    This has some mildly dodgy use of CIM cmdlets...
.COMPONENT
    PSHyperTools
.ROLE
    GPUP
.FUNCTIONALITY
    Creates a guest driver package.
#>
function New-GPUPDriverPackage {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        PositionalBinding = $true,
        HelpUri = 'http://www.microsoft.com/',
        ConfirmImpact = 'Low')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Path to output directory.
        # If no file name is specified the filename will be GPUPDriverPackage-YYYYMMMDD.zip
        [Parameter(Mandatory = $false,
            HelpMessage = "Path to one or more locations.")]
        [Alias("PSPath", "Path")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DestinationPath,

        # Device friendly name filter.
        # Only devices whose friendly names contain the supplied string will be processed
        [Parameter(Mandatory = $false,
            HelpMessage = "Only add drivers for devices whose friendly names contain the supplied string.")]
        [ValidateNotNullOrEmpty]
        [String]
        $Filter
    )

    process {
        try {
            # make me a temporary folder, and assemble the structure
            $fTempFolder = Join-Path -Path $Env:TEMP -ChildPath "GPUPDriverPackage"
            (New-Item -ItemType Directory -Path "$fTempFolder/System32/HostDriverStore/FileRepository" -Force -ErrorAction SilentlyContinue | Out-Null)
            (New-Item -ItemType Directory -Path "$fTempFolder/SysWOW64" -Force -ErrorAction SilentlyContinue | Out-Null)

            # Do some processing on the DestinationPath
            $ArchiveName = ('GPUPDriverPackage-{0}.zip' -f $(Get-Date -UFormat '+%Y%b%d'))
            switch ($DestinationPath) {
                # if path is a folder that exists, use the default name and just put it there
                { Test-Path -Path $_ -PathType Container -ErrorAction SilentlyContinue } {
                    $ArchiveFolder = $DestinationPath
                    break
                }
                # if path is a folder that does NOT exist, create it and put archive in it
                { Test-Path -Path $_ -PathType Container -IsValid -ErrorAction SilentlyContinue } {
                    $ArchiveFolder = $DestinationPath
                    (New-Item -ItemType Directory -Path $ArchiveFolder -Force -ErrorAction SilentlyContinue | Out-Null)
                    break
                }
                # if path is a valid path with a file name ending in .zip, use that
                { Test-Path -Path $_ -PathType Leaf -IsValid -ErrorAction SilentlyContinue } {
                    $ArchiveFolder = Split-Path -Path $DestinationPath -Parent
                    $ArchiveName = Split-Path -Path $DestinationPath -Leaf
                    break
                }
                # if param not supplied, use current directory and default name
                Default { $ArchiveFolder = (Get-Location).Path }
            }

            # just double check that one
            if (-not $ArchiveFolder) { $ArchiveFolder = (Get-Location).Path }

            Write-Output -InputObject ('Creating GPU-P driver package for host {0}' -f $Env:COMPUTERNAME)
            Write-Output -InputObject ('Destination path: {0}' -f (Join-Path -Path $ArchiveFolder -ChildPath $ArchiveName))

            <#
                Determine which cmdlet we should use to gather the list of GPU-P capable GPUs.
                On Windows builds before Server 2022/21H2, the cmdlet is 'Get-VMPartitionableGpu'
                On later builds, it's 'Get-VMHostPartitionableGpu', and the old cmdlet just prints an error.
                So, we check if Get-VMHostPartitionableGpu is a valid cmdlet to determine whether we should use it.
            #>
            Write-Output -InputObject "Getting all GPU-P capable GPUs in the current system..."
            if (Get-Command -Name 'Get-VMHostPartitionableGpu' -ErrorAction SilentlyContinue) {
                Write-Verbose -Message 'Using new Get-VMHostPartitionableGpu cmdlet'
                $PVCapableGPUs = Get-VMHostPartitionableGpu
            } else {
                Write-Verbose -Message 'Using old Get-VMPartitionableGpu cmdlet'
                $PVCapableGPUs = Get-VMPartitionableGpu
            }

            # if we found no GPU-P capable GPUs, throw an exception
            if ($PVCapableGPUs.Count -lt 1) {
                throw [System.Management.Automation.ItemNotFoundException]::new('Did not find any GPU-P capable GPUs in this system.')
            } elseif ($PvGPUs.Count -gt 1) {
                Write-Warning -Message (
                    ("You have {0} GPU-P capable GPUs in this system. `n" -f $PvGPUs.Count) +
                    "         At present, there is no way to control which one is assigned to a given VM.`n" +
                    "         Unless one of the available GPUs is an intel IGP, it is highly recommended`n" +
                    "         that you disable the GPU(s) you do not wish to use.`n")
                $choices = '&Yes', '&No'
                $question = 'Do you wish to proceed without disabling the extra GPU(s)?'
                if ($Host.UI.PromptForChoice('', $question, $choices, 1) -eq 1) {
                    throw [System.Management.Automation.ActionPreferenceStopException]::new('User requested to cancel.')
                }
            }


            # Map each PVCapableGPU to the corresponding PnPDevice. Regex (mostly) extracts the InstanceId from the VMPartitionableGpu 'name' property.
            Write-Output -InputObject ('Mapping GPU-P capable GPUs to their corresponding PnPDevice objects...')
            $InstanceExpr = [regex]::New('^\\\\\?\\(.+)#.*$')
            $TargetGPUs = $PVCapableGPUs.Name | ForEach-Object -Process {
                # I'm not proud of this dirty regex trick, but it works.
                Get-PnpDevice -InstanceId $InstanceExpr.Replace($_, '$1').Replace('#', '\')
            }

            # OK, now that we have some actual device names, we can filter them if we've been asked to
            if ($null -ne $Filter) {
                Write-Output -InputObject ('Applying filter "{0}" to device list...' -f $Filter)
                $TargetGPUs = $TargetGPUs | Where-Object { $_.FriendlyName -like ('*{0}*' -f $Filter) }
            }
            Write-Output -InputObject ('Will create driver package for {0} GPUs:' -f $TargetGPUs.Count)
            $TargetGPUs.FriendlyName | ForEach-Object { Write-Output -InputObject ('  - {0}' -f $_) }
        } catch { throw $PSItem }

        # Last chance to turn back, traveler. Are you sure?
        if ($pscmdlet.ShouldProcess("Driver Package", "Create")) {
            try {
                Write-Output -InputObject ('The next few steps may take some time, depending on how many devices & driver packages are installed.')
                Write-Output -InputObject ('If the script appears hung, please give it a few minutes to complete before terminating.')
                # Get display class devices
                Write-Output -InputObject ('Gathering display device CIM objects...')
                $PnPEntities = Get-CimInstance -ClassName 'Win32_PnPEntity' | Where-Object { $_.Class -like 'Display' }
                # Get display class drivers
                Write-Output -InputObject ('Gathering display driver CIM objects...')
                $PnPSignedDrivers = Get-CimInstance -ClassName 'Win32_PnPSignedDriver' -Filter "DeviceClass = 'DISPLAY'"
                # next we have to get every PnPSignedDriverCIMDataFile, because Get-CimAssociatedInstance doesn't wanna play ball
                Write-Output -InputObject ('Gathering all driver file CIM objects... (this is the slow one. Blame Microsoft.)') # or me not understanding CIM i guess?
                $SignedDriverFiles = Get-CimInstance -ClassName 'Win32_PNPSignedDriverCIMDataFile' # -Verbose
                Write-Output -InputObject ('CIM objects gathered.')

                foreach ($GPU in $TargetGPUs) {
                    Write-Output -InputObject ('Getting driver package for {0}' -f $GPU.FriendlyName)
                    $PnPEntity = $PnPEntities | Where-Object { $_.InstanceId -eq $GPU.InstanceId }[0]
                    $PnPSignedDriver = $PnPSignedDrivers | Where-Object { $_.DeviceId -eq $GPU.InstanceId }
                    $SystemDriver = Get-CimAssociatedInstance -InputObject $PnPEntity -Association Win32_SystemDriverPNPEntity
                    $DriverStoreFolder = Split-Path -Path $SystemDriver.PathName -Parent
                    Write-Output -InputObject ('Found package {0}, copying DriverStore folder {1} to temporary directory' -f $PnPSignedDriver.InfName, (Split-Path $DriverStoreFolder -Leaf))
                    Copy-Item -Path $DriverStoreFolder -Destination "$fTempFolder/System32/HostDriverStore/FileRepository/" -Recurse -Force

                    # Get driver files from system32 etc and copy
                    Write-Output -InputObject ('DriverStore folder copied, gathering files from System32 and SysWOW64')
                    $DriverFiles = $SignedDriverFiles | Where-Object { $_.Antecedent.DeviceID -like $GPU.DeviceID }.Dependent.Name
                    $System32Files = $DriverFiles | Where-Object { (Split-Path -Path $_ -Parent) -like "$Env:SYSTEMROOT\System32" }
                    $SysWOW64Files = $DriverFiles | Where-Object { (Split-Path -Path $_ -Parent) -like "$Env:SYSTEMROOT\SysWOW64" }

                    Write-Output -InputObject ('Found {0} files:' -f ($System32Files.Count + $SysWOW64Files.Count))
                    $System32Files | ForEach-Object { Write-Output -InputObject ('  - System32\{0}' -f (Split-Path -Path $_ -Leaf)) }
                    $SysWOW64Files | ForEach-Object { Write-Output -InputObject ('  - SysWOW64\{0}' -f (Split-Path -Path $_ -Leaf)) }

                    Write-Output -InputObject ('Copying to temporary directory...')
                    Copy-Item -Path $System32Files -Destination "$fTempFolder/System32/"
                    Copy-Item -Path $SysWOW64Files -Destination "$fTempFolder/SysWOW64/"

                    Write-Output -InputObject ('Finished gathering files for {0}' -f $GPU.FriendlyName)
                }
                Write-Output -InputObject ('All driver files have been collected, creating archive file')
                $Location = (Get-Location).Path
                Set-Location -Path (Split-Path -Path $fTempFolder -Parent)
                Compress-Archive -Path $fTempFolder -DestinationPath (Join-Path -Path $ArchiveFolder -ChildPath $ArchiveName) -CompressionLevel Fastest -Confirm:$false
                Set-Location -Path $Location
                Write-Output -InputObject ('GPU driver package has been created at path {0}\{1}' -f $ArchiveFolder, $ArchiveName)
            } catch {
                throw $PSItem
            } finally {
                Write-Output -InputObject ('Cleaning up temporary directory {0}' -f $fTempFolder)
                Remove-Item -Recurse -Force -Path $fTempFolder
            }
        }
        Write-Output -InputObject ('Driver package generation complete.')
        Write-Output -InputObject ('Please copy it to your guest and extract the archive into C:\Windows\')
    }
}
