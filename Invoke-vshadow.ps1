function Invoke-vshadow {
    # Get volume as parameter
    param([string]$volume)

    # Ensure this script is run with administrative privileges
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script must be run as an administrator. Please restart the PowerShell session with administrative privileges."
        exit
    }

    # Check if the volume parameter is provided. This is a bit redundant due to the Mandatory flag but shown here for custom handling.
    If (-not $volume) {
        Write-Host "You must provide a volume parameter to continue. Example usage: .\vshadow.ps1 -volume 'C:\'"
        exit
    }

    Write-Host "Proceeding with volume: $volume"
    Write-Host "Creating Win32_ShadowCopy Object"
    $vssobject = [wmiclass]"root\cimv2:win32_shadowcopy"

    # Create a VSS copy for the specified volume
    Write-Host "Creating persistent VSS Copy for volume: $($volume)"
    $vssvolume = $vssobject.create($volume, "ClientAccessible")

    # Check for successful VSS creation
    if ($vssvolume.ReturnValue -ne 0) {
        Write-Error "Failed to create VSS copy. Error code: $($vssvolume.Status)"
        exit
    }

    # Display the Snapshot ID
    Write-Host "`n"
    $SnapshotId = [string]$vssvolume.ShadowID
    Write-Host "Snapshot ID: $($SnapshotId)"

    # Retrieve details of the created VSS copy
    $vsscopy = Get-WmiObject Win32_ShadowCopy | Where-Object { $_.ID -eq $SnapshotId }

    if ($vsscopy) {
        # Display details of the created VSS copy
        Write-Host "Details of the created VSS Copy:"
        Write-Host "    - Device Object  : $($vsscopy.DeviceObject)"
        Write-Host "    - Volume Name    : $($vsscopy.VolumeName) [$volume]"
        Write-Host "    - State          : $($vsscopy.State) (1 = Created, 2 = Completed)"
        Write-Host "    - Originating Machine : $($vsscopy.OriginatingMachine)"
        Write-Host "    - Service Machine     : $($vsscopy.ServiceMachine)"
        # Format and display the creation time
        $creationTime = [Management.ManagementDateTimeConverter]::ToDateTime($vsscopy.InstallDate)
        Write-Host "Creation Time       : $creationTime"
        Write-Host "`n"
        Write-Host "Snapshot creation done."
    } else {
        Write-Warning "Created VSS instance not found."
    }
}

