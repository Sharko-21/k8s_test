#!/bin/bash
set -e

# Переменные
MEMBERS=(member1 member2 member3)
KARMADA_CONTEXT="kind-karmada-host"
KARMADA_KUBECONFIG="$HOME/.kube/config"

# Создание кластеров
for MEMBER in "${MEMBERS[@]}"; do
  echo "🚀 Создаю кластер: $MEMBER ..."
  cat <<EOF | kind create cluster --name "$MEMBER" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
EOF
done

# Проверка кластеров
echo "✅ Кластеры Kind:"
kind get clusters
echo

# Генерация kubeconfig для членов
for MEMBER in "${MEMBERS[@]}"; do
  echo "💾 Сохраняю kubeconfig для $MEMBER..."
  kind get kubeconfig --name "$MEMBER" > "/tmp/${MEMBER}.config"
done
echo

# Присоединение к Karmada
for MEMBER in "${MEMBERS[@]}"; do
  echo "🔗 Присоединяю кластер $MEMBER к федерации Karmada..."
  karmadactl join "$MEMBER" --kubeconfig="$KARMADA_KUBECONFIG" --cluster-kubeconfig="/tmp/${MEMBER}.config" --v=2
done

echo "✅ Все кластеры успешно присоединены!"
