#!/bin/bash
logDir="/root/logsPropios"
firewallCmd="firewall-cmd"
year=$(date +%Y-%m-%d)

function menu() {
    clear
    echo "#########################"
    echo "  GESTIÓN DE FIREWALL    "
    echo "#########################"
    echo "1- Ver estado del firewall" 
    echo "2- Habilitar firewall"
    echo "3- Deshabilitar firewall"
    echo "4- Agregar regla de firewall"
    echo "5- Eliminar regla de firewall"
    echo "6- Listar reglas de firewall" 
    echo "0- Volver al menú principal"
}

function verificarInstalacion() {
    if ! command -v $firewallCmd &> /dev/null; then
        echo "Error: $firewallCmd no está instalado."
        exit 1
    fi
    [ ! -d "$logDir" ] && mkdir -p "$logDir"
}

function logEvent() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $1" >> "$logDir/firewallGestion.log"
}

function estadoFirewall() {
    clear
    $firewallCmd --state
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function habilitarFirewall() {
    clear
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    logEvent "El firewall fue habilitado."
    echo "El firewall fue habilitado."
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function deshabilitarFirewall() {
    clear
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
    logEvent "El firewall fue deshabilitado."
    echo "El firewall fue deshabilitado."
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function agregarRegla() {
    clear
    echo "Seleccione el tipo de regla a agregar:"
    echo "1) Puerto y protocolo (ej: 80/tcp)"
    echo "2) Servicio (ej: http, ssh)"
    read -p "Ingrese su opción: " opcion

    case $opcion in
        1)
            read -p "Ingrese el puerto y protocolo en formato número/protocolo (ej: 80/tcp): " regla
            if [[ ! "$regla" =~ ^[0-9]+/(tcp|udp)$ ]]; then
                echo "Error: El formato debe ser número/protocolo (ej: 80/tcp)."
                return
            fi
            ;;
        2)
            read -p "Ingrese el nombre del servicio (ej: http, ssh): " regla
            if [[ ! "$regla" =~ ^[a-zA-Z]+$ ]]; then
                echo "Error: El servicio debe contener solo letras (ej: http, ssh)."
                return
            fi
            ;;
        *)
            echo "Opción no válida. Por favor, ingrese 1 o 2."
            return
            ;;
    esac

    # Agregar la regla al firewall
    $firewallCmd --zone=public --add-port="$regla" --permanent
    if [ $? -eq 0 ]; then
        $firewallCmd --reload
        logEvent "Regla agregada: $regla"
        echo "Regla $regla agregada exitosamente."
    else
        echo "Error al agregar la regla $regla."
        logEvent "Error al agregar regla: $regla"
    fi

    read -p "Presione cualquier tecla para continuar..." -n 1
}

function eliminarRegla() {
    clear
    read -p "Ingrese el puerto o servicio a eliminar: " regla
    sudo $firewallCmd --zone=public --remove-port="$regla" --permanent
    if [ $? -eq 0 ]; then
        sudo $firewallCmd --reload
        logEvent "Regla eliminada: $regla"
        echo "Regla $regla eliminada exitosamente."
    else
        echo "Error al eliminar la regla $regla."
        logEvent "Error al eliminar regla: $regla"
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}


function listarReglas() {
    clear
    $firewallCmd --list-all
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function main() {
    verificarInstalacion
    while true; do
        menu
        echo "#########################"
        read -p "Seleccione una opción: " opc
        case $opc in
            1) estadoFirewall ;;
            2) habilitarFirewall ;;
            3) deshabilitarFirewall ;;
            4) agregarRegla ;;
            5) eliminarRegla ;;
            6) listarReglas ;;
            0) ./menuPrincipal ;;  # Asegúrate de que el script menuPrincipal exista y sea ejecutable
            *) echo "Opción incorrecta." ;;
        esac
    done
}

main
