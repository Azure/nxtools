# Commands to wrap
# lsb_release -a
# chmod
# chown
# https://linux.die.net/man/1/chown
# du
# df -B1 . -PT


Set-FileOwner
    -recurse

# chgrp

# system_profiler SPSoftwareDataType -json > ./nxtools/info.txt

# -detailLevel n    specifies the level of detail for the report
#     mini = short report (contains no identifying or personal information)
#     basic = basic hardware and network information
#     full = all available information

#     {
#         "SPSoftwareDataType" : [
#           {
#             "_name" : "os_overview",
#             "boot_mode" : "normal_boot",
#             "boot_volume" : "Macintosh HD",
#             "kernel_version" : "Darwin 20.3.0",
#             "local_host_name" : "Someones MacBook Air",
#             "os_version" : "macOS 11.2.3 (20D91)",
#             "secure_vm" : "secure_vm_enabled",
#             "system_integrity" : "integrity_enabled",
#             "uptime" : "up 17:18:21:22",
#             "user_name" : "My Fullname (accountname)"
#           }
#         ]
#       }
