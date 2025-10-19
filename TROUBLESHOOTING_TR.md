# SORUN GİDERME KILAVUZU - ST7789 240x240 CS Pinsiz

Bu dokümanda CS pinsiz ST7789 240x240 ekran ile ilgili yaygın sorunlar ve çözümleri bulabilirsiniz.

## 🔴 SORUN: Ekran Hiç Tepki Vermiyor / Siyah Ekran

### Kontrol Edilecekler:

#### 1. GPIO Pin Bağlantıları
**DOĞRU PIN BAĞLANTILARI (Python driver ile aynı):**

| ST7789 | Raspberry Pi | GPIO |
|--------|--------------|------|
| VCC    | 3.3V         | -    |
| GND    | GND          | -    |
| SCL    | Pin 23       | 11 (SPI0 SCLK) |
| SDA    | Pin 19       | 10 (SPI0 MOSI) |
| RES    | Pin 13       | 27   |
| DC     | Pin 22       | 25   |
| BLK    | Pin 18       | 24   |
| CS     | Bağlanmaz    | -    |

**Komut ile kontrol:**
```bash
gpio readall
```

#### 2. SPI Etkinleştirme
SPI'nın etkin olduğundan emin olun:

```bash
sudo raspi-config
# Interface Options → SPI → Enable
```

Veya doğrudan:
```bash
sudo raspi-config nonint do_spi 0
```

Kontrol:
```bash
ls /dev/spi*
# Çıktı: /dev/spidev0.0  /dev/spidev0.1 olmalı
```

#### 3. SPI Mode 3 Kontrolü
Bu modül **mutlaka SPI Mode 3** gerektirir (CPOL=1, CPHA=1).

Doğru derleme:
```bash
cd fbcp-ili9341-master
rm -rf build
mkdir build
cd build
cmake -DCUSTOM_ST7789_240X240=ON -DSPI_BUS_CLOCK_DIVISOR=6 ..
make
```

#### 4. Güç Besleme
- **3.3V kullanın, 5V DEĞİL!**
- Zayıf güç kaynağı sorun çıkarabilir
- USB hub yerine doğrudan Pi'ye bağlayın

#### 5. Bağlantı Kalitesi
- Jumper kablolar gevşek olabilir - sıkıca bastırın
- Kısa kablolar kullanın (10-15cm ideal)
- Breadboard yerine doğrudan lehimleme tercih edin

## 🟠 SORUN: Ekranda Bozuk Görüntü / Gürültü

### Çözümler:

#### 1. SPI Hızını Azaltın
Daha yüksek CDIV değeri = daha yavaş ama daha stabil

```bash
# CDIV=8 ile deneyin (daha güvenli)
cmake -DCUSTOM_ST7789_240X240=ON -DSPI_BUS_CLOCK_DIVISOR=8 ..

# CDIV=10 ile deneyin (çok güvenli)
cmake -DCUSTOM_ST7789_240X240=ON -DSPI_BUS_CLOCK_DIVISOR=10 ..
```

**SPI Hız Tablosu (Pi 3B, 400MHz):**
| CDIV | Hız      | Durum |
|------|----------|-------|
| 4    | 100 MHz  | ❌ Çok hızlı, bozulma |
| 6    | 66.7 MHz | ⚠️ Bazı modüllerde sorun |
| 8    | 50 MHz   | ✅ Önerilen |
| 10   | 40 MHz   | ✅ Çok güvenli |
| 12   | 33.3 MHz | ✅ En güvenli ama yavaş |

#### 2. Core Frequency Sabitleme
`/boot/config.txt` dosyasına ekleyin:

```bash
sudo nano /boot/config.txt
```

Ekleyin:
```
# ST7789 için sabit core frequency
core_freq=400
core_freq_min=400
```

Yeniden başlatın:
```bash
sudo reboot
```

#### 3. Kablo Uzunluğu
- 10cm'den kısa kablolar kullanın
- Ekran ile Pi arasındaki mesafeyi azaltın

## 🟡 SORUN: Renkler Yanlış

### Çözüm 1: Renk İnversiyonu
```bash
cmake -DCUSTOM_ST7789_240X240=ON \
      -DDISPLAY_INVERT_COLORS=ON \
      -DSPI_BUS_CLOCK_DIVISOR=8 ..
```

### Çözüm 2: BGR/RGB Swap
```bash
cmake -DCUSTOM_ST7789_240X240=ON \
      -DDISPLAY_SWAP_BGR=ON \
      -DSPI_BUS_CLOCK_DIVISOR=8 ..
```

## 🟢 SORUN: Ekran 180 Derece Ters

```bash
cmake -DCUSTOM_ST7789_240X240=ON \
      -DDISPLAY_ROTATE_180_DEGREES=ON \
      -DSPI_BUS_CLOCK_DIVISOR=8 ..
```

## 🔵 SORUN: Performans Düşük / Yavaş

### Çözüm 1: DMA Etkinleştir
```bash
cmake -DCUSTOM_ST7789_240X240=ON \
      -DUSE_DMA_TRANSFERS=ON \
      -DSPI_BUS_CLOCK_DIVISOR=6 ..
```

### Çözüm 2: HDMI Çözünürlüğü Eşitle
`/boot/config.txt`:
```
hdmi_group=2
hdmi_mode=87
hdmi_cvt=240 240 60 1 0 0 0
hdmi_force_hotplug=1
```

### Çözüm 3: Overclock (Dikkatli!)
`/boot/config.txt`:
```
# Sadece Pi 3/4 için
over_voltage=2
arm_freq=1400
```

## ⚫ SORUN: "Could not open SPI device" Hatası

### Çözüm:
```bash
# SPI modülünü kontrol et
lsmod | grep spi

# SPI modülünü yükle
sudo modprobe spi_bcm2835

# /boot/config.txt kontrol
sudo nano /boot/config.txt
# Bu satır olmalı: dtparam=spi=on

# Yeniden başlat
sudo reboot
```

## 🟣 SORUN: Ekran Yanıp Sönüyor

### Çözümler:
1. **Güç kaynağı zayıf** - Daha güçlü adaptör kullanın (5V 2.5A+)
2. **SPI hızı çok yüksek** - CDIV'i artırın
3. **Kötü bağlantı** - Kabloları kontrol edin

## 🔷 SORUN: Sadece Beyaz/Renkli Ekran, Görüntü Yok

### Kontrol:
```bash
# fbcp-ili9341 çalışıyor mu?
ps aux | grep fbcp

# Manuel başlat
sudo /path/to/build/fbcp-ili9341

# Log kontrol
dmesg | grep spi
```

### Çözüm:
```bash
# Tekrar derle
cd fbcp-ili9341-master
rm -rf build
./build.sh

# Test et
cd build
sudo ./fbcp-ili9341
```

## 🔶 İLERİ SEVİYE SORUN GİDERME

### Debug Modu ile Çalıştır
```bash
# Detaylı log için
sudo ./fbcp-ili9341 -stats 2

# SPI trafiğini görüntüle
sudo cat /sys/kernel/debug/spi/spidev0.0/debug
```

### SPI Test
Python ile basit test:
```python
import spidev
spi = spidev.SpiDev()
spi.open(0, 0)
spi.mode = 3  # SPI Mode 3
spi.max_speed_hz = 40000000
spi.xfer([0x00])  # Test byte
```

### GPIO Test
```bash
# GPIO 25 (DC) test
echo 25 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio25/direction
echo 1 > /sys/class/gpio/gpio25/value
sleep 1
echo 0 > /sys/class/gpio/gpio25/value
```

## 📋 TAM TEST PROSEDÜRÜ

### 1. Temel Kontroller
```bash
# SPI etkin mi?
ls /dev/spi* && echo "SPI OK" || echo "SPI FAIL"

# GPIO pinler doğru mu?
gpio readall | grep -E "GPIO (10|11|24|25|27)"

# Güç 3.3V mi? (multimetre ile)
```

### 2. Minimal Test Derleme
```bash
cd fbcp-ili9341-master
rm -rf build
mkdir build
cd build

# En güvenli ayarlarla
cmake -DCUSTOM_ST7789_240X240=ON \
      -DSPI_BUS_CLOCK_DIVISOR=12 \
      -DUSE_DMA_TRANSFERS=OFF \
      ..
      
make
sudo ./fbcp-ili9341
```

Eğer bu çalışırsa, yavaş yavaş CDIV'i azaltın ve DMA'yı etkinleştirin.

### 3. Adım Adım Optimizasyon
```bash
# Adım 1: CDIV=10 ile test
# Adım 2: Çalışıyorsa CDIV=8
# Adım 3: Çalışıyorsa DMA=ON ekle
# Adım 4: Çalışıyorsa CDIV=6
```

## 🆘 HÂL SORUN ÇÖZÜLMÜYORSA

### Bilgi Toplama
Aşağıdaki bilgileri toplayın:

```bash
# Sistem bilgisi
cat /proc/cpuinfo | grep Model
cat /proc/cpuinfo | grep Revision

# SPI bilgisi
ls -la /dev/spi*
cat /boot/config.txt | grep spi

# GPIO durumu
gpio readall

# Kernel mesajları
dmesg | tail -50

# fbcp-ili9341 log
sudo ./fbcp-ili9341 2>&1 | tee fbcp.log
```

### Donanım Kontrolü
1. Multimetre ile VCC 3.3V ölçün
2. Multimetre ile GND bağlantısını kontrol edin
3. Farklı jumper kablolar deneyin
4. Farklı bir ekran modülü test edin
5. Başka bir Raspberry Pi ile test edin

## 📞 DESTEK

Eğer tüm bunları denediyseniz ve hâlâ çalışmıyorsa:

1. **GitHub Issues** açın
2. Yukarıdaki tüm bilgileri paylaşın
3. Ekran fotoğrafları ekleyin
4. Hangi adımları denediğinizi belirtin

## ✅ BAŞARILI KURULUM KONFİGÜRASYONLARI

### Raspberry Pi 3B+ / 4B
```bash
cmake -DCUSTOM_ST7789_240X240=ON \
      -DSPI_BUS_CLOCK_DIVISOR=6 \
      -DUSE_DMA_TRANSFERS=ON \
      ..
```

### Raspberry Pi Zero W
```bash
cmake -DCUSTOM_ST7789_240X240=ON \
      -DSPI_BUS_CLOCK_DIVISOR=10 \
      -DUSE_DMA_TRANSFERS=ON \
      -DSINGLE_CORE_BOARD=ON \
      ..
```

### Raspberry Pi 2B
```bash
cmake -DCUSTOM_ST7789_240X240=ON \
      -DSPI_BUS_CLOCK_DIVISOR=8 \
      -DUSE_DMA_TRANSFERS=ON \
      ..
```

---

**Son Güncelleme:** 2025-10-18  
**Versiyon:** 1.0  
**Katkıda Bulunanlar:** ST7789 CS Pinsiz Proje Ekibi
