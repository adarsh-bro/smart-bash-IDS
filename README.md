# Smart Bash IDS 🛡️

A lightweight Intrusion Detection System (IDS) built using **Bash scripting**.  
This project is designed for **learning, experimenting, and demonstrating** basic security monitoring techniques in a Linux environment, which gives you the understanding of how automation works.

---

## 📌 Features
- Real-time **log monitoring**
- Detects **failed login attempts**
- Detects **suspicious IP activity**
- Simple **alert system through Telegram Bot**
- Easy to customize and extend
- In future we gonna made it extra advance with the features like - AI with the advance IDS (which include pre build IDSs) 💀
---

## 🚀 Getting Started

1️⃣ Clone the Repository
```bash
git clone https://github.com/adarsh-bro/smart-bash-IDS.git
cd smart-bash-IDS
2️⃣ Make the Script Executable
chmod +x smart-bash-IDS.sh

3️⃣ Run the IDS
./smart-bash-IDS.sh
## Prerequisites
 I have tested my code through LIVE Persistence Kali USB, so some thing may be change like:  
  - System logs may not be available in the same way as normal Kali.  
  - Some features depending on `/var/log/` may not work.  
  - You may need to manually configure persistence for log storage.  
- Git installed  
- Basic knowledge of Linux commands
Note : You may need to know your logging system, and if you want this script run after start up and every ten minutes like mine then you need to edit your startup with specific command.
