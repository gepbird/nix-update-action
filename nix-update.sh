#!/usr/bin/env bash
set -euo pipefail

enterFlakeFolder() {
  if [[ -n "$PATH_TO_FLAKE_DIR" ]]; then
    cd "$PATH_TO_FLAKE_DIR"
  fi
}

sanitizeInputs() {
  # remove all whitespace
  PACKAGES="${PACKAGES// /}"
  BLACKLIST="${BLACKLIST// /}"
}

determinePackages() {
  # determine packages to update
  if [[ -z "$PACKAGES" ]]; then
    PACKAGES=$(nix flake show --json | jq -r '[.packages[] | keys[]] | sort | unique |  join(",")')
  fi
}

checkFlakeNeeded() {
  # --flake is required when the repo lacks maintainers/scripts/update.nix
  if [[ ! -f "maintainers/scripts/update.nix" ]]; then
    FLAKE_FLAG="--flake"
  else
    FLAKE_FLAG=""
  fi
}

updatePackages() {
  # update packages
  for PACKAGE in ${PACKAGES//,/ }; do
    if [[ ",$BLACKLIST," == *",$PACKAGE,"* ]]; then
      echo "Package '$PACKAGE' is blacklisted, skipping."
      continue
    fi
    echo "Updating package '$PACKAGE'."
    nix-update --commit --use-update-script $FLAKE_FLAG "$PACKAGE" 1>/dev/null
  done
}

enterFlakeFolder
sanitizeInputs
checkFlakeNeeded
determinePackages
updatePackages
