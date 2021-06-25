---
external help file: PSHyperTools-help.xml
Module Name: PSHyperTools
online version:
schema: 2.0.0
---

# New-GPUPDriverPackage

## SYNOPSIS
Create a GPU-P Guest driver package.

## SYNTAX

```
New-GPUPDriverPackage [[-DestinationPath] <String>] [[-Filter] <ValidateNotNullOrEmptyAttribute>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Gathers the necessary files for a GPU-P enabled Windows guest to run.

## EXAMPLES

### EXAMPLE 1
```
New-GPUPDriverPackage -DestinationPath '.'
```

### EXAMPLE 2
```
New-GPUPDriverPackage -Filter 'nvidia' -DestinationPath '.'
```

## PARAMETERS

### -DestinationPath
Path to output directory.
If no file name is specified the filename will be GPUPDriverPackage-YYYYMMMDD.zip

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath, Path

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Device friendly name filter.
Only devices whose friendly names contain the supplied string will be processed

```yaml
Type: ValidateNotNullOrEmptyAttribute
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### A driver package .zip
## NOTES
This has some mildly dodgy use of CIM cmdlets...

## RELATED LINKS
