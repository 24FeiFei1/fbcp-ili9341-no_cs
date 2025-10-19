#!/bin/bash

# ST7789 240x240 CS Pinsiz Ekran - Hızlı Derleme Scripti
# Kullanım: ./build.sh

echo "ST7789 240x240 (CS pinsiz) için fbcp-ili9341 derleniyor..."
echo "GPIO Pinleri: RST=27, DC=25, LED=24"
echo ""

# Build dizini oluştur
mkdir -p build
cd build

# CMake ile yapılandır
echo "CMake yapılandırması yapılıyor..."
cmake -DCUSTOM_ST7789_240X240=ON \
      -DSPI_BUS_CLOCK_DIVISOR=6 \
      -DUSE_DMA_TRANSFERS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      ..

# Derleme başarılı mı kontrol et
if [ $? -ne 0 ]; then
    echo "HATA: CMake yapılandırması başarısız!"
    exit 1
fi

# Derle
echo ""
echo "Derleme yapılıyor..."
make -j4

# Derleme başarılı mı kontrol et
if [ $? -ne 0 ]; then
    echo "HATA: Derleme başarısız!"
    exit 1
fi

echo ""
echo "================================================"
echo "✓ Derleme başarılı!"
echo "================================================"
echo ""
echo "Çalıştırmak için:"
echo "  cd build"
echo "  sudo ./fbcp-ili9341"
echo ""
echo "Otomatik başlatma için:"
echo "  sudo cp ../fbcp-ili9341.service /etc/systemd/system/"
echo "  sudo systemctl enable fbcp-ili9341.service"
echo "  sudo systemctl start fbcp-ili9341.service"
echo ""
