#!/bin/bash

# Workaround to switch to the default user
mkdir /home/abc
chown abc:abc /home/abc
usermod -d /home/abc -s /bin/bash abc
su abc <<'EOF'
    echo "[switch-user.sh] wine initialization for eac3to..." 
    eac3to &> /dev/null
    echo "[switch-user.sh] done."
EOF
echo "[switch-user.sh] login to default user (uid: $(id -u abc); gid: $(id -g abc))."
su - abc
echo "[switch-user.sh] done."
