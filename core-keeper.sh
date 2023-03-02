sudo apt update && sudo apt upgrade -y 
sudo apt install unzip apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg -y
sudo apt update

#install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

#create random string for password
CKPW=$(echo $RANDOM | md5sum | head -c 20)

#get stackname created by user data script and update SSM parameter name with this to make it unique
STACKNAME=$(</tmp/mcParamName.txt)
PARAMNAME=mcCoreKeeperPW-$STACKNAME

#put random string into parameter store as encrypted string value
aws ssm put-parameter --name $PARAMNAME --value $CKPW --type "SecureString" --overwrite


#install docker and core keeper app on docker
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo apt install docker-compose -y
sudo usermod -aG docker $USER
sudo mkdir /usr/games/serverconfig
cd /usr/games/serverconfig
sudo bash -c 'echo "version: \"3\"
services:
  core-keeper:
    image: escaping/core-keeper-dedicated
    volumes:
      - ./server-files:/home/steam/core-keeper-dedicated
      - ./server-data:/home/steam/core-keeper-data
      - /tmp/.X11-unix:/tmp/.X11-unix
    environment:
      - WORLD_INDEX=0
      - WORLD_NAME=Core Keeper Server
      - WORLD_SEED=
      - GAME_ID=
      - DATA_PATH=
      - MAX_PLAYERS=10
      - DISCORD=0
    restart: always
    stop_grace_period: 2m'
echo "@reboot root (cd /usr/games/serverconfig/ && docker-compose up)" > /etc/cron.d/awsgameserver
sudo docker-compose up
