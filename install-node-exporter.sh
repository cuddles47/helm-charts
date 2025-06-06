#!/bin/bash
# Script cài đặt Node Exporter
# Phiên bản: 1.0
# Tác giả: kewwi

# Cài đặt phiên bản Node Exporter
NODE_EXPORTER_VERSION="1.3.1"

echo "=== BẮT ĐẦU CÀI ĐẶT NODE EXPORTER v${NODE_EXPORTER_VERSION} ==="
echo ""

# Bước 1: Tạo user node_exporter
echo "Bước 1: Tạo user cho Node Exporter..."
sudo useradd --system --no-create-home --shell /bin/false node_exporter

# Bước 2: Tải Node Exporter
echo "Bước 2: Tải Node Exporter phiên bản ${NODE_EXPORTER_VERSION}..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Bước 3: Giải nén
echo "Bước 3: Giải nén Node Exporter..."
tar -xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Bước 4: Di chuyển binary vào /usr/local/bin
echo "Bước 4: Di chuyển binary vào /usr/local/bin..."
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/

# Bước 5: Dọn dẹp
echo "Bước 5: Dọn dẹp các file tạm..."
rm -rf node_exporter*

# Bước 6: Kiểm tra phiên bản
echo "Bước 6: Kiểm tra phiên bản Node Exporter..."
node_exporter --version

# Bước 7: Tạo systemd service
echo "Bước 7: Tạo file systemd service..."
cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter \
    --collector.logind

[Install]
WantedBy=multi-user.target
EOF

# Bước 8: Reload systemd daemon
echo "Bước 8: Reload systemd daemon..."
sudo systemctl daemon-reload

# Bước 9: Enable service
echo "Bước 9: Enable Node Exporter service..."
sudo systemctl enable node_exporter

# Bước 10: Khởi động service
echo "Bước 10: Khởi động Node Exporter service..."
sudo systemctl start node_exporter

# Bước 11: Kiểm tra trạng thái service
echo "Bước 11: Kiểm tra trạng thái Node Exporter service..."
sudo systemctl status node_exporter

# Hiện thông tin endpoint
echo ""
echo "=== CÀI ĐẶT NODE EXPORTER HOÀN TẤT ==="
echo "Node Exporter metrics có thể truy cập tại: http://localhost:9100/metrics"
echo ""
