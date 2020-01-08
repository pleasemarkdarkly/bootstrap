#!/bin/bash
# http://netatalk.sourceforge.net/wiki/index.php/Install_Netatalk_3.1.12_on_Ubuntu_18.10_Cosmic
# gist: https://gist.github.com/21d090cba63cff6a8377f5831d71e54d
# wget http://bit.ly/2T6lSNc -O netatalk_install.sh; chmod +x netatalk_install.sh;

trap "exit 1"	HUP INT PIPE QUIT TERM
trap cleanup	EXIT

session="$(date '+%F-%H%M-%S')"

install_prereqs () {
sudo apt install -y \
 build-essential \
 libevent-dev \
 libssl-dev \
 libgcrypt-dev \
 libkrb5-dev \
 libpam0g-dev \
 libwrap0-dev \
 libdb-dev \
 libtdb-dev \
 libmysqlclient-dev \
 avahi-daemon \
 libavahi-client-dev \
 libacl1-dev \
 libldap2-dev \
 libcrack2-dev \
 systemtap-sdt-dev \
 libdbus-1-dev \
 libdbus-glib-1-dev \
 libglib2.0-dev \
 libio-socket-inet6-perl \
 tracker \
 libtracker-sparql-2.0-dev \
 libtracker-miner-2.0-dev
}

download_netatalk () {
 wget https://downloads.sourceforge.net/project/netatalk/netatalk/3.1.12/netatalk-3.1.12.tar.bz2
 tar xvf netatalk-3.1.12.tar.bz2
 cd netatalk-3.1.12
}

cleanup () {
  rm -rvf ./netatalk-3.1.12 ./netatalk-3.1.12.tar.bz2
}

configure_compile_netatalk () {
 # ./configure --help
 ./configure \
        --with-init-style=debian-systemd \
        --without-libevent \
        --without-tdb \
        --with-cracklib \
        --enable-krbV-uam \
        --with-pam-confdir=/etc/pam.d \
        --with-dbus-daemon=/usr/bin/dbus-daemon \
        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
        --with-tracker-pkgconfig-version=2.0

 # pkg-config --list-all | grep tracker
 make
 echo "check http://netatalk.sourceforge.net/wiki/index.php/Install_Netatalk_3.1.12_on_Ubuntu_18.10_Cosmic for build instructions"
 echo "make install"
}

backup_configs () {
  if [ -f "/usr/local/etc/afp.conf" ]; then
    sudo cp -v /usr/local/etc/afp.conf /usr/local/etc/afp.conf."$session".backup
    ls -alh /usr/local/etc/afp.conf."$session".backup
    mv -v /usr/local/etc/afp.conf."$session".backup .
  fi

  if [ -f "/etc/samba/smb.conf" ]; then
    sudo cp -v /etc/samba/smb.conf /etc/samba/smb.conf."$session".backup
    ls -alh /etc/samba/smb.conf."$session".backup
    mv -v /etc/samba/smb.conf."$session".backup
  fi

  if [ -f "/etc/avahi/avahi-daemon.conf" ]; then
    sudo cp -v /etc/avahi/avahi-daemon.conf /etc/avahi/avahi-daemon.conf."$session".backup
    ls -alh /etc/avahi/avahi-daemon.conf."$session".backup
    mv -v /etc/avahi/avahi-daemon.conf."$session".backup
  fi

  echo "creating local afp.conf template, smb.conf.template for reference"

cat << EOF > afp.conf.template
[Global]
    spotlight = yes

[Homes]
    basedir regex = /home

[Test Volume]
    path = /export/test1

[My Time Machine Volume]
    path = /export/timemachine
    time machine = yes
    spotlight = no
EOF

cat << EOF > smb.conf.template
[global]
    foo = bar
    baz = qux

    ea support = Yes
    vfs objects = catia fruit streams_xattr
    fruit:locking = netatalk
    fruit:encoding = native
    streams_xattr:prefix = user.
    streams_xattr:store_stream_type = no
    mdns name = mdns

    hide files = /.DS_Store/Network Trash Folder/TheFindByContentFolder/TheVolumeSettingsFolder/Temporary Items/.TemporaryItems/.VolumeIcon.icns/Icon?/.FBCIndex/.FBCLockFolder/

    read only = No

[homes]

[Test Volume]
    path = /export/test1

[My Time Machine Volume]
    path = /export/timemachine
;   fruit:time machine = yes
EOF

  ls -alh  afp.conf.template smb.conf.template

  if [ -f /usr/local/etc/afp.conf ]; then
    echo "afp.conf located"
    cp -v /usr/local/etc/afp.conf /usr/local/etc/afp.conf."$sesson".backup
    ls -alh /usr/local/etc/afp.conf."session".backup
  fi

  if [ -f /etc/avahi/avahi-daemon.conf ]; then
    cp -v /etc/avahi/avahi-daemon.conf /etc/avahi/avahi-daemon.conf."$session".backup
    echo "update the following with respective network interfaces"
    echo "/etc/avahi/avahi-daemon.conf < allow-interfaces=eth0,wlan0"
  fi

}

start_netatalk_services () {
  if [ -f /lib/systemd/system/netatalk.service ]; then
    sudo systemctl enable avahi-daemon
    sudo systemctl enable netatalk
    # service avahi-daemon status
    sudo systemctl start avahi-daemon
    sudo systemctl start netatalk
  fi
}

install_avahi () {
  apt install -y avahi-utils mdns-scan
}

debug_avahi () {
  timeout 30s avahi-browse -arp
  # mdns-scan
}

function display_xwindows () {
 while opt=$(zenity --title="$title" --text="$prompt" --list \
                    --column="Options" "${options[@]}"); do
     case "$opt" in
     "${options[0]}" ) zenity --info --text="You picked $opt, option 1";;
     "${options[1]}" ) zenity --info --text="You picked $opt, option 2";;
     "${options[2]}" ) zenity --info --text="You picked $opt, option 3";;
     *) zenity --error --text="Invalid option. Try another one.";;
     esac
 done
}

title="Submodule Installer Netatalk-Avahi"
prompt="Select action:"
options=("Download/Install" "Configure" "Backup" "Avahi-debug")

echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do
    case "$REPLY" in

    1 ) echo "You picked $opt which is option $REPLY"
            install_prereqs
            download_netatalk
            configure_compile_netatalk
        ;;
    2 ) echo "You picked $opt which is option $REPLY"
            ls -alh /usr/local/sbin/netatalk
            install_avahi
            ls /usr/local/sbin/afpd -V
            netatalk -V
            afpd -V
        ;;
    3 ) echo "You picked $opt which is option $REPLY"
            backup_configs
        ;;
    4 ) echo "You picked $opt which is option $REPLY"
            timeout 30s avahi-browse -arp
        ;;

    $(( ${#options[@]}+1 )) ) echo "Thank you for reading this sentence."; break;;
    *) echo "Oopps, not an option. Try another one.";
       continue;;

    esac
done


