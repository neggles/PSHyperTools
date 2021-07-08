---
external help file: PSHyperTools-help.xml
Module Name: PSHyperTools
online version:
schema: 2.0.0
---

# New-GPUPVirtualMachine

## SYNOPSIS
Create a GPU-P enabled Hyper-V VM, or update the settings of an existing one.

## SYNTAX

### VMByName (Default)
```
New-GPUPVirtualMachine -VMName <String> [-MemoryBytes <ValidateNotNullOrEmptyAttribute>]
 [-Cores <ValidateNotNullOrEmptyAttribute>] [-MinPartitionResources <ValidateNotNullOrEmptyAttribute>]
 [-MaxPartitionResources <ValidateNotNullOrEmptyAttribute>]
 [-OptimalPartitionResources <ValidateNotNullOrEmptyAttribute>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### VMByObject
```
New-GPUPVirtualMachine -VM <VirtualMachine> [-MemoryBytes <ValidateNotNullOrEmptyAttribute>]
 [-Cores <ValidateNotNullOrEmptyAttribute>] [-MinPartitionResources <ValidateNotNullOrEmptyAttribute>]
 [-MaxPartitionResources <ValidateNotNullOrEmptyAttribute>]
 [-OptimalPartitionResources <ValidateNotNullOrEmptyAttribute>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates or updates a Hyper-V VM to enable GPU-P usage.

## EXAMPLES

### EXAMPLE 1
```
New-GPUPVirtualMachine -VMName GPUVM
```

### EXAMPLE 2
```
New-GPUPVirtualMachine -VM (Get-VM -Name GPUVM) -Cores 8 -MemoryBytes 16384MB -MinPartitionResources 100000000 -MaxPartitionResources 100000000 -OptimalPartitionResources 100000000
```

## PARAMETERS

### -VMName
Name of virtual machine to create or update.

```yaml
Type: String
Parameter Sets: VMByName
Aliases: Name

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VM
Hyper-V VM Object to update.

```yaml
Type: VirtualMachine
Parameter Sets: VMByObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemoryBytes
Amount of memory to allocate for this VM.
All VM memory will be reserved at startup.

```yaml
Type: ValidateNotNullOrEmptyAttribute
Parameter Sets: (All)
Aliases: Memory, RAM

Required: False
Position: Named
Default value: 8589934592
Accept pipeline input: False
Accept wildcard characters: False
```

### -Cores
Number of vCores to allocate for this VM.

```yaml
Type: ValidateNotNullOrEmptyAttribute
Parameter Sets: (All)
Aliases: CPUs, vCores

Required: False
Position: Named
Default value: 4
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinPartitionResources
Value to set for MinPartitionVRAM, MinPartitionCompute, MinPartitionEncode, MinPartitionDecode

```yaml
Type: ValidateNotNullOrEmptyAttribute
Parameter Sets: (All)
Aliases: Minimum, MinResources

Required: False
Position: Named
Default value: 80000000
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxPartitionResources
Value to set for MaxPartitionVRAM, MaxPartitionCompute, MaxPartitionEncode, MaxPartitionDecode

```yaml
Type: ValidateNotNullOrEmptyAttribute
Parameter Sets: (All)
Aliases: Maximum, MaxResources

Required: False
Position: Named
Default value: 100000000
Accept pipeline input: False
Accept wildcard characters: False
```

### -OptimalPartitionResources
Value to set for OptimalPartitionVRAM, OptimalPartitionCompute, OptimalPartitionEncode, OptimalPartitionDecode

```yaml
Type: ValidateNotNullOrEmptyAttribute
Parameter Sets: (All)
Aliases: Optimal, OptimalResources

Required: False
Position: Named
Default value: 100000000
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

### None.
## NOTES
this is not guaranteed to keep working, as the Partition Resource limits don't seem to be sane or reasonable yet.

## RELATED LINKS
