# vscode
curl -fsSL https://code-server.dev/install.sh | sh
nohup bash -c " \
code-server --force --install-extension golang.Go || true ;\
code-server --force --install-extension ms-vscode.cpptools-extension-pack|| true ;\
code-server --force --install-extension waderyan.nodejs-extension-pack || true ;\
code-server --force --install-extension donjayamanne.python-extension-pack || true ;\
code-server --force --install-extension swellaby.rust-pack || true ;\
code-server --force --install-extension ms-vscode.vscode-typescript-next || true ;\
code-server --force --install-extension gydunhn.javascript-essentials || true ;\
" > /tmp/vsc.out &

nohup bash -c 'PASSWORD=1234 code-server --bind-addr=0.0.0.0:3030' > /tmp/coder.out 2>&1 &
