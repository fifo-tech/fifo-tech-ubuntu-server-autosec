#!/bin/bash

# Security Checks Script

LOG_FILE="security_audit_$(date +%Y%m%d_%H%M%S).log"

echo "=== SECURITY AUDIT REPORT ===" > "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "Hostname: $(hostname)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Function to run check
run_check() {
    echo "Running: $1"
    echo "=== $1 ===" >> "$LOG_FILE"
    eval "$2" >> "$LOG_FILE" 2>&1
    echo "" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo ""
}

# 1. System Information
run_check "System Information" "uname -a && cat /etc/os-release"

# 2. Failed Login Attempts
run_check "Recent Failed Logins" "grep -i 'failed\|invalid\|authentication failure' /var/log/auth.log | tail -50"

# 3. Current Logins
run_check "Current Logins" "who"

# 4. Open Ports
run_check "Open Ports" "ss -tulpn"

# 5. SSH Configuration
run_check "SSH Configuration Check" "grep -E 'PermitRootLogin|PasswordAuthentication|Port' /etc/ssh/sshd_config"

# 6. Firewall Status
run_check "Firewall Status" "sudo ufw status verbose"

# 7. Fail2ban Status
run_check "Fail2ban Status" "sudo fail2ban-client status"

# 8. User Accounts
run_check "User Accounts" "cat /etc/passwd | grep -E '/bin/bash|/bin/sh'"

# 9. Sudo Users
run_check "Sudo Users" "grep -Po '^sudo.+:\K.*$' /etc/group"

# 10. System Updates
run_check "Update Check" "apt list --upgradable 2>/dev/null | grep -v 'Listing...'"

echo "Security audit completed!"
echo "Report saved to: $LOG_FILE"
echo ""
echo "=== SUMMARY ==="
echo "To view the full report: cat $LOG_FILE"
echo "To monitor auth log in real-time: sudo tail -f /var/log/auth.log | grep -i 'failed\|attempt'"