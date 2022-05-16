echo -e "Linux DDoS Alert to Discord webhook service"
echo
echo "Made by Josh S."
echo
echo -e "033[97mPackets/s \033[36m{}\n\033[97mBytes/s \033[36m{}\n\033[97mKbp/s \033[36m{}\n\033[97mGbp/s \033[36m{}\n\033[97mMbp/s \033[36m{}"
interface=eth0 ##Change this to your custom network interface if needed
dumpdir=/root/dumps ## either leave this at the default setting or change it "/root/<directory>"
url='WEBHOOK HERE' ## Change this to your Webhook URL
while /bin/true; do
  old_b=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $1 }'`
  
  old_ps=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $2 }'`
  sleep 1
  new_b=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $1 }'`

  new_ps=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $2 }'`
  ##Defining Packets/s
  pps=$(( $new_ps - $old_ps ))
  ##Defining Bytes/s
  byte=$(( $new_b - $old_b ))

  gigs=$(( $byte/1024 ** 3 ))
  mbps=$(( $byte/1024 ** 2 ))
  kbps=$(( $byte/1024 ** 1 ))

  echo -ne "\r$pps packets/s\033[0K"
  tcpdump -n -s0 -c 1500 -w $dumpdir/capture.`date +"%Y%m%d-%H%M%S"`.pcap
  echo "`date` Detecting Attack Packets."
  sleep 1
  if [ $pps -gt 10000 ]; then ## DDoS alert will be shown after X amount of PPS are dectected
    echo " Attack Detected Monitoring Incoming Traffic"
    curl -H "Content-Type: application/json" -X POST -d '{
      "embeds": [{
      	"inline": false,
        "title": "DDoS Attack Detected",
        "username": "DDoS Alerts",
        "color": 15158332,
         "thumbnail": {
          "url": ""
        },
         "footer": {
            "text": "Our systems are trying their best to mitigate the attack and automated pcap dumping has been enabled.",
            "icon_url": ""
          },
    
        "description": "Descriptive information of the on going attack:",
         "fields": [
      {
        "name": "**Server Provider**",
        "value": "<Server Provider>",
        "inline": false
      },
      {
        "name": "**IP Address**",
        "value": "<IP ADDRESS",
        "inline": false
      },
      {
        "name": "**Incoming Data**",
        "value": " '$pps' PPS | '$byte' Bytes ",
        "inline": false
      }
    ]
      }]
    }' $url
    echo "Paused for."
    sleep 120  && pkill -HUP -f /usr/sbin/tcpdump  ## The "Attack no longer detected" alert will display in 220 seconds
    ## echo "Traffic Attack Packets Scrubbed"
    echo -ne "\r$mbps megabytes/s\033[97"
    curl -H "Content-Type: application/json" -X POST -d '{
      "embeds": [{
      	"inline": false,
        "title": "DDoS attack stopped",
        "username": "DDoS Alerts",
        "color": 3066993,
         "thumbnail": {
          "url": ""
        },
         "footer": {
            "text": "Our systems have mitigated the attack and automated pcap dumping has been stopped.",
            "icon_url": ""
          },    
          
        "description": "Descriptive information on the last attack.",
         "fields": [
      {
        "name": "**Server Provider**",
        "value": "<Server Provider>",
        "inline": false
      },
      {
        "name": "**IP Address**",
        "value": "<IP ADDRESS>",
        "inline": false
      },
      {
        "name": "**Incoming Data**",
        "value": " '$pps' PPS | '$byte' Bytes ",
        "inline": false
      }
    ]
      }]
    }' $url
  fi
done
