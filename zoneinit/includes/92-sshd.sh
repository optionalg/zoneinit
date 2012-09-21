# Old style SSH host keys were stored under /etc/ssh and needed to be
# recreated using /lib/svc/method/sshd -c.
#
# New (SmartOS) style SSH host keys are stored under /var/ssh and are
# automatically recreated by the SMF method if missing.
#
# We assume here that the old keys were already deleted previously
# (e.g. by sm-prepare-image).

if awk '/^HostKey/ {print $2}' /etc/ssh/sshd_config | grep '/etc/ssh' > /dev/null; then
  log "generating a new pair of SSH keys"
  /lib/svc/method/sshd -c >/dev/null || \
    error "SSH key refresh failed."
fi

if [ ${SSH_ALLOW_PASSWORDS} ]; then
  log "enabling password authentication in SSH"
  sed '/^PasswordAuthentication/s/[nN][yY]$/yes/' \
    /etc/ssh/sshd_config > /tmp/sshd_config.tmp && \
    mv /tmp/sshd_config.tmp /etc/ssh/sshd_config
fi
