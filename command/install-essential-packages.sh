sudo add-apt-repository -y ppa:apt-fast/stable
sudo apt-get update
sudo apt-get install -y apt-fast apt-transport-https && sudo apt-fast update
sudo apt-fast install -y inotify-tools