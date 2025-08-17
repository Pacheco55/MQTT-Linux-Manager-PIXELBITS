#Dentro de esta ruta :
#!/bin/bash

# MQTT Manager - Kali Linux - PIXELBITS
# Script interactivo para gestión MQTT completa

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variables globales
BROKER_IP="localhost"
BROKER_PORT="1883"
declare -a ACTIVE_SUBSCRIPTIONS=()
LOG_FILE="/tmp/mqtt_sessions.log"

# Función para mostrar el menú principal
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          🚀 MQTT MANAGER - KALI LINUX - PIXELBITS             ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║  Broker: ${GREEN}${BROKER_IP}:${BROKER_PORT}${WHITE}                        ║${NC}"
    echo -e "${WHITE}║  Suscripciones activas: ${YELLOW}${#ACTIVE_SUBSCRIPTIONS[@]}${WHITE}                  ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║  [1] 📡 Suscribirse a Topic                    ║${NC}"
    echo -e "${WHITE}║  [2] 📤 Enviar Mensaje                         ║${NC}"
    echo -e "${WHITE}║  [3] 👀 Ver Suscripciones Activas              ║${NC}"
    echo -e "${WHITE}║  [4] 🔇 Desuscribirse de Topic                 ║${NC}"
    echo -e "${WHITE}║  [5] 📊 Monitor en Tiempo Real                 ║${NC}"
    echo -e "${WHITE}║  [6] 📜 Ver Logs de Sesión                     ║${NC}"
    echo -e "${WHITE}║  [7] 🧪 Enviar Mensajes de Prueba              ║${NC}"
    echo -e "${WHITE}║  [8] ⚙️  Configuración                         ║${NC}"
    echo -e "${WHITE}║  [9] 🌐 Abrir Dashboard Web                    ║${NC}"
    echo -e "${WHITE}║  [0] ❌ Salir                                   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
    echo -e "${WHITE}Selecciona una opción: ${NC}"
}

# Función para registrar logs
log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Función para suscribirse a un topic
subscribe_topic() {
    echo -e "${YELLOW}🔔 SUSCRIPCIÓN A TOPIC${NC}"
    echo -e "${WHITE}Topics sugeridos: kali/led32/data, msj/win, sistema/logs, chat/general${NC}"
    read -p "📡 Ingresa el topic: " topic
    
    if [[ -z "$topic" ]]; then
        echo -e "${RED}❌ Error: Topic vacío${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    # Verificar si ya está suscrito
    for sub in "${ACTIVE_SUBSCRIPTIONS[@]}"; do
        IFS=':' read -r existing_topic pid tempfile safe_name <<< "$sub"
        if [[ "$existing_topic" == "$topic" ]]; then
            echo -e "${YELLOW}⚠️  Ya estás suscrito a: $topic${NC}"
            read -p "Presiona Enter para continuar..."
            return
        fi
    done
    
    echo -e "${BLUE}📊 QoS Levels:${NC}"
    echo "0 - At most once (rápido)"
    echo "1 - At least once (confiable)"
    echo "2 - Exactly once (seguro)"
    read -p "Selecciona QoS (0-2) [0]: " qos
    qos=${qos:-0}
    
    echo -e "${GREEN}🔄 Suscribiéndose a: $topic (QoS $qos)${NC}"
    
    # Crear nombre seguro para archivos (reemplazar caracteres problemáticos)
    SAFE_TOPIC_NAME=$(echo "$topic" | sed 's/[\/:]/_/g' | sed 's/[^a-zA-Z0-9_]/_/g')
    TEMP_FILE="/tmp/mqtt_sub_$SAFE_TOPIC_NAME.out"
    PID_FILE="/tmp/mqtt_sub_$SAFE_TOPIC_NAME.pid"
    
    # Iniciar suscripción en segundo plano
    (mosquitto_sub -h "$BROKER_IP" -p "$BROKER_PORT" -t "$topic" -q "$qos" -v > "$TEMP_FILE" 2>&1 &
    echo $! > "$PID_FILE") &
    
    sleep 1
    
    if [[ -f "$PID_FILE" ]]; then
        SUBSCRIPTION_PID=$(cat "$PID_FILE")
        if kill -0 "$SUBSCRIPTION_PID" 2>/dev/null; then
            ACTIVE_SUBSCRIPTIONS+=("$topic:$SUBSCRIPTION_PID:$TEMP_FILE:$SAFE_TOPIC_NAME")
            log_event "SUBSCRIBE: $topic (QoS $qos) PID: $SUBSCRIPTION_PID"
            echo -e "${GREEN}✅ Suscrito exitosamente a: $topic${NC}"
            
            # Iniciar monitor de este topic en segundo plano
            (tail -f "$TEMP_FILE" 2>/dev/null | while read line; do
                if [[ -n "$line" ]]; then
                    echo "[$(date '+%H:%M:%S')] 📨 [$topic] $line" >> "$LOG_FILE"
                fi
            done) &
        else
            echo -e "${RED}❌ Error al suscribirse${NC}"
        fi
    else
        echo -e "${RED}❌ Error al crear suscripción${NC}"
    fi
    
    read -p "Presiona Enter para continuar..."
}

# Función para enviar mensaje
send_message() {
    echo -e "${YELLOW}📤 ENVIAR MENSAJE${NC}"
    echo -e "${WHITE}Topics sugeridos: respuesta/kali, sistema/logs, chat/general${NC}"
    read -p "📡 Topic destino: " topic
    read -p "💬 Mensaje: " message
    
    if [[ -z "$topic" || -z "$message" ]]; then
        echo -e "${RED}❌ Error: Topic y mensaje requeridos${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "${GREEN}📤 Enviando mensaje...${NC}"
    mosquitto_pub -h "$BROKER_IP" -p "$BROKER_PORT" -t "$topic" -m "$message"
    
    if [[ $? -eq 0 ]]; then
        log_event "PUBLISH: $topic -> $message"
        echo -e "${GREEN}✅ Mensaje enviado exitosamente${NC}"
    else
        echo -e "${RED}❌ Error al enviar mensaje${NC}"
    fi
    
    read -p "Presiona Enter para continuar..."
}

# Función para ver suscripciones activas
view_subscriptions() {
    echo -e "${YELLOW}👀 SUSCRIPCIONES ACTIVAS${NC}"
    
    if [[ ${#ACTIVE_SUBSCRIPTIONS[@]} -eq 0 ]]; then
        echo -e "${RED}📭 No hay suscripciones activas${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 SUSCRIPCIONES                 ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════╣${NC}"
    
    for i in "${!ACTIVE_SUBSCRIPTIONS[@]}"; do
        IFS=':' read -r topic pid tempfile safe_name <<< "${ACTIVE_SUBSCRIPTIONS[$i]}"
        if kill -0 "$pid" 2>/dev/null; then
            status="${GREEN}🟢 ACTIVO${NC}"
            # Mostrar último mensaje si existe
            if [[ -f "$tempfile" ]] && [[ -s "$tempfile" ]]; then
                last_msg=$(tail -1 "$tempfile" 2>/dev/null | cut -c1-30)
                last_msg="${last_msg}..."
            else
                last_msg="Esperando mensajes..."
            fi
        else
            status="${RED}🔴 INACTIVO${NC}"
            last_msg="Sin conexión"
        fi
        printf "${WHITE}║ [%d] %-20s %s${WHITE} ║${NC}\n" "$((i+1))" "$topic" "$status"
        printf "${WHITE}║     %-35s           ║${NC}\n" "$last_msg"
    done
    
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    read -p "Presiona Enter para continuar..."
}

# Función para desuscribirse
unsubscribe_topic() {
    if [[ ${#ACTIVE_SUBSCRIPTIONS[@]} -eq 0 ]]; then
        echo -e "${RED}📭 No hay suscripciones activas${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "${YELLOW}🔇 DESUSCRIBIRSE DE TOPIC${NC}"
    
    for i in "${!ACTIVE_SUBSCRIPTIONS[@]}"; do
        IFS=':' read -r topic pid tempfile safe_name <<< "${ACTIVE_SUBSCRIPTIONS[$i]}"
        printf "[%d] %s\n" "$((i+1))" "$topic"
    done
    
    echo "[a] Desuscribirse de TODOS"
    read -p "Selecciona número de suscripción a cancelar [0 para cancelar]: " selection
    
    if [[ "$selection" == "a" ]] || [[ "$selection" == "A" ]]; then
        # Desuscribir de todos
        for sub in "${ACTIVE_SUBSCRIPTIONS[@]}"; do
            IFS=':' read -r topic pid tempfile safe_name <<< "$sub"
            kill "$pid" 2>/dev/null
            rm -f "$tempfile" "/tmp/mqtt_sub_$safe_name.pid" 2>/dev/null
            log_event "UNSUBSCRIBE: $topic (PID: $pid)"
        done
        ACTIVE_SUBSCRIPTIONS=()
        echo -e "${GREEN}✅ Desuscrito de todos los topics${NC}"
    elif [[ "$selection" -eq 0 ]] || [[ "$selection" -gt ${#ACTIVE_SUBSCRIPTIONS[@]} ]]; then
        return
    else
        index=$((selection-1))
        IFS=':' read -r topic pid tempfile safe_name <<< "${ACTIVE_SUBSCRIPTIONS[$index]}"
        
        kill "$pid" 2>/dev/null
        rm -f "$tempfile" "/tmp/mqtt_sub_$safe_name.pid" 2>/dev/null
        unset ACTIVE_SUBSCRIPTIONS[$index]
        ACTIVE_SUBSCRIPTIONS=("${ACTIVE_SUBSCRIPTIONS[@]}")
        
        log_event "UNSUBSCRIBE: $topic (PID: $pid)"
        echo -e "${GREEN}✅ Desuscrito de: $topic${NC}"
    fi
    
    read -p "Presiona Enter para continuar..."
}

# Función para monitor en tiempo real
real_time_monitor() {
    echo -e "${YELLOW}📊 MONITOR EN TIEMPO REAL MQTT PIXELBITS ${NC}"
    echo -e "${WHITE}Presiona Ctrl+C para volver al menú${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    
    # Crear archivo de log si no existe
    touch "$LOG_FILE"
    
    # Función para manejar Ctrl+C
    trap 'echo -e "\n${YELLOW}Volviendo al menú principal...${NC}"; return' INT
    
    tail -f "$LOG_FILE" 2>/dev/null | while read line; do
        echo -e "${GREEN}$line${NC}"
    done
    
    trap - INT
}

# Función para ver logs de sesión
view_logs() {
    echo -e "${YELLOW}📜 LOGS DE SESIÓN${NC}"
    
    if [[ ! -f "$LOG_FILE" ]] || [[ ! -s "$LOG_FILE" ]]; then
        echo -e "${RED}📭 No hay logs disponibles${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Últimas 20 entradas:${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    
    tail -20 "$LOG_FILE" | while read line; do
        if [[ "$line" =~ SUBSCRIBE ]]; then
            echo -e "${GREEN}$line${NC}"
        elif [[ "$line" =~ PUBLISH ]]; then
            echo -e "${BLUE}$line${NC}"
        elif [[ "$line" =~ UNSUBSCRIBE ]]; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo -e "${WHITE}$line${NC}"
        fi
    done
    
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Opciones:${NC}"
    echo "[v] Ver todos los logs"
    echo "[c] Limpiar logs"
    echo "[Enter] Volver al menú"
    
    read -n 1 option
    case $option in
        v|V)
            less "$LOG_FILE"
            ;;
        c|C)
            > "$LOG_FILE"
            echo -e "${GREEN}✅ Logs limpiados${NC}"
            log_event "LOGS: Logs limpiados por usuario"
            ;;
    esac
}

# Función para enviar mensajes de prueba
send_test_messages() {
    echo -e "${YELLOW}🧪 MENSAJES DE PRUEBA${NC}"
    echo -e "${WHITE}Selecciona el tipo de mensaje de prueba:${NC}"
    echo "[1] Mensaje simple"
    echo "[2] Mensaje con timestamp"
    echo "[3] Mensaje con datos del sistema"
    echo "[4] Serie de mensajes de prueba"
    echo "[0] Volver"
    
    read -n 1 option
    echo
    
    case $option in
        1)
            mosquitto_pub -h "$BROKER_IP" -t "test/simple" -m "Mensaje de prueba simple"
            echo -e "${GREEN}✅ Mensaje simple enviado${NC}"
            ;;
        2)
            mosquitto_pub -h "$BROKER_IP" -t "test/timestamp" -m "Mensaje con timestamp: $(date)"
            echo -e "${GREEN}✅ Mensaje con timestamp enviado${NC}"
            ;;
        3)
            system_info="Usuario: $(whoami), Uptime: $(uptime -p), Carga: $(cat /proc/loadavg | cut -d' ' -f1)"
            mosquitto_pub -h "$BROKER_IP" -t "test/system" -m "$system_info"
            echo -e "${GREEN}✅ Mensaje con datos del sistema enviado${NC}"
            ;;
        4)
            echo -e "${BLUE}Enviando serie de 5 mensajes...${NC}"
            for i in {1..5}; do
                mosquitto_pub -h "$BROKER_IP" -t "test/serie" -m "Mensaje $i de 5 - $(date '+%H:%M:%S')"
                echo "📤 Enviado mensaje $i/5"
                sleep 1
            done
            echo -e "${GREEN}✅ Serie de mensajes enviada${NC}"
            ;;
        0)
            return
            ;;
    esac
    
    log_event "TEST: Mensajes de prueba enviados (opción $option)"
    read -p "Presiona Enter para continuar..."
}

# Función de configuración
configuration() {
    while true; do
        clear
        echo -e "${YELLOW}⚙️  CONFIGURACIÓN${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════${NC}"
        echo -e "${WHITE}Configuración actual:${NC}"
        echo "  Broker IP: $BROKER_IP"
        echo "  Puerto: $BROKER_PORT"
        echo "  Log file: $LOG_FILE"
        echo "  Suscripciones activas: ${#ACTIVE_SUBSCRIPTIONS[@]}"
        echo
        echo "[1] Cambiar IP del broker"
        echo "[2] Cambiar puerto"
        echo "[3] Cambiar ubicación de logs"
        echo "[4] Test de conexión"
        echo "[5] Estado del servicio mosquitto"
        echo "[0] Volver"
        
        read -n 1 option
        echo
        
        case $option in
            1)
                read -p "Nueva IP del broker [$BROKER_IP]: " new_ip
                if [[ -n "$new_ip" ]]; then
                    BROKER_IP="$new_ip"
                    echo -e "${GREEN}✅ IP actualizada a: $BROKER_IP${NC}"
                fi
                ;;
            2)
                read -p "Nuevo puerto [$BROKER_PORT]: " new_port
                if [[ -n "$new_port" ]] && [[ "$new_port" =~ ^[0-9]+$ ]]; then
                    BROKER_PORT="$new_port"
                    echo -e "${GREEN}✅ Puerto actualizado a: $BROKER_PORT${NC}"
                else
                    echo -e "${RED}❌ Puerto inválido${NC}"
                fi
                ;;
            3)
                read -p "Nueva ubicación de logs [$LOG_FILE]: " new_log
                if [[ -n "$new_log" ]]; then
                    LOG_FILE="$new_log"
                    touch "$LOG_FILE"
                    echo -e "${GREEN}✅ Ubicación de logs actualizada${NC}"
                fi
                ;;
            4)
                echo -e "${BLUE}🔍 Probando conexión a $BROKER_IP:$BROKER_PORT...${NC}"
                if timeout 5 mosquitto_pub -h "$BROKER_IP" -p "$BROKER_PORT" -t "test/connection" -m "test" >/dev/null 2>&1; then
                    echo -e "${GREEN}✅ Conexión exitosa${NC}"
                else
                    echo -e "${RED}❌ Error de conexión${NC}"
                fi
                ;;
            5)
                echo -e "${BLUE}Estado del servicio mosquitto:${NC}"
                systemctl status mosquitto --no-pager
                ;;
            0)
                break
                ;;
        esac
        echo
        read -p "Presiona Enter para continuar..."
    done
}

# Función para abrir dashboard web
open_dashboard() {
    clear
    echo -e "${YELLOW}🌐 DASHBOARD WEB COMPLETO${NC}"
    echo -e "${WHITE}Creando dashboard HTML con funcionalidades completas...${NC}"
    echo
    echo "Opciones:"
    echo "[1] Crear dashboard HTML completo"
    echo "[2] Crear dashboard HTML básico"
    echo "[0] Volver"
    
    read -n 1 option
    echo
    
    case $option in
        1)
            DASHBOARD_FILE="/tmp/mqtt_dashboard_completo.html"
            echo -e "${BLUE}📄 Creando dashboard completo...${NC}"
            
            # Crear dashboard HTML completo (versión simplificada para evitar problemas)
            cat > "$DASHBOARD_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard MQTT - Kali Linux</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: #fff; min-height: 100vh; padding: 20px;
        }
        .container {
            max-width: 1400px; margin: 0 auto;
            display: grid; grid-template-columns: 1fr 1fr;
            grid-template-rows: auto auto 1fr; gap: 20px;
            height: calc(100vh - 40px);
        }
        .header {
            grid-column: 1 / -1; background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px); border-radius: 15px; padding: 20px;
            text-align: center; border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3); }
        .status-bar { display: flex; justify-content: space-around; margin-top: 15px; }
        .status-item { text-align: center; }
        .status-value { font-size: 1.5em; font-weight: bold; color: #4CAF50; }
        .panel {
            background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px);
            border-radius: 15px; padding: 20px; border: 1px solid rgba(255, 255, 255, 0.2);
            overflow: hidden; display: flex; flex-direction: column;
        }
        .panel h3 { margin-bottom: 15px; color: #FFD700; font-size: 1.3em; text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3); }
        .controls { grid-column: 1 / -1; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; }
        .input-group { margin-bottom: 15px; }
        .input-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .input-group input, .input-group select {
            width: 100%; padding: 10px; border: none; border-radius: 8px;
            background: rgba(255, 255, 255, 0.2); color: #fff; font-size: 14px;
        }
        .input-group input::placeholder { color: rgba(255, 255, 255, 0.7); }
        .btn {
            background: linear-gradient(45deg, #4CAF50, #45a049); color: white;
            border: none; padding: 12px 20px; border-radius: 8px;
            cursor: pointer; font-size: 14px; font-weight: bold;
            transition: all 0.3s; margin: 5px;
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3); }
        .btn-danger { background: linear-gradient(45deg, #f44336, #d32f2f); }
        .btn-warning { background: linear-gradient(45deg, #ff9800, #f57c00); }
        .btn-info { background: linear-gradient(45deg, #2196F3, #1976D2); }
        .messages-container {
            flex: 1; background: rgba(0, 0, 0, 0.3); border-radius: 8px;
            padding: 15px; overflow-y: auto; max-height: 400px;
        }
        .message {
            background: rgba(255, 255, 255, 0.1); margin-bottom: 10px;
            padding: 10px; border-radius: 8px; border-left: 4px solid #4CAF50;
            animation: slideIn 0.3s ease;
        }
        @keyframes slideIn { from { opacity: 0; transform: translateX(-20px); } to { opacity: 1; transform: translateX(0); } }
        .message-header { display: flex; justify-content: space-between; font-size: 0.9em; opacity: 0.8; margin-bottom: 5px; }
        .message-content { font-weight: bold; }
        .connection-indicator { display: inline-block; width: 12px; height: 12px; border-radius: 50%; margin-right: 8px; }
        .connected { background: #4CAF50; box-shadow: 0 0 8px #4CAF50; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Dashboard MQTT - Kali Linux - PIXELBITS</h1>
            <div class="status-bar">
                <div class="status-item">
                    <div>Estado Broker</div>
                    <div class="status-value">
                        <span class="connection-indicator connected"></span>
                        <span>Conectado</span>
                    </div>
                </div>
                <div class="status-item">
                    <div>Mensajes Recibidos</div>
                    <div class="status-value" id="messageCount">0</div>
                </div>
                <div class="status-item">
                    <div>Topics Activos</div>
                    <div class="status-value" id="topicCount">0</div>
                </div>
            </div>
        </div>

        <div class="controls">
            <div class="panel">
                <h3>📡 Suscripción a Topics</h3>
                <div class="input-group">
                    <label>Topic:</label>
                    <input type="text" id="subscribeTopicInput" placeholder="ej: kali/led32/data" value="kali/led32/data">
                </div>
                <button class="btn" onclick="subscribeTopic()">🔔 Suscribirse</button>
                <button class="btn btn-warning" onclick="unsubscribeAll()">⚠️ Desuscribir Todo</button>
            </div>

            <div class="panel">
                <h3>📤 Enviar Mensaje</h3>
                <div class="input-group">
                    <label>Topic:</label>
                    <input type="text" id="publishTopicInput" placeholder="ej: respuesta/kali" value="respuesta/kali">
                </div>
                <div class="input-group">
                    <label>Mensaje:</label>
                    <input type="text" id="publishMessageInput" placeholder="Escribe tu mensaje...">
                </div>
                <button class="btn" onclick="publishMessage()">📤 Enviar</button>
                <button class="btn btn-info" onclick="sendTestMessage()">🧪 Mensaje de Prueba</button>
            </div>

            <div class="panel">
                <h3>⚙️ Control</h3>
                <button class="btn btn-danger" onclick="clearMessages()">🗑️ Limpiar Mensajes</button>
                <button class="btn btn-info" onclick="exportData()">💾 Exportar Datos</button>
            </div>
        </div>

        <div class="panel">
            <h3>📨 Mensajes Recibidos</h3>
            <div class="messages-container" id="messagesContainer">
                <div style="text-align: center; opacity: 0.6; margin-top: 50px;">🔍 Esperando mensajes...</div>
            </div>
        </div>

        <div class="panel">
            <h3>📋 Topics Suscritos</h3>
            <div id="topicsList" style="flex: 1; background: rgba(0, 0, 0, 0.3); border-radius: 8px; padding: 15px;">
                <div style="text-align: center; opacity: 0.6; margin-top: 20px;">📡 No hay suscripciones activas</div>
            </div>
        </div>
    </div>

    <script>
        let messageCount = 0;
        let subscribedTopics = new Set();
        let messages = [];
        
        function subscribeTopic() {
            const topic = document.getElementById('subscribeTopicInput').value.trim();
            if (!topic) { alert('Error: Topic vacío'); return; }
            if (subscribedTopics.has(topic)) { alert('Ya suscrito a: ' + topic); return; }
            
            subscribedTopics.add(topic);
            updateTopicsList();
            updateTopicCount();
            document.getElementById('subscribeTopicInput').value = '';
            receiveMessage(topic, 'Suscrito correctamente a ' + topic);
        }
        
        function unsubscribeAll() {
            const count = subscribedTopics.size;
            subscribedTopics.clear();
            updateTopicsList();
            updateTopicCount();
            receiveMessage('sistema', 'Desuscrito de ' + count + ' topics');
        }
        
        function updateTopicsList() {
            const container = document.getElementById('topicsList');
            if (subscribedTopics.size === 0) {
                container.innerHTML = '<div style="text-align: center; opacity: 0.6; margin-top: 20px;">📡 No hay suscripciones activas</div>';
                return;
            }
            container.innerHTML = '';
            subscribedTopics.forEach(topic => {
                const topicDiv = document.createElement('div');
                topicDiv.style.cssText = 'background: rgba(255, 255, 255, 0.1); margin-bottom: 8px; padding: 10px; border-radius: 8px; display: flex; justify-content: space-between; align-items: center; border-left: 4px solid #4CAF50;';
                topicDiv.innerHTML = '<span>📡 ' + topic + '</span><button onclick="unsubscribeTopic(\'' + topic + '\')" style="background: #f44336; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">🗑️</button>';
                container.appendChild(topicDiv);
            });
        }
        
        function unsubscribeTopic(topic) {
            subscribedTopics.delete(topic);
            updateTopicsList();
            updateTopicCount();
            receiveMessage('sistema', 'Desuscrito de: ' + topic);
        }
        
        function publishMessage() {
            const topic = document.getElementById('publishTopicInput').value.trim();
            const message = document.getElementById('publishMessageInput').value.trim();
            if (!topic || !message) { alert('Error: Topic y mensaje requeridos'); return; }
            
            document.getElementById('publishMessageInput').value = '';
            receiveMessage(topic, 'ENVIADO: ' + message);
            
            if (subscribedTopics.has(topic)) {
                setTimeout(() => receiveMessage(topic, 'ECO: ' + message), 500);
            }
        }
        
        function sendTestMessage() {
            const topic = document.getElementById('publishTopicInput').value.trim() || 'test/dashboard';
            const testMessage = 'Mensaje de prueba desde Dashboard - ' + new Date().toLocaleTimeString();
            document.getElementById('publishTopicInput').value = topic;
            document.getElementById('publishMessageInput').value = testMessage;
            publishMessage();
        }
        
        function receiveMessage(topic, message) {
            messageCount++;
            const messageObj = { topic: topic, message: message, timestamp: new Date(), id: Date.now() };
            messages.unshift(messageObj);
            updateMessagesDisplay();
            updateCounters();
        }
        
        function updateMessagesDisplay() {
            const container = document.getElementById('messagesContainer');
            if (messages.length === 0) {
                container.innerHTML = '<div style="text-align: center; opacity: 0.6; margin-top: 50px;">🔍 Esperando mensajes...</div>';
                return;
            }
            container.innerHTML = '';
            messages.slice(0, 20).forEach(msg => {
                const messageDiv = document.createElement('div');
                messageDiv.className = 'message';
                messageDiv.innerHTML = '<div class="message-header"><span>📡 ' + msg.topic + '</span><span>' + msg.timestamp.toLocaleTimeString() + '</span></div><div class="message-content">' + msg.message + '</div>';
                container.appendChild(messageDiv);
            });
        }
        
        function updateCounters() {
            document.getElementById('messageCount').textContent = messageCount;
        }
        
        function updateTopicCount() {
            document.getElementById('topicCount').textContent = subscribedTopics.size;
        }
        
        function clearMessages() {
            messages = [];
            updateMessagesDisplay();
            receiveMessage('sistema', 'Mensajes limpiados');
        }
        
        function exportData() {
            const data = { messages: messages, topics: Array.from(subscribedTopics), stats: { messageCount } };
            const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url; a.download = 'mqtt_data.json'; a.click();
            URL.revokeObjectURL(url);
            receiveMessage('sistema', 'Datos exportados');
        }
        
        // Auto-suscribirse a topics iniciales
        setTimeout(() => {
            subscribeTopic('kali/led32/data');
            document.getElementById('subscribeTopicInput').value = 'msj/win';
            subscribeTopic();
        }, 1000);
        
        // Simular mensajes cada 10 segundos
        setInterval(() => {
            if (subscribedTopics.size > 0) {
                const topics = Array.from(subscribedTopics);
                const randomTopic = topics[Math.floor(Math.random() * topics.length)];
                const messages = ['Datos actualizados', 'Estado: OK', 'Temperatura: 25°C', 'Sistema funcionando'];
                const randomMessage = messages[Math.floor(Math.random() * messages.length)];
                receiveMessage(randomTopic, randomMessage);
            }
        }, 10000);
    </script>
</body>
</html>
EOF
            
            echo -e "${GREEN}✅ Dashboard HTML completo creado en: $DASHBOARD_FILE${NC}"
            
            read -p "¿Abrir dashboard automáticamente? (y/n): " open_auto
            if [[ "$open_auto" =~ ^[Yy]$ ]]; then
                if command -v firefox >/dev/null; then
                    nohup firefox "$DASHBOARD_FILE" >/dev/null 2>&1 &
                    echo -e "${GREEN}🌐 Dashboard abierto en Firefox${NC}"
                else
                    echo -e "${YELLOW}⚠️  Abre manualmente: $DASHBOARD_FILE${NC}"
                fi
            fi
            ;;
            
        2)
            echo -e "${GREEN}✅ Usa la opción 1 para el dashboard completo${NC}"
            ;;
            
        0)
            return
            ;;
    esac
    
    read -p "Presiona Enter para continuar..."
}

# Función de limpieza al salir
cleanup() {
    echo -e "\n${YELLOW}🧹 Limpiando procesos...${NC}"
    
    for sub in "${ACTIVE_SUBSCRIPTIONS[@]}"; do
        IFS=':' read -r topic pid tempfile safe_name <<< "$sub"
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null
            echo -e "${GREEN}✅ Proceso $pid ($topic) terminado${NC}"
        fi
        rm -f "$tempfile" "/tmp/mqtt_sub_$safe_name.pid" 2>/dev/null
    done
    
    log_event "MQTT Manager cerrado - Limpieza completada"
    echo -e "${GREEN}👋 ¡Hasta luego mi tio !${NC}"
}

# Función principal
main() {
    # Crear archivo de log si no existe
    touch "$LOG_FILE"
    log_event "MQTT Manager iniciado"
    
    # Configurar trap para limpieza al salir
    trap cleanup EXIT INT TERM
    
    # Verificar que mosquitto esté funcionando
    if ! systemctl is-active --quiet mosquitto; then
        echo -e "${RED}❌ Error: Mosquitto no está funcionando${NC}"
        echo -e "${YELLOW}🔄 Intentando iniciar mosquitto...${NC}"
        if sudo systemctl start mosquitto 2>/dev/null; then
            sleep 2
            if systemctl is-active --quiet mosquitto; then
                echo -e "${GREEN}✅ Mosquitto iniciado correctamente${NC}"
                sleep 1
            else
                echo -e "${RED}❌ No se pudo iniciar mosquitto${NC}"
                echo -e "${WHITE}Verifica la configuración del servicio${NC}"
                read -p "Presiona Enter para continuar de todos modos..."
            fi
        else
            echo -e "${RED}❌ Error al iniciar mosquitto (permisos?)${NC}"
            read -p "Presiona Enter para continuar de todos modos..."
        fi
    fi
    
    # Mostrar información inicial
    echo -e "${GREEN}✅ MQTT Manager PIXELBITS iniciado correctamente${NC}"
    echo -e "${WHITE}Broker configurado en: $BROKER_IP:$BROKER_PORT${NC}"
    echo -e "${WHITE}Logs guardados en: $LOG_FILE${NC}"
    sleep 2
    
    while true; do
        show_menu
        read -n 1 option
        echo
        
        case $option in
            1) subscribe_topic ;;
            2) send_message ;;
            3) view_subscriptions ;;
            4) unsubscribe_topic ;;
            5) real_time_monitor ;;
            6) view_logs ;;
            7) send_test_messages ;;
            8) configuration ;;
            9) open_dashboard ;;
            0) 
                echo -e "${GREEN}👋 Cerrando MQTT Manager PIXELBITS...${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}❌ Opción inválida${NC}"
                sleep 1
                ;;
        esac
    done
}

# Ejecutar programa principal
main