TARGET := iphone:clang:latest:5.1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = perceptprefs

perceptprefs_FILES = XXXRootListController.m
perceptprefs_FRAMEWORKS = UIKit
perceptprefs_PRIVATE_FRAMEWORKS = Preferences
perceptprefs_INSTALL_PATH = /Library/PreferenceBundles
perceptprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
