#!/bin/bash

# Novice Inspector for system resources and alert system

read -p "Enter CPU danger threshold % (e.g, 90 for any CPU usage past 90%): " CPU_DANGER
read -p "Enter RAM danger threshold % (e.g, 90): " RAM_DANGER
read -p "Enter host to ping (e.g., 8.8.8.8): " HOST

# TODO: Agregar la opción de guardar la configuración en algun lado y poder cargar otras con argumentos
# de linea de comando.
# e.g.:         ./script --option /home/user/script.cfg

echo ""

while true; do
        CPU_USAGE=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')

        # RAM USAGE (en %)
        RAM_USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')

        if [ "$CPU_USAGE" -gt "$CPU_DANGER" ]; then
                TIMESTAMP=$(date +"%H:%M:%S")
                echo -e "\n[${TIMESTAMP}] ALERT: CPU IS OVER ${CPU_DANGER}%!"
        fi

        if [ "$RAM_USAGE" -gt "$RAM_DANGER" ]; then
                TIMESTAMP=$(date +"%H:%M:%S")
                echo -e "\n[${TIMESTAMP}] ALERT: RAM IS OVER ${RAM_DANGER}%!"
        fi

        # OUTPUT EN UNA SOLA LÍNEA
        echo -ne "\rCPU: ${CPU_USAGE}% | RAM: ${RAM_USAGE}%"

        while true; do
                # Hacemos un ping rápido (1 paquete, timeout 1 segundo)
                if ping -c 1 -W 1 "$HOST" > /dev/null 2>&1; then
                        NET_STATUS="OK"
                else
                        NET_STATUS="DOWN"
                        TIMESTAMP=$(date +"%H:%M:%S")
                        echo -e "\n[${TIMESTAMP}] ALERT: NO NETWORK ACCESS TO ${HOST}!"
                fi
                
                echo ""
                echo "NETWORK: ${NET_STATUS}"

                sleep 30
        done

done
