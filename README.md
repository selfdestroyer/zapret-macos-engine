# zapret-macos-engine

Движок `utunws` для [Zapretify](https://github.com/selfdestroyer/Zapretify) на macOS.
Форк [Flowseal/zapret-mac-discord-youtube](https://github.com/Flowseal/zapret-mac-discord-youtube),
который основан на [bol-van/zapret](https://github.com/bol-van/zapret) (`nfq`). Лицензия MIT.

Ветка `zapretify` — то, что собирает Zapretify. `master` повторяет upstream Flowseal.

## Что собирается

Один файл `utunws` (universal: arm64 + x86_64, macOS 14+). В релизе также `SHA256SUMS.txt`
и `BUILDINFO.txt` (коммит, версия clang, SDK).

```sh
./scripts/build-universal.sh   # результат в dist/
```

Сборка воспроизводима: дата сборки берётся из последнего коммита (`SOURCE_DATE_EPOCH`),
поэтому один коммит тем же clang даёт тот же SHA256. Скрипт сам проверяет обе архитектуры
и что движок принимает правильный конфиг и отклоняет неизвестную опцию.

Релиз: тег `v*` на ветке `zapretify` запускает `.github/workflows/engine-release.yml`.
Zapretify закрепляет версию и SHA256 в `macos/engine.lock` своего репозитория.

Контракт запуска — [CONTRACT.md](CONTRACT.md), происхождение кода — [NOTICE.md](NOTICE.md).

## Обновление upstream

```sh
git remote add upstream https://github.com/Flowseal/zapret-mac-discord-youtube
git fetch upstream && git switch zapretify && git merge upstream/master
```

После слияния: сборка, `go test` демона Zapretify с `ZAPRETIFY_UTUNWS=dist/utunws`
(проверка всех стратегий через `--dry-run`), новый тег.
