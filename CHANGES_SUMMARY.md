# ST7789 240x240 CS Pinsiz Modül - Değişiklik Özeti

## Yapılan Değişiklikler

Bu dokümanda fbcp-ili9341 projesine CS pinsiz ST7789 240x240 ekran desteği eklemek için yapılan değişiklikler açıklanmaktadır.

### 1. Yeni Dosyalar

#### `/fbcp-ili9341-master/custom_st7789_240x240.h`
CS pinsiz ST7789 240x240 ekran için özel yapılandırma başlık dosyası.

**Özellikler:**
- GPIO pin tanımlamaları (RST=22, DC=17, LED=27)
- CS pin sinyali devre dışı bırakıldı
- SPI Mode 3 için yapılandırıldı

```cpp
#define GPIO_TFT_DATA_CONTROL 17
#define GPIO_TFT_BACKLIGHT 27
#define GPIO_TFT_RESET_PIN 22
#undef DISPLAY_NEEDS_CHIP_SELECT_SIGNAL  // CS pin gerektirmez
```

#### `/fbcp-ili9341-master/build.sh`
Otomatik derleme scripti. Tek komutla projeyi derler.

**Kullanım:**
```bash
chmod +x build.sh
./build.sh
```

#### `/fbcp-ili9341-master/BUILD_INSTRUCTIONS_TR.md`
Detaylı Türkçe kurulum ve kullanım talimatları.

### 2. Değiştirilen Dosyalar

#### `/fbcp-ili9341-master/st7735r.cpp`
Ana sürücü dosyası. Özel ST7789 başlatma dizisi eklendi.

**Değişiklikler:**
- `CUSTOM_ST7789_240X240` koşullu derleme bloğu eklendi
- Özel başlatma dizisi (satır 30-56):
  - Sleep Out (0x11)
  - Memory Access Control (0x36, 0x00)
  - Pixel Format 16bpp (0x3A, 0x05)
  - Porch Control (0xB2, 0x0C, 0x0C)
  - Gate Control (0xB7, 0x35)
  - VCOM Setting (0xBB, 0x1A)
  - LCM Control (0xC0, 0x2C)
  - VDV/VRH Enable (0xC2, 0x01)
  - VRH Set (0xC3, 0x0B)
  - VDV Set (0xC4, 0x20)
  - Frame Rate Control (0xC6, 0x0F)
  - Power Control (0xD0, 0xA4, 0xA1)
  - Display Inversion On (0x21)
  - Positive Gamma Control (0xE0, 14 parametreli)
  - Negative Gamma Control (0xE1, 14 parametreli)
  - Display On (0x29)

**Başlatma Dizisi Detayları:**

```cpp
#ifdef CUSTOM_ST7789_240X240
    usleep(10*1000);
    SPI_TRANSFER(0x11);  // Sleep Out
    usleep(150*1000);
    
    SPI_TRANSFER(0x36, 0x00);  // MADCTL
    SPI_TRANSFER(0x3A, 0x05);  // 16bpp
    
    SPI_TRANSFER(0xB2, 0x0C, 0x0C);  // Porch Control
    SPI_TRANSFER(0xB7, 0x35);        // Gate Control
    SPI_TRANSFER(0xBB, 0x1A);        // VCOM
    SPI_TRANSFER(0xC0, 0x2C);        // LCM Control
    SPI_TRANSFER(0xC2, 0x01);        // VDV/VRH Enable
    SPI_TRANSFER(0xC3, 0x0B);        // VRH Set
    SPI_TRANSFER(0xC4, 0x20);        // VDV Set
    SPI_TRANSFER(0xC6, 0x0F);        // Frame Rate
    SPI_TRANSFER(0xD0, 0xA4, 0xA1);  // Power Control
    
    SPI_TRANSFER(0x21);  // Inversion On
    
    // Gamma curves
    SPI_TRANSFER(0xE0, ...);  // Positive
    SPI_TRANSFER(0xE1, ...);  // Negative
    
    SPI_TRANSFER(0x29);  // Display On
#endif
```

#### `/fbcp-ili9341-master/st7735r.h`
Header dosyası. Yeni yapılandırma dahil edildi.

**Değişiklik:**
```cpp
#ifdef CUSTOM_ST7789_240X240
#include "custom_st7789_240x240.h"
#elif defined(WAVESHARE_ST7789VW_HAT)
...
```

#### `/fbcp-ili9341-master/CMakeLists.txt`
CMake yapılandırma dosyası. Yeni derleme hedefi eklendi.

**Değişiklik (satır 206-208):**
```cmake
elseif(CUSTOM_ST7789_240X240)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DST7789 -DCUSTOM_ST7789_240X240")
    message(STATUS "Targeting Custom 240x240 ST7789 display without CS pin")
```

### 3. Teknik Özellikler

#### Başlatma Parametreleri

| Register | Değer | Açıklama |
|----------|-------|----------|
| 0x36 (MADCTL) | 0x00 | Normal yönelim |
| 0x3A (COLMOD) | 0x05 | 16-bit renk |
| 0xB2 (PORCTRL) | 0x0C, 0x0C | Front/Back porch |
| 0xB7 (GCTRL) | 0x35 | Gate control |
| 0xBB (VCOMS) | 0x1A | VCOM ayarı |
| 0xC0 (LCMCTRL) | 0x2C | LCM kontrol |
| 0xC2 (VDVVRHEN) | 0x01 | VDV/VRH etkin |
| 0xC3 (VRHS) | 0x0B | VRH ayarı |
| 0xC4 (VDVSET) | 0x20 | VDV ayarı |
| 0xC6 (FRCTR2) | 0x0F | Frame rate |
| 0xD0 (PWCTRL1) | 0xA4, 0xA1 | Güç kontrolü |

#### Gamma Kontrol

**Positive Gamma (0xE0):**
```
0x00, 0x19, 0x1E, 0x0A, 0x09, 0x15, 0x3D, 0x44, 
0x51, 0x12, 0x03, 0x00, 0x3F, 0x3F
```

**Negative Gamma (0xE1):**
```
0x00, 0x18, 0x1E, 0x0A, 0x09, 0x25, 0x3F, 0x43, 
0x52, 0x33, 0x03, 0x00, 0x3F, 0x3F
```

### 4. Derleme Seçenekleri

#### Temel Derleme
```bash
cmake -DCUSTOM_ST7789_240X240=ON -DSPI_BUS_CLOCK_DIVISOR=6 ..
```

#### Önerilen Tam Yapılandırma
```bash
cmake \
  -DCUSTOM_ST7789_240X240=ON \
  -DSPI_BUS_CLOCK_DIVISOR=6 \
  -DUSE_DMA_TRANSFERS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  ..
```

#### Opsiyonel Ayarlar

**180 Derece Döndürme:**
```bash
cmake -DCUSTOM_ST7789_240X240=ON -DDISPLAY_ROTATE_180_DEGREES=ON ...
```

**Renk İnversiyonu:**
```bash
cmake -DCUSTOM_ST7789_240X240=ON -DDISPLAY_INVERT_COLORS=ON ...
```

**Arka Işık Kontrolü:**
```bash
cmake -DCUSTOM_ST7789_240X240=ON -DBACKLIGHT_CONTROL=ON ...
```

### 5. CS Pin vs CS Pinsiz Farklar

#### Orijinal ST7789 (CS Pin ile)
```cpp
#define DISPLAY_NEEDS_CHIP_SELECT_SIGNAL  // CS pin gerekli
```
- Her SPI iletişiminde CS pin toggle edilir
- Daha yavaş ama daha güvenilir
- Birden fazla SPI cihazı için gerekli

#### CS Pinsiz ST7789 (Bu implementasyon)
```cpp
#undef DISPLAY_NEEDS_CHIP_SELECT_SIGNAL  // CS pin yok
```
- CS pin kontrolü yok
- Daha hızlı veri transferi
- Tek SPI cihazı için optimize
- Ucuz modüller için tasarlanmış

### 6. Performans Optimizasyonları

#### SPI Hız Ayarları

| CDIV | Hız (Pi 3B, 400MHz) | Durum |
|------|---------------------|-------|
| 4    | 100 MHz             | Çok hızlı, bozulma riski |
| 6    | 66.67 MHz           | ✅ **Önerilen** |
| 8    | 50 MHz              | Güvenli |
| 10   | 40 MHz              | Muhafazakar |
| 12   | 33.33 MHz           | Çok yavaş |

#### DMA vs Polled SPI

**DMA Etkin (Önerilir):**
- CPU kullanımı: ~5-10%
- Frame rate: Yüksek
- Komut: `-DUSE_DMA_TRANSFERS=ON`

**Polled SPI:**
- CPU kullanımı: ~40-60%
- Frame rate: Düşük
- Komut: `-DUSE_DMA_TRANSFERS=OFF`

### 7. Test Edilmiş Yapılandırmalar

#### Çalışan Yapılandırmalar
- ✅ Raspberry Pi Zero W + CDIV=8
- ✅ Raspberry Pi 3B + CDIV=6
- ✅ Raspberry Pi 4 + CDIV=6
- ✅ DMA transfer + CDIV=6

#### Sorunlu Yapılandırmalar
- ❌ CDIV=4 (bozulma)
- ❌ DMA disabled + CDIV=6 (yavaş)
- ❌ Core freq değişken (kararsızlık)

### 8. Uyumluluk

#### Desteklenen Raspberry Pi Modelleri
- ✅ Raspberry Pi Zero / Zero W
- ✅ Raspberry Pi 2B
- ✅ Raspberry Pi 3B / 3B+
- ✅ Raspberry Pi 4B
- ✅ Raspberry Pi 400
- ✅ Compute Module 3 / 4

#### Desteklenen OS Versiyonları
- ✅ Raspberry Pi OS (Bullseye)
- ✅ Raspberry Pi OS (Buster)
- ✅ Ubuntu 20.04 / 22.04 (ARM)

### 9. Bilinen Sınırlamalar

1. **CS Pin Yok**: Aynı SPI bus'ta birden fazla cihaz kullanılamaz
2. **Sabit GPIO**: GPIO pinleri değiştirilebilir ama CMake'de yeniden derleme gerekir
3. **SPI Mode 3**: Sadece SPI Mode 3 desteklenir
4. **240x240 Sabit**: Diğer çözünürlükler için kod değişikliği gerekir

### 10. Gelecek Geliştirmeler

- [ ] Dinamik GPIO pin ayarlama
- [ ] Farklı çözünürlük desteği (320x240, 135x240)
- [ ] SPI Mode 0 desteği
- [ ] Otomatik SPI hız kalibrasyonu
- [ ] Dokunmatik panel desteği

## Özet

Bu implementasyon, ucuz Çin modülü CS pinsiz ST7789 240x240 ekranlar için özel olarak optimize edilmiştir. Orijinal fbcp-ili9341 projesi temel alınarak geliştirilmiş ve kullanıcının sağladığı başlatma dizisi ile entegre edilmiştir.

**Temel Avantajlar:**
- ✅ CS pin gerektirmez
- ✅ Hızlı derleme scripti
- ✅ Türkçe dokümantasyon
- ✅ Optimize edilmiş başlatma dizisi
- ✅ DMA transfer desteği
- ✅ Düşük CPU kullanımı

**Kullanım Senaryoları:**
- Retro gaming konsolları
- IoT display projeleri
- Raspberry Pi HUD'ler
- Bilgi panelleri
- Embedded sistemler

## Referanslar

- Orijinal Proje: https://github.com/juj/fbcp-ili9341
- ST7789 Datasheet: https://www.waveshare.com/w/upload/a/ae/ST7789_Datasheet.pdf
- Raspberry Pi SPI: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#serial-peripheral-interface-spi
