# Get all VMs within the vCenter
$vms = Get-VM

# Create an empty array to store VM data
$vmData = @()

foreach ($vm in $vms){
    $snapshots = Get-Snapshot -VM $vm

    # Initialize total size for this VM
    $totalSize = 0

    foreach ($snapshot in $snapshots){
        if($snapshot.Name -like "*VEEAM BACKUP TEMPORARY SNAPSHOT*"){
            # Add snapshot size to total size
            $totalSize += $snapshot.SizeGB
        }
    }

    # If total size is greater than 0, add the VM to the VM data
    if ($totalSize -gt 0){
        # Round the total size to two decimal places
        $totalSize = [Math]::Round($totalSize, 2)

        $vmData += New-Object PSObject -Property @{
            VMName = $vm.Name
            TotalSnapshotSizeGB = $totalSize
        }
    }
}

# Output VM data
$vmData | Format-Table -AutoSize

# Print total number of VMs and combined size of all snapshots
$vmCount = $vmData.Count
$totalSize = ($vmData | Measure-Object -Property TotalSnapshotSizeGB -Sum).Sum
Write-Output "VMs: $vmCount, Size: $totalSize GB"
