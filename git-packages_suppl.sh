git_suppl=(
  hello_suppl
  trash-cli_install
)

function hello_suppl() {
  echo "hello_suppl: supplemental git routines are included as functions from .suppl file"
  echo "define the function and add the function name to the git_suppl array"
}

function trash-cli_install() {
  echo "function: trash-cli installing home dir"
  sudo apt-get install -y python-setuptools
  cd
  git clone https://github.com/andreafrancia/trash-cli.git
  cd trash-cli
  sudo python setup.py install
  cd

  cat <<EOF >trash-cli_instructions
$ trash-put           #trash files and directories.
$ trash-empty         #empty the trashcan(s).
$ trash-list          #list trashed files.
$ trash-restore       #restore a trashed file.
$ trash-rm            #remove individual files from the trashcan.
EOF

  cat ./trash-cli_instructions
}

function git_suppl() {
  for func in "${git_suppl[@]}"; do
    $func
  done
}

function run_git_suppl() {
  echo "function: git_package_suppl routine called"
  git_suppl
}
