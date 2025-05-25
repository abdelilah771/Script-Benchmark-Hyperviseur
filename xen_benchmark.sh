#!/bin/bash

REPORT="/tmp/xen_dom0_benchmark_$(date +%Y%m%d_%H%M%S).txt"

echo " Benchmark XenServer – $(hostname)" | tee $REPORT
echo " Date : $(date)" | tee -a $REPORT
echo "=====================================" | tee -a $REPORT

# === CPU Info
echo -e "\n CPU Info" | tee -a $REPORT
lscpu | tee -a $REPORT

# === RAM Info
echo -e "\n RAM Info" | tee -a $REPORT
free -h | tee -a $REPORT

# === Disk I/O Info
echo -e "\n Disk Stats (iostat -xm 1 2)" | tee -a $REPORT
iostat -xm 1 2 | tee -a $REPORT

# === Network Interfaces + IP
echo -e "\n Network Interfaces" | tee -a $REPORT
ip -br a | tee -a $REPORT

# === Network Stats (vmnic0 or xenbr0)
if esxcli network nic list >/dev/null 2>&1; then
  echo -e "\n VMware esxcli not available on XenServer" | tee -a $REPORT
else
  for iface in $(ip -o link | awk -F': ' '{print $2}' | grep -v lo); do
    echo -e "\n Interface $iface" | tee -a $REPORT
    ethtool -S "$iface" 2>/dev/null | tee -a $REPORT
  done
fi

# === Load Average
echo -e "\n  Charge CPU moyenne (load average)" | tee -a $REPORT
uptime | tee -a $REPORT

echo -e "\n Rapport généré : $REPORT" | tee -a $REPORT
