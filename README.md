<img width="1024" height="203" alt="Image" src="https://github.com/user-attachments/assets/14d618cc-fff9-4443-9aa9-48613e3cdc04" />


Monitor en CLI para sistemas Linux especificamente Kali , para testeo de experimentos MQTT abiertos . 

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-lightgrey.svg)](https://github.com)
[![MQTT](https://img.shields.io/badge/MQTT-3.1.1-blue.svg)](https://mqtt.org/)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-green.svg)](https://www.gnu.org/software/bash/)

>  **Herramienta completa de gestión MQTT con dashboard web interactivo**

Una solución integral para monitorear, gestionar y visualizar comunicaciones MQTT entre dispositivos. Incluye un script interactivo de terminal y un dashboard web moderno con funcionalidades avanzadas.


## 📊 Estadísticas del Proyecto

<div align="center">

![GitHub last commit](https://img.shields.io/github/last-commit/Pacheco55/MQTT-Linux-Manager-PIXELBITS?color=orange)
![GitHub issues](https://img.shields.io/github/issues/Pacheco55/MQTT-Linux-Manager-PIXELBITS?color=yellow)
![GitHub stars](https://img.shields.io/github/stars/Pacheco55/MQTT-Linux-Manager-PIXELBITS?style=social)

<img width="265" height="222" alt="Image" src="https://github.com/user-attachments/assets/5a46581e-1623-4af3-9b66-7ddadab679b0" />

<br>

## ✨ Características Principales

### 🎯 **Script de Terminal Interactivo**
- 📡 **Suscripción dinámica** a múltiples topics con QoS configurable
- 📤 **Envío de mensajes** con validación automática
- 👀 **Monitor en tiempo real** de todas las comunicaciones
- 📊 **Estadísticas de sesión** y logs detallados
- ⚙️ **Configuración avanzada** de broker y conexiones
- 🧪 **Mensajes de prueba** automatizados

### 🌐 **Dashboard Web Moderno**
- 🎨 **Interface moderna** con efectos glassmorphism
- 📈 **Visualización en tiempo real** de mensajes y estadísticas
- 🔔 **Notificaciones inteligentes** y alertas visuales
- 💾 **Exportación de datos** en JSON y logs en texto
- 📱 **Diseño responsivo** para todos los dispositivos
- 🎛️ **Control total** de suscripciones y configuraciones

### 🔧 **Funcionalidades Técnicas**
- ✅ Soporte completo para **MQTT 3.1.1**
- ✅ **Multi-plataforma**: Linux, Windows, macOS
- ✅ **Auto-reconexión** y manejo de errores
- ✅ **Logs persistentes** y debugging avanzado
- ✅ **Temas con colores** para mejor visualización
- ✅ **Limpieza automática** de procesos al salir

---

## 🎬 Demostracion de uso 

![Image](https://github.com/user-attachments/assets/128f40fe-55c1-4c9d-bf27-a3176a731fb7)
![Image](https://github.com/user-attachments/assets/d34ab8da-a228-4ed7-bcf7-70d8386d2377)
![Image](https://github.com/user-attachments/assets/65049d1e-b659-4785-aa4b-ba909ecc7895)

```bash
# Instalar y ejecutar en 3 comandos
curl -O https://raw.githubusercontent.com/tu-repo/mqtt-manager.sh
chmod +x mqtt_manager.sh
./mqtt_manager.sh
```

---

## 📦 Instalación Completa

### 🐧 **Linux (Ubuntu/Debian/Kali)**

#### 1. Instalar MQTT Broker (Mosquitto)
```bash
# Actualizar repositorios
sudo apt update && sudo apt upgrade -y

# Instalar mosquitto broker y clientes
sudo apt install mosquitto mosquitto-clients -y

# Iniciar y habilitar el servicio
sudo systemctl start mosquitto
sudo systemctl enable mosquitto

# Verificar estado
sudo systemctl status mosquitto
```

#### 2. Configurar Mosquitto para conexiones externas
```bash
# Crear archivo de configuración
sudo tee /etc/mosquitto/conf.d/external.conf << EOF
listener 1883 0.0.0.0
allow_anonymous true
protocol mqtt
EOF

# Reiniciar servicio
sudo systemctl restart mosquitto

# Configurar firewall
sudo ufw allow 1883
sudo ufw reload
```

#### 3. Instalar MQTT Manager
```bash
# Descargar script
wget https://raw.githubusercontent.com/tu-repo/mqtt-manager.sh

# Dar permisos
chmod +x mqtt_manager.sh

# Ejecutar
./mqtt_manager.sh
```

---

### 🪟 **Windows 10/11**

#### 1. Instalar MQTT Cliente

**Opción A: Con Chocolatey (Recomendado)**
```powershell
# Instalar Chocolatey (como Administrador)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar Mosquitto
choco install mosquitto -y

# Verificar instalación
mosquitto_pub --help
```

**Opción B: Instalación Manual**
1. Descargar desde [mosquitto.org/download](https://mosquitto.org/download/)
2. Instalar en `C:\Program Files\mosquitto\`
3. Agregar al PATH del sistema:
   - `Win + R` → `sysdm.cpl`
   - Opciones avanzadas → Variables de entorno
   - Editar `Path` → Agregar: `C:\Program Files\mosquitto`

#### 2. Configurar Variables de Entorno
```cmd
# Verificar instalación
mosquitto_pub --help

# Si no funciona, agregar manualmente al PATH:
set PATH=%PATH%;C:\Program Files\mosquitto
```

#### 3. Scripts de uso
Crear `mqtt_sender.bat`:
```batch
@echo off
title MQTT Sender - Windows
set BROKER_IP=192.168.1.100 % tu IP %
set TOPIC=msj/win

:loop
set /p mensaje="Mensaje: "
if "%mensaje%"=="exit" goto fin
mosquitto_pub -h %BROKER_IP% -t "%TOPIC%" -m "%mensaje%"
echo [ENVIADO] %mensaje%
goto loop

:fin
pause
```

---

### 🍎 **macOS**

#### 1. Instalar usando Homebrew
```bash
# Instalar Homebrew si no está instalado
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar mosquitto
brew install mosquitto

# Iniciar broker
brew services start mosquitto

# Verificar instalación
mosquitto_pub --help
```

#### 2. Configurar Mosquitto
```bash
# Crear archivo de configuración
sudo mkdir -p /usr/local/etc/mosquitto/conf.d
sudo tee /usr/local/etc/mosquitto/conf.d/external.conf << EOF
listener 1883 0.0.0.0
allow_anonymous true
protocol mqtt
EOF

# Reiniciar servicio
brew services restart mosquitto
```

#### 3. Configurar Firewall (Opcional)
```bash
# Permitir puerto 1883 en firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/sbin/mosquitto
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/sbin/mosquitto
```

---

## 🔧 Configuración de Red

### 📡 **Configuración del Broker**

Para permitir conexiones desde otras máquinas:

```bash
# Editar configuración principal
sudo nano /etc/mosquitto/mosquitto.conf

# Agregar al final:
listener 1883 0.0.0.0
allow_anonymous true
bind_address 0.0.0.0
```

### 🔒 **Configuración de Firewall**

**Linux:**
```bash
sudo ufw allow 1883
sudo iptables -A INPUT -p tcp --dport 1883 -j ACCEPT
```

**Windows:**
```cmd
netsh advfirewall firewall add rule name="MQTT" dir=in action=allow protocol=TCP localport=1883
```

**macOS:**
```bash
sudo pfctl -e
echo "pass in on en0 proto tcp from any to any port 1883" | sudo pfctl -f -
```

---

## 🚀 Uso Rápido

### 🎯 **Script de Terminal**

```bash
# Ejecutar MQTT Manager
./mqtt_manager.sh

# Opciones principales:
[1] 📡 Suscribirse a Topic      # Escuchar mensajes
[2] 📤 Enviar Mensaje           # Enviar datos
[3] 👀 Ver Suscripciones        # Estado actual
[9] 🌐 Dashboard Web            # Interface gráfica
```

### 🌐 **Dashboard Web**

El dashboard se auto-genera en `/tmp/mqtt_dashboard_completo.html`

**Características:**
- ✅ Suscripción visual a topics
- ✅ Envío de mensajes con QoS
- ✅ Monitor en tiempo real
- ✅ Exportación de datos
- ✅ Estadísticas detalladas

---

## 💡 Ejemplos de Uso

### 🔄 **Comunicación entre Windows y Linux**

**En Linux (Kali) - Receptor:**
```bash
# Suscribirse a mensajes de Windows
mosquitto_sub -h localhost -t "windows/data" -v
```

**En Windows - Emisor:**
```cmd
# Enviar mensaje a Linux
mosquitto_pub -h 192.168.1.100 -t "windows/data" -m "Hola desde Windows!"
```

### 🏠 **IoT y Sensores**

**Topics sugeridos:**
```bash
sensor/temperatura/sala      # Temperatura ambiente
sensor/humedad/jardin       # Humedad del suelo
dispositivo/led/cocina      # Control de luces
sistema/alarma/estado       # Estados de seguridad
```

**Ejemplo de sensor:**
```bash
# Simular sensor de temperatura
while true; do
  temp=$(shuf -i 18-28 -n 1)
  mosquitto_pub -h localhost -t "sensor/temperatura/sala" -m "Temperatura: ${temp}°C"
  sleep 30
done
```

### 📊 **Monitoreo de Sistema**

```bash
# Script de monitoreo automático
#!/bin/bash
while true; do
  cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
  ram=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
  
  mosquitto_pub -h localhost -t "sistema/cpu" -m "CPU: ${cpu}%"
  mosquitto_pub -h localhost -t "sistema/ram" -m "RAM: ${ram}%"
  
  sleep 60
done
```

---

## 🐛 Troubleshooting

### ❌ **Problemas Comunes**

**1. "mosquitto_pub: command not found"**
```bash
# Linux/macOS:
which mosquitto_pub
sudo apt install mosquitto-clients  # Ubuntu/Debian
brew install mosquitto              # macOS

# Windows:
# Verificar que esté en PATH o usar ruta completa
"C:\Program Files\mosquitto\mosquitto_pub.exe" --help
```

**2. "Connection refused"**
```bash
# Verificar que mosquitto esté corriendo
sudo systemctl status mosquitto     # Linux
brew services list | grep mosquitto # macOS

# Verificar puerto
sudo netstat -tlnp | grep 1883      # Linux
lsof -i :1883                       # macOS
netstat -an | find "1883"           # Windows
```

**3. "No se puede establecer conexión"**
```bash
# Verificar firewall
sudo ufw status                     # Linux
# Verificar IP del broker
ping [IP_DEL_BROKER]
# Probar conexión
telnet [IP_DEL_BROKER] 1883
```

**4. "Topics con barras dan error"**
```bash
# El script maneja automáticamente caracteres especiales
# Topics válidos: sensor/temp, dispositivo/led, sistema/logs
# Se convierten a nombres de archivo seguros automáticamente
```

### 🔍 **Debugging Avanzado**

```bash
# Logs detallados de mosquitto
sudo tail -f /var/log/mosquitto/mosquitto.log

# Test de conectividad completo
mosquitto_pub -h localhost -t "test/connection" -m "test" -d

# Monitor de red
sudo tcpdump -i any port 1883

# Verificar configuración
sudo mosquitto -c /etc/mosquitto/mosquitto.conf -v
```

---

## 📈 Características Avanzadas

### 🔐 **Seguridad (Opcional)**

```bash
# Habilitar autenticación
sudo mosquitto_passwd -c /etc/mosquitto/passwd usuario1

# Configurar SSL/TLS
sudo nano /etc/mosquitto/conf.d/ssl.conf
```

### 🌐 **WebSocket Support**

```bash
# Habilitar WebSocket para dashboard avanzado
echo "listener 9001" | sudo tee -a /etc/mosquitto/conf.d/websocket.conf
echo "protocol websockets" | sudo tee -a /etc/mosquitto/conf.d/websocket.conf
sudo systemctl restart mosquitto
```

### 📊 **Integración con Grafana**

```bash
# Instalar InfluxDB + Grafana para visualización avanzada
sudo apt install influxdb grafana
# Configurar MQTT → InfluxDB → Grafana pipeline
```

---

##  🛠️ Tecnologias

![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)

![Bash](https://img.shields.io/badge/Bash-Scripting-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

![Linux](https://img.shields.io/badge/Linux-Kernel-000000?style=for-the-badge&logo=linux&logoColor=white)

![Kali Linux](https://img.shields.io/badge/Kali-Linux-557C94?style=for-the-badge&logo=kalilinux&logoColor=white)

![MQTT](https://img.shields.io/badge/MQTT-Protocol-6600CC?style=for-the-badge&logo=mqtt&logoColor=white)

---

## 🏆 Agradecimientos

- 🙏 [Eclipse Mosquitto](https://mosquitto.org/) - MQTT Broker
- KALI LINUX
- 📡 [MQTT.org](https://mqtt.org/) - Protocolo y documentación

---
## **Consideraciones Legales**

**IMPORTANTE**: Este Modelo no deve ser usado para fines comerciales ni para su explotacion con fines de lucro .

**Úsala responsablemente y respeta las leyes locales sobre derechos de autor i propiedad intelectual.**

---

## 🌐 Contacto

<div align="center">

**PIXELBITS Studios** - *Innovación en tecnología embebida*

[![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCkLUjIeYTECtigFdcQjWu5Q)
[![Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://x.com/pixelbitstud)
[![Twitch](https://img.shields.io/badge/Twitch-9146FF?style=for-the-badge&logo=twitch&logoColor=white)](https://www.twitch.tv/pixelbits_studio/about)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:info@pixelbits.studio)

</div>

---

## 📜 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para detalles.

[![License](https://img.shields.io/badge/Licencia-MIT-green.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

---

<div align="center">

### **Hecho con 👽 por PIXELBITS Studios**

**MQTT Linux Manager PIXELBITS Monitor - Porque entender tu entorno es el primer paso hacia la conectividad.**

[![Repository Views](https://komarev.com/ghpvc/?username=pixelbits-opera-num&color=00ff41&style=flat-square&label=Visitas+de+otros+Mundos)](https://github.com/Pacheco55/WiFi-Monitor-ESP32)


</div>
