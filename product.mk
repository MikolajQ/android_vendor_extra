EXTRA_PATH := vendor/extra

# ADB
ifneq (,$(wildcard $(EXTRA_PATH)/adbkey.pub))
PRODUCT_ADB_KEYS := $(EXTRA_PATH)/adbkey.pub
PRODUCT_COPY_FILES += $(PRODUCT_ADB_KEYS):$(TARGET_COPY_OUT_RECOVERY)/root/$(TARGET_COPY_OUT_PRODUCT)/etc/security/adb_keys
endif

# Droid-ify zamiast F-Droida (decyzja 21.09: F-Droid ciężki i toporny; Droid-ify nie ma Privileged Extension
# ani INSTALL_PACKAGES — cicha instalacja tylko przez root KSU-Next). Repozytoria IzzyOnDroid/NewPipe/IronFox
# przez XML w /system/etc/org.fdroid.fdroid/additional_repos.xml — Droid-ify (OemRepositoryParser) czyta tę
# ścieżkę. LineageOS tego pliku nie instaluje (robił to vendor/lineage Tomoms do 0.1.x przepisu), więc tu.
ifneq (,$(wildcard external/droidify/Android.bp))
PRODUCT_PACKAGES += Droidify
endif
PRODUCT_COPY_FILES += \
    $(EXTRA_PATH)/fdroid/additional_repos.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/org.fdroid.fdroid/additional_repos.xml

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

# Moto Camera stockowa (MotCamera4 + MotCamera3AI + MotoSignature) — przetestowana 21.09 na telefonie
# (moduł KSU-Next), decyzja 22.09: do obrazu. GCam MGC 8.6 zostaje aplikacją z ręki, nie wchodzi tu.
# scripts/motocam-extras.sh generuje Android.bp + extras.mk z zipa (argument HAM motocam_zip).
$(call inherit-product-if-exists, vendor/motocam-extras/extras.mk)

# PIF values (PropImitationHooks — NIE ma ich w LineageOS; kod z forków Tomoms, w przepisie jako patche
# patches/{frameworks_base,bionic,build_soong,system_core}; persist.sys.pihooks_*, czytane przez GMS unstable).
# Odświeżone 22.09: poprzedni profil był BETA (blazer_beta, CP21.260306.017 z marca) — od pewnego czasu
# beta fingerprinty NIE przechodzą już nawet DEVICE integrity, tylko STRONG (a to wymaga TrickyStore +
# prawdziwego keyboxa sprzętowego, którego nie mamy) — patrz github.com/daboynb/autojson README, cytuje
# github.com/osm0sis/PlayIntegrityFork. To była też przyczyna "Urządzenie nie ma certyfikatu" w Play (21.09).
# Nowy profil: prawdziwy, NIE-beta build Pixela 10 Pro (blazer, nie blazer_beta) z legalnego dumpu firmware
# (github.com/gm-stuffs/google_blazer_dump, gałąź blazer-user-16-BD3A.251105.010.E1-...-release-keys,
# fingerprint zweryfikowany z vendor/build.prop tego dumpu). RELEASE/SDK_INT spójne (Android 16 / API 36) —
# poprzedni profil miał RELEASE=17 razem z SDK_INT=32, co się wzajemnie wyklucza.
# Odświeżanie na przyszłość: to persist.*, więc da się to podmienić na żywo (resetprop) bez rebuilda, jeśli
# ten profil też trafi na czarną listę Google — szukać najnowszego NIE-beta dumpu "blazer" albo następcy
# Pixela 10 na github (branże/repo "*_dump", filtrować po "-release-keys", odrzucać "_beta"/"canary").
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.pihooks_MANUFACTURER?=Google \
    persist.sys.pihooks_BRAND?=google \
    persist.sys.pihooks_PRODUCT?=blazer \
    persist.sys.pihooks_DEVICE?=blazer \
    persist.sys.pihooks_ID?=BD3A.251105.010.E1 \
    persist.sys.pihooks_RELEASE?=16 \
    persist.sys.pihooks_SECURITY_PATCH?=2025-11-05 \
    persist.sys.pihooks_DEVICE_INITIAL_SDK_INT?=36 \
    persist.sys.pihooks_SDK_INT?=36

PRODUCT_BUILD_PROP_OVERRIDES += \
    PihooksGmsFp="google/blazer/blazer:16/BD3A.251105.010.E1/14337626:user/release-keys" \
    PihooksGmsModel="Pixel 10 Pro"

# Overlays
PRODUCT_PACKAGE_OVERLAYS += \
    $(EXTRA_PATH)/overlay \
    $(EXTRA_PATH)/overlay-lineage
