include theos/makefiles/common.mk

TWEAK_NAME = TTSTest
TTSTest_FILES = Tweak.xm
TTSTest_FRAMEWORKS = UIKit AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
