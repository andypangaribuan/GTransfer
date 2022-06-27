#!/bin/bash
have_smb=false
have_sftp=false

if [ ! -z $SMB_USER ] && [ ! -z $SMB_PASSWORD ] && [ ! -z $SMB_SHARED_NAME ]; then
	have_smb=true
fi
if [ ! -z $SFTP_USER ] && [ ! -z $SFTP_PASSWORD ] && [ ! -z $SFTP_ROOT_DIR ] && [ ! -z $SFTP_INIT_DIR ]; then
	have_sftp=true
fi


if [ ! -d $GCS_MOUNT_PATH ]; then
  mkdir -p $GCS_MOUNT_PATH
fi

cleanup() {
	if [ -d $GCS_MOUNT_PATH ]; then
		umount $GCS_MOUNT_PATH &> /dev/null
	fi
}

# trap kill event to handle the cleanup func
trap cleanup SIGTERM SIGINT SIGQUIT SIGHUP ERR


# start gcsfuse with 0777 permission
if [ -z $GCS_ONLY_DIR ]; then
	gcsfuse -o allow_other --file-mode=0777 --dir-mode=0777 --key-file=$GCS_SA_PATH $GCS_BUCKET_NAME $GCS_MOUNT_PATH
else
	gcsfuse -o allow_other --file-mode=0777 --dir-mode=0777 --only-dir=$GCS_ONLY_DIR --key-file=$GCS_SA_PATH $GCS_BUCKET_NAME $GCS_MOUNT_PATH
fi



if $have_smb; then
	init_smb=/.init_smb
	if [ ! -f $init_smb ]; then
		adduser -S $SMB_USER -G root -G disk
		echo -e "$SMB_PASSWORD\n$SMB_PASSWORD" | smbpasswd -s -a $SMB_USER
		echo "1" > $init_smb
	fi

	echo "
[global]
  workgroup = MYGROUP
  server string = File Server
  server role = standalone server
  max log size = 3
  dns proxy = no

[$SMB_SHARED_NAME]
  path = $GCS_MOUNT_PATH
  read only = no
  writeable = yes
  browseable = yes
  guest ok = yes
  create mask = 0777
  directory mask = 0777
" > /etc/samba/smb.conf

	nmbd --daemon
	smbd
fi


if $have_sftp; then
	init_ssh=/.init_ssh
	init_sftp=/.init_sftp

	if [ ! -f $init_ssh ]; then
		ssh-keygen -A
		echo "1" > $init_ssh
	fi
	if [ ! -f $init_sftp ]; then
		echo -e "$SFTP_PASSWORD\n$SFTP_PASSWORD" | adduser --no-create-home $SFTP_USER -G root
		echo "1" > $init_sftp
	fi

	echo "
Port 900

AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication yes
AllowTcpForwarding no
GatewayPorts no
X11Forwarding no
Subsystem	sftp	/usr/lib/ssh/sftp-server

AllowUsers $SFTP_USER
Match User $SFTP_USER
  ChrootDirectory $SFTP_ROOT_DIR
  ForceCommand internal-sftp -d $SFTP_INIT_DIR
  AllowTCPForwarding no
  X11Forwarding no
" > /etc/ssh/sshd_config

	/usr/sbin/sshd -D -e &
fi


# keep the container active
sleep infinity &
wait $!