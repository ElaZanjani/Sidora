import hashlib
import sqlite3
from datetime import datetime
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Mobil / Web bağlantı izinleri (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# SQLite Veri Tabanı İlklendirme
def init_db():
    conn = sqlite3.connect("sidora_kanit.db")
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS kanitlar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dosya_adi TEXT,
            sha256_hash TEXT,
            yukleme_tarihi TEXT
        )
    ''')
    conn.commit()
    conn.close()

init_db()

@app.get("/health")
def health_check():
    return {"status": "ok", "servis": "Sidora Güvenlik Sunucusu"}

@app.post("/upload")
async def upload_audio(file: UploadFile = File(...)):
    # Dosya içeriğini oku
    content = await file.read()
    
    # SHA-256 Hash hesapla
    sha256_hash = hashlib.sha256(content).hexdigest()
    
    # Tarih damgası al
    zaman = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Veri tabanına yaz
    conn = sqlite3.connect("sidora_kanit.db")
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO kanitlar (dosya_adi, sha256_hash, yukleme_tarihi) VALUES (?, ?, ?)",
        (file.filename, sha256_hash, zaman)
    )
    conn.commit()
    conn.close()
    
    return {
        "status": "success",
        "dosya_adi": file.filename,
        "sha256": sha256_hash,
        "tarih": zaman
    }