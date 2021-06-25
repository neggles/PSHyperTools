<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function New-WindowsVHD {
    [CmdletBinding(
        DefaultParameterSetName = 'Parameter Set 1',
        PositionalBinding = $false,
        HelpUri = 'https://neg2led.github.io/HVStuff/New-WindowsVhdx',
        ConfirmImpact = 'Medium')]
    [Alias('New-WindowsVHDX')]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = "Path to source ISO image.")]
        [Alias("ISOPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ImagePath,

        [Parameter(Mandatory = $false,
            Position = 1,
            HelpMessage = "Windows image index (defaults to 1)")]
        [Alias("Index")]
        [ValidateNotNullOrEmpty()]
        [UInt32]
        $ImageIndex = 1,


        [Parameter(Mandatory = $true,
            Position = 2,
            HelpMessage = "Destination path for the VHDX image.")]
        [Alias("OutPath", "VHDPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Destination,

        [Parameter(Mandatory = $false,
            Position = 3,
            HelpMessage = "Size (in bytes) of the VHDX to create")]
        [Alias("Size")]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(32GB, 2TB)]
        [UInt64]
        $SizeBytes = 127GB,

        [Parameter(Mandatory = $false,
            Position = 4,
            HelpMessage = "VHD type to create, dynamic (default) or fixed")]
        [ValidateSet('Dynamic', 'Fixed')]
        [string]
        $VHDType = 'Dynamic',

        [Parameter(Mandatory = $false,
            Position = 5,
            HelpMessage = "Path to unattend.xml to apply (if desired) with DISM offline deploy.")]
        [Alias("Unattend", "AutoUnattend")]
        [ValidateNotNullOrEmpty()]
        [string]
        $UnattendPath,

        [Parameter(Mandatory = $false,
            Position = 6,
            HelpMessage = "boolean to enable or disable RD by default")]
        [boolean]
        $RemoteDesktopEnable = $true
    )

    begin {
        # check if we're being run copy-pasted or as a cmdlet
        $ExecContext = if ($PSCmdlet) { $PSCmdlet } else { $ExecutionContext }
        # assemble some variables, test some paths

        $ImagePath = $ExecContext.SessionState.Path.GetResolvedProviderPathFromPSPath($ImagePath)
        # make sure ImagePath exists
        try { Test-Path -LiteralPath $ImagePath -PathType Leaf } catch { throw $PSItem }

        # if UnattendPath isn't null, make sure it exists
        if ($UnattendPath) {
            $UnattendPath = $ExecContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($UnattendPath)
            Test-Path -LiteralPath $UnattendPath -PathType Leaf
        }

        # check if destination ends with .vhdx, if it doesn't then assume it's a folder
        $Destination = $ExecContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
        if ($Destination.EndsWith('.vhdx')) {
            $DestDir = Split-Path -Path $Destination
            $VHDName = Split-Path -Path $Destination -Leaf
        } else {
            $DestDir = $Destination
            $VHDName = $null # we will set this later once the ISO image is mounted
        }
    }

    process {
        #make sure destination dir exists
        (New-Item -ItemType Directory -Path $DestDir -ErrorAction SilentlyContinue -Force) | Out-Null
        try {
            # mount the ISO
            $MountedImage = Mount-DiskImage -ImagePath $ISOPath -PassThru
            $ISODrive = (($MountedImage | Get-Volume).DriveLetter + ':')
            $SourcePath = (Join-Path -Path $ISODrive -ChildPath "sources\install.wim")
            # make sure wim is there
            Test-Path -Path $SourcePath -PathType Leaf

            # generate vhd name if not provided
            if ($null -eq $VHDName) {
                $WindowsImage = Get-WindowsImage -ImagePath $SourcePath -Index $ImageIndex
                $VHDName = ('{0}-{1}.vhdx' -f $WindowsImage.ImageName.Replace(' ', '-'), (Get-Date -UFormat '%d%b%Y'))
            }

            # set VHD path
            $VHDPath = Join-Path -Path $DestDir -ChildPath $VHDName

            # build parameters
            $Params = @{
                SourcePath = $SourcePath
                VHDPath = $VHDPath
                Edition = $ImageIndex
                SizeBytes = $SizeBytes
                VHDType = $VHDType
                VhdFormat           = 'VHDX'
                BcdInVhd            = 'VirtualMachine'
                DiskLayout          = 'UEFI'
                RemoteDesktopEnable = $RemoteDesktopEnable
            }
            if ($UnattendPath) {
                $Params.Add('UnattendPath', $UnattendPath)
            }
            # do the it
            _ConvertWindowsImage @Params
        } catch {
            throw $PSItem
        } finally {
            Dismount-DiskImage -ImagePath $ISOPath
        }
    }

    end {
    }
}
