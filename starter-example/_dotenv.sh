dotenv() {
  #local file=$([ -z "$1" ] && echo ".env" || echo ".env.$1")
  local file=$([ -z "$1" ] && echo "bash.env")

  if [ -f $file ]; then
    set -a
    source $file
    set +a
  else
    echo "No $file file found" 1>&2
    return 1
  fi
}

#dotenv
#env
