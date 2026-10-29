#!/bin/sh
# Сборка universal-бинаря utunws (arm64 + x86_64, macOS 14+). Запускать на macOS с Xcode Command Line Tools.
# Сборка воспроизводима: дата сборки в бинаре — время последнего коммита (SOURCE_DATE_EPOCH),
# поэтому один и тот же коммит одним и тем же clang даёт тот же SHA256.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
DIST="$ROOT/dist"
SDK=$(/usr/bin/xcrun --sdk macosx --show-sdk-path)
CLANG=$(/usr/bin/xcrun -f clang)
SOURCE_DATE_EPOCH=$(git -C "$ROOT" log -1 --format=%ct)
export SOURCE_DATE_EPOCH

/bin/mkdir -p "$DIST"
/usr/bin/make -C "$ROOT/nfq" clean mac CC="$CLANG" SDKROOT="$SDK"
/bin/cp "$ROOT/nfq/utunws" "$DIST/utunws"
/bin/chmod 755 "$DIST/utunws"
ARCHS=$(/usr/bin/lipo -archs "$DIST/utunws")
case "$ARCHS" in *x86_64*arm64*|*arm64*x86_64*) ;; *) echo "нужны arm64 и x86_64, получено: $ARCHS" >&2; exit 1 ;; esac

# Самопроверка: движок разбирает типичный конфиг (--dry-run должен стоять внутри @файла).
printf -- '--filter-tcp=443\n--dpi-desync=fake\n--dry-run\n' > "$DIST/selftest.conf"
"$DIST/utunws" "@$DIST/selftest.conf" >/dev/null
printf -- '--filter-tcp=443\n--no-such-option\n--dry-run\n' > "$DIST/selftest.conf"
if "$DIST/utunws" "@$DIST/selftest.conf" >/dev/null 2>&1; then
  echo "самопроверка: неизвестная опция не отклонена" >&2; exit 1
fi
/bin/rm -f "$DIST/selftest.conf"

{
  echo "commit $(git -C "$ROOT" rev-parse HEAD)"
  echo "clang  $("$CLANG" --version | head -1)"
  echo "sdk    $(/usr/bin/xcrun --sdk macosx --show-sdk-version)"
} > "$DIST/BUILDINFO.txt"
(cd "$DIST" && /usr/bin/shasum -a 256 utunws > SHA256SUMS.txt)
/usr/bin/file "$DIST/utunws"
cat "$DIST/SHA256SUMS.txt" "$DIST/BUILDINFO.txt"
