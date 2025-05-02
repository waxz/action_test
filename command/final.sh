if which tailscale &>/dev/null; then
    echo 'tailscale logout'
    sudo tailscale logout|| true;
fi
if which netbird &>/dev/null; then
    echo 'netbird down'
    sudo netbird down|| true;
fi

# onedriver
cd /tmp/self-host-reader/ondriver/ && ./upload.sh
cd /tmp/self-host-reader/ondriver/ && ./commit.sh

# action
cd /tmp/action_test && gh run list --workflow=run_proxy.yml
cd /tmp/action_test && gh workflow run .github/workflows/run_proxy.yml && gh run list --workflow=run_proxy.yml


echo "commit github update"
(cd /tmp/self-host-reader/ && git add --all && git commit -m "update" && git push origin main ) || true
(cd /tmp/quartz/ && git add --all && git commit -m "update" && git push origin main ) || true

