# ST7789 240x240 CS Pinsiz Ekran için Derleme Talimatları

## Ekran Özellikleri
- **Boyut**: 240x240 piksel
- **Kontrolcü**: ST7789
- **CS Pin**: YOK (ucuz Çin modülü)
- **SPI Modu**: Mode 3 (CPOL=1, CPHA=1)
- **GPIO Pinleri**:
  - RST (Reset): GPIO 27
  - DC (Data/Command): GPIO 25
  - LED (Backlight): GPIO 24

## Gereksinimler
- Raspberry Pi (tüm modeller desteklenir)
- Raspberry Pi OS (Raspbian)
- CMake
- bcm_host kütüphanesi

## Kurulum Adımları

### 1. Gerekli Paketleri Yükleyin
```bash
sudo apt-get update
sudo apt-get install cmake libraspberrypi-dev
```

### 2. Projeyi İndirin
```bash
cd ~
# Projeyi buraya çıkartın
```

### 3. Build Dizini Oluşturun
```bash
cd fbcp-ili9341-master
mkdir build
cd build
```

### 4. CMake ile Yapılandırın
```bash
cmake -DCUSTOM_ST7789_240X240=ON -DSPI_BUS_CLOCK_DIVISOR=6 -DUSE_DMA_TRANSFERS=ON ..
```

**Önemli CMake Parametreleri:**
- `-DCUSTOM_ST7789_240X240=ON`: CS pinsiz ST7789 desteğini etkinleştirir
- `-DSPI_BUS_CLOCK_DIVISOR=6`: SPI hızını ayarlar (daha yüksek değer = daha yavaş, daha düşük = daha hızlı)
- `-DUSE_DMA_TRANSFERS=ON`: DMA transferlerini etkinleştirir (performans için önerilir)

**Hız Ayarlama:**
- Raspberry Pi 3B için: CDIV=6 iyi çalışır
- Eğer ekranda bozukluk görürseniz: CDIV değerini artırın (8, 10, 12, vb.)
- Daha hızlı performans için: CDIV değerini düşürün (4), ancak dikkatli olun!

### 5. Derleyin
```bash
make -j4
```

### 6. Test Edin
```bash
sudo ./fbcp-ili9341
```

## Otomatik Başlatma (Opsiyonel)

### Systemd Servisi Oluşturun
```bash
sudo cp ../fbcp-ili9341.service /etc/systemd/system/
sudo systemctl enable fbcp-ili9341.service
sudo systemctl start fbcp-ili9341.service
```

## /boot/config.txt Ayarları

HDMI çıkışını ekran çözünürlüğüne eşleştirmek için `/boot/config.txt` dosyasını düzenleyin:

```bash
sudo nano /boot/config.txt
```

Aşağıdaki satırları ekleyin:
```
# 240x240 ekran için
hdmi_group=2
hdmi_mode=87
hdmi_cvt=240 240 60 1 0 0 0
hdmi_force_hotplug=1
```

Değişiklikleri kaydedin ve yeniden başlatın:
```bash
sudo reboot
```

## Sorun Giderme

### Ekran Çalışmıyor
1. GPIO pinlerini kontrol edin (RST=22, DC=17, LED=27)
2. SPI'nın etkin olduğundan emin olun: `sudo raspi-config` → Interface Options → SPI → Enable
3. SPI hızını azaltın: Daha yüksek CDIV değeri deneyin

### Ekranda Bozukluk Var
- `-DSPI_BUS_CLOCK_DIVISOR` değerini artırın (8, 10, 12)
- Core frekansını kontrol edin: `/boot/config.txt` içinde `core_freq=400` olmalı

### Yavaş Güncelleme
- `-DSPI_BUS_CLOCK_DIVISOR` değerini azaltın (dikkatli olun!)
- DMA'nın etkin olduğundan emin olun: `-DUSE_DMA_TRANSFERS=ON`

## Gelişmiş Seçenekler

### Ekranı 180 Derece Döndürme
```bash
cmake -DCUSTOM_ST7789_240X240=ON -DDISPLAY_ROTATE_180_DEGREES=ON -DSPI_BUS_CLOCK_DIVISOR=6 ..
```

### Renkleri Ters Çevirme
```bash
cmake -DCUSTOM_ST7789_240X240=ON -DDISPLAY_INVERT_COLORS=ON -DSPI_BUS_CLOCK_DIVISOR=6 ..
```

### Arka Işık Kontrolü
```bash
cmake -DCUSTOM_ST7789_240X240=ON -DBACKLIGHT_CONTROL=ON -DSPI_BUS_CLOCK_DIVISOR=6 ..
```

## Pin Bağlantıları

| ST7789 Pin | Raspberry Pi Pin | GPIO |
|------------|------------------|------|
| VCC        | 3.3V             | -    |
| GND        | GND              | -    |
| SCL (SCK)  | GPIO 11 (SPI0 SCLK) | 11   |
| SDA (MOSI) | GPIO 10 (SPI0 MOSI) | 10   |
| RES (RST)  | GPIO 27          | 27   |
| DC         | GPIO 25          | 25   |
| BLK (LED)  | GPIO 24          | 24   |
| CS         | **BAĞLANMAZ** (bu modülde yok) | -    |

## Performans İpuçları

1. **SPI Hızı**: En iyi sonuç için `CDIV=6` ile başlayın
2. **DMA**: Mutlaka etkinleştirin (`-DUSE_DMA_TRANSFERS=ON`)
3. **HDMI Çözünürlüğü**: 240x240'a ayarlayın (pixel-perfect render için)
4. **Core Frequency**: `/boot/config.txt` içinde sabit tutun

## Lisans
Bu proje orijinal fbcp-ili9341 projesi temel alınarak geliştirilmiştir.

## Destek
Sorunlar için GitHub issues kullanın veya orijinal fbcp-ili9341 projesine bakın.
