include theos/makefiles/common.mk

BUNDLE_NAME = auditusPrefs
auditusPrefs_FILES = auditusPrefs.x
auditusPrefs_INSTALL_PATH = /Library/PreferenceBundles
auditusPrefs_FRAMEWORKS = UIKit
auditusPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/auditusPrefs.plist$(ECHO_END)
