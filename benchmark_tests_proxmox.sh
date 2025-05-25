#!/bin/bash

# === Configuration ===
REPORT="benchmark_report_$(hostname)_$(date +%Y%m%d_%H%M%S).txt"
IPERF_SERVER="127.0.0.1"  # Modifier si besoin d’un test externe

echo " Lancement des tests de performance..." | tee $REPORT
echo "=== Hôte : $(hostname) - Date : $(date)" | tee -a $REPORT
echo "==========================================" | tee -a $REPORT

# === Test CPU ===
echo -e "\n Test CPU (1 thread)" | tee -a $REPORT
sysbench cpu --cpu-max-prime=20000 --threads=1 run | tee -a $REPORT

echo -e "\n Test CPU (4 threads)" | tee -a $REPORT
sysbench cpu --cpu-max-prime=20000 --threads=4 run | tee -a $REPORT

# === Test RAM ===
echo -e "\n Test RAM (écriture 1 thread)" | tee -a $REPORT
sysbench memory run | tee -a $REPORT

echo -e "\n Test RAM (écriture 4 threads)" | tee -a $REPORT
sysbench memory --threads=4 run | tee -a $REPORT

echo -e "\n Test RAM (lecture 4 threads)" | tee -a $REPORT
sysbench memory --memory-oper=read --threads=4 run | tee -a $REPORT

echo -e "\n Test RAM (blocs 4K, 4 threads)" | tee -a $REPORT
sysbench memory --threads=4 --memory-block-size=4K run | tee -a $REPORT

# === Test Disque ===
echo -e "\n Test Disque (fio 4K read/write)" | tee -a $REPORT
fio --name=disk-test --rw=randrw --bs=4k --size=1G --iodepth=16 --runtime=60s --group_reporting | tee -a $REPORT

# === Test Réseau (iperf3 local) ===
if [[ "$IPERF_SERVER" != "<IP_DU_SERVEUR_IPERF3>" && "$IPERF_SERVER" != "" ]]; then
    echo -e "\n Test Réseau (iperf3 vers $IPERF_SERVER)" | tee -a $REPORT
    iperf3 -s > /dev/null 2>&1 &
    SERVER_PID=$!
    sleep 2
    iperf3 -c $IPERF_SERVER | tee -a $REPORT
    kill $SERVER_PID
else
    echo -e "\n Test réseau ignoré : IP serveur non définie." | tee -a $REPORT
fi

echo -e "\n Rapport terminé : $REPORT"
