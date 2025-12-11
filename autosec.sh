#!/bin/bash

# Ubuntu Server Auto Security Setup Script
# Author: Your Name
# Description: Automated security setup for Ubuntu servers

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="logs/security_scan.log"
mkdir -p logs

# Function to log messages
log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
    log_message "[SUCCESS] $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    log_message "[WARNING] $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
    log_message "[ERROR] $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
    log_message "[INFO] $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Function to update system
update_system() {
    print_info "Updating system packages..."
    apt update && apt upgrade -y
    if [ $? -eq 0 ]; then
        print_status "System updated successfully"
    else
        print_error "Failed to update system"
    fi
}

# Function to run security checks
run_security_checks() {
    print_info "Running security checks..."
    
    # Check for failed login attempts
    print_info "Checking failed login attempts..."
    echo "=== FAILED LOGIN ATTEMPTS ===" >> "$LOG_FILE"
    sudo tail -f /var/log/auth.log 2>/dev/null | grep -i "failed\|attempt" &
    PID=$!
    sleep 5
    kill $PID
    
    # Check open ports
    print_info "Checking open ports..."
    echo "=== OPEN PORTS ===" >> "$LOG_FILE"
    ss -tulpn >> "$LOG_FILE" 2>/dev/null
    
    # Check for root SSH access
    print_info "Checking SSH configuration..."
    echo "=== SSH CONFIG ===" >> "$LOG_FILE"
    grep -i "PermitRootLogin" /etc/ssh/sshd_config >> "$LOG_FILE" 2>/dev/null
    
    # Check firewall status
    print_info "Checking firewall status..."
    echo "=== FIREWALL STATUS ===" >> "$LOG_FILE"
    ufw status verbose >> "$LOG_FILE" 2>/dev/null
    
    print_status "Security checks completed"
}

# Function to install and configure fail2ban
setup_fail2ban() {
    print_info "Installing fail2ban..."
    apt install -y fail2ban
    
    # Create custom jail.local
    print_info "Configuring fail2ban..."
    cp config/jail.local /etc/fail2ban/jail.local
    
    # Restart fail2ban
    systemctl restart fail2ban
    systemctl enable fail2ban
    
    # Check fail2ban status
    print_info "Checking fail2ban status..."
    echo "=== FAIL2BAN STATUS ===" >> "$LOG_FILE"
    fail2ban-client status >> "$LOG_FILE" 2>/dev/null
    
    print_status "Fail2ban installed and configured"
}

# Function to setup basic firewall
setup_firewall() {
    print_info "Setting up firewall..."
    
    # Enable UFW if not enabled
    ufw --force enable
    
    # Default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH
    ufw allow ssh
    
    # Allow HTTP/HTTPS if needed
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Reload firewall
    ufw reload
    
    print_status "Firewall configured"
}

# Function to show final status
show_status() {
    print_info "=== FINAL SECURITY STATUS ==="
    
    # Show fail2ban status for sshd
    echo ""
    print_info "Fail2ban SSH Jail Status:"
    sudo fail2ban-client status sshd
    
    # Show banned IPs
    echo ""
    print_info "Currently Banned IPs:"
    sudo fail2ban-client status sshd | grep "Banned IP list"
    
    # Show firewall status
    echo ""
    print_info "Firewall Status:"
    ufw status
    
    # Show last security scan
    echo ""
    print_info "Last security scan log:"
    tail -20 "$LOG_FILE"
}

# Main execution
main() {
    clear
    echo "========================================="
    echo "   Ubuntu Server Auto Security Setup     "
    echo "========================================="
    echo ""
    
    # Check root privileges
    check_root
    
    # Step 1: Update system
    update_system
    
    # Step 2: Run security checks
    run_security_checks
    
    # Step 3: Setup firewall
    setup_firewall
    
    # Step 4: Install and configure fail2ban
    setup_fail2ban
    
    # Step 5: Show final status
    show_status
    
    echo ""
    print_status "Security setup completed successfully!"
    print_info "Detailed logs saved to: $LOG_FILE"
}

# Run main function
main "$@"