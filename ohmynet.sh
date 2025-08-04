#!/bin/bash

set -e

PING_TARGET="8.8.8.8"
CHECK_INTERVAL=3

get_connected_interfaces() {
    nmcli -t -f DEVICE,STATE d | grep -w 'connected' | cut -d: -f1
}

get_default_interface() {
    ip route | grep '^default' | awk '{print $5}' | head -n1
}

has_internet() {
    local iface="$1"
    ping -I "$iface" -c 2 -W 2 "$PING_TARGET" > /dev/null 2>&1
}

switch_default_interface() {
    local new_iface="$1"
    local ip_info
    ip_info=$(ip -4 addr show "$new_iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')
    local gateway
    gateway=$(ip route show dev "$new_iface" | grep 'default' | awk '{print $3}')

    if [[ -n "$ip_info" && -n "$gateway" ]]; then
        sudo ip route del default
        sudo ip route add default via "$gateway" dev "$new_iface"
        echo "🔁 Switched default route to $new_iface via $gateway"
    else
        echo "⚠️ Could not find gateway for $new_iface"
    fi
}

echo "🌐 Starting internet monitor (checking every $CHECK_INTERVAL seconds)..."

while true; do
    interfaces=($(get_connected_interfaces))
    default_iface=$(get_default_interface)

    if [[ -z "$default_iface" || ! " ${interfaces[*]} " =~ " $default_iface " ]]; then
        echo "⚠️ No valid default interface found"
        sleep "$CHECK_INTERVAL"
        continue
    fi

    if has_internet "$default_iface"; then
        echo "✅ Internet OK on $default_iface"
    else
        echo "❌ Lost internet on $default_iface. Searching for alternative..."
        switched=false
        for iface in "${interfaces[@]}"; do
            if [[ "$iface" == "$default_iface" ]]; then continue; fi
            if has_internet "$iface"; then
                switch_default_interface "$iface"
                switched=true
                break
            fi
        done

        if ! $switched; then
            echo "❌ No alternative interface has internet!"
        fi
    fi

    sleep "$CHECK_INTERVAL"
done
