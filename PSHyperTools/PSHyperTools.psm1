# Main module load file.

# Load classes
$moduleClasses = Get-ChildItem -Recurse -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Classes') -Include '*.ps1' -Exclude '*.tests.ps1' -ErrorAction Stop
foreach ($class in $moduleClasses) {
    try {
        . $class.FullName
    } catch {
        throw ("Unable to dot source [{0}]" -f $class.FullName)
    }
}

# Load public functions
$publicFunctions = Get-ChildItem -Recurse -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public') -Include '*.ps1' -Exclude '*.tests.ps1' -ErrorAction Stop
foreach ($function in $publicFunctions) {
    try {
        . $function.FullName
    } catch {
        throw ("Unable to dot source [{0}]" -f $function.FullName)
    }
}

# Load private functions
$privateFunctions = Get-ChildItem -Recurse -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private') -Include '*.ps1' -Exclude '*.tests.ps1' -ErrorAction Stop
foreach ($function in $privateFunctions) {
    try {
        . $function.FullName
    } catch {
        throw ("Unable to dot source [{0}]" -f $function.FullName)
    }
}

# Export public functions
Export-ModuleMember -Function $publicFunctions.Basename
