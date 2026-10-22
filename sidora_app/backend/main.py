import os
import hashlib
import sqlite3
from datetime import datetime
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def init_db():
    conn = sqlite3.connect("sidora_kanit.db")
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS kanitlar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dosya_adi TEXT,
            sha256_hash TEXT,
            onceki_hash TEXT,
            zincir_hash TEXT,
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
    content = await file.read()
    
    # 1. Dosyanın SHA-256 hash'ini hesapla
    dosya_hash = hashlib.sha256(content).hexdigest()
    
    # 2. Fiziksel olarak 'uploads' klasörüne kaydet
    os.makedirs("uploads", exist_ok=True)
    uzanti = os.path.splitext(os.path.basename(file.filename or ""))[1]
    if not uzanti:
        uzanti = ".m4a"
    with open(os.path.join("uploads", dosya_hash + uzanti), "wb") as f:
        f.write(content)
    
    # 3. Önceki zincir hash'ini çek
    conn = sqlite3.connect("sidora_kanit.db")
    cursor = conn.cursor()
    cursor.execute("SELECT zincir_hash FROM kanitlar ORDER BY id DESC LIMIT 1")
    son_kayit = cursor.fetchone()
    
    onceki_hash = son_kayit[0] if son_kayit else "GENESIS_BLOCK_SIDORA_00000000000000000000000000000000"
    
    # 4. Yeni zincir hash'i oluştur
    birlesik = f"{onceki_hash}{dosya_hash}"
    zincir_hash = hashlib.sha256(birlesik.encode('utf-8')).hexdigest()
    zaman = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # 5. Veritabanına kaydet
    cursor.execute(
        "INSERT INTO kanitlar (dosya_adi, sha256_hash, onceki_hash, zincir_hash, yukleme_tarihi) VALUES (?, ?, ?, ?, ?)",
        (file.filename, dosya_hash, onceki_hash, zincir_hash, zaman)
    )
    conn.commit()
    conn.close()
    
    return {
        "status": "success",
        "dosya_adi": file.filename,
        "dosya_hash": dosya_hash,
        "zincir_hash": zincir_hash,
        "tarih": zaman
    }

@app.get("/events")
def get_events():
    conn = sqlite3.connect("sidora_kanit.db")
    cursor = conn.cursor()
    cursor.execute("SELECT id, dosya_adi, sha256_hash, zincir_hash, yukleme_tarihi FROM kanitlar ORDER BY id DESC")
    rows = cursor.fetchall()
    conn.close()
    
    olaylar = []
    for r in rows:
        olaylar.append({
            "id": r[0],
            "dosya_adi": r[1],
            "sha256": r[2],
            "zincir_hash": r[3],
            "tarih": r[4]
        })
    return {"toplam_olay": len(olaylar), "olaylar": olaylar}

# Adli Hash Zinciri Sağlamlık Doğrulama Uç Noktası
@app.get("/verify")
def verify_chain():
    conn = sqlite3.connect("sidora_kanit.db")
    rows = conn.execute(
        "SELECT id, sha256_hash, onceki_hash, zincir_hash FROM kanitlar ORDER BY id ASC"
    ).fetchall()
    conn.close()
    
    onceki = "GENESIS_BLOCK_SIDORA_00000000000000000000000000000000"
    for id_, dosya_hash, kayitli_onceki, kayitli_zincir in rows:
        beklenen = hashlib.sha256(f"{onceki}{dosya_hash}".encode("utf-8")).hexdigest()
        if kayitli_onceki != onceki or kayitli_zincir != beklenen:
            return {"gecerli": False, "bozulan_id": id_}
        onceki = kayitli_zincir
        
    return {"gecerli": True, "toplam": len(rows)}