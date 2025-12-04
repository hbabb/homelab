#!/bin/sh
# Pi-hole Update Script for Alpine Linux
# Sends email notification via Resend API when complete
# Loads secrets from .env file

# Load environment variables from .env file
if [ -f "/usr/local/bin/.env" ]; then
    export $(grep -v '^#' /usr/local/bin/.env | xargs)
else
    echo "ERROR: .env file not found at /usr/local/bin/.env"
    exit 1
fi

HOSTNAME=$(hostname)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/var/log/pihole-updates.log"

# Start logging
echo "=== Pi-hole Update Started: $TIMESTAMP ===" | tee -a "$LOG_FILE"

# Update Alpine packages
echo "Updating Alpine packages..." | tee -a "$LOG_FILE"
APK_OUTPUT=$(apk update 2>&1)
APK_EXIT=$?
echo "$APK_OUTPUT" | tee -a "$LOG_FILE"

if [ $APK_EXIT -eq 0 ]; then
    UPGRADE_OUTPUT=$(apk upgrade 2>&1)
    UPGRADE_EXIT=$?
    echo "$UPGRADE_OUTPUT" | tee -a "$LOG_FILE"
    
    if [ $UPGRADE_EXIT -eq 0 ]; then
        APK_STATUS="✅ Alpine packages updated successfully"
    else
        APK_STATUS="❌ Alpine package upgrade failed (exit $UPGRADE_EXIT)"
    fi
else
    APK_STATUS="❌ Alpine package update failed (exit $APK_EXIT)"
    UPGRADE_EXIT=$APK_EXIT
fi

echo "$APK_STATUS" | tee -a "$LOG_FILE"

# Update Pi-hole
echo "Updating Pi-hole..." | tee -a "$LOG_FILE"
PIHOLE_OUTPUT=$(pihole -up 2>&1)
PIHOLE_EXIT=$?
echo "$PIHOLE_OUTPUT" | tee -a "$LOG_FILE"

if [ $PIHOLE_EXIT -eq 0 ]; then
    PIHOLE_STATUS="✅ Pi-hole updated successfully"
else
    PIHOLE_STATUS="❌ Pi-hole update failed (exit $PIHOLE_EXIT)"
fi

echo "$PIHOLE_STATUS" | tee -a "$LOG_FILE"

# Update gravity (blocklists)
echo "Updating gravity..." | tee -a "$LOG_FILE"
GRAVITY_OUTPUT=$(pihole -g 2>&1)
GRAVITY_EXIT=$?
echo "$GRAVITY_OUTPUT" | tee -a "$LOG_FILE"

if [ $GRAVITY_EXIT -eq 0 ]; then
    GRAVITY_STATUS="✅ Gravity updated successfully"
else
    GRAVITY_STATUS="❌ Gravity update failed (exit $GRAVITY_EXIT)"
fi

echo "$GRAVITY_STATUS" | tee -a "$LOG_FILE"

# Determine status
if [ $UPGRADE_EXIT -eq 0 ] && [ $PIHOLE_EXIT -eq 0 ] && [ $GRAVITY_EXIT -eq 0 ]; then
    SUBJECT="✅ Pi-hole Updates - Success"
    MESSAGE="All updates completed successfully"
else
    SUBJECT="❌ Pi-hole Updates - Failed"
    MESSAGE="Some updates failed - check server logs"
fi

# Send email
echo "Sending email notification..." | tee -a "$LOG_FILE"
curl -X POST 'https://api.resend.com/emails' \
    -H "Authorization: Bearer $RESEND_API" \
    -H 'Content-Type: application/json' \
    -d '{
        "from": "'"$FROM_EMAIL"'",
        "to": ["'"$TO_EMAIL"'"],
        "subject": "'"$SUBJECT"'",
        "text": "'"$MESSAGE"'"
    }' >> "$LOG_FILE" 2>&1

echo "=== Update Complete: $TIMESTAMP ===" | tee -a "$LOG_FILE"

exit $((UPGRADE_EXIT + PIHOLE_EXIT + GRAVITY_EXIT))
