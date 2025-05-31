# vscode
# wget https://vscode.download.prss.microsoft.com/dbazure/download/stable/848b80aeb52026648a8ff9f7c45a9b0a80641e2e/code-stable-x64-1747260498.tar.gz -O /tmp/vscode.tar.gz
# mkdir -p $HOME/.vscode-server/vscode-server
# sudo tar xf /tmp/vscode.tar.gz --strip-components=1 -C $HOME/.vscode-server/vscode-server
# install code-server

curl -fsSL https://code-server.dev/install.sh | sh
nohup bash -c " \
mkdir -p $HOME/.vscode-server/extensions/ && \
code-server --force --install-extension golang.Go || true ;\
code-server --force --install-extension ms-vscode.cpptools-extension-pack|| true ;\
code-server --force --install-extension waderyan.nodejs-extension-pack || true ;\
code-server --force --install-extension donjayamanne.python-extension-pack || true ;\
code-server --force --install-extension swellaby.rust-pack || true ;\
code-server --force --install-extension ms-vscode.vscode-typescript-next || true ;\
code-server --force --install-extension gydunhn.javascript-essentials || true ;\
code-server --force --install-extension denoland.vscode-deno || true ;\
code-server --force --install-extension GitHub.copilot || true ;\
" > /tmp/vsc.out &

nohup bash -c 'PASSWORD=1234 code-server --bind-addr=0.0.0.0:3030' > /tmp/coder.out 2>&1 &
