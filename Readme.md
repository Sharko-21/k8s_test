# Info API Kubernetes Release Manager

Минималистичный инструмент для локального управления релизами приложения в Kubernetes-кластере с помощью Bash-скриптов.

---

## 📦 О проекте

Этот репозиторий содержит:

- Приложение `info-api` на FastAPI.
- Скрипты автоматизации процесса релизов в Kubernetes.
- Поддержку сборки новых релизов, переключения трафика, отката и финализации.

**Идеально подходит для практики и прототипирования CI/CD процессов.**

---

## 🛠 Требования

- [Docker](https://www.docker.com/)
- [Kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Bash (если используешь Windows — WSL или Git Bash)

---

## 🧩 Структура проекта

```plaintext
info-api/
├── app.py                   # Приложение FastAPI
├── Dockerfile               # Сборка образа
├── active-release.txt       # Имя текущего активного релиза
├── deploys/                 # История YAML файлов релизов
├── release.sh               # Скрипт сборки и выкладки нового релиза
├── switch.sh                # Переключение трафика на новый релиз
├── rollback.sh              # Откат релиза на предыдущий
└── finalize.sh              # Завершение релиза и удаление старого
```

---

## 🚀 Как пользоваться

### 1. Подготовка кластера

Создай Kubernetes кластер через Kind с нужной конфигурацией:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 30080
        protocol: TCP
  - role: worker
  - role: worker
```

Создание кластера:

```bash
kind create cluster --name multi --config kind-config.yaml
```

Создай сервис `info-api-service`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: info-api-service
spec:
  type: NodePort
  selector:
    app: info-api
    release: v1
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080
```

Применение:

```bash
kubectl apply -f info-api-service.yaml
```

---

### 2. Выпуск нового релиза

```bash
./release.sh v2
```

- Собирается Docker-образ `info-api:v2`.
- Загружается в kind-кластер.
- Создаётся новый Deployment `info-api-v2`.
- YAML сохраняется в папку `deploys/`.

---

### 3. Переключение трафика на новый релиз

```bash
./switch.sh v2
```

- Сервис `info-api-service` перенастраивается на `release: v2`.
- Обновляется файл `active-release.txt`.

---

### 4. Завершение релиза

```bash
./finalize.sh
```

- Проверяется, что трафик направлен на активный релиз.
- Удаляются все деплойменты и поды старше активного релиза.

---

### 5. Откат релиза (если что-то пошло не так)

```bash
./rollback.sh
```

- Переключение сервиса обратно на предыдущий релиз.
- Удаление неудачного нового релиза.

---

## 📈 Примеры рабочих цепочек

### Новый релиз

```bash
./release.sh v3
./switch.sh v3
./finalize.sh
```

### Откат релиза

```bash
./rollback.sh
```

---

## 📋 Важно

- Скрипты поддерживают семантику версий вида `v1`, `v2`, `v3` и так далее.
- Финализация возможна только если трафик уже переведён на новый релиз.
- Все YAML'ы деплойментов сохраняются в `deploys/` для истории.

---

## 📜 Лицензия

Свободно используйте и модифицируйте проект для любых целей.

---

## ✨

Проект построен в учебных целях для понимания Kubernetes, процессов CI/CD и практического управления релизами.
