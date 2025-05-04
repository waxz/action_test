git clone git@github.com:waxz/action_test.git --depth 1  /tmp/action_test
git clone git@github.com:waxz/quartz.git --depth 1  /tmp/quartz
git clone git@github.com:waxz/markdown-editor.git --depth 1  /tmp/markdown-editor
git clone git@github.com:waxz/cf-deploy.git --depth 1  /tmp/cf-deploy
git clone git@github.com:waxz/pages-fns-with-wasm-demo.git --depth 1  /tmp/pages-fns-with-wasm-demo
    
# onedriver
git clone git@github.com:waxz/self-host-reader.git --depth 1 /tmp/self-host-reader
/tmp/self-host-reader/secret/mount.sh

# create r2 rclone configure file
if [ -f source /mnt/data/mydisk10/cloudflare/var.sh ]; then source /mnt/data/mydisk10/cloudflare/var.sh; fi
if [ -f /mnt/data/mydisk10/cloudflare/create_rclone_config.sh ]; then source /mnt/data/mydisk10/cloudflare/create_rclone_config.sh; fi


nohup bash -c "cd /tmp/self-host-reader/ondriver/ && ./download.sh " > /tmp/ondriver.out 2>&1 &


# export QUARTZ_PORT=8002
# export QUARTZ_CONTENT=/tmp/self-host-reader/notes
# export QUARTZ_DOMAIN=quartz
# nohup /tmp/quartz/run_quartz.sh > /tmp/$QUARTZ_DOMAIN.out 2>&1 &
# sleep 15
# cat /tmp/$QUARTZ_DOMAIN.out

# export QUARTZ_PORT=8003
# export QUARTZ_CONTENT=/tmp/quartz/content
# export QUARTZ_DOMAIN=quartz-public
# nohup /tmp/quartz/run_quartz.sh > /tmp/$QUARTZ_DOMAIN.out 2>&1 &        
# sleep 5
# cat /tmp/$QUARTZ_DOMAIN.out

# export MDE_PORT=8004
# export MDE_CONTENT=/tmp/self-host-reader/notes
# export MDE_DOMAIN=mdeditor
# nohup /tmp/markdown-editor/run_editor.sh > /tmp/markdown.out 2>&1 &  


nohup /tmp/self-host-reader/run_readeck.sh > /tmp/reader.out 2>&1 &


