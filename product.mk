EXTRA_PATH := vendor/extra

# ADB
ifneq (,$(wildcard $(EXTRA_PATH)/adbkey.pub))
PRODUCT_ADB_KEYS := $(EXTRA_PATH)/adbkey.pub
PRODUCT_COPY_FILES += $(PRODUCT_ADB_KEYS):$(TARGET_COPY_OUT_RECOVERY)/root/$(TARGET_COPY_OUT_PRODUCT)/etc/security/adb_keys
endif

# Droid-ify zamiast F-Droida (decyzja 21.09: F-Droid ciężki i toporny; Droid-ify nie ma Privileged Extension
# ani INSTALL_PACKAGES — cicha instalacja tylko przez root KSU-Next). Repozytoria IzzyOnDroid/NewPipe/IronFox
# nadal przez XML: Tomoms kopiuje vendor/lineage/prebuilt/common/etc/additional_fdroid_repos.xml do
# /system/etc/org.fdroid.fdroid/additional_repos.xml (vendor/lineage/config/common.mk) — przepis nadpisuje ten
# plik naszym fdroid/additional_repos.xml; Droid-ify (OemRepositoryParser) czyta dokładnie tę samą ścieżkę
# i ten sam format, więc zero zmian w samym pliku repozytoriów.
ifneq (,$(wildcard external/droidify/Android.bp))
PRODUCT_PACKAGES += Droidify
endif

# WebView: prebuilt oficjalny LineageOS (moduł "webview" z external/chromium-webview, sync bez remove-project
# w rhode.xml) zamiast Cromite (22.09: patch Cromite wymuszający partycjonowanie połączeń wywala SIGTRAP-em
# kazda apke wolajaca WebView preconnect z pustym NetworkAnonymizationKey - github.com/uazo/cromite/issues/3085).
# Nazwa pakietu APK (com.android.webview) taka sama jak wczesniej - nakladka config_webview_packages bez zmian.
ifneq (,$(wildcard external/chromium-webview/Android.bp))
PRODUCT_PACKAGES += webview
endif

# Bloker, warstwa 2: /system/etc/hosts — scripts/fetch-hosts.sh nadpisuje system/core/rootdir/etc/hosts (moduł etc_hosts AOSP);
# własny moduł z overrides nie działa: soong generuje regułę instalacji dla obu i kati pada na duplikacie.

# KernelSU-Next: manager NIE w obrazie. targetSdk>=30 + presigned wymaga preprocessed:true,
# a to z kolei wymaga niekompresowanych bibliotek JNI w zipie - prawdziwy plik z GitHuba ma je
# skompresowane. Rozpakowanie zmienilo by bajty APK i uniewazniloby podpis v2/v3, po czym jadro
# przestaloby rozpoznawac manager (sprawdza certyfikat podpisu) - a wlasne podpisywanie odrzucone.
# Manager instalowany po flashu jako zwykla aplikacja z oryginalnym, nietknietym APK z GitHuba;
# jadro rozpoznaje go identycznie, root dziala tak samo.

# OTA: własne release'y
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    lineage.updater.uri=https://raw.githubusercontent.com/MikolajQ/rhode_releases/main/23.x/{device}.json

# Default ADB shell prompt
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.sys.adb.shell=/system_ext/bin/bash

# Google Apps: MindTheGapps (przycięte patchem) + dodatki z zipa (GmsSupervision, Gearhead) w vendor/gapps-extras
ifeq ($(WITH_GMS), true)
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)
# (APK nie może iść przez PRODUCT_COPY_FILES — build to odrzuca; scripts/gapps-extras.sh generuje Android.bp + extras.mk)
$(call inherit-product-if-exists, vendor/gapps-extras/extras.mk)
endif

# PIF values
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.pihooks_MANUFACTURER?=Google \
    persist.sys.pihooks_BRAND?=google \
    persist.sys.pihooks_PRODUCT?=blazer_beta \
    persist.sys.pihooks_DEVICE?=blazer \
    persist.sys.pihooks_ID?=CP21.260306.017 \
    persist.sys.pihooks_RELEASE?=17 \
    persist.sys.pihooks_SECURITY_PATCH?=2026-03-05 \
    persist.sys.pihooks_DEVICE_INITIAL_SDK_INT?=21 \
    persist.sys.pihooks_SDK_INT?=32

PRODUCT_BUILD_PROP_OVERRIDES += \
    PihooksGmsFp="google/blazer_beta/blazer:17/CP21.260306.017/15063635:user/release-keys" \
    PihooksGmsModel="Pixel 10 Pro"

# Overlays
PRODUCT_PACKAGE_OVERLAYS += \
    $(EXTRA_PATH)/overlay \
    $(EXTRA_PATH)/overlay-lineage
