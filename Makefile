include theos/makefiles/common.mk

TWEAK_NAME = Auditus
Auditus_FILES = Tweak.xm
Auditus_FRAMEWORKS = UIKit AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
