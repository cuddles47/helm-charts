#!/bin/bash
# Script chuẩn bị image cho local registry

# Phiên bản node exporter
NODE_EXPORTER_VERSION="1.6.1"
# Phiên bản kube-rbac-proxy nếu sử dụng
KUBE_RBAC_PROXY_VERSION="v0.19.1"
# Địa chỉ local registry
LOCAL_REGISTRY="localhost:5000"

echo "=== Chuẩn bị image cho local registry ==="

# Pull image node-exporter từ quay.io
echo "Pulling node-exporter từ quay.io..."
docker pull quay.io/prometheus/node-exporter:v${NODE_EXPORTER_VERSION}

# Tag lại image cho local registry
echo "Tag image node-exporter cho local registry..."
docker tag quay.io/prometheus/node-exporter:v${NODE_EXPORTER_VERSION} ${LOCAL_REGISTRY}/prometheus/node-exporter:v${NODE_EXPORTER_VERSION}

# Push image lên local registry
echo "Push image node-exporter lên local registry..."
docker push ${LOCAL_REGISTRY}/prometheus/node-exporter:v${NODE_EXPORTER_VERSION}

# Nếu sử dụng kube-rbac-proxy
if [ "$1" == "--with-rbac-proxy" ]; then
  echo "Pulling kube-rbac-proxy từ quay.io..."
  docker pull quay.io/brancz/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
  
  echo "Tag image kube-rbac-proxy cho local registry..."
  docker tag quay.io/brancz/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION} ${LOCAL_REGISTRY}/brancz/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
  
  echo "Push image kube-rbac-proxy lên local registry..."
  docker push ${LOCAL_REGISTRY}/brancz/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
fi

echo "=== Hoàn tất chuẩn bị image ==="
echo "Các image đã được đưa vào local registry: ${LOCAL_REGISTRY}"
echo "Sử dụng lệnh sau để cài đặt với Helm:"
echo "helm install node-exporter ./charts/prometheus-node-exporter \\"
echo "  --namespace monitoring --create-namespace \\"
echo "  -f values/local-registry-values.yaml"
