TARGET = iphone:clang:latest:14.0
ARCHS = arm64 arm64e

THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DSSlasherCheat
DSSlasherCheat_FILES = Tweak.mm
DSSlasherCheat_CFLAGS = -fobjc-arc -std=c++17
DSSlasherCheat_LDFLAGS = -framework Foundation -framework UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
