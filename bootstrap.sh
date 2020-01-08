#!/usr/bin/env bash
#--------------------------------------------------------------------------------------------------
# bootstrap
#--------------------------------------------------------------------------------------------------

# set -e
version=0.0.9

# http://www.skybert.net/bash/debugging-bash-scripts-on-the-command-line/
export PS4='# ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]}() - [${SHLVL},${BASH_SUBSHELL},$?] '

session=$(date +"%Y%m%d_%H%M_%S")
start=`date +%s`

UNAME=$( command -v uname)

apt_refresh () {
  apt-get update && apt-get install -yq curl && apt-get clean
}

prereqs=(
 avahi-utils
 bash-completion
 catimg
 curl
 dstat
 dtach
 fonts-powerline
 fortune
 fzf
 git
 gitk
 hfsprogs
 hfsutils
 htop
 iperf
 lynx
 mdns-scan
 mosh
 nano
 netatalk
 nfs-common
 nfs-server
 nmap
 nodejs
 p7zip-full
 p7zip-rar
 powerline
 rclone
 ruby
 ruby-colorize
 ruby-dev
 ruby-full
 samba
 screenfetch
 silversearcher-ag
 sshfs
 sudo
 tig
 tldr
 tmux
 wget
 zsh
)

snaps=(
 shfmt
)

gems=(
 gist
 tldr
)

nodes=(
 empty-trash-cli
 fkill
 http-server
 prettier
 speed-test
 torrent
 trash-cli
 vtop
 wifi-password
 wikit
)

function verify_installs () {
  log_warning "function: verify installs: emoty"
}

function install_prereqs () {
  for app in "${prereqs[@]}"
  do
    log_info "installing: $app"
    case $( "${UNAME}" | tr '[:upper:]' '[:lower:]') in
      linux*)
        apt install -y $app
        ;;
      darwin*)
        brew install $app & brew upgrade $app
        ;;
      *)
        ;;
    esac
  done
  apt --fix-broken install
  apt-get update -y; apt autoremove
}

function install_gems () {
  for g in "${gems[@]}"
  do
   sudo gem install $g
  done
}

function install_snaps () {
  for snap in "${snaps[@]}"
  do
   sudo snap install $snap
  done
}

function colorls_install () {
  echo '[[ "$TERM" == "xterm" ]] && export TERM=xterm-256color' >> ~/.bashrc
  echo 'export DISPLAY=:0' >> ~/.bashrc
  echo "[ -t 1 ] && exec zsh" >> ~/.bashrc

  curl -SLO http://scie.nti.st/dist/256colors2.pl
  perl 256colors2.pl

  apt install -y fortune-mod ddate toilet toilet-fonts lolcat cmatrix cowsay screenfetch
  apt update -y

  apt install -y ruby ruby-dev ruby-colorize
  apt update -y

  sudo apt install -y libncurses5-dev libtinfo-dev
  apt update -y

  sudo gem install colorls

  log_info "testing colorls"
  colorls
}

function install_nodes () {
  cd
  apt update -y

  apt-get install -y build-essential && apt update -y && apt upgrade -y
  curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
  sudo apt-get install -y gcc g++ make

  if [ command -v npm 2>/dev/null ]; then
    for node in "${nodes[@]}"
    do
      npm install -g $node
    done
  else
    log_warning "npm not found, package installer will continue"
  fi
}

function verify_log4bash () {
 if [[ ! -e ./log4bash.sh ]]; then
  echo "update remote link to github"
  wget http://pretty.pleasemarkdarkly.com:8080/jP8Nd/log4bash.sh
   cp -v log4bash.sh /bootstrap/log4bash.sh
 fi

 source ./log4bash.sh

 log "example log outputs"
 log "log output";
 log_info "log_info output";
 log_success "log_success output";
 log_warning "log_warning output";
 log_error "log_error: error";
 log "end example log outputs"
 echo
}

backup () {
  mkdir -p /backups
  sudo /bin/tar -czvf "/backups/${SESS}.`whoami`.${HOSTNAME}.tar.gz" ${HOME} /etc && pushover "bootstrap: ${SESS} backup finished"
}

function os_detect () {
 log "os_detect function called"
 case $( "${UNAME}" | tr '[:upper:]' '[:lower:]') in
   linux*)
     log_info 'linux\n'
     if [ command -v rclone 2>/dev/null & hash wget 2>/dev/null ]; then
        log_info "prerequisites rclone, wget found"
     else
        log_info "installing prerequisites"
        install_prereqs
     fi
     ;;
   darwin*)
     log_info 'darwin\n'
     if [ command -v rclone 2>/dev/null & command -v wget 2>/dev/null ]; then
        log_info "prerequisites rclone, wget found"
     else
        log_info "installing prerequisites"
        install_prereqs
     fi
     ;;
   msys*|cygwin*|mingw*)
     # or possible 'bash on windows'
     log_warning 'windows\n'
     return
     ;;
   nt|win*)
     log_warning 'windows\n'
     return
     ;;
   *)
     ;;
 esac
}

function post_private_gist () {
  [[ -z "$1" ]] && {echo "Usage: post_private_gist [filename] [description]" }
  [[ -z "$2" ]] && {echo "No description, must be really awesome code."} | echo "Missing filename and description"

  local desc='The gist script robot has added this message, for your pleasure.'

  desc=$2

  gist -f $1 \
    -d $desc \
    -s < $1
}

function post_public_gist () {
  [[ -z "$1" ]] && {echo "Usage: post_private_gist [filename] [description]."}
  [[ -z "$2" ]] && {echo "No description? Gist viewers will be disappointed."; echo "Will add default message"} | echo "Missing filename and decription"

  local desc='The gist script robot has added this message, for your pleasure.'

  gist -f $1 \
   -d $desc \
    < $1
}

function login_gist () {
  gist --login
}

gits=(
 terminal_imageviewer
)

function terminal_imageviewer () {
  if [ -d TerminalImageViewer ]; then
    return
  else
    git clone https://github.com/stefanhaustein/TerminalImageViewer.git
    cd TerminalImageViewer/src/main/cpp
    make
    sudo make install
  fi
  cd
}

function install_gits () {
  for git in "${gits[@]}"
  do
    "$git"
  done
}

curls=(
  transfersh_install
)

function transfersh_install () {
  log_warning "installing transfersh"
  log_warning "transfer also available at https://transfersh.pleasemarkdarkly.com/CaEu8/transfer.sh"
  if [[ ! -e "./transfer" ]]; then
    sudo wget https://gist.githubusercontent.com/pleasemarkdarkly/358028bc369f02dd68eca780680e0f41/raw/02a070849363fb07849b54d7af8a1f72ea446e9a/transfer.sh -O transfer && \
      sudo chmod +x transfer && \
      cp -v transfer /usr/local/bin/transfer
  fi

  if [[ ! -e chuck_norris_cowsay-files.zip ]]; then
    log_warning "loading chuck norris cowsay"
    wget http://pretty.pleasemarkdarkly.com:8080/4crFz/chuck_norris_cowsay-files.zip
  fi

  if [[ ! -e "/usr/local/bin/cht.sh" ]]; then
    log_warning "cht.sh"
    curl https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh
    chmod +x /usr/local/bin/cht.sh
  fi
}

function install_curls () {
  for curl in "${curls[@]}"
  do
    "$curl"
  done
}

function ohmyzsh_install () {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

function tmux_install () {
  if [ -f ~/.tmux/.tmux.conf ]; then
   log_warning "tmux configuration found"
   return
  fi
  if [ -e .tmux.conf.local ]; then
   log_warning "tmux.config already exists"
   return
  else
   cd
   git clone https://github.com/gpakosz/.tmux.git
   ln -s -f .tmux/.tmux.conf
   cp .tmux/.tmux.conf.local .
 fi
}

bat_install () {
  if ! command -v bat 2>/dev/null; then
   architecture=""
   case $(uname -m) in
    i386)   architecture="386" ;;
    i686)   architecture="386" ;;
    x86_64)
            architecture="amd64"
            wget https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb
            echo sudo dpkg -i bat_0.12.1_amd64.deb
            ;;
    arm)
            dpkg --print-architecture | grep -q "arm64" && architecture="arm64" || architecture="arm"
            wget https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_armhf.deb
            echo sudo dpkg -i bat_0.12.1_amd64.deb
            ;;
   esac
  fi
}

function cleanup () {
  log_warning "function: cleaned up"
  log_warning "not implemented"
}

function rclone_install () {
  if command -v rclone 2>/dev/null; then
   log_info "rclone found"
   if [[ ! -e ~/.config/rclone/rclone.conf ]]; then
     log_warning "rclone installed, rclone.conf not found"
     log_warning "possible fresh rclone install"
     mkdir -p ~/.config/rclone/
     touch ~/.config/rclone/rclone.conf
     if [[ ! -e ~/.config/rclone/rclone.conf ]]; then
       log_success "created rclone.conf"
     fi
   else
     log_info "backing up existing rclone.conf to rclone.conf.backup.${session}"
      mv -v ~/.config/rclone/rclone.conf ~/.config/rclone/rclone.conf.backup.${session}
   fi

   log_info "fetching local copy of rclone.conf called rclone.conf.local"
   wget http://pretty.pleasemarkdarkly.com:8080/Oshhv/rclone.conf

   log_warning "saving local rclone.conf.local in operating directory"
   mv -v rclone.conf rclone.conf.local
   mv -v ./rclone.conf.local ~/.config/rclone/rclone.conf
   log_success "verifying rclone listremotes"
   rclone listremotes
   return
 else
   log_error "rclone install not found"
   log_error "rclone.conf operations not performed"
   log_error "manually investigate issues"
 fi
}

function pushover_install () {
  if [[ ! -e "./pushover" ]]; then
    wget https://gist.github.com/pleasemarkdarkly/05cf0e99c39d176f15603d4a3870c67c/raw -O ./pushover
    chmod +x ./pushover
    cp -v ./pushover /usr/local/bin
    ./pushover "bootstrap installed successfully"
  fi
}

jldeen_does_dotfiles () {
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/jldeen/dotfiles/mac/configure.sh)"
}

chuck_norris () {
  if [[ ! -e "./chuck_norris.sh" ]]; then
  cat << EOF > ./chuck_norris.sh
curl -s http://api.icndb.com/jokes/random/ | python -c 'import sys, json; print "\n"+json.load(sys.stdin)["value"]["joke"]+"\n\n"'
EOF
  chmod +x ./chuck_norris.sh
  fi
}

docker_install () {
  if [[ ! -e "./docker_install.sh" ]]; then
    log_warning "docker_arm64_install"
    wget https://transfersh.pleasemarkdarkly.com/wKnih/docker_install.sh
    curl -Lo docker-functions.sh http://j.mp/docker-functions # && source docker-functions
  fi
}

netatalk_install () {
  if [[ ! -e "./network_install.sh" ]]; then
    log_warning "netatalk_install script download"
    wget https://gist.githubusercontent.com/pleasemarkdarkly/21d090cba63cff6a8377f5831d71e54d/raw/90c5db3e5a3cc8219c61d5adeee5fe2d0576a1b8/netatalk_install.sh \
      -O netatalk_install.sh; chmod +x netatalk_install.sh;
  fi
}

chtsh_install () {
  if [[ ! -e "/usr/local/bin/cht.sh" ]]; then
    sudo curl https://cht.sh/:cht.sh > ./cht.sh; sudo chmod +x ./cht.sh; sudo mv ./cht.sh /usr/local/bin/cht.sh
    if [ -f ~/.zshrc ]; then
      log_warning "cht.sh added to .zshrc"
      echo "/usr/local/bin/cht.sh" >> ~/.zshrc
    fi
    if [ -f ~/.bashrc ]; then
      log_warning "cht.sh added to .bashrc"
      echo "/usr/local/bin/cht.sh" >> ~/.bashrc
    fi
 fi
}

nano_install () {
  # if ! command -v nano 2>/dev/null; then
    cd
    this="http://bit.ly/39VJiLw"
    curl "$this" -O "./nano_install.sh"; chmod +x "./nano_install.sh"
    ./nano_install.sh
  # fi
}

git_completion_install () {
  echo ''
  echo "Now configuring git-completion..."
  GIT_VERSION=`git --version | awk '{print $3}'`
  URL="https://raw.github.com/git/git/v$GIT_VERSION/contrib/completion/git-completion.bash"
  echo ''
  echo "Downloading git-completion for git version: $GIT_VERSION..."
  if ! curl "$URL" --silent --output "$HOME/.git-completion.bash"; then
    echo "ERROR: Couldn't download completion script. Make sure you have a working internet connection." && exit 1
  fi
}

function main () {
  echo "bootstrap version: " ${VERSION}

  verify_log4bash

  apt_refresh
  os_detect
  apt_refresh

  ruby --version
  rclone_install
  tmux_install

  pushover_install

  install_nodes
  install_gems

  install_curls
  git_completion_install

  install_gits

  colorls_install
  bat_install
  docker_install
  netatalk_install
  chtsh_install

  chuck_norris

  echo jldeen_does_dotfiles

  if [[ ! -d ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi

  if [[ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
  fi

  if [[ ! -e "./package_installs.sh" ]]; then
    cd
    wget https://transfersh.pleasemarkdarkly.com/HHr4k/package_installs.sh
    chmod +x ./package_installs.sh
  fi

  echo "package_installs.sh ready, check list file prior to executing"
  sh ./package_installs.sh

  end=`date +%s`
  runtime=$((end-start))
  pushover "$session: bootstrap runtime $runtime"
}

main "[@]" | tee -a /bootstrap/bootstrap."$session".log

