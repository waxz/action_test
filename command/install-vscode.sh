# vscode
curl -fsSL https://code-server.dev/install.sh | sh
nohup bash -c " \
mkdir -p $HOME/.vscode-server/extensions/ && \
code-server --force --install-extension golang.Go --extensions-dir $HOME/.vscode-server/extensions/ || true ;\
code-server --force --install-extension ms-vscode.cpptools-extension-pack --extensions-dir $HOME/.vscode-server/extensions/|| true ;\
code-server --force --install-extension waderyan.nodejs-extension-pack --extensions-dir $HOME/.vscode-server/extensions/ || true ;\
code-server --force --install-extension donjayamanne.python-extension-pack --extensions-dir $HOME/.vscode-server/extensions/ || true ;\
code-server --force --install-extension swellaby.rust-pack --extensions-dir $HOME/.vscode-server/extensions/ || true ;\
code-server --force --install-extension ms-vscode.vscode-typescript-next --extensions-dir $HOME/.vscode-server/extensions/ || true ;\
code-server --force --install-extension gydunhn.javascript-essentials --extensions-dir $HOME/.vscode-server/extensions/ || true ;\
code-server --force --install-extension denoland.vscode-deno --extensions-dir $HOME/.vscode-server/extensions/ || true ;\
code-server --force --install-extension GitHub.copilot --extensions-dir $HOME/.vscode-server/extensions/ || true ;\
" > /tmp/vsc.out &

nohup bash -c 'PASSWORD=1234 code-server --bind-addr=0.0.0.0:3030 --extensions-dir $HOME/.vscode-server/extensions/' > /tmp/coder.out 2>&1 &
