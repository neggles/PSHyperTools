<#
.SYNOPSIS
    Create a GPU-P enabled Hyper-V VM, or update the settings of an existing one.
.DESCRIPTION
    Creates or updates a Hyper-V VM to enable GPU-P usage.
.EXAMPLE
    New-GPUPVirtualMachine -VMName GPUVM
.EXAMPLE
    New-GPUPVirtualMachine -VM (Get-VM -Name GPUVM) -Cores 8 -MemoryBytes 16384MB -MinPartitionResources 100000000 -MaxPartitionResources 100000000 -OptimalPartitionResources 100000000
.INPUTS
    None.
.OUTPUTS
    None.
.NOTES
    this is not guaranteed to keep working, as the Partition Resource limits don't seem to be sane or reasonable yet.
.COMPONENT
    PSHyperTools
.ROLE
    GPUP
.FUNCTIONALITY
    Create GPUPVirtualMachine
#>
function New-GPUPVirtualMachine {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = "VMByName",
        PositionalBinding = $true,
        HelpUri = 'https://neg2led.github.io/PSHyperTools/New-GPUPVirtualMachine',
        ConfirmImpact = 'Medium')]
    [Alias('Update-GPUPVirtualMachine')]
    [OutputType([String])]
    Param (
        [Parameter(
            Mandatory = $true,
            ParameterSetName = "VMByName",
            HelpMessage = "Name of virtual machine to create or update.")]
        [Alias('Name')]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMName,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = "VMByObject",
            HelpMessage = "Hyper-V VM Object to update.")]
        [ValidateNotNullOrEmpty()]
        [Microsoft.HyperV.PowerShell.VirtualMachine]
        $VM,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Amount of memory to allocate for this VM. All VM memory will be reserved at startup.")]
        [ValidateNotNullOrEmpty]
        [Alias('Memory', 'RAM')]
        [Int64]
        $MemoryBytes = 8192MB,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Number of vCores to allocate for this VM.")]
        [ValidateNotNullOrEmpty]
        [Alias('CPUs', 'vCores')]
        [Int64]
        $Cores = 4,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Value to set for MinPartitionVRAM, MinPartitionCompute, MinPartitionEncode, MinPartitionDecode")]
        [ValidateNotNullOrEmpty]
        [Int64]
        [Alias('Minimum', 'MinResources')]
        $MinPartitionResources = 80000000,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Value to set for MaxPartitionVRAM, MaxPartitionCompute, MaxPartitionEncode, MaxPartitionDecode")]
        [ValidateNotNullOrEmpty]
        [Int64]
        [Alias('Maximum', 'MaxResources')]
        $MaxPartitionResources = 100000000,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Value to set for OptimalPartitionVRAM, OptimalPartitionCompute, OptimalPartitionEncode, OptimalPartitionDecode")]
        [ValidateNotNullOrEmpty]
        [Alias('Optimal', 'OptimalResources')]
        [Int64]
        $OptimalPartitionResources = 100000000
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'VMByObject' {
                $TargetAction = 'Update'
                # Re-resolve the object for validation
                try {
                    $TargetVM = Get-VM -Name $VM.Name
                    $VMName = $TargetVM.Name
                } catch { throw $PSItem }
                break
            }
            'VMByName' {
                if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
                    # We have been passed the name of a VM that exists, so update it
                    $TargetAction = 'Update'
                    $TargetVM = Get-VM -Name $VMName
                } else {
                    # VM name does not exist, so we'll be creating it
                    $TargetAction = 'Create'
                    $TargetVM = $null
                }
                break
            }
            Default {
                $ExceptionMessage = 'Invalid parameter set name. If you are seeing this, please open an issue on GitHub with your log.'
                throw [System.Management.Automation.ParameterBindingException]::new($ExceptionMessage)
            }
        }

        if ($pscmdlet.ShouldProcess("GPU-P Virtual Machine $VMName", $TargetAction)) {
            if ($TargetAction -eq 'Create') {
                $CreateParams = @{
                    Name               = $VMName
                    MemoryStartupBytes = $MemoryBytes
                    Generation         = 2
                    Version            = (Get-VMHostSupportedVersion | Sort-Object -Property Version -Descending | Select-Object -First 1).Version.ToString()
                }
                try {
                    $TargetVM = New-VM @CreateParams
                } catch { throw $PSItem }
            }
            try {
                # Enable VM features required for this to work
                $SetParams = @{
                    VM                        = $TargetVM
                    GuestControlledCacheTypes = $true
                    LowMemoryMappedIoSpace    = 1GB
                    HighMemoryMappedIoSpace   = 32GB
                    AutomaticStopAction       = 'TurnOff'
                    CheckpointType            = 'Disabled'
                }
                Set-VM @SetParams

                # Set vCore count
                Set-VMProcessor -VM $VM -Count $Cores

                # Disable secure boot
                Set-VMFirmware -VMName $Config.VMName -EnableSecureBoot 'Off'

                # Parameters for vAdapter
                $GPUParams = @{
                    VM                      = $TargetVM
                    MinPartitionVRAM        = $MinPartitionResources
                    MaxPartitionVRAM        = $MaxPartitionResources
                    OptimalPartitionVRAM    = $OptimalPartitionResources
                    MinPartitionEncode      = $MinPartitionResources
                    MaxPartitionEncode      = $MaxPartitionResources
                    OptimalPartitionEncode  = $OptimalPartitionResources
                    MinPartitionDecode      = $MinPartitionResources
                    MaxPartitionDecode      = $MaxPartitionResources
                    OptimalPartitionDecode  = $OptimalPartitionResources
                    MinPartitionCompute     = $MinPartitionResources
                    MaxPartitionCompute     = $MaxPartitionResources
                    OptimalPartitionCompute = $OptimalPartitionResources
                }
                # Add adapter if not present, update if present
                if (-not (Get-VMGpuPartitionAdapter -VMName $Config.VMName)) {
                    Add-VMGpuPartitionAdapter @GPUParams
                } else {
                    Set-VMGpuPartitionAdapter @GPUParams
                }
            } catch { throw $PSItem }
        }
    }
}

