#!/bin/bash
year=$(date +%Y-%m-%d)
logFile="/root/logsPropios/gestionRedes.log"
sshService="sshd"
loginService="login"

function logEvent() {
    echo "$(date +%Y-%m-%d-%H:%M:%S) - $1" >> "$logFile"
}

function menu() {
    clear
    echo "##############################"
    echo "  GESTIÓN DE LOGS DE LOGIN    "
    echo "##############################"
    echo "1- Ver intentos de login exitosos por SSH"
    echo "2- Ver intentos de login fallidos por SSH"
    echo "3- Ver todos los logs de login por SSH" 
    echo "4- Exportar logs de login por SSH a un archivo"
    echo "5- Ver intentos de login exitosos locales"
    echo "6- Ver intentos de login fallidos locales"
    echo "7- Ver todos los logs de login locales"
    echo "8- Exportar logs de login locales a un archivo"
    echo "0- Volver al menú principal"
}

function mostrarLogs() {
    local servicio=$1
    local patron=$2
    local mensaje=$3
    clear
    echo "$mensaje"
    journalctl -u "$servicio" | grep "$patron"
    echo " "
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function exportarLogs() {
    local servicio=$1
    local patron=$2
    local mensaje=$3
    clear
    read -p "Ingrese la ruta del archivo de salida: " archivoSalida
    if [[ -z "$archivoSalida" ]]; then
        echo "Error: La ruta del archivo no puede estar vacía."
        logEvent "Error en exportación de logs: Ruta del archivo vacía."
    elif [ ! -d "$(dirname "$archivoSalida")" ]; then
        echo "Error: El directorio no existe."
        logEvent "Error en exportación de logs: Directorio no existe."
    else
        if journalctl -u "$servicio" | grep "$patron" > "$archivoSalida"; then
            echo "$mensaje exportados correctamente a $archivoSalida."
            logEvent "$mensaje exportados a $archivoSalida."
        else
            echo "Error al exportar los $mensaje."
            logEvent "Error al exportar los $mensaje a $archivoSalida."
        fi
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}


function main() {
    local opc=1
    while [ $opc -ne 0 ]; do
        menu
        echo "##############################"
        read -p "Ingrese una opción: " opc
        case $opc in
            1) mostrarLogs "$sshService" "Accepted" "Mostrando intentos de login exitosos mediante SSH" ;;
            2) mostrarLogs "$sshService" "Failed" "Mostrando intentos de login fallidos mediante SSH" ;;
            3) mostrarLogs "$sshService" "Accepted\|Failed" "Mostrando todos los logs de login mediante SSH" ;;
            4) exportarLogs "$sshService" "Accepted\|Failed" "Logs de login SSH" ;;
            5) mostrarLogs "$loginService" "session opened" "Mostrando intentos de login exitosos locales" ;;
            6) mostrarLogs "$loginService" "Failed" "Mostrando intentos de login fallidos locales" ;;
            7) mostrarLogs "$loginService" "session opened\|Failed" "Mostrando todos los logs de login locales" ;;
            8) exportarLogs "$loginService" "session opened\|Failed" "Logs de login locales" ;;
            0) ./menuPrincipal ;;
            *) echo "Opción incorrecta."; read -p "Presione cualquier tecla para continuar..." -n 1 ;;
        esac
    done
}

main
