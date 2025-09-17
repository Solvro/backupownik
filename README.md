# 🗃️ Backupownik

Uniwersalny kontener Docker do wykonywania backupów wybranych katalogów z dowolnego projektu i wysyłania ich do serwera **S3/MinIO** w formacie `.tar.zst`.

---

## ✨ Funkcje
- **Uniwersalny obraz** – działa z dowolnym projektem i wolumenem Dockera.  
- **Precyzyjny wybór ścieżek** – podajesz dokładnie, które katalogi mają trafić do archiwum.  
- **Kompresja Zstandard** – szybkie i wydajne `.tar.zst`.  
- **Upload do S3/MinIO** – wykorzystuje [MinIO Client (`mc`)](https://min.io/docs/minio/linux/reference/minio-mc.html).  
- Obsługa harmonogramu zewnętrznego (np. **Coolify Jobs** / Cron).

---

## 🚀 Szybki start

### 1️⃣ Build & Run lokalnie
```bash
# Zbuduj obraz
docker build -t solvro/backupownik:local .

# Uruchom jednorazowy backup
docker run --rm \
  -e MINIO_ENDPOINT=https://backup.example.com \
  -e MINIO_ACCESS_KEY=your_key \
  -e MINIO_SECRET_KEY=your_secret \
  -e MINIO_BUCKET=myproject-backups \
  -e BACKUP_PATHS="/volume/public /volume/storage/temp /volume/uploads" \
  -v myproject_data:/volume \
  solvro/backupownik:local

