function Get-nxKernelInfo
{
    [CmdletBinding()]
    param
    (

    )

    $kernelName, $ComputerName, $kernelRelease, $machineHardware, $processor, $hardwarePlatform, $OS = (Invoke-NativeCommand -Executable 'uname' -Parameters @(
        '--kernel-name',
        '--nodename',
        '--kernel-release',
        '--machine',
        '--processor',
        '--hardware-platform',
        '--operating-system'
        )
    ) -split '\s'

    $kernelVersion = Invoke-NativeCommand -Executable 'uname' -Parameters '--kernel-version'

    [PSCustomObject]@{
        kernelName       = $kernelName
        ComputerName     = $ComputerName
        KernelRelease    = $kernelRelease
        KernelVersion    = $kernelVersion
        MachineHardware  = $machineHardware
        processor        = $processor
        hardwarePlatform = $hardwarePlatform
        OS               = $OS
    } | Add-Member -TypeName 'nx.KernelInfo' -PassThru
}
