#!/bin/zsh

# Identify active interfaces
active_interfaces=($(ifconfig | awk '/flags=.*<.*UP.*RUNNING.*>/ {iface=$1} /status: active/ {print substr(iface, 1, length(iface)-1)}'))

# Check for Ethernet connection
ethernet_connected=false
for iface in "${active_interfaces[@]}"; do
    if networksetup -listallhardwareports | awk -v iface="$iface" '
        $2 == iface {print iface, "is Ethernet"; exit}'; then
        ethernet_connected=true
        break
    fi
done

# Check Tailscale status
tailscale_connected=false
local_tailscale_ip=$(tailscale ip -4)
if tailscale status | grep -q "$local_tailscale_ip"; then
    tailscale_connected=true
fi

# Output results and mount based on conditions
if $ethernet_connected && $tailscale_connected; then
    echo "Ethernet and Tailscale are both connected. Mounting iSCSI LUN..."
    # sudo iscsiadm attach-target -n iqn.2000-01.com.synology:diskstation.target
elif $tailscale_connected; then
    echo "Only Tailscale is connected. Mounting SMB/NFS shares..."
    # mount_smbfs //user@server/share /Volumes/SMB
    # mount -t nfs server:/share /Volumes/NFS
else
    echo "Neither Ethernet nor Tailscale is connected."
fi
