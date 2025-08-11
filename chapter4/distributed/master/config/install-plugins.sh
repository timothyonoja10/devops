#!/bin/bash

set -e

plugin_dir=/var/lib/jenkins/plugins
file_owner=jenkins.jenkins

mkdir -p "$plugin_dir"

declare -A installed_plugins

installPlugin() {
  local name_version="$1"
  local force="$2"
  local name=$(echo "$name_version" | cut -d: -f1)
  local version=$(echo "$name_version" | cut -s -d: -f2)

  # Track installed to prevent reprocessing
  if [[ -n "${installed_plugins[$name]}" ]]; then
    return 0
  fi

  local plugin_file="${plugin_dir}/${name}.hpi"

  if [ -f "$plugin_file" ] && [ "$force" != "1" ]; then
    echo "Skipped: $name (already installed)"
    installed_plugins[$name]=1
    return 0
  fi

  if [ -z "$version" ]; then
    echo "Installing: $name (latest)"
    curl -fsSL -o "$plugin_file" "https://updates.jenkins-ci.org/latest/${name}.hpi"
  else
    echo "Installing: $name (version $version)"
    curl -fsSL -o "$plugin_file" "https://updates.jenkins-ci.org/download/plugins/${name}/${version}/${name}.hpi"
  fi

  installed_plugins[$name]=1
  return 0
}

# Install base plugins
while read -r plugin || [ -n "$plugin" ]; do
  plugin=$(echo "$plugin" | tr -d '\r')
  [[ -z "$plugin" || "$plugin" == \#* ]] && continue
  installPlugin "$plugin" 0
done < "/tmp/config/plugins.txt"

# Resolve dependencies
changed=1
maxloops=100

while [ "$changed" -eq 1 ]; do
  echo "Checking for missing dependencies..."
  changed=0

  if [ "$maxloops" -le 0 ]; then
    echo "Max loop count reached — exiting to avoid infinite loop (possible corrupt plugin or unmet dependency)"
    break
  fi

  ((maxloops--))

  for f in "$plugin_dir"/*.hpi; do
    deps=$(unzip -p "$f" META-INF/MANIFEST.MF 2>/dev/null \
      | tr -d '\r' \
      | sed -e ':a;N;$!ba;s/\n //g' \
      | grep -e "^Plugin-Dependencies: " \
      | awk '{ print $2 }' \
      | tr ',' '\n' \
      | awk -F ':' '{ print $1 }' \
      | tr '\n' ' ')

    for dep in $deps; do
      if [[ -z "${installed_plugins[$dep]}" ]]; then
        installPlugin "$dep" 1 && changed=1
      fi
    done
  done
done

echo "Fixing permissions..."
chown "$file_owner" "$plugin_dir" -R

echo "All plugins installed successfully."
 