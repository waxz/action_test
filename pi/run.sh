sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
echo DNS=127.0.0.1 | sudo tee -a  /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
docker compose up
#-d
