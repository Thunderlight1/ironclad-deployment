#!/bin/bash
# Resource monitoring

CPU_THRESHOLD=80
MEM_THRESHOLD=85
DISK_THRESHOLD=80

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    echo "⚠️ High CPU usage: ${CPU_USAGE}%" | logger -t ironclad-monitor
fi

if (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
    echo "⚠️ High memory usage: ${MEM_USAGE}%" | logger -t ironclad-monitor
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "⚠️ Low disk space: ${DISK_USAGE}%" | logger -t ironclad-monitor
fi
