#!/bin/bash

# Verificar que el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root o con sudo."
    exit 1
fi

# Obtener la versión de Ubuntu
UBUNTU_VERSION=$(lsb_release -r | awk '{print $2}')

# Verificar si es Ubuntu 22
if [[ "$UBUNTU_VERSION" != "22."* ]]; then
    echo "Este script solo es compatible con Ubuntu 22."
    exit 1
fi

echo "Sistema operativo validado: Ubuntu $UBUNTU_VERSION"

# Actualizar paquetes
echo "Actualizando paquetes..."
apt update -y && apt upgrade -y

# Función para verificar si un paquete está instalado
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Instalar Apache si no está instalado
if is_installed apache2; then
    echo "Apache ya está instalado."
else
    echo "Instalando Apache..."
    apt install apache2 -y
    systemctl enable apache2
    systemctl start apache2
fi

# Instalar Node.js si no está instalado
if command -v node &>/dev/null; then
    echo "Node.js ya está instalado. Versión: $(node -v)"
else
    echo "Instalando Node.js..."
    apt install -y nodejs npm
fi

# Instalar Java 17 si no está instalado
if java -version 2>&1 | grep -q "17."; then
    echo "Java 17 ya está instalado."
else
    echo "Instalando OpenJDK 17..."
    apt install -y openjdk-17-jdk
fi

# Instalar MySQL Server si no está instalado
if is_installed mysql-server; then
    echo "MySQL ya está instalado."
else
    echo "Instalando MySQL Server..."
    apt install -y mysql-server
    systemctl enable mysql
    systemctl start mysql
    echo "Ejecutando mysql_secure_installation..."
    mysql_secure_installation
fi

# Mostrar versiones instaladas
echo "Verificación de instalaciones:"
echo "Apache: $(apache2 -v | grep 'Server version' || echo 'No instalado')"
echo "Node.js: $(node -v || echo 'No instalado')"
echo "Java: $(java -version 2>&1 | head -n 1 || echo 'No instalado')"
echo "MySQL: $(mysql --version || echo 'No instalado')"

echo "Instalación completada con éxito."
