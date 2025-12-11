#!/bin/bash

# Fail2ban Installation Script

echo "Installing Fail2ban on Ubuntu..."

# Update system
sudo apt update

# Install fail2ban
sudo apt install -y fail2ban

# Copy configuration
sudo cp config/jail.local /etc/fail2ban/jail.local

# Create filter for SSH DDOS
sudo tee /etc/fail2ban/filter.d/sshd-ddos.conf > /dev/null << EOF
[Definition]
failregex = ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>\s*$
            ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
            ^%(__prefix_line)sFailed publickey for .* from <HOST> port .* ssh2\s*$
            ^%(__prefix_line)sReceived disconnect from <HOST>: 11: (?:Bye|Network is unreachable)\s*$
ignoreregex =
EOF

# Start and enable fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Check status
echo "Fail2ban installation completed!"
echo "Checking status..."
sudo fail2ban-client status

echo ""
echo "To check specific jail status:"
echo "sudo fail2ban-client status sshd"