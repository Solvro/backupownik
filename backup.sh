#!/bin/bash
set -euo pipefail

# CONFIG (env)
: "${BACKUP_PATHS:=/volume}"         # np. "/volume/public /volume/storage/temp /volume/uploads"
: "${MINIO_ENDPOINT:=}"
: "${MINIO_ACCESS_KEY:=}"
: "${MINIO_SECRET_KEY:=}"
: "${MINIO_BUCKET:=backups}"
: "${PROJECT_NAME:=backup}"
: "${STREAM_MODE:=0}"               # 0 = rsync then tar, 1 = tar stream directly
TMP_WORKDIR="/tmp/backup-work-$$"
ARCHIVE="/tmp/${PROJECT_NAME}_$(date +%F_%H-%M).tar.zst"
MC_ALIAS="minio"

cleanup() {
  rm -rf "$TMP_WORKDIR" || true
}
trap cleanup EXIT

mkdir -p "$TMP_WORKDIR"

# split BACKUP_PATHS into array
read -r -a PATHS <<< "$BACKUP_PATHS"

if [ "$STREAM_MODE" = "1" ]; then
  # stream tar -> zstd (no intermediate copy)
  tar -cf - "${PATHS[@]}" | zstd -9 -T0 -o "$ARCHIVE"
else
  # safer default: copy each path's basename into tmp dir, then tar that dir
  for SRC in "${PATHS[@]}"; do
    if [ ! -e "$SRC" ]; then
      echo "[WARN] Path does not exist, skipping: $SRC" >&2
      continue
    fi
    BASENAME=$(basename "$SRC")
    rsync -a --delete "$SRC" "$TMP_WORKDIR/$BASENAME"
  done
  tar -C "$TMP_WORKDIR" -cf - . | zstd -9 -T0 -o "$ARCHIVE"
fi

# upload using mc (MinIO Client)
if [ -z "$MINIO_ENDPOINT" ] || [ -z "$MINIO_ACCESS_KEY" ] || [ -z "$MINIO_SECRET_KEY" ]; then
  echo "[ERROR] Missing MINIO_* env vars; archive created at: $ARCHIVE" >&2
  exit 1
fi

# configure mc and upload
mc alias set "$MC_ALIAS" "$MINIO_ENDPOINT" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" --api S3v4
mc cp "$ARCHIVE" "$MC_ALIAS/$MINIO_BUCKET/"

# optional: remove local archive after upload
rm -f "$ARCHIVE"

