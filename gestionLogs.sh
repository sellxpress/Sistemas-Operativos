#!/bin/bash
year=$(date +%Y-%m-%d)

function menu() {
    clear
    echo "#################################"
    echo "  GESTIÓN DE LOGS DEL SISTEMA    "
    echo "#################################"
    echo "1- Ver logs más recientes"
    echo "2- Buscar logs por servicio"
    echo "3- Buscar logs por nivel de prioridad"
    echo "4- Exportar logs a un archivo"
    echo "0- Volver al menú principal"
}

function crearDirectorioLogs() {
    logDir="/root/logsPropios"
    [ ! -d "$logDir" ] && mkdir -p "$logDir"
}

function verLogsRecientes() {
    clear
    echo "Mostrando los logs más recientes del sistema:"
    journalctl -xe
    echo " "
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function buscarLogsXServicio() {
    clear
    read -p "Ingrese el nombre del servicio (ej: sshd): " servicio
    if [ -z "$servicio" ]; then
        echo "Error: El nombre del servicio no puede estar vacío."
    else
        echo "Logs del servicio $servicio:"
        journalctl -u "$servicio"
    fi
    echo " "
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function buscarLogsXPrioridad() {
    clear
    read -p "Ingrese el nivel de prioridad (ej: debug, warn, emerg): " prioridad
    if [ -z "$prioridad" ]; then
        echo "Error: El nivel de prioridad no puede estar vacío."
    else
        echo "Logs con nivel de prioridad $prioridad:"
        journalctl -p "$prioridad"
    fi
    echo " "
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function exportarLogs() {
    clear
    read -p "Ingrese la ruta del archivo de salida (ej: /tmp/logs_$year.txt): " archivoSalida
    if [ -z "$archivoSalida" ]; then
        echo "Error: La ruta del archivo no puede estar vacía."
    elif [ ! -d "$(dirname "$archivoSalida")" ]; then
        echo "Error: El directorio no existe."
    else
        journalctl > "$archivoSalida"
        if [ $? -eq 0 ]; then
            echo "Logs exportados a $archivoSalida exitosamente."
            crearDirectorioLogs
            echo "$(date +%Y-%m-%d-%H:%M:%S) - Logs exportados a $archivoSalida." >> /root/logsPropios/logs.log
        else
            echo "Error al exportar los logs."
        fi
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function main() {
    opc=1
    while [ $opc -ne 0 ]; do
        menu
        echo "#################################"
        read -p "Ingrese una opción: " opc
        case $opc in
            1) verLogsRecientes ;;
            2) buscarLogsXServicio ;;
            3) buscarLogsXPrioridad ;;
            4) exportarLogs ;;
            0) ./menuPrincipal ;;
            *) echo "Opción incorrecta." ;;
        esac
    done
}

main
