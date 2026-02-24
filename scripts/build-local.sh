#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/build-local.sh [TARGET]

Builds a Fuseki Docker image locally using docker buildx bake.

Arguments:
  TARGET    Optional bake target or group to build (default: fuseki-6-0-0).
            You may pass version formats like 6.0.0 or fuseki-6.0.0; they will
            be normalized automatically.

Environment variables:
  PLATFORM  Override the target platform(s) for the build (default: linux/amd64).
            Use a comma separated list to test multiple platforms.
  OUTPUT    Set to 'load' (default) to load the image into Docker, or 'push' to
            push to the registry configured in docker-bake.hcl.

Examples:
  scripts/build-local.sh
  scripts/build-local.sh 5.5.0
  OUTPUT=push PLATFORM=linux/amd64,linux/arm64 scripts/build-local.sh fuseki-6.0.0

EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

normalize_target() {
  local value="${1}"
  if [[ -z "${value}" ]]; then
    echo "fuseki-6-0-0"
    return
  fi

  value="${value//./-}"

  case "${value}" in
    fuseki-*)
      echo "${value}"
      ;;
    *)
      echo "fuseki-${value}"
      ;;
  esac
}

RAW_TARGET="${1:-fuseki-6-0-0}"
TARGET="$(normalize_target "${RAW_TARGET}")"
PLATFORM="${PLATFORM:-linux/amd64}"
OUTPUT="${OUTPUT:-load}"

case "${OUTPUT}" in
  load)
    OUTPUT_ARGS=(--load)
    ;;
  push)
    OUTPUT_ARGS=(--push)
    ;;
  *)
    echo "Unsupported OUTPUT value: ${OUTPUT}" >&2
    exit 1
    ;;
esac

if [[ "${OUTPUT}" == "load" && "${PLATFORM}" == *","* ]]; then
  echo "Multiple platforms require OUTPUT=push or a custom Buildx output. Refusing to continue." >&2
  exit 1
fi

if ! docker buildx inspect >/dev/null 2>&1; then
  docker buildx create --name fuseki-local --use >/dev/null
fi

docker buildx inspect --bootstrap >/dev/null

SET_ARGS=()
if [[ -n "${PLATFORM}" ]]; then
  SET_ARGS+=(--set)
  SET_ARGS+=("*.platform=${PLATFORM}")
fi

docker buildx bake \
  --file docker-bake.hcl \
  "${TARGET}" \
  "${SET_ARGS[@]}" \
  "${OUTPUT_ARGS[@]}"

case "${OUTPUT}" in
  load)
    echo "Build finished. The image is now available in your local Docker image store."
    ;;
  push)
    echo "Build finished. The image has been pushed using the configuration in docker-bake.hcl."
    ;;
esac
