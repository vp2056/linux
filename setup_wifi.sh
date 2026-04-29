#!/bin/bash

echo "=== Configuração de Wi-Fi no Ubuntu Server ==="

# Verifica se é root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root (sudo)"
  exit 1
fi

# Detecta interfaces Wi-Fi
echo "Detectando interfaces Wi-Fi..."
interfaces=$(iw dev | awk '$1=="Interface"{print $2}')

if [ -z "$interfaces" ]; then
  echo "Nenhuma interface Wi-Fi encontrada."
  exit 1
fi

echo "Interfaces encontradas:"
echo "$interfaces"

read -p "Digite a interface Wi-Fi (ex: wlan0): " iface

# Entrada do usuário
read -p "SSID (nome da rede): " ssid
read -s -p "Senha: " password
echo ""

# Arquivo Netplan
netplan_file="/etc/netplan/99-wifi-config.yaml"

# Cria configuração
cat <<EOF > $netplan_file
network:
  version: 2
  wifis:
    $iface:
      dhcp4: true
      access-points:
        "$ssid":
          password: "$password"
EOF

echo "Arquivo Netplan criado em $netplan_file"

# Aplica configuração
netplan generate
netplan apply

echo "Configuração aplicada!"

# Teste de conexão
echo "Testando conexão..."
ping -c 3 8.8.8.8

if [ $? -eq 0 ]; then
  echo "Wi-Fi conectado com sucesso!"
else
  echo "Falha na conexão. Verifique os dados."
fi
