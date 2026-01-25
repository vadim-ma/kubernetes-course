# 📋 Полная инструкция по установке Minikube в ВМ Яндекс.Облака (Ubuntu 24.04)

## Шаг 1: Подготовка системы и пользователя
```
# Подключитесь к вашей ВМ по SSH
ssh username@<ваш_ip_адрес_вм>

# Обновите пакеты и установите базовые утилиты
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl
```

## Шаг 2: Установка Docker
```
# 2.1 Установите зависимости и добавьте репозиторий Docker
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 2.2 Установите Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 2.3 Запустите и настройте автоматический запуск Docker
sudo systemctl enable --now docker

# 2.4 Добавьте вашего пользователя в группу docker (чтобы не использовать sudo)
sudo usermod -aG docker $USER
```
### Проверка успеха шага 2:
```
sudo systemctl status docker  # Должно быть: Active: active (running)
```
## Шаг 3: Применение прав пользователя
```
# ВАЖНО: Выйдите из SSH-сессии и подключитесь заново, чтобы изменения вступили в силу
exit
# Снова подключитесь к вашей ВМ
ssh username@<ваш_ip_адрес_вм>
```
### Проверка успеха шага 3:
```
docker ps  # Должна выполниться без ошибок "permission denied", вернув пустой список контейнеров
```

## Шаг 4: Установка kubectl
```
# Скачайте последнюю стабильную версию kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# Установите kubectl в систему
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
```
###  Проверка успеха шага 4:
```
kubectl version --client  # Должна отобразиться версия клиента
```
## Шаг 5: Установка Minikube
```
# Скачайте и установите Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64 
```
###  Проверка успеха шага 5:
```
minikube version  # Должна отобразиться версия Minikube
```
## Шаг 6: Запуск кластера Minikube
```
# Запустите Minikube с драйвером Docker (процесс займет несколько минут)
minikube start --driver=docker
```
### Проверка успеха шага 6:
```
minikube status
# Успех: все компоненты (host, kubelet, apiserver) должны быть в состоянии Running
```
## Шаг 7: Финальная проверка кластера
```
# Проверьте, что узел кластера готов к работе
kubectl get nodes
```
### Успех шага 7: В выводе команды узел minikube должен быть в статусе Ready.