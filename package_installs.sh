#!/usr/bin/env bash

section=" "

echo_break() {
  echo
  echo "#------------------------------------------------------------------------------"
  echo "#"
  echo "# $section"
  echo "#"
  echo "# ------------------------------------------------------------------------------"
  echo
}

package_installer() {
  section="2nd Stage Bulk Package Installer"
  echo_break

  cd
  wget https://transfersh.pleasemarkdarkly.com/kPAKp/packages.tar.gz
  tar -xvf ./packages.tar.gz

  section="Package installing: APT"
  echo_break

  if [ -e "./apt-packages.list" ]; then
    echo "reading apt-packages entries"
    IFS=$'\n' read -d '' -r -a lines <"./apt-packages.list"
    for apt in "${lines[@]}"; do
      echo "installing: $apt"
      sudo apt-get install -y "${apt}"
    done
    source ./apt-packages_suppl.sh
    run_apt_suppl
    apt --fix-broken install
    apt-get update -y
    apt autoremove
  else
    echo "missing apt-packages.list"
  fi

  section="Package installing: GIT"
  echo_break

  if [[ ! -d "developer" ]]; then
    mkdir -p "developer"
  fi

  cp -v ./git-packages.list ./developer
  cp -v ./git-packages.suppl ./developer
  cp -v ./npm-packages.list ./developer
  cp -v ./gem-packages.list ./developer

  cd "developer"
  ls -al developer

  if [ -e "./git-packages.list" ]; then
    echo "reading git-package entries"
    IFS=$'\n' read -d '' -r -a lines <"./git-packages.list"
    for git in "${lines[@]}"; do
      echo git clone "${git}"
    done
    source ./git-packages_suppl.sh
    run_git_suppl
  else
    echo "missing git-packages.list"
  fi

  section="Package installing: NPM"
  echo_break

  echo "rerun nodejs install for npm"
  apt install -y nodejs

  if [ -e "./npm-packages.list" ]; then
    echo "reading npm-package entries"
    IFS=$'\n' read -d '' -r -a lines <"./npm-packages.list"
    for npm in "${lines[@]}"; do
      npm install -g "${npm}"
    done
  else
    echo "missing npm-packages.list"
  fi

  section="Package installing: GEM"
  echo_break

  if [ -e "./gem-packages.list" ]; then
    echo "reading gem-package entries"
    IFS=$'\n' read -d '' -r -a lines <"./gem-packages.list"
    for gem in "${lines[@]}"; do
      sudo gem install "${gem}"
    done
  else
    echo "no gem-packages.list"
  fi

  echo "return to base directory"
  cd
}

package_installer "[@]"
