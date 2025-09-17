# backupownik

docker build -t solvro/backup:local .
docker run --rm \
  -e MINIO_ENDPOINT=https://minio.example.com \
  -e MINIO_ACCESS_KEY=xxx \
  -e MINIO_SECRET_KEY=yyy \
  -e MINIO_BUCKET=eventownik-backups \
  -e BACKUP_PATHS="/volume/public /volume/storage/temp /volume/uploads" \
  -v /host/path/public:/volume/public \
  -v /host/path/storage/temp:/volume/storage/temp \
  -v /host/path/uploads:/volume/uploads \
  solvro/backup:local

