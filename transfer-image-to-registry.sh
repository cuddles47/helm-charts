#!/bin/bash
# Script chuyển image từ máy có internet vào local registry trên VM
# Usage: ./transfer-image-to-registry.sh <image_name> <image_tag> [vm_user] [vm_ip]
# Example: ./transfer-image-to-registry.sh quay.io/prometheus/node-exporter v1.6.1 ubuntu 192.168.1.100

# Kiểm tra các tham số đầu vào
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <image_name> <image_tag> [vm_user] [vm_ip]"
    echo "Example: $0 quay.io/prometheus/node-exporter v1.6.1 ubuntu 192.168.1.100"
    exit 1
fi

# Lấy các tham số
IMAGE_NAME=$1
IMAGE_TAG=$2
VM_USER=${3:-"root"}
VM_IP=${4:-"localhost"}

# Tên file tar (trích xuất từ IMAGE_NAME)
IMAGE_FILENAME=$(echo $IMAGE_NAME | tr '/' '-' | tr ':' '-')
TAR_FILE="${IMAGE_FILENAME}-${IMAGE_TAG}.tar"

echo "=== Chuẩn bị chuyển image ${IMAGE_NAME}:${IMAGE_TAG} vào local registry ==="

# Bước 1: Pull image từ registry bên ngoài
echo "Pulling image từ registry gốc..."
docker pull ${IMAGE_NAME}:${IMAGE_TAG}

# Bước 2: Lưu image thành file tar
echo "Lưu image thành file ${TAR_FILE}..."
docker save -o ${TAR_FILE} ${IMAGE_NAME}:${IMAGE_TAG}

# Bước 3: Chuyển file tar sang VM nếu không phải localhost
if [ "$VM_IP" != "localhost" ]; then
    echo "Chuyển file ${TAR_FILE} sang VM ${VM_IP}..."
    scp ${TAR_FILE} ${VM_USER}@${VM_IP}:/tmp/
    
    # Bước 4-6: Thực hiện các lệnh trên VM qua SSH
    echo "Load image và push vào local registry trên VM..."
    ssh ${VM_USER}@${VM_IP} "docker load -i /tmp/${TAR_FILE} && \
        docker tag ${IMAGE_NAME}:${IMAGE_TAG} localhost:5000/$(basename ${IMAGE_NAME}):${IMAGE_TAG} && \
        docker push localhost:5000/$(basename ${IMAGE_NAME}):${IMAGE_TAG} && \
        curl -s http://localhost:5000/v2/_catalog && \
        curl -s http://localhost:5000/v2/$(basename ${IMAGE_NAME})/tags/list"
else
    # Bước 4-6: Thực hiện các lệnh trên máy local
    echo "Load image và push vào local registry..."
    docker load -i ${TAR_FILE}
    docker tag ${IMAGE_NAME}:${IMAGE_TAG} localhost:5000/$(basename ${IMAGE_NAME}):${IMAGE_TAG}
    docker push localhost:5000/$(basename ${IMAGE_NAME}):${IMAGE_TAG}
    
    echo "Kiểm tra registry..."
    curl -s http://localhost:5000/v2/_catalog
    curl -s http://localhost:5000/v2/$(basename ${IMAGE_NAME})/tags/list
fi

echo "=== Hoàn tất quá trình chuyển image vào local registry ==="
echo "Image có thể được sử dụng trong Kubernetes với tên: localhost:5000/$(basename ${IMAGE_NAME}):${IMAGE_TAG}"
