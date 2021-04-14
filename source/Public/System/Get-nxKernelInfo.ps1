function Get-nxKernelInfo
{
    [CmdletBinding()]
    param
    (

    )

    $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters.Verbose) -or $VerbosePreference -ne 'SilentlyContinue'

    $unameOutput = Invoke-NativeCommand -Executable 'uname' -Parameters @(
        # MacOS does not support long arguments
        '-s' # '--kernel-name',
        '-n' # '--nodename',
        '-r' # '--kernel-release',
        '-m' # '--machine',
        '-p' # '--processor',
        '-i' # '--hardware-platform',
        '-o' # '--operating-system'
    ) -Verbose:$verbose -ErrorAction 'Stop'

    if ($unameOutput -match '^\/.*uname:\s+')
    {
        throw $unameOutput
    }

    $kernelName, $ComputerName, $kernelRelease, $machineHardware, $processor, $hardwarePlatform, $OS = $unameOutput -split '\s'

    # uname --kernel-version
    $kernelVersion = Invoke-NativeCommand -Executable 'uname' -Parameters '-v' -Verbose:$verbose -ErrorAction 'Stop'

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
