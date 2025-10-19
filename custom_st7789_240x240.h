#pragma once

// Custom ST7789 240x240 Display without CS pin
// Cheap Chinese module with SPI Mode 3
#ifdef CUSTOM_ST7789_240X240

#if !defined(GPIO_TFT_DATA_CONTROL)
#define GPIO_TFT_DATA_CONTROL 25
#endif

#if !defined(GPIO_TFT_BACKLIGHT)
#define GPIO_TFT_BACKLIGHT 24
#endif

#if !defined(GPIO_TFT_RESET_PIN)
#define GPIO_TFT_RESET_PIN 27
#endif

// This custom ST7789 240x240 module does NOT need CS signal
// It works without chip select (CS pin-less design)
#undef DISPLAY_NEEDS_CHIP_SELECT_SIGNAL

// SPI Mode 3 (CPOL=1, CPHA=1) - required for this cheap Chinese module
#define DISPLAY_SPI_DRIVE_SETTINGS (BCM2835_SPI0_CS_CPOL | BCM2835_SPI0_CS_CPHA)

#endif
