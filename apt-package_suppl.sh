apt_suppl=(
  hello_suppl
  ssh_config
)

function hello_suppl() {
  echo "hello_suppl: supplemental apt routines are included as functions from _suppl file"
  echo "define the function and add the function name to the apt_suppl array to be run"
}

function ssh_config() {
  sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
}

function apt_suppl() {
  for func in "$apt_suppl[@]}"; do
    $func
  done
}

function run_apt_suppl() {
  echo "function: ap_package_suppl routine called"
  apt_suppl
}
