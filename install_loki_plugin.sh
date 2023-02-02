# A script to install loki docker driver
#  - https://grafana.com/docs/loki/latest/clients/docker-driver/

set -eu pipefail # fail on error , debug all lines

get_distribution() {
    lsb_dist=""
    # Every system that we officially support has /etc/os-release
    if [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
    fi
    # Returning an empty string here should be alright since the
    # case statements don't act unless you provide an actual value
    echo "$lsb_dist"
}

# Install the plugin
if [[ $(docker plugin ls) == *"loki"* ]]; then
  echo "Loki plugin already installed"
else
  echo "Running install plugin command"
  # perform some very rudimentary platform detection
  lsb_dist=$(get_distribution)
  lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
  case "$lsb_dist" in
      ol)
          # See https://github.com/grafana/loki/issues/974 for installation on ARM devices
          # Install go on Oracle Linux: sudo dnf install go-toolset
          # The command 'dockerd' helpful in debugging
          docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions # Let it fil with Error response from daemon: dial unix...
          working_directory=$(pwd)
          git clone https://github.com/grafana/loki ~ && cd ~/loki
          sudo dnf install go-toolset -y
          GOOS=linux GOARCH=arm GOARM=7 go build ./clients/cmd/docker-driver
          cp docker-driver /var/lib/docker/plugins/*/rootfs/bin
          cd $working_directory
      ;;
      *)
          docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
      ;;
  esac
  docker plugin enable loki
fi

# Check the plugin was installed
if [[ $(docker plugin ls) == *"loki"* ]]; then
  echo "✅ Plugin was installed successfully"
else
  echo "🔴 Loki plugin not installed successfully. Please try to make sure the following command succeeds:"
  echo "docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions"
  echo "and the plugin is visible in the output of the command `docker plugin ls`."
  exit 1
fi


FILE="/etc/docker/daemon.json"
if [ ! -e "$FILE" ] ; then  # If file does not exist, create it
  mkdir -p -- "${FILE%/*}"
  touch "$FILE"
fi
/bin/cat <<EOM >$FILE
{
    "log-driver": "loki",
    "log-opts": {
        "loki-url": "http://localhost:3100/loki/api/v1/push",
        "mode": "non-blocking",
        "loki-batch-size": "400",
        "max-size": "1g" 
    }
}
EOM

# Recreate all containers to reload the new configuration
sudo systemctl restart docker
# docker-compose up -d --force-recreate