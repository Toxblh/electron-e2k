# electron-e2k — Electron для Эльбруса (e2k-v5)

Порт Electron на архитектуру e2k (Эльбрус-8СВ, e2k-v5) с нативным JIT V8 для e2k. Здесь — серия патчей, сценарии
сборки и аргументы GN. Готовые сборки — в выпусках (Releases) этого репозитория. Бинарных файлов в git нет.

## Версии
| компонент | версия | примечание |
|---|---|---|
| Electron | 46.0.0-nightly.20260902 (electron 15d32f2) | ночная сборка; её Chromium — 154.0.8037.0, точка ветвления M154 |
| Chromium | 154.0.8037.97 | исходники пакета ALT chromium 154.0.8037.97-alt1 + порт e2k |
| V8 | 15.4.80.20 | бэкенд e2k: Ignition, Sparkplug, Maglev, TurboFan, WebAssembly (с SIMD) |
| Node.js | 24.20.0 | из Electron, с BoringSSL |

Почему ночная сборка: стабильных Electron на Chromium 154 нет (линия 45 была на 154 только в alpha.1–3, затем
перешла на 155). Ночная 46.0.0-nightly.20260902 собрана ровно на ветке M154, поэтому патчи Electron (257 штук)
легли на наше дерево 154.0.8037.97 почти без правок: 3 отклонённых куска, все поправлены руками или не нужны (Wayland).

## Состав
- `patches/chromium-e2k/` — порт Chromium 154 и V8 на e2k (99 патчей, пути от корня исходников пакета ALT:
  `chromium/...`, накладывать `git am`/`patch -p1` из корня). Ставятся после патчей пакета ALT (`%autopatch`).
  Патч 0003 (`DEV:`) — правки флагов из `%prep` спеки, нужен для сборки без rpm.
- `patches/electron/` — правки самого Electron (накладывать в `src/electron`):
  отказ от ресурсов tracing (в тарболе нет catapult), подстройка под 154.0.8037.97, увеличенный стек потока
  ShutdownDetector на e2k (32 КБ переполнялись при старте потока).
- `patches/chromium-for-electron/` — после `electron/patches/*`: группа `//third_party/zstd:headers` (в дереве ALT
  zstd системный), `#include <map>` (кусок патча Electron не лёг), возврат libc++ ABI 2 (см. ниже).
- `build/` — `args-electron.gn` (аргументы GN), `xs-el` (сборка в контейнере перекрёстной сборки),
  `apply-electron-patches.py` (наложение патчей Electron без gclient), дополнения обёртки clang и rustc,
  `pack-electron.sh` (сборка пакета).
- `scripts/electron.sh`, `scripts/run-app.sh` — запуск на Эльбрусе.
- `examples/smoke` — проверочное приложение (версии, IPC, preload, wasm, canvas, N-API-модуль, снимок окна).

## Сборка
Перекрёстная сборка на x86-64 тем же окружением, что и Chromium для e2k: clang 21.1.1 МЦСТ + lccopt (кодогенерация
lcc 1.29.16), плагины проходов e2k-rmw-fence и e2k-i65-fix, корень e2k (sysroot) из пакетов ALT e2kv5, distcc.
Программы, которые сборка запускает (mksnapshot, torque, v8_context_snapshot_generator), выполняются на Эльбрусе
(xs-rexec); Rust берётся из «затравки» — результатов нативной сборки rustc на Эльбрусе для Chromium e2k.

1. Исходники пакета ALT chromium 154.0.8037.97-alt1, `%autopatch -p1`, затем `patches/chromium-e2k`.
2. `git clone --branch v46.0.0-nightly.20260902 https://github.com/electron/electron src/electron`,
   `src/third_party/electron_node` = nodejs/node v24.20.0, `src/third_party/nan` = nodejs/nan 675cefeb.
3. `python3 build/apply-electron-patches.py src` (патчи Electron; squirrel/ReactiveObjC/reclient пропускаются),
   затем `patches/chromium-for-electron`, затем `patches/electron` (в `src/electron`).
4. В `src/electron`: `node .yarn/releases/yarn-4.12.0.cjs install --immutable --mode=skip-build` (нужен node и npm
   на x86 и внутри контейнера для шагов webpack/tsc).
5. `xs-el gen build/args-electron.gn`, `xs-el build electron` (≈ 42 тыс. шагов; на 70 ядрах + 120 удалённых —
   около 45 минут).
6. `pack-electron.sh out/e2k-electron electron-...` — пакет без символов.

Важные решения:
- libc++ ABI 2 вместо ABI 1 Electron: ABI 1 меняет вывод bindgen, и ни один крейт Rust не совпадает с затравкой.
  Модули, которые передают типы libc++ через границу с Electron, несовместимы; N-API и nan этого не делают.
- `gtk_version = 3` (заглушки GTK Electron только для GTK3), `is_component_ffmpeg = false`,
  `enable_resource_allowlist_generation = false` (tools/resources/ar.py не разбирает тонкие архивы GNU ar для e2k),
  без сжатия указателей и песочницы V8 (как во всём порте e2k), без Vulkan/Dawn/SwiftShader.
- Обёртка clang: `js2c.cc` — `-O0` (MCST clang зависает на -O1/-O2), `cc/scroll_snap_data.o` — без векторизации
  (lccopt ссылается на отсутствующий `__lccrt_builtin_cmp_eq_i_v2i2`), у каждой компиляции предел времени.

## Запуск
```sh
./electron.sh --version
./electron.sh examples/smoke
./run-app.sh <каталог resources готового приложения Electron для x86>
```
`--no-sandbox` (chrome-sandbox не собран) и `--disable-gpu` (программная отрисовка) ставит `electron.sh`.
`libXNVCtrl.so.0` лежит в пакете (в системе её может не быть).

## Что работает (Эльбрус-8СВ, ядро 6.1, Xvfb)
- `--version`, режим node (`ELECTRON_RUN_AS_NODE=1`), JIT: fib(30) ≈ 150 мс.
- Окно, HTML/CSS, canvas, Intl ru-RU, RegExp \p{L}, WebAssembly, preload/contextBridge, IPC (invoke/handle, send/on),
  `capturePage`.
- N-API-модуль, собранный node-gyp на Эльбрусе: грузится в процессе main и в режиме node.
- Obsidian 1.8.10 из deb для x86: запуск, самообновление до 1.15.1, хранилище, Markdown, подсветка кода, формулы.
- TickTick 6.0.30 из deb для x86: запуск, сеть, окно входа.
- VS Code 1.147.0 из tar.gz для x86 (JS без изменений): запуск, открытие каталога, редактор с подсветкой,
  передача файла уже запущенному экземпляру. Нативные модули пересобраны на Эльбрусе (`apps/vscode/`): kerberos,
  native-is-elevated, node-pty, @parcel/watcher, native-watchdog, policy-watcher, spdlog, sqlite3, native-keymap;
  vsda, os-proxy-resolver, copilot и deviceid есть только в x86-сборках (не грузятся).
  lcc 1.29.16 не порождает шаблон функции, названный только в аргументе шаблона по умолчанию
  (node-addon-api `AttachData<..., default_finalizer<T>>`) — неопределённый символ при загрузке модуля;
  обход — упомянуть шаблон в теле функции в napi-inl.h (`apps/vscode/natbuild3.sh`, `natbuild4.sh`). native-keymap использует API V8 напрямую: `-DV8_CPPGC_MICROTASK_QUEUE`.

## Ограничения и что дальше
- Модули .node из x86-приложений нужно пересобирать для e2k.
- Нет песочницы, SwiftShader, crashpad; аппаратное ускорение не проверялось.
- Основа — ветка порта `e2k-v8-js3`; правки Chrome из релизной ветки (VA-API, AV1 и др.) сюда не входят.
- Цель `electron:node_headers` не собирается (configure.py Node не знает `--dest-cpu e2k`); для N-API-модулей
  подходят заголовки Node 26 для e2k.

Журнал работы — `LOG.md`.
