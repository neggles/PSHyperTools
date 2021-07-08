---
external help file: PSHyperTools-help.xml
Module Name: PSHyperTools
online version:
schema: 2.0.0
---

# New-WindowsVHDX

## SYNOPSIS
Short description

## SYNTAX

```
New-WindowsVHDX [-ImagePath] <String> [[-ImageIndex] <UInt32>] [-Destination] <String> [[-SizeBytes] <UInt64>]
 [[-VHDType] <String>] [[-UnattendPath] <String>] [[-RemoteDesktopEnable] <Boolean>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
Example of how to use this cmdlet
```

### EXAMPLE 2
```
Another example of how to use this cmdlet
```

## PARAMETERS

### -ImagePath
Path to source ISO image.

```yaml
Type: String
Parameter Sets: (All)
Aliases: ISOPath

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImageIndex
Windows image index (defaults to 1)

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: Index

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination
Destination path for the VHDX image.

```yaml
Type: String
Parameter Sets: (All)
Aliases: OutPath, VHDPath

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SizeBytes
Size (in bytes) of the VHDX to create

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: Size

Required: False
Position: 4
Default value: 136365211648
Accept pipeline input: False
Accept wildcard characters: False
```

### -VHDType
VHD type to create, dynamic (default) or fixed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Dynamic
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnattendPath
Path to unattend.xml to apply (if desired) with DISM offline deploy.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Unattend, AutoUnattend

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoteDesktopEnable
boolean to enable or disable RD by default

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: True
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

### Inputs to this cmdlet (if any)
## OUTPUTS

### Output from this cmdlet (if any)
## NOTES
General notes

## RELATED LINKS
