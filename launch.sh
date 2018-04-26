THIS_DIR=$(cd $(dirname $0); pwd)
 install() {

wget "https://valtman.name/files/telegram-cli-1222"

mv telegram-cli-1222 tg

chmod +x tg

sudo apt-get install libreadline-dev -y

sudo apt install libreadline-dev -y

sudo apt-get install libreadline6 -y

sudo apt-get install libreadline6-dev -y

sudo apt-get install libconfig-dev -y

sudo apt-get install libssl-dev -y

sudo apt-get install lua5.2 -y

sudo apt-get install liblua5.2-dev -y

sudo apt-get install lua-socket -y

sudo apt-get install lua-sec -y

sudo apt-get install lua-expat -y

sudo apt-get install libevent-dev -y

sudo apt-get install make -y

sudo apt-get install unzip -y-

sudo apt-get install git -y

sudo apt-get install redis-server -y

sudo apt-get install autoconf -y

sudo apt-get install g++ -y

sudo apt-get install libjansson-dev -y

sudo apt-get install libpython-dev -y

sudo apt-get install expat libexpat1-dev -y

sudo apt-get install ppa-purge -y

sudo apt-get install python3-pip -y

sudo apt-get install python3-dev -y

sudo apt-get install software-properties-common -y

sudo apt-get install python-software-properties -y

sudo apt-get install gcc-6 -y

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test 

sudo apt-get update

sudo apt-get upgrade

sudo apt-get dist-upgrade

sudo ppa-purge

sudo pip3 install redis

sudo service redis-server restart

wget http://luarocks.org/releases/luarocks-2.2.2.tar.gz

 tar zxpf luarocks-2.2.2.tar.gz

 rm luarocks-2.2.2.tar.gz

 cd luarocks-2.2.2

 ./configure; sudo make bootstrap

 cd ..

sudo luarocks install serpent

sudo luarocks install redis-lua

chmod 777 tg

RED='\033[0;31m'

NC='\033[0m'

CYAN='\033[0;36m'

BIYellow='\033[1;93m'

echo -e "-${RED} Self Bot installed ! ${NC}Now run With ${CYAN}./launch.sh ${NC}command"
echo -e "${BIYellow} **@HEART_SEARCH**"
}

 if [ "$1" = "install" ]; then

  install

  else

 if [ ! -f ./tg ]; then

    echo "tg binary not found"

    echo "Run $0 install"

    exit 1

  fi
rm -rf /$THIS_DIR/.telegram-cli/data/thumb
rm -rf /$THIS_DIR/.telegram-cli/data/photo
rm -rf /$THIS_DIR/.telegram-cli/data/video
rm -rf /$THIS_DIR/.telegram-cli/data/audio
rm -rf /$THIS_DIR/.telegram-cli/data/sticker
rm -rf /$THIS_DIR/.telegram-cli/data/voice
rm -rf /$THIS_DIR/.telegram-cli/data/document
rm -rf /$THIS_DIR/.telegram-cli/data/animation

./tg -s ./bot.lua 

fi
