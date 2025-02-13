

# tmate   
### add ssh key in Github Setting     
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=webui
### set key in local machine
```
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
chmod 400 .ssh/id_ed25519.pub   
```

### connect tmate
```
ssh -i ~/.ssh/id_ed25519 xxxx@nyc1.tmate.io
```
