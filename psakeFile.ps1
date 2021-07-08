properties {
    # Set this to $true to create a module with a monolithic PSM1
    $PSBPreference.Build.CompileModule = $false
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Test.ScriptAnalysisEnabled = $false
    $PSBPreference.Test.CodeCoverage.Enabled  = $true
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
}

task Default -depends Build

task Build -FromModule PowerShellBuild -minimumVersion '0.6.1'
