#!/bin/bash

# Bash-скрипт для автоматичного встановлення DevOps інструментів
# Автор: DevOps Engineer
# Дата: $(date +%Y-%m-%d)

set -e  # Вийти при будь-якій помилці

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функція для логування
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Функція для перевірки чи команда існує
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Функція для оновлення списку пакетів
update_package_list() {
    log_info "Оновлення списку пакетів..."
    sudo apt update -y
}

# Функція для встановлення Docker
install_docker() {
    if command_exists docker; then
        local docker_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1)
        log_warning "Docker вже встановлений (версія: $docker_version)"
        return 0
    fi

    log_info "Встановлення Docker..."
    
    # Встановлення необхідних пакетів
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Додавання GPG ключа Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Додавання репозиторію Docker
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Оновлення списку пакетів
    sudo apt update -y
    
    # Встановлення Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # Додавання користувача до групи docker
    sudo usermod -aG docker $USER
    
    # Запуск і увімкнення Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    log_success "Docker успішно встановлений!"
}

# Функція для встановлення Docker Compose
install_docker_compose() {
    if command_exists docker-compose; then
        local compose_version=$(docker-compose --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1)
        log_warning "Docker Compose вже встановлений (версія: $compose_version)"
        return 0
    fi

    log_info "Встановлення Docker Compose..."
    
    # Отримання останньої версії Docker Compose
    local latest_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
    
    # Завантаження Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/${latest_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Надання прав на виконання
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Створення символічного посилання
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    log_success "Docker Compose успішно встановлений!"
}

# Функція для встановлення Python
install_python() {
    if command_exists python3; then
        local python_version=$(python3 --version 2>/dev/null | cut -d' ' -f2)
        local major_version=$(echo $python_version | cut -d'.' -f1)
        local minor_version=$(echo $python_version | cut -d'.' -f2)
        
        if [[ $major_version -eq 3 && $minor_version -ge 9 ]]; then
            log_warning "Python вже встановлений (версія: $python_version)"
            return 0
        fi
    fi

    log_info "Встановлення Python 3.9+..."
    
    # Встановлення Python та pip
    sudo apt install -y python3 python3-pip python3-venv python3-dev
    
    # Створення символічного посилання для python команди
    if ! command_exists python; then
        sudo ln -sf /usr/bin/python3 /usr/bin/python
    fi
    
    # Оновлення pip
    python3 -m pip install --upgrade pip
    
    log_success "Python успішно встановлений!"
}

# Функція для встановлення Django
install_django() {
    if python3 -c "import django" 2>/dev/null; then
        local django_version=$(python3 -c "import django; print(django.get_version())" 2>/dev/null)
        log_warning "Django вже встановлений (версія: $django_version)"
        return 0
    fi

    log_info "Встановлення Django..."
    
    # Встановлення Django через pip
    python3 -m pip install --user django
    
    log_success "Django успішно встановлений!"
}

# Функція для перевірки встановлених інструментів
verify_installation() {
    log_info "Перевірка встановлених інструментів..."
    
    echo "----------------------------------------"
    
    if command_exists docker; then
        local docker_version=$(docker --version 2>/dev/null)
        echo "Docker: $docker_version"
    else
        echo "Docker: Не встановлений"
    fi
    
    if command_exists docker-compose; then
        local compose_version=$(docker-compose --version 2>/dev/null)
        echo "Docker Compose: $compose_version"
    else
        echo "Docker Compose: Не встановлений"
    fi
    
    if command_exists python3; then
        local python_version=$(python3 --version 2>/dev/null)
        echo "Python: $python_version"
    else
        echo "Python: Не встановлений"
    fi
    
    if python3 -c "import django" 2>/dev/null; then
        local django_version=$(python3 -c "import django; print('Django ' + django.get_version())" 2>/dev/null)
        echo "$django_version"
    else
        echo "Django: Не встановлений"
    fi
    
    echo "----------------------------------------"
}

# Головна функція
main() {
    log_info "=== Початок встановлення DevOps інструментів ==="
    
    # Перевірка чи користувач має sudo права
    if ! sudo -n true 2>/dev/null; then
        log_error "Для виконання скрипта потрібні sudo права"
        exit 1
    fi
    
    # Оновлення списку пакетів
    update_package_list
    
    # Встановлення інструментів
    install_docker
    install_docker_compose
    install_python
    install_django
    
    # Перевірка встановлення
    verify_installation
    
    log_success "=== Встановлення завершено! ==="
    log_info "Можливо потрібно перезайти в систему для використання Docker без sudo"
    log_info "Або використайте команду: newgrp docker"
}

# Запуск головної функції
main "$@"