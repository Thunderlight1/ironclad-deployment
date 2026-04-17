#!/bin/bash
# Smart backup rotation

BACKUP_DIR="/backups/ironclad"
DAYS_KEEP=7
WEEKS_KEEP=4
MONTHS_KEEP=12

find $BACKUP_DIR/daily -type f -mtime +$DAYS_KEEP -delete
find $BACKUP_DIR/weekly -type f -mtime +$((WEEKS_KEEP * 7)) -delete
find $BACKUP_DIR/monthly -type f -mtime +$((MONTHS_KEEP * 30)) -delete
find $BACKUP_DIR/daily -type f -name "*.sql" -mtime +3 -exec gzip {} \;

echo "✅ Backup rotation complete"
