# ZSH Configuration with Oh-My-Zsh

Автоматический установщик ZSH с Oh-My-Zsh и полезными плагинами.

## 🚀 Быстрая установка

```bash
curl -fsSL https://raw.githubusercontent.com/0FL01/shell-config/main/install.sh | bash
```

## 📦 Что устанавливается

### Пакеты
- **zsh** — Z Shell
- **git** — система контроля версий
- **bat** — улучшенный cat с подсветкой синтаксиса
- **fzf** — fuzzy finder для поиска по истории и файлам
- **zoxide** — умный cd, запоминает часто используемые директории
- **pay-respects** — исправление команд нажатием F (замена thefuck на Rust)

### Oh-My-Zsh
- [Oh-My-Zsh](https://ohmyz.sh/) — фреймворк для управления конфигурацией ZSH

### Плагины
| Плагин | Описание |
|--------|----------|
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Подсветка синтаксиса команд |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Автодополнение на основе истории |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Дополнительные completion-скрипты |
| git | Алиасы и функции для Git |
| docker | Автодополнение для Docker |
| docker-compose | Автодополнение для Docker Compose |
| kubectl | Автодополнение для Kubernetes |

## 🖥️ Поддерживаемые системы

| Дистрибутив | Пакетный менеджер |
|-------------|-------------------|
| Ubuntu / Debian | apt |
| Fedora / RHEL / CentOS | dnf |
| Arch Linux / Manjaro | pacman |
| openSUSE | zypper |
| Alpine Linux | apk |

## ⚙️ Включённые функции

### 🔍 FZF — Fuzzy Finder

```bash
Ctrl+R    # Поиск по истории команд
Ctrl+T    # Поиск файлов в текущей директории
Alt+C     # Переход в директорию
```

### 📂 Zoxide — Умный cd

```bash
z proj         # Перейти в часто используемую директорию, содержащую "proj"
z foo bar      # Нечёткий поиск по нескольким словам
zi             # Интерактивный выбор директории с fzf
```

### 🙏 Pay Respects — Исправление команд

```bash
f              # Исправить последнюю неверную команду
# Нажми F чтобы отдать респект и исправить ошибку!
```

### 🎨 Цветной вывод с bat

Все функции используют `bat` для подсветки синтаксиса:

```bash
cat file.json        # Подсветка синтаксиса
tail -f /var/log/... # Цветные логи
head file.log        # Цветные логи
psf                  # Цветной ps auxf
```

### 🐳 Docker

```bash
dlogs          # Логи docker-compose с подсветкой
dl <container> # Логи конкретного контейнера
```

### 📓 Systemd Journal

```bash
jlogs              # Логи journalctl (новые сверху)
jfollow            # Следить за логами в реальном времени
jerr               # Только ошибки
jboot              # Логи с момента загрузки
junit <service>    # Логи конкретного сервиса

# С sudo
sudo jlogs
sudo junit nginx
```

### ☸️ Kubernetes

```bash
# Основная функция k() с умным форматированием
k get pods -o yaml    # Автоматическая подсветка YAML
k get svc -o json     # Автоматическая подсветка JSON
k logs <pod>          # Цветные логи

# Алиасы
kg, kgp, kgd, kgs     # get, get pods, get deployment, get service
kgi, kgn, kgns, kgcm  # get ingress, nodes, namespaces, configmap
kgy, kgj              # get -o yaml, get -o json
ka                    # apply -f
kdel, kdelp, kdelf    # delete, delete pod, delete -f
kdesc, kedit, kex     # describe, edit, exec -it
kl                    # logs -f
```

## 📁 Структура

```
.
├── install.sh     # Скрипт установки
├── .zshrc         # Конфигурация ZSH
└── README.md      # Документация
```

## 🔧 Ручная установка

Если автоматическая установка не работает:

```bash
# 1. Установите зависимости
# Ubuntu/Debian:
sudo apt install zsh git curl bat fzf zoxide

# Fedora:
sudo dnf install zsh git curl bat fzf zoxide

# Arch:
sudo pacman -S zsh git curl bat fzf zoxide

# 1.1. Установите pay-respects
curl -sSfL https://raw.githubusercontent.com/iffse/pay-respects/main/install.sh | sh

# 2. Установите Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. Установите плагины
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-completions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# 4. Скачайте конфигурацию
curl -fsSL https://raw.githubusercontent.com/0FL01/shell-config/main/.zshrc -o ~/.zshrc

# 5. Смените оболочку
chsh -s $(which zsh)
```

## 🎨 Кастомизация

### Смена темы

Отредактируйте `~/.zshrc` и измените строку:

```bash
ZSH_THEME="robbyrussell"
```

Популярные темы: `agnoster`, `powerlevel10k`, `spaceship`, `pure`

Полный список: [Oh-My-Zsh Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)

### Добавление плагинов

```bash
plugins=(
    git
    docker
)
```

## 🔗 Ссылки

- [Oh-My-Zsh](https://ohmyz.sh/)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-completions](https://github.com/zsh-users/zsh-completions)
- [bat](https://github.com/sharkdp/bat)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [pay-respects](https://github.com/iffse/pay-respects)

