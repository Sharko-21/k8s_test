#!/bin/bash
set -e

# Настройки
FEDERATION_NAMESPACE="federation-system"

echo "📦 Создаём 3 кластера через kind..."

kind create cluster --name cluster1
kind create cluster --name cluster2
kind create cluster --name cluster3

echo "✅ Кластеры подняты."

# Устанавливаем Federation Control Plane
echo "🚀 Устанавливаем Federation Control Plane в cluster1..."

kubefedctl init ${FEDERATION_NAMESPACE} \
  --host-cluster-context=kind-cluster1 \
  --dns-provider=coredns \
  --dns-zone-name=example.com. \
  --limited-scope=false

echo "✅ Federation Control Plane установлен."

# Присоединяем остальные кластеры
echo "🔗 Присоединяем cluster1 в федерацию..."
kubefedctl join cluster1 --host-cluster-context=kind-cluster1 --add-to-registry --v=2

echo "🔗 Присоединяем cluster2 в федерацию..."
kubefedctl join cluster2 --host-cluster-context=kind-cluster1 --add-to-registry --v=2

echo "🔗 Присоединяем cluster3 в федерацию..."
kubefedctl join cluster3 --host-cluster-context=kind-cluster1 --add-to-registry --v=2

echo "🎉 Федерация успешно создана и настроена!"
