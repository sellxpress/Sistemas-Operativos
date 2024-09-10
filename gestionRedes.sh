#!/bin/bash
year=$(date +%Y-%m-%d)
logDir="/root/logsPropios"
logFile="$logDir/gestionRedes.log"

# Verificaca que el directorio y los archivos de logs existan, y si no los crea
mkdir -p "$logDir" && chmod 700 "$logDir"
[ ! -f "$logFile" ] && touch "$logFile" && chmod 600 "$logFile"

function logEvent() {
    echo "$(date +%Y-%m-%d-%H:%M:%S) - $1" >> "$logFile"
}

function menu() {
    clear
    echo "######################"
    echo "  GESTIÓN DE REDES    "
    echo "######################"
    echo "1- Ver configuración de red"
    echo "2- Configurar una nueva IP"
    echo "3- Reiniciar interfaz de red"
    echo "4- Ver tabla de enrutamiento"
    echo "5- Configurar DNS"
    echo "6- Buscar interfaces de red"
    echo "0- Volver al menú principal"
}

function verConfiguracionDeRed() {
    clear
    ip a
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function configurarIP() {
    clear
    read -p "Ingrese el nombre del adaptador de red: " interfaz
    read -p "Ingrese la dirección IP: " ip
    read -p "Ingrese la máscara de subred (ejemplo: 255.255.255.0): " mascara
    read -p "Ingrese la puerta de enlace: " puerta
    read -p "Ingrese el servidor DNS: " dns

    echo "Configurando IP estática en $interfaz..."
    sudo nmcli con mod "$interfaz" ipv4.addresses "$ip/$mascara"
    sudo nmcli con mod "$interfaz" ipv4.gateway "$puerta"
    sudo nmcli con mod "$interfaz" ipv4.dns "$dns"
    sudo nmcli con mod "$interfaz" ipv4.method manual
    sudo nmcli con up "$interfaz"
    
    if [ $? -eq 0 ]; then
        echo "Configuración aplicada correctamente."
        log_event "IP estática configurada en $interfaz: IP=$ip, Máscara=$mascara, Puerta=$puerta, DNS=$dns."
    else
        echo "Error al configurar la IP estática."
        log_event "Error al configurar IP estática en $interfaz."
    fi

    read -p "Presione cualquier tecla para continuar..." -n 1
}

function reiniciarInterfaz() {
    clear
    read -p "Ingrese el nombre del adaptador de red: " interfaz
    if ip link show "$interfaz" &> /dev/null; then
        ip link set "$interfaz" down && ip link set "$interfaz" up
        logEvent "La interfaz $interfaz fue reiniciada."
        echo "Interfaz $interfaz reiniciada correctamente."
    else
        echo "Error: La interfaz $interfaz no existe."
        logEvent "Error al reiniciar la $interfaz."
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function verTablaEnrutamiento() {
    clear
    ip route show
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function configurarDNS() {
    clear
    read -p "Ingrese archivo de configuración de DNS (por defecto /etc/resolv.conf): " archivoDns
    archivoDns=${archivoDns:-/etc/resolv.conf}
    read -p "Ingrese servidor DNS primario: " dnsPrimario
    if [ -n "$dnsPrimario" ]; then
        echo "nameserver $dnsPrimario" | sudo tee "$archivoDns" > /dev/null
        logEvent "DNS primario configurado: $dnsPrimario"
        echo "DNS configurado correctamente."
    else
        echo "Error: No se ingresó un servidor DNS válido."
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function buscarInterfaces() {
    clear
    read -p "Ingrese el nombre del adaptador de red: " interfaz
    if ifconfig -a | grep -q "^$interfaz:"; then
        echo "Información de $interfaz:"
        ifconfig "$interfaz"
    else
        echo "La interfaz $interfaz no existe."
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function main() {
    while true; do
        menu
        echo "######################"
        read -p "Ingrese una opción: " opc
        echo "######################"
        case $opc in
            1) verConfiguracionDeRed ;;
            2) configurarIP ;;
            3) reiniciarInterfaz ;;
            4) verTablaEnrutamiento ;;
            5) configurarDNS ;;
            6) buscarInterfaces ;;
            0) ./menuPrincipal ;;
            *) echo "Opción inválida." ;;
        esac
    done
}

main
