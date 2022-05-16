# Linux DDoS Alert to Discord webhook

This is a script that sends alerts of a possible DDoS attack to a discord webhook.


# How to start using script

Step 1. Go to discord -> Your Server -> Your selected channel -> Integrations -> Create Webhook

Step 2. Upload the "discordalerts.sh" and "discord.service"

Step 3. Use an SFTP/FTP client to move "discordalerts.sh" and "discord.service" -> /root

- Move the "discord.service" file to "/etc/systemd" by running "mv /root/discord.service /etc/systemd/system/discord.service"

- Create a "dump" folder for the ".pcap" files, you can do this by running "mkdir /root/dumps" or "/root/<your custom directory>"

# Commands

Step 4. Open your SSH terminal and run the following commands"

  sudo apt-get update && sudo apt-get upgrade -y

  sudo apt-get install tcpdump -y

  sudo apt-get install dos2unix -y

  sudo apt-get install curl -y

  sudo apt-get install screen -y
  
  systemctl daemon-reload
  
  systemctl start discord
  
  systemctl enable discord

  service discord start && service discord status