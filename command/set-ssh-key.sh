export USER_HOME=/home/$MY_SSH_USER
export MY_SSH_USER=$MY_SSH_USER
export SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY
export SSH_PRIVATE_KEY=$SSH_PRIVATE_KEY

sudo mkdir -p $USER_HOME/.ssh
echo "$SSH_PUBLIC_KEY" | sudo tee -a   $USER_HOME/.ssh/authorized_keys
echo "$SSH_PUBLIC_KEY" | sudo tee -a   $USER_HOME/.ssh/id_ed25519.pub
echo "$SSH_PRIVATE_KEY"| sudo tee -a   $USER_HOME/.ssh/id_ed25519
sudo chown $MY_SSH_USER:$MY_SSH_USER $USER_HOME/.ssh
sudo chown $MY_SSH_USER:$MY_SSH_USER $USER_HOME/.ssh/*
sudo chmod 600 $USER_HOME/.ssh/*
sudo chmod 700 $USER_HOME/.ssh
