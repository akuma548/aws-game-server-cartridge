sudo apt update && sudo apt upgrade -y 
sudo apt install unzip apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg -y
sudo apt update

#install docker and core keeper app on docker
sudo usermod -aG docker $USER
sudo mkdir /usr/games/serverconfig
cd /usr/games/serverconfig
sudo bash -c 'echo "version: \"2.0\"
services:
  necesse:
    container_name: necesse-server
    image: brammys/necesse-server
    restart: always
    ports:
      -  14159:14159/udp
    environment:
      MOTD: merp
      PASSWORD: a password
      SLOTS: 5
      PAUSE: 1
      WORLD: worldname
    volumes:
      - /usr/games/serverconfig/saves:/necesse/saves
      - /usr/games/serverconfig/logs:/necesse/logs" >> docker-compose.yml'
echo "@reboot root (cd /usr/games/serverconfig/ && docker-compose up)" > /etc/cron.d/awsgameserver
sudo docker-compose up
