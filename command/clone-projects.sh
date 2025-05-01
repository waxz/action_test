git clone git@github.com:waxz/action_test.git /tmp/action_test
git clone git@github.com:waxz/self-host-reader.git /tmp/self-host-reader
git clone git@github.com:waxz/quartz.git /tmp/quartz
git clone git@github.com:waxz/markdown-editor.git /tmp/markdown-editor
git clone git@github.com:waxz/cf-deploy.git /tmp/cf-deploy
git clone git@github.com:waxz/pages-fns-with-wasm-demo.git /tmp/pages-fns-with-wasm-demo
    
export QUARTZ_PORT=8002
export QUARTZ_CONTENT=/tmp/self-host-reader/notes
export QUARTZ_DOMAIN=quartz
nohup /tmp/quartz/run_quartz.sh > /tmp/$QUARTZ_DOMAIN.out 2>&1 &
sleep 15
cat /tmp/$QUARTZ_DOMAIN.out

export QUARTZ_PORT=8003
export QUARTZ_CONTENT=/tmp/quartz/content
export QUARTZ_DOMAIN=quartz-public
nohup /tmp/quartz/run_quartz.sh > /tmp/$QUARTZ_DOMAIN.out 2>&1 &        
sleep 5
cat /tmp/$QUARTZ_DOMAIN.out

export MDE_PORT=8004
export MDE_CONTENT=/tmp/self-host-reader/notes
export MDE_DOMAIN=mdeditor
nohup /tmp/markdown-editor/run_editor.sh > /tmp/markdown.out 2>&1 &  


nohup /tmp/self-host-reader/run_readeck.sh > /tmp/reader.out 2>&1 &