# Personal dotfiles

Настройки с текущего Linux: zsh/Oh My Zsh, tmux, терминалы WezTerm и Ghostty и актуальный Neovim на `vim.pack`. Старый конфиг Neovim в `nvim/` оставлен без удаления; установщик использует **`current-nvim/`**.

## Установка на новый компьютер

После публикации изменений этого репозитория запусти в стандартном терминале macOS или Ubuntu/Debian:

```sh
curl -fsSL https://raw.githubusercontent.com/Solarmove/dotfiles/main/install.sh -o /tmp/solarmove-install.sh && bash /tmp/solarmove-install.sh
```

Скрипт скачает репозиторий в `~/dotfiles`, установит зависимости и создаст ссылки на конфиги. На macOS для первой установки Xcode Command Line Tools появится системное окно: подтверди установку и **повтори команду** после завершения. Homebrew и sudo могут запросить пароль. Требуются интернет, права администратора и свободное место. Не запускай скрипт от root. Внимательно проверь код перед запуском скачанного скрипта.

Из уже клонированного репозитория, включая неопубликованные изменения:

```sh
bash ~/dotfiles/install.sh
```

Повторный запуск допустим. Если `~/dotfiles` уже существует, скачанный отдельно скрипт не будет его перезаписывать: запусти `install.sh` из этого каталога либо задай другой путь через `DOTFILES_DIR`.

Предыдущие конфиги, которые заменяются ссылками, сохраняются в `~/.dotfiles-backup/install.*`, включая каталог Neovim. Инструменты и приложения устанавливаются в систему и могут занимать много места. Login shell не меняется: установленный WezTerm запускает zsh автоматически, zsh запускает tmux (отключить: `DOTFILES_AUTO_TMUX=0`). Старые настройки Neovim и незатронутые приложения не удаляются.

### Что устанавливается

- Homebrew; на macOS также потребуются Command Line Tools. Linux bootstrap рассчитан на Ubuntu/Debian с `apt`.
- zsh, Oh My Zsh, fzf-tab, autosuggestions, history-substring-search, vi-mode, fast-syntax-highlighting; tmux и TPM/resurrect/continuum.
- Git, GitHub CLI, eza, fzf, fd, bat, ripgrep, zoxide, lf, lazygit, Python, uv, Node.js/npm, Hack и JetBrains Mono Nerd Fonts.
- Neovim не ниже 0.12 (если нужно — официальный 0.12.6), плагины из `current-nvim/nvim-pack-lock.json`, инструменты Mason и парсеры Tree-sitter. Для сборки нужны компилятор и интернет; установка может быть долгой.
- На macOS: WezTerm, Ghostty, VS Code, Zed, Docker Desktop, Chrome, Spotify и Obsidian через Homebrew Cask. Список можно изменить в `install.sh`.
- Настройки и клавиши VS Code и Zed; 57 расширений VS Code устанавливаются, если команда VS Code доступна и не задан `--no-apps`. Шесть текущих расширений Zed автоматически устанавливаются при запуске Zed. Пути временных файлов удалены из настроек VS Code, а глобальное доверие всем проектам отключено в Zed. Остальные данные приложений не копируются.
- На Ubuntu/Debian x86_64: WezTerm AppImage (распакован без FUSE) и шрифты. Другие графические приложения Linux автоматически не устанавливаются. На Linux ARM для WezTerm нужна ручная установка или `--no-apps`.

Установка приложений не переносит авторизации, платные лицензии, содержимое Docker, базы, документы, браузерный профиль, SSH/GPG-ключи или Git identity. Copilot нужно авторизовать отдельно в Neovim (`:Copilot auth`), а Git — настроить самостоятельно. Секреты и профили браузера намеренно не включены в репозиторий. macOS может потребовать отдельные разрешения и подтверждения запуска приложений.

### Варианты

```sh
bash ~/dotfiles/install.sh --no-apps       # без графических приложений; шрифт и CLI остаются
bash ~/dotfiles/install.sh --skip-packages # не устанавливать системные пакеты и приложения
bash ~/dotfiles/install.sh --link-only     # только ссылки и резервные копии
```

`--skip-packages` по-прежнему скачивает плагины shell/Neovim, расширения VS Code и инструменты Mason; требуемые программы должны быть уже установлены. На Linux ARM Markdown Preview не имеет готового бинарника в upstream. macOS и Linux могут отличаться доступностью отдельных инструментов Mason; ошибка установки останавливает скрипт, после устранения причины его можно повторить.

## Neovim и проверка

Текущие сочетания клавиш и описание Python: [`current-nvim/README.md`](current-nvim/README.md). Исторические сведения в нём об откате относятся к исходному Linux, не к новой машине. `docs/nvim-keys.md` описывает старый конфиг `nvim/`.

```sh
bash -n ~/dotfiles/install.sh
bash ~/dotfiles/tests/test-links.sh
DOTFILES_AUTO_TMUX=0 zsh -ic 'command -v nvim tmux fzf rg'
nvim --headless +qa
```

В редакторе: `:checkhealth`, `:Mason`, `:Copilot auth`. Для обновления зафиксированных плагинов используй `:lua vim.pack.update()` и проверь изменения lock-файла перед публикацией. Не добавляй в Git файлы с токенами, ключами или приватными данными.
