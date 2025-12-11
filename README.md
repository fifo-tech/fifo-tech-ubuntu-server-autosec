# Ubuntu Server Auto Security Setup

একটি স্বয়ংক্রিয় সিকিউরিটি সেটআপ স্ক্রিপ্ট ফর Ubuntu সার্ভার।

## Features
- 🔍 স্বয়ংক্রিয় সিকিউরিটি চেক
- 🛡️ Fail2ban ইন্সটলেশন ও কনফিগারেশন
- 🔥 ফায়ারওয়াল সেটআপ
- 📊 রিয়েল-টাইম লগ মনিটরিং
- 📈 ডিটেইল্ড রিপোর্ট জেনারেশন

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/ubuntu-server-autosec.git
cd ubuntu-server-autosec

# Make scripts executable
chmod +x *.sh

# Run the main script (as root)
sudo ./autosec.sh