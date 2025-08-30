#!/bin/bash

# === Setup ===
BOT_TOKEN="8265209820:AAGUh95FSLd8wmP59DbFSbAkrQ5vQ" #Here you need to provide you Bot Token
CHAT_ID="144998745295" #Here you need to prpvide your Chat ID
ALERT_IMG="alerts/custom_$(date +%s).jpg"

# === IP Detection ===
ATTACKER_IP=$(who | awk '{print $5}' | tr -d '()')

# === Screenshot Capture ===
fswebcam -r 640x480 --no-banner "$ALERT_IMG" 2>/dev/null

# === Geolocation (requires curl) ===
if [[ $ATTACKER_IP ]]; then
    LOCATION=$(curl -s "http://ip-api.com/json/$ATTACKER_IP" | jq -r '.country, .regionName, .city, .org' | paste -sd ', ' -)
else
    LOCATION="Unknown"
fi

# === Send Alert Message ===
MSG="📡 Custom Response Triggered!

🕵️‍♂️ IP: $ATTACKER_IP
🌍 Location: $LOCATION
🔐 Action: Screenshot taken + Lockdown"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d text="$MSG" > /dev/null

# === Send Screenshot ===
curl -s -F chat_id="$CHAT_ID" -F photo=@"$ALERT_IMG" \
     "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" > /dev/null

# === Optional: Lock the user/system ===
passwd -l root 2>/dev/null
