export THEOS_DEVICE_IP = 192.168.40.29
export THEOS_DEVICE_PORT = 22

TARGET := iphone:clang:5.1
ARCHS = armv6 armv7

export DEBUG = 0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Percept
Percept_FILES = AICommands.mm
Percept_FRAMEWORKS = Foundation UIKit
Percept_INSTALL_PATH = /Library/AssistantExtensions

include $(THEOS_MAKE_PATH)/bundle.mk

after-stage::
	$(ECHO_NOTHING)mv $(THEOS_STAGING_DIR)/Library/AssistantExtensions/Percept.bundle $(THEOS_STAGING_DIR)/Library/AssistantExtensions/Percept.assistantExtension$(ECHO_END)
	$(ECHO_NOTHING)cp AIExtension-Info.plist $(THEOS_STAGING_DIR)/Library/AssistantExtensions/Percept.assistantExtension/Info.plist$(ECHO_END)
	$(ECHO_NOTHING)cp AIExtension-Info.plist $(THEOS_STAGING_DIR)/Library/AssistantExtensions/Percept.assistantExtension/Percept-Info.plist$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += perceptprefs
include $(THEOS_MAKE_PATH)/aggregate.mk