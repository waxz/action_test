sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
