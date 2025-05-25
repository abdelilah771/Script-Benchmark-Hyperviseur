#!/bin/bash

# === Configuration
REPORT="hyperv_benchmark_$(hostname)_$(date +%Y%m%d_%H%M%S).txt"
IPERF_SERVER="127.0.0.1"  # Change si test réseau vers une autre VM

echo " Lancement des tests de performance (Hyper-V)" | tee $REPORT
echo "=== Hôte : $(hostname) - Date : $(date)" | tee -a $REPORT
echo "==============================================" | tee -a $REPORT

# === CPU ===
echo -e "\n Test CPU (1 thread)" | tee -a $REPORT
sysbench cpu --cpu-max-prime=20000 --threads=1 run | tee -a $REPORT

echo -e "\n Test CPU (4 threads)" | tee -a $REPORT
sysbench cpu --cpu-max-prime=20000 --threads=4 run | tee -a $REPORT

# === RAM ===
echo -e "\n Test RAM (1 thread)" | tee -a $REPORT
sysbench memory run | tee -a $REPORT

echo -e "\n Test RAM (4 threads)" | tee -a $REPORT
sysbench memory --threads=4 run | tee -a $REPORT

echo -e "\n Test RAM (lecture 4 threads)" | tee -a $REPORT
sysbench memory --memory-oper=read --threads=4 run | tee -a $REPORT

echo -e "\n Test RAM (blocs 4K, 4 threads)" | tee -a $REPORT
sysbench memory --threads=4 --memory-block-size=4K run | tee -a $REPORT

# === Disque ===
echo -e "\n Test Disque (fio 4K read/write)" | tee -a $REPORT
fio --name=disk-test --rw=randrw --bs=4k --size=1G --iodepth=16 --runtime=60s --group_reporting | tee -a $REPORT

# === Réseau (loopback si serveur local) ===
if [ "$IPERF_SERVER" != "" ]; then
    echo -e "\n Test Réseau (iperf3 vers $IPERF_SERVER)" | tee -a $REPORT
    iperf3 -c $IPERF_SERVER | tee -a $REPORT
else
    echo -e "\n IP serveur iperf3 non définie. Test réseau ignoré." | tee -a $REPORT
fi

echo -e "\n Rapport terminé : $REPORT" | tee -a $REPORT
