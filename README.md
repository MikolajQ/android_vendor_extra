# vendor/extra — rhode (MikolajQ), gałąź `rhode`

Historycznie fork `Tomoms/android_vendor_extra` @16.2; od przepisu 0.2.0 baza to czysty LineageOS lineage-23.2.
Dociągany przez `inherit-product-if-exists` z `vendor/lineage/config/common.mk` (jako pierwszy, więc może nadpisywać). Używany przez przepis [rhode-los23.2](https://github.com/MikolajQ/rhode-los23.2).

| Co | Jak |
|---|---|
| OTA | `lineage.updater.uri` → `MikolajQ/rhode_releases/main/23.x/{device}.json` |
| Klient F-Droid | `Droidify` (moduł z `external/droidify`, `scripts/fetch-droidify.sh`; zamiast F-Droida od 22.09) + repozytoria IzzyOnDroid, NewPipe, IronFox: `fdroid/additional_repos.xml`, instalowany przez `PRODUCT_COPY_FILES` do `/system/etc/org.fdroid.fdroid/additional_repos.xml` (LineageOS go nie instaluje) — tę ścieżkę czyta Droid-ify (`OemRepositoryParser`); certyfikaty z `index-v1.jar` każdego repo. Brak Privileged Extension — Droid-ify nie ma `INSTALL_PACKAGES`, aktualizacje przez root |
| WebView | prebuilt oficjalny LineageOS, moduł `webview` z `external/chromium-webview` (sync bez `remove-project` w `rhode.xml`) + overlay `config_webview_packages.xml` z `com.android.webview`; do 22.09 był to Cromite — zamieniony po [uazo/cromite#3085](https://github.com/uazo/cromite/issues/3085) (SIGTRAP w apkach z Google Mobile Ads SDK) |
| Bloker, warstwa 2 | `/system/etc/hosts` = moduł AOSP `etc_hosts`; jego plik źródłowy `system/core/rootdir/etc/hosts` nadpisuje `scripts/fetch-hosts.sh` przed `mka` (własny moduł z `overrides` dawał duplikat reguły instalacji w kati) |
| Bloker, warstwa 1 | `overlay-lineage/…/SimpleSettingsConfig`: przy pierwszym boocie `private_dns_mode=hostname`, `private_dns_specifier=family.adguard-dns.com` |
| KernelSU-Next | `KernelSUNext` — oryginalny manager v3.3.0 (`prebuilt/KernelSUNext.apk`, sha256 `fd0b1238…`) |
| Play Integrity (PIF) | `persist.sys.pihooks_*` (działa dzięki PropImitationHooks z forków Tomoms, w przepisie jako patche) — profil Pixel 10 Pro `blazer` (NIE `blazer_beta`; beta nie przechodzi już DEVICE integrity), build `BD3A.251105.010.E1`, z realnego dumpu firmware; `persist.*` da się podmienić na żywo bez rebuilda, jeśli ten profil też padnie |
| GApps | `WITH_GMS=true`: MindTheGapps + `vendor/gapps-extras/extras.mk` (GmsSupervision, Gearhead — generowane z zipa) |
| Allowlista Android.mk | `build/androidmk/allowlist.txt` — soong (A16) blokuje `Android.mk` pod `packages/`; czytał ją fork `build_soong` Tomoms (LineageOS jej nie czyta). Pusta od 22.09 (jedyny wpis, F-Droid Privileged Extension, usunięty z Droid-ify) |
| Wycięte | Bellis, LogViewer |

Upstream Tomoms (`git fetch https://github.com/Tomoms/android_vendor_extra 16.2`) — tylko do podglądu, bez automatycznego merge.
