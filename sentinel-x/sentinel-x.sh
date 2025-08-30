#!/bin/bash

# === CONFIGURATION ===
TELEGRAM_BOT_TOKEN="8265209820:AAGUh95FSLd8wmP59DbFSbAkrsfjtQ5vQ" #Here you need to provide your telegram bot token!
TELEGRAM_CHAT_ID="144996925295" #Here you need to provide your telegram chat ID
RULES_FILE="/home/kali/Desktop/sentinel-x/rules.conf"
LOG_FILE="logs/sentinel-x.log"
INTEGRITY_DB="file_integrity.db"
USE_JOURNALCTL=true  # Set to false to use /var/log/auth.log

# === INIT ===
mkdir -p logs alerts plugins

send_alert() {
    msg="🚨 [$(hostname)] $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE"
    curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
         -d chat_id=$TELEGRAM_CHAT_ID -d text="$msg" > /dev/null
}

perform_action() {
    local action_string="$1"
    local pid="$2"
    local ip=$(who | awk '{print $5}' | tr -d '()')

    IFS='+' read -ra actions <<< "$action_string"
    for action in "${actions[@]}"; do
        case "$action" in
            alert) ;;
            kill)
                [[ $pid ]] && kill -9 "$pid" 2>/dev/null
                ;;
            photo)
                fswebcam -r 640x480 --no-banner "alerts/alert_$(date +%s).jpg" 2>/dev/null
                ;;
            lock)
                passwd -l root 2>/dev/null
                ;;
            block)
                [[ $ip ]] && iptables -A INPUT -s "$ip" -j DROP
                ;;
            custom)
                bash plugins/custom_response.sh
                ;;
            *)
                echo "Unknown action: $action" >> "$LOG_FILE"
                ;;
        esac
    done
}

initialize_file_hashes() {
    > "$INTEGRITY_DB"
    while IFS=':' read -r type filepath _ _; do
        [[ "$type" == "file" && -f "$filepath" ]] && \
        echo "$filepath $(sha256sum "$filepath" | awk '{print $1}')" >> "$INTEGRITY_DB"
    done < "$RULES_FILE"
}

check_file_changes() {
    while IFS=':' read -r type filepath alert action; do
        [[ "$type" != "file" || ! -f "$filepath" ]] && continue
        new_hash=$(sha256sum "$filepath" | awk '{print $1}')
        old_hash=$(grep "$filepath" "$INTEGRITY_DB" | awk '{print $2}')
        if [[ "$new_hash" != "$old_hash" ]]; then
            send_alert "$alert"
            perform_action "$action"
            sed -i "/$filepath/d" "$INTEGRITY_DB"
            echo "$filepath $new_hash" >> "$INTEGRITY_DB"
        fi
    done < "$RULES_FILE"
}

run_ids() {
    while IFS=':' read -r type pattern alert action; do
        case "$type" in
            log)
                if [[ "$USE_JOURNALCTL" == true ]]; then
                    journalctl -xe | grep -qi "$pattern" && { send_alert "$alert"; perform_action "$action"; }
                else
                    grep -qi "$pattern" /var/log/auth.log && { send_alert "$alert"; perform_action "$action"; }
                fi
                ;;
            proc)
                pgrep -f "$pattern" > /dev/null && {
                    pid=$(pgrep -f "$pattern" | head -n1)
                    send_alert "$alert"
                    perform_action "$action" "$pid"
                }
                ;;
        esac
    done < "$RULES_FILE"
}

# === START ===
[[ ! -f "$INTEGRITY_DB" ]] && initialize_file_hashes
send_alert "✅ Sentinel X started scanning"
run_ids
check_file_changes
send_alert "✅ Scan complete"
