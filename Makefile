FW_DEVICE_IP=192.168.11.5

include theos/makefiles/common.mk

TWEAK_NAME = SBPowerOption
SBPowerOption_FILES = Tweak.xm
SBPowerOption_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp SBPowerOptionSettings.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SBPowerOption.plist $(ECHO_END)
	$(ECHO_NOTHING)cp respring@3x.png $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SBPowerOption@3x.png $(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"
