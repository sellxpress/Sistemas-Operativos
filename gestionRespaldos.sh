#!/bin/bash
year=$(date +%Y-%m-%d)
logDir="/root/logsPropios"
respaldosDir="/root/respaldos/servidor"
logFile="$logDir/respaldo.log"

mkdir -p "$respaldosDir" "$logDir"

function log_event() {
    echo "$(date +%Y-%m-%d-%H:%M:%S) - $1" >> "$logFile"
}

# Función para el menú
function menu() {
    clear
    echo "#######################################"
    echo "  GESTIÓN DE RESPALDOS DEL SERVIDOR    "
    echo "#######################################"
    echo "1- Realizar un respaldo completo"
    echo "2- Realizar un respaldo de directorios específicos"
    echo "3- Realizar un respaldo del sistema"
    echo "4- Restaurar un respaldo"
    echo "0- Salir"
}

function realizarRespaldo() {
    local tipoRespaldo=$1
    local rutaRespaldo=$2
    local descripcion=$3

    tar -czvf "$rutaRespaldo" $4
    if [ $? -eq 0 ]; then
        echo "$descripcion realizado exitosamente."
        log_event "$descripcion realizado exitosamente."
    else
        echo "Error al realizar $descripcion."
        log_event "Error al realizar $descripcion."
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function respaldoCompleto() {
    realizarRespaldo "Respaldo completo" "$respaldosDir/respaldoCompleto_$year.tar.gz" "Respaldo completo del servidor" "/"
}

function respaldoDirectorios() {
    clear
    echo "Ingrese los directorios que desea respaldar (separados por espacio): "
    read directorios
    if [ -z "$directorios" ]; then
        echo "Error: No se especificaron directorios."
        log_event "Error: No se especificaron directorios."
        read -p "Presione cualquier tecla para continuar..." -n 1
        return
    fi
    realizarRespaldo "Respaldo de directorios" "$respaldosDir/respaldoDirectorios_$year.tar.gz" "Respaldo de directorios" "$directorios"
}

function respaldoSistema() {
    realizarRespaldo "Respaldo del sistema" "$respaldosDir/respaldoSistema_$year.tar.gz" "Respaldo del sistema" "/"
}

function restaurarRespaldo() {
    clear
    echo "Ingrese la ruta completa del archivo de respaldo (.tar.gz) que desea restaurar: "
    read archivoRespaldo

    if [ ! -f "$archivoRespaldo" ]; then
        echo "Error: El archivo '$archivoRespaldo' no existe."
        log_event "Error: El archivo '$archivoRespaldo' no existe."
        read -p "Presione cualquier tecla para continuar..." -n 1
        return
    fi
    echo "Restaurando respaldo desde $archivoRespaldo..."
    tar -xzvf "$archivoRespaldo" -C /
    if [ $? -eq 0 ]; then
        echo "Restauración completada."
        log_event "Restauración completada desde $archivoRespaldo."
    else
        echo "Error al restaurar el respaldo."
        log_event "Error al restaurar el respaldo desde $archivoRespaldo."
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function main() {
    opc=1
    while [ $opc -ne 0 ]; do
        menu
        echo "#######################################"
        echo "Ingrese una opción: "
        read opc
        case $opc in
            1) respaldoCompleto ;;
            2) respaldoDirectorios ;;
            3) respaldoSistema ;;
            4) restaurarRespaldo ;;
            0) ./menuPrincipal ;;
            *) echo "Opción incorrecta. Intente de nuevo." ;;
        esac
        read -p "Presione cualquier tecla para continuar..." -n 1
    done
}
main
