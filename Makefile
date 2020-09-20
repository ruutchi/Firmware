CC					?= cc
STRIP				?= strip
FAKEROOT			?= fakeroot
LDID				?= ldid

DESTDIR				?= out

FIRMWARE_MAINTAINER	?= Zebra Team

TARGET_PLATFORM		?= iphoneos
TARGET_VERSION		?= 11.0
TARGET_ARCH			?= arm64
TARGET_SYSROOT		?= $(shell xcrun --sdk $(TARGET_PLATFORM) --show-sdk-path)

ifeq (,$(findstring -arch ,$(CFLAGS)))
	CFLAGS			+= -arch $(TARGET_ARCH)
endif

ifeq (,$(findstring -isysroot ,$(CFLAGS)))
	CFLAGS			+= -isysroot $(TARGET_SYSROOT)
endif

CFLAGS				+= -m$(TARGET_PLATFORM)-version-min=$(TARGET_VERSION)


all:: main.m Firmware.m DeviceInfo.m
	$(CC) $(CFLAGS) -fobjc-arc -DMAINTAINER='@"$(FIRMWARE_MAINTAINER)"' main.m Firmware.m DeviceInfo.m -o firmware -I. -framework Foundation -O3
	$(STRIP) firmware

install::
	mkdir -p $(DESTDIR)
	cp firmware $(DESTDIR)
	$(LDID) -Sentitlements.plist $(DESTDIR)/firmware
	$(FAKEROOT) chmod 755 $(DESTDIR)/firmware

clean::
	rm -rf firmware out