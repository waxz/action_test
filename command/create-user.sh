
# Set user and group 


export USERNAME=test
export MUID=$(id -u)
export MGID=$(id -g)

# add user without password

sudo groupadd -g $MGID $USERNAME
# same uid with host user
# sudo useradd -u $MUID -g $MGID -m -s /bin/bash $USERNAME
sudo useradd  -g $MGID -m -s /bin/bash $USERNAME
sudo passwd -d $USERNAME
sudo usermod -a -G sudo $USERNAME
sudo usermod -a -G docker $USERNAME


# add user with password
export USERNAME=test2
sudo groupadd -g $MGID $USERNAME
# same uid with host user
# sudo useradd -u $MUID -g $MGID -m -s /bin/bash $USERNAME
sudo useradd  -g $MGID -m -s /bin/bash $USERNAME
echo $USERNAME:$USERNAME | sudo chpasswd
sudo usermod -a -G sudo $USERNAME
sudo usermod -a -G docker $USERNAME

