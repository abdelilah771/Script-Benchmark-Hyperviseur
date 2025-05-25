#!/bin/sh

REPORT="/tmp/esxi_benchmark_$(hostname)_$(date +%Y%m%d_%H%M%S).txt"

echo "Benchmark ESXi – $(hostname)" | tee $REPORT
echo "Date : $(date)" | tee -a $REPORT
echo "==========================================" | tee -a $REPORT

# === Informations système ===
echo "\n Informations système" | tee -a $REPORT
uname -a | tee -a $REPORT
uptime | tee -a $REPORT

# === CPU ===
echo "\n Charge CPU moyenne (load average)" | tee -a $REPORT
esxtop -b -n 2 | grep -m 1 "PCPU USED" | tee -a $REPORT

# === Mémoire ===
echo "\n Utilisation mémoire" | tee -a $REPORT
esxcli hardware memory get | tee -a $REPORT

# === Disque (statistiques I/O globales) ===
echo "\n Statistiques disque (I/O par périphérique)" | tee -a $REPORT
for device in $(esxcli storage core device list | grep -o "mpx.*" | awk '{print $1}'); do
  echo "\n Device: $device" | tee -a $REPORT
  esxcli storage core device stats get -d $device | tee -a $REPORT
done

# === Réseau ===
echo "\n Statistiques réseau" | tee -a $REPORT
esxcli network nic list | tee -a $REPORT
for nic in $(esxcli network nic list | awk 'NR>1 {print $1}'); do
  echo "\n Interface $nic" | tee -a $REPORT
  esxcli network nic stats get -n $nic | tee -a $REPORT
done

# === Températures (si disponible) ===
echo "\n  Températures capteurs (si supporté)" | tee -a $REPORT
esxcli hardware monitoring sensors list 2>/dev/null | tee -a $REPORT

# === Fin ===
echo "\n Rapport généré : $REPORT" | tee -a $REPORT
