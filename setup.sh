#! /bin/sh
CMD=$1

MYSQL_USER="twister5"
MYSQL_PASS="twister5"
MYSQL_DB="adas_one"
SCHEMA_FILE="$(dirname "$0")/adas_one_schemas.sql"

# Elasticsearch 相關前置設定（swap / sysctl / limits）
setup_elasticsearch_prereq() {
    # 關閉 swap（僅針對當前開機，永久關閉仍需手動編輯 /etc/fstab）
    sudo swapoff -a

    # sysctl 參數
    sudo bash -c 'cat >/etc/sysctl.d/99-elasticsearch.conf <<EOF
vm.max_map_count=262144
vm.swappiness=0
fs.file-max=65536
EOF'
    sudo sysctl --system

    # limits 設定，若尚未寫入則追加
    sudo bash -c 'if ! grep -q "elasticsearch soft nofile" /etc/security/limits.conf; then
cat >>/etc/security/limits.conf <<EOF
elasticsearch soft nofile 65536
elasticsearch hard nofile 65536
elasticsearch soft nproc 4096
elasticsearch hard nproc 4096
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited
EOF
fi'
}

# Elasticsearch 安裝流程（8.x）
install_elasticsearch() {
    setup_elasticsearch_prereq

    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl gnupg2 apt-transport-https lsb-release

    sudo mkdir -p /usr/share/keyrings
    curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch \
      | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
      | sudo tee /etc/apt/sources.list.d/elasticsearch-8.x.list

    sudo apt update
    sudo apt install -y elasticsearch

    # 建立必要的目錄並設定權限（避免啟動失敗）
    echo "==> 設定目錄權限..."
    sudo mkdir -p /var/lib/elasticsearch
    sudo mkdir -p /var/log/elasticsearch
    sudo mkdir -p /etc/elasticsearch
    sudo mkdir -p /usr/share/elasticsearch/logs
    
    sudo chown -R elasticsearch:elasticsearch /var/lib/elasticsearch
    sudo chown -R elasticsearch:elasticsearch /var/log/elasticsearch
    sudo chown -R elasticsearch:elasticsearch /etc/elasticsearch
    sudo chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
    
    sudo chmod 750 /var/lib/elasticsearch
    sudo chmod 750 /var/log/elasticsearch
    sudo chmod 750 /etc/elasticsearch

    # systemd 服務限制：MEMLOCK
    sudo mkdir -p /etc/systemd/system/elasticsearch.service.d
    sudo bash -c 'cat >/etc/systemd/system/elasticsearch.service.d/override.conf <<EOF
[Service]
LimitMEMLOCK=infinity
EOF'

    sudo systemctl daemon-reload
    sudo systemctl enable elasticsearch
    sudo systemctl start elasticsearch

    echo "==> 等待 Elasticsearch 啟動..."
    sleep 10

    # 檢查服務狀態
    if sudo systemctl is-active --quiet elasticsearch; then
        echo "✓ Elasticsearch 安裝與啟動成功！"
        echo ""
        echo "提示：如需重設 elastic 使用者密碼，請執行："
        echo "  sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic"
    else
        echo "⚠ Elasticsearch 啟動可能有問題，請檢查日誌："
        echo "  sudo journalctl -u elasticsearch.service -n 50"
    fi
}

# Kibana 安裝流程（8.x）
install_kibana() {
    # 確保 Elasticsearch 的 APT 源已配置
    if [ ! -f /etc/apt/sources.list.d/elasticsearch-8.x.list ]; then
        echo "==> 配置 Elasticsearch APT 源..."
        sudo mkdir -p /usr/share/keyrings
        curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch \
          | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

        echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
          | sudo tee /etc/apt/sources.list.d/elasticsearch-8.x.list
    fi

    # 安裝 Kibana
    echo "==> 安裝 Kibana..."
    sudo apt update
    sudo apt install -y kibana

    # 建立必要的目錄並設定權限（避免啟動失敗）
    echo "==> 設定目錄權限..."
    sudo mkdir -p /var/lib/kibana
    sudo mkdir -p /var/log/kibana
    sudo mkdir -p /etc/kibana
    sudo mkdir -p /usr/share/kibana
    sudo mkdir -p /var/run/kibana
    
    sudo chown -R kibana:kibana /var/lib/kibana
    sudo chown -R kibana:kibana /var/log/kibana
    sudo chown -R kibana:kibana /etc/kibana
    sudo chown -R kibana:kibana /usr/share/kibana
    sudo chown -R kibana:kibana /var/run/kibana
    
    sudo chmod 750 /var/lib/kibana
    sudo chmod 750 /var/log/kibana
    sudo chmod 750 /etc/kibana
    sudo chmod 755 /var/run/kibana

    # 配置 kibana.yml
    echo "==> 配置 Kibana 設定檔..."
    sudo bash -c 'cat >>/etc/kibana/kibana.yml <<EOF

# 基本網路設定
server.port: 5601
server.host: "0.0.0.0"
server.publicBaseUrl: "http://0.0.0.0:5601"

# 中文界面（可選）
i18n.locale: "zh-CN"
EOF'

    # 啟動並啟用 Kibana 服務
    echo "==> 啟動 Kibana 服務..."
    sudo systemctl daemon-reload
    sudo systemctl enable kibana
    sudo systemctl start kibana
    
    # 等待 Kibana 啟動
    echo "==> 等待 Kibana 啟動..."
    sleep 10
    
    # 檢查服務狀態
    if sudo systemctl is-active --quiet kibana; then
        echo "✓ Kibana 安裝與啟動成功！"
        echo ""
        echo "監聽位址：http://0.0.0.0:5601"
        echo ""
        echo "後續設定步驟："
        echo "1. 生成 Enrollment Token："
        echo "   sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana"
        echo ""
        echo "2. 訪問 http://<伺服器IP>:5601 並輸入 Token"
        echo ""
        echo "3. 生成驗證碼："
        echo "   sudo /usr/share/kibana/bin/kibana-verification-code"
    else
        echo "⚠ Kibana 啟動可能有問題，請檢查日誌："
        echo "  sudo journalctl -u kibana.service -n 50"
        echo "  sudo systemctl status kibana"
    fi
}

if [ -z "$CMD" ] ; then
    echo 'basic           >> For Basic install include GRUB, rcS, Basic package'
    echo 'env             >> For Install ENV package '
    echo 'elasticsearch   >> For Install Elasticsearch '
    echo 'kibana          >> For Install kibana '
    echo 'mysql           >> For Install MySQL '
    exit 0
fi

case "${CMD}" in
    basic)
        #安裝必要的系統套件
        sudo apt update
        sudo apt install -y curl wget git build-essential lsof procps net-tools

        # 安裝 Node.js
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs

        # git安裝
        sudo apt-get install git
        
        # npm安裝
        sudo apt install npm

        # mcp proxy安裝
        sudo apt install -y python3 python3-pip
        sudo apt install -y pipx
        pipx ensurepath
        source ~/.bashrc
        pipx install mcp-proxy

        # 驗證安裝
        which mcp-proxy
        mcp-proxy --version

        # 安裝 Docker
        sudo apt update
        sudo apt install -y docker.io docker-compose
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker "$USER"

        # 安裝 Elasticsearch（依新版 SOP）
        install_elasticsearch

        # 安裝 Kibana
        install_kibana

        # 移除既有 MySQL（如果有的話）
        echo "==> 停止並移除舊版 MySQL..."
        sudo systemctl stop mysql >/dev/null 2>&1 || true
        sudo apt purge -y mysql-server mysql-client mysql-common
        sudo apt autoremove -y
        sudo apt autoclean -y
        
        # 完整清理 MySQL 相關目錄
        echo "==> 清理 MySQL 相關目錄..."
        sudo rm -rf /var/lib/mysql
        sudo rm -rf /etc/mysql
        sudo rm -rf /var/log/mysql
        sudo rm -rf /var/run/mysqld

        # 安裝 MySQL
        echo "==> 安裝 MySQL..."
        sudo apt update
        sudo apt install -y mysql-server

        # 建立並設定必要的目錄權限（避免啟動失敗）
        echo "==> 設定目錄權限..."
        sudo mkdir -p /var/lib/mysql
        sudo mkdir -p /var/log/mysql
        sudo mkdir -p /var/run/mysqld
        sudo mkdir -p /etc/mysql
        
        sudo chown -R mysql:mysql /var/lib/mysql
        sudo chown -R mysql:mysql /var/log/mysql
        sudo chown -R mysql:mysql /var/run/mysqld
        
        sudo chmod 750 /var/lib/mysql
        sudo chmod 750 /var/log/mysql
        sudo chmod 755 /var/run/mysqld

        # 啟動 MySQL 服務
        sudo systemctl enable mysql
        sudo systemctl start mysql
        
        # 等待 MySQL 啟動
        echo "==> 等待 MySQL 啟動..."
        sleep 5
        
        # 檢查 MySQL 是否正常啟動
        if ! sudo systemctl is-active --quiet mysql; then
            echo "⚠ MySQL 啟動失敗，請檢查日誌："
            echo "  sudo journalctl -u mysql.service -n 50"
            exit 1
        fi
        
        echo "✓ MySQL 啟動成功！"
        echo "==> 建立資料庫與帳號（${MYSQL_DB} / ${MYSQL_USER})..."

        # 使用 auth_socket 認證（透過 sudo），root 不需要設定密碼
        sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

        echo "==> 調整 MySQL bind-address 允許外部連線..."

        # 修改 /etc/mysql/mysql.conf.d/mysqld.cnf
        if [ -f /etc/mysql/mysql.conf.d/mysqld.cnf ]; then
            sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
            sudo sed -i "s/^bind_address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
        else
            echo "WARN: 找不到 mysqld.cnf，略過 bind-address 設定"
        fi

        echo "==> 重啟 MySQL 讓設定生效..."
        sudo systemctl restart mysql
        
        # 再次檢查啟動狀態
        sleep 3
        if ! sudo systemctl is-active --quiet mysql; then
            echo "⚠ MySQL 重啟後無法正常運行"
            exit 1
        fi

        # 匯入 schema（如果檔案存在）
        if [ -f "${SCHEMA_FILE}" ]; then
            echo "==> 匯入 schema 檔：${SCHEMA_FILE}"
            sudo mysql "${MYSQL_DB}" < "${SCHEMA_FILE}"
            echo "✓ Schema 匯入完成"
        else
            echo "WARN: 找不到 schema 檔 ${SCHEMA_FILE}，略過匯入"
        fi

        echo "✓ MySQL 初始化完成！"

        echo ""
        echo "=========================================="
        echo "基本環境安裝完成！"
        echo "=========================================="
        echo ""
        echo "Kibana 後續設定："
        echo "1. 生成 Kibana Enrollment Token："
        echo "   sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana"
        echo ""
        echo "2. 訪問 http://<伺服器IP>:5601 並輸入 Token"
        echo ""
        echo "3. 生成驗證碼："
        echo "   sudo /usr/share/kibana/bin/kibana-verification-code"
        echo "=========================================="
    ;;
    env)
        #安裝必要的系統套件
        sudo apt update
        sudo apt install -y curl wget git build-essential lsof procps net-tools

        # 安裝 Node.js
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs

        # git安裝
        sudo apt-get install git
        
        # npm安裝
        sudo apt install npm

        # mcp proxy安裝
        sudo apt install -y python3 python3-pip
        sudo apt install -y pipx
        pipx ensurepath
        source ~/.bashrc
        pipx install mcp-proxy

        # 驗證安裝
        which mcp-proxy
        mcp-proxy --version

        # 安裝 Docker
        sudo apt update
        sudo apt install -y docker.io docker-compose
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker "$USER"
    ;;
    elasticsearch)
        # 移除舊版 Elasticsearch
        echo "==> 停止並移除舊版 Elasticsearch..."
        sudo systemctl stop elasticsearch 2>/dev/null || true
        sudo systemctl disable elasticsearch 2>/dev/null || true
        sudo apt purge elasticsearch -y
        sudo apt autoremove -y
        
        # 完整清理所有相關目錄和檔案
        echo "==> 清理 Elasticsearch 相關目錄..."
        sudo rm -rf /var/lib/elasticsearch
        sudo rm -rf /etc/elasticsearch
        sudo rm -rf /var/log/elasticsearch
        sudo rm -rf /usr/share/elasticsearch
        sudo rm -rf /var/run/elasticsearch
        
        # 清理 systemd 相關檔案
        sudo rm -f /lib/systemd/system/elasticsearch.service
        sudo rm -rf /etc/systemd/system/elasticsearch.service.d
        sudo rm -f /etc/systemd/system/multi-user.target.wants/elasticsearch.service
        
        # 清理 APT 源和金鑰
        sudo rm -f /etc/apt/sources.list.d/elasticsearch-8.x.list
        sudo rm -f /usr/share/keyrings/elasticsearch-keyring.gpg
        
        sudo systemctl daemon-reload
        sudo systemctl reset-failed 2>/dev/null || true
        sudo apt update
        
        echo "✓ 舊 Elasticsearch 已徹底移除。"
        echo ""

        # 依新版 SOP 重新安裝 Elasticsearch
        install_elasticsearch
    ;;
    kibana)
        # 移除舊版 Kibana
        echo "==> 停止並移除舊版 Kibana..."
        sudo systemctl stop kibana 2>/dev/null || true
        sudo systemctl disable kibana 2>/dev/null || true
        sudo apt purge kibana -y
        sudo apt autoremove -y
        
        # 完整清理所有相關目錄和檔案
        echo "==> 清理 Kibana 相關目錄..."
        sudo rm -rf /var/lib/kibana
        sudo rm -rf /etc/kibana
        sudo rm -rf /var/log/kibana
        sudo rm -rf /usr/share/kibana
        sudo rm -rf /var/run/kibana
        
        # 清理 systemd 相關檔案
        sudo rm -f /lib/systemd/system/kibana.service
        sudo rm -rf /etc/systemd/system/kibana.service.d
        sudo rm -f /etc/systemd/system/multi-user.target.wants/kibana.service
        
        sudo systemctl daemon-reload
        sudo systemctl reset-failed 2>/dev/null || true
        
        echo "✓ 舊 Kibana 已徹底移除。"
        echo ""
        
        # 使用 install_kibana 函數重新安裝
        install_kibana

        # 顯示額外的設定說明（install_kibana 已經顯示基本說明）
        echo ""
        echo "=========================================="
        echo "額外提示："
        echo "=========================================="
        echo "如需設定 kibana_system 使用者密碼："
        echo "  sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u kibana_system"
        echo ""
        echo "檢查服務狀態："
        echo "  sudo systemctl status kibana"
        echo ""
        echo "查看日誌："
        echo "  sudo journalctl -u kibana.service -f"
        echo "=========================================="
    ;;
    mysql)
        # 移除既有 MySQL（如果有的話）
        echo "==> 停止並移除舊版 MySQL..."
        sudo systemctl stop mysql >/dev/null 2>&1 || true
        sudo apt purge -y mysql-server mysql-client mysql-common
        sudo apt autoremove -y
        sudo apt autoclean -y
        
        # 完整清理 MySQL 相關目錄
        echo "==> 清理 MySQL 相關目錄..."
        sudo rm -rf /var/lib/mysql
        sudo rm -rf /etc/mysql
        sudo rm -rf /var/log/mysql
        sudo rm -rf /var/run/mysqld

        # 安裝 MySQL
        echo "==> 安裝 MySQL..."
        sudo apt update
        sudo apt install -y mysql-server

        # 建立並設定必要的目錄權限（避免啟動失敗）
        echo "==> 設定目錄權限..."
        sudo mkdir -p /var/lib/mysql
        sudo mkdir -p /var/log/mysql
        sudo mkdir -p /var/run/mysqld
        sudo mkdir -p /etc/mysql
        
        sudo chown -R mysql:mysql /var/lib/mysql
        sudo chown -R mysql:mysql /var/log/mysql
        sudo chown -R mysql:mysql /var/run/mysqld
        
        sudo chmod 750 /var/lib/mysql
        sudo chmod 750 /var/log/mysql
        sudo chmod 755 /var/run/mysqld

        # 啟動 MySQL 服務
        sudo systemctl enable mysql
        sudo systemctl start mysql
        
        # 等待 MySQL 啟動
        echo "==> 等待 MySQL 啟動..."
        sleep 5
        
        # 檢查 MySQL 是否正常啟動
        if ! sudo systemctl is-active --quiet mysql; then
            echo "⚠ MySQL 啟動失敗，請檢查日誌："
            echo "  sudo journalctl -u mysql.service -n 50"
            echo "  sudo cat /var/log/mysql/error.log"
            exit 1
        fi
        
        echo "✓ MySQL 啟動成功！"
        echo "==> 建立資料庫與帳號（${MYSQL_DB} / ${MYSQL_USER})..."

        # 使用 auth_socket 認證（透過 sudo），root 不需要設定密碼
        sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

        echo "==> 調整 MySQL bind-address 允許外部連線..."

        # 修改 /etc/mysql/mysql.conf.d/mysqld.cnf
        if [ -f /etc/mysql/mysql.conf.d/mysqld.cnf ]; then
            sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
            sudo sed -i "s/^bind_address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
        else
            echo "WARN: 找不到 mysqld.cnf，略過 bind-address 設定"
        fi

        echo "==> 重啟 MySQL 讓設定生效..."
        sudo systemctl restart mysql
        
        # 再次檢查啟動狀態
        sleep 3
        if ! sudo systemctl is-active --quiet mysql; then
            echo "⚠ MySQL 重啟後無法正常運行"
            exit 1
        fi

        # 匯入 schema（如果檔案存在）
        if [ -f "${SCHEMA_FILE}" ]; then
            echo "==> 匯入 schema 檔：${SCHEMA_FILE}"
            sudo mysql "${MYSQL_DB}" < "${SCHEMA_FILE}"
            echo "✓ Schema 匯入完成"
        else
            echo "WARN: 找不到 schema 檔 ${SCHEMA_FILE}，略過匯入"
        fi

        echo ""
        echo "=========================================="
        echo "✓ MySQL 初始化完成！"
        echo "=========================================="
        echo "資料庫：${MYSQL_DB}"
        echo "使用者：${MYSQL_USER}"
        echo "密碼：${MYSQL_PASS}"
        echo ""
        echo "連線方式："
        echo "  sudo mysql                          # root 使用 auth_socket"
        echo "  mysql -u${MYSQL_USER} -p${MYSQL_PASS}  # 一般使用者"
        echo ""
        echo "檢查狀態："
        echo "  sudo systemctl status mysql"
        echo "=========================================="
    ;;
esac

exit 0
