# vendor/extra — rhode (MikolajQ), gałąź `rhode`

Fork `Tomoms/android_vendor_extra` @16.2. Dociągany przez `inherit-product-if-exists` z jego `vendor/lineage`
(jako pierwszy, więc może nadpisywać). Używany przez przepis [rhode-los23.2](https://github.com/MikolajQ/rhode-los23.2).

| Co | Jak |
|---|---|
| OTA | `lineage.updater.uri` → `MikolajQ/rhode_releases/main/23.x/{device}.json` |
| F-Droid | `F-Droid` (prebuilt Tomoms) + repozytoria IzzyOnDroid, NewPipe, IronFox: `fdroid/additional_repos.json` (klient od 03.2026, `/product/etc/fdroid/`) i `.xml` (starszy, `/system/etc/org.fdroid.fdroid/`); certyfikaty wyciągnięte z `index-v1.jar` każdego repo |
| WebView | `CromiteWebView` (moduł z `external/chromium-webview`, tworzony przez `scripts/fetch-webview.sh`) + overlay `config_webview_packages.xml` z `org.cromite.webview` |
| Bloker, warstwa 2 | `hosts_rhode` → `/system/etc/hosts`, `overrides: ["etc_hosts"]`; plik `hosts` to placeholder nadpisywany przez `scripts/fetch-hosts.sh` przed `mka` |
| Bloker, warstwa 1 | `overlay-lineage/…/SimpleSettingsConfig`: przy pierwszym boocie `private_dns_mode=hostname`, `private_dns_specifier=family.adguard-dns.com` |
| KernelSU-Next | `KernelSUNext` — oryginalny manager v3.3.0 (`prebuilt/KernelSUNext.apk`, sha256 `fd0b1238…`) |
| GApps | `WITH_GMS=true`: MindTheGapps + `vendor/gapps-extras/extras.mk` (GmsSupervision, Gearhead — generowane z zipa) |
| Wycięte | Bellis, LogViewer |

Aktualizacja z upstreamu: `git fetch https://github.com/Tomoms/android_vendor_extra 16.2 && git merge FETCH_HEAD`.
