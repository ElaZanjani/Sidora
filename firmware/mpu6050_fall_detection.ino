#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

Adafruit_MPU6050 mpu;

// Eşik Değerleri (Thresholds)
const float SERBEST_DUSUS_ESIK = 0.4;  // g biriminde (A < 0.4g)
const float CARPMA_ESIK = 2.5;         // g biriminde (A > 2.5g)

bool serbestDususAlgilandi = false;
unsigned long dususZamani = 0;

void setup() {
  Serial.begin(115200);
  
  // ESP32-S3 I2C Pin Konfigürasyonu (SDA, SCL)
  Wire.begin(8, 9); 

  if (!mpu.begin()) {
    Serial.println("MPU6050 sensörü bulunamadı!");
    while (1) { delay(10); }
  }

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  Serial.println("Sidora MPU6050 Düşme Algılama Modülü Aktif.");
}

void loop() {
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  // m/s^2 cinsinden gelen ivmeyi 'g' birimine çevir (1g = 9.80665 m/s^2)
  float ax = a.acceleration.x / 9.80665;
  float ay = a.acceleration.y / 9.80665;
  float az = a.acceleration.z / 9.80665;

  // Vektörel Toplam İvme Büyüklüğü
  float toplamIvme = sqrt(ax * ax + ay * ay + az * az);

  // 1. Aşaması: Serbest Düşüş Tespiti
  if (toplamIvme < SERBEST_DUSUS_ESIK && !serbestDususAlgilandi) {
    serbestDususAlgilandi = true;
    dususZamani = millis();
    Serial.println("[UYARI] Serbest Düşme İvmesi Algılandı!");
  }

  // 2. Aşaması: Çarpma Tespiti (Serbest düşüşten sonraki 1 saniye içinde)
  if (serbestDususAlgilandi) {
    if (millis() - dususZamani < 1000) {
      if (toplamIvme > CARPMA_ESIK) {
        Serial.println("[CRITICAL] DÜŞME VE ÇARPMA TESPİT EDİLDİ! ALARM TETİKLENİYOR...");
        
        // Burada BLE/Wi-Fi üzerinden mobil uygulamaya SOS sinyali gönderilir
        serbestDususAlgilandi = false; 
      }
    } else {
      // 1 saniye içinde çarpma olmadıysa yanlış alarmı sıfırla
      serbestDususAlgilandi = false;
    }
  }

  delay(20); // 50 Hz Örnekleme Frekansı
}