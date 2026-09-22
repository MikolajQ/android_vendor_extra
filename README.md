# vendor/extra — rhode (MikolajQ), gałąź `rhode`

Fork `Tomoms/android_vendor_extra` @16.2. Dociągany przez `inherit-product-if-exists` z jego `vendor/lineage`
(jako pierwszy, więc może nadpisywać). Używany przez przepis [rhode-los23.2](https://github.com/MikolajQ/rhode-los23.2).

| Co | Jak |
|---|---|
| OTA | `lineage.updater.uri` → `MikolajQ/rhode_releases/main/23.x/{device}.json` |
| F-Droid | `F-Droid` (prebuilt Tomoms) + repozytoria IzzyOnDroid, NewPipe, IronFox: `fdroid/additional_repos.json` jako moduł (`/product/etc/fdroid/`, klient od 03.2026) oraz `fdroid/additional_repos.xml`, którym przepis nadpisuje `vendor/lineage/prebuilt/common/etc/additional_fdroid_repos.xml` Tomoms (on kopiuje go do `/system/etc/org.fdroid.fdroid/`); certyfikaty z `index-v1.jar` każdego repo |
| WebView | prebuilt oficjalny LineageOS, moduł `webview` z `external/chromium-webview` (sync bez `remove-project` w `rhode.xml`) + overlay `config_webview_packages.xml` z `com.android.webview`; do 22.09 był to Cromite — zamieniony po [uazo/cromite#3085](https://github.com/uazo/cromite/issues/3085) (SIGTRAP w apkach z Google Mobile Ads SDK) |
| Bloker, warstwa 2 | `/system/etc/hosts` = moduł AOSP `etc_hosts`; jego plik źródłowy `system/core/rootdir/etc/hosts` nadpisuje `scripts/fetch-hosts.sh` przed `mka` (własny moduł z `overrides` dawał duplikat reguły instalacji w kati) |
| Bloker, warstwa 1 | `overlay-lineage/…/SimpleSettingsConfig`: przy pierwszym boocie `private_dns_mode=hostname`, `private_dns_specifier=family.adguard-dns.com` |
| KernelSU-Next | `KernelSUNext` — oryginalny manager v3.3.0 (`prebuilt/KernelSUNext.apk`, sha256 `fd0b1238…`) |
| GApps | `WITH_GMS=true`: MindTheGapps + `vendor/gapps-extras/extras.mk` (GmsSupervision, Gearhead — generowane z zipa) |
| Allowlista Android.mk | `build/androidmk/allowlist.txt` — soong (A16) blokuje `Android.mk` pod `packages/`; fork `build_soong` Tomoms czyta tę listę, F-Droid Privileged Extension buduje się z `Android.mk` |
| Wycięte | Bellis, LogViewer |

Aktualizacja z upstreamu: `git fetch https://github.com/Tomoms/android_vendor_extra 16.2 && git merge FETCH_HEAD`.
