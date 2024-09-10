#!/bin/bash
year=$(date +%Y-%m-%d)

function menu() {
    echo "#########################"
    echo "     MENÚ PRINCIPAL      "
    echo "#########################"
    echo "1- Gestión de usuarios"
    echo "2- Gestión de grupos"
    echo "3- Gestión de respaldos"
    echo "4- Gestión de redes"
    echo "5- Gestión de bases de datos"
    echo "6- Gestión de firewall"
    echo "7- Gestión de logs del Sistema"
    echo "8- Gestión de logs del sistema referidos a los intentos de login"
    echo "0- Salir"
}

function ejecutarScript() {
    local script=$1
    if [ -f "$script" ]; then
        bash "$script"
        if [ $? -ne 0 ]; then
            echo "Error al ejecutar $script"
        fi
    else
        echo "Error: El archivo $script no existe."
    fi
}

function main() {
    opc=1
    while [ $opc -ne 0 ]
    do
        clear
        menu
        echo "#########################"
        echo "  Ingrese una opción: "
        read opc
        case $opc in
            1) ejecutarScript /home/proyecto/gestionUsuarios.sh ;;
            2) ejecutarScript /home/proyecto/gestionGrupos.sh ;;
            3) ejecutarScript /home/proyecto/gestionRespaldos.sh ;;
            4) ejecutarScript /home/proyecto/gestionRedes.sh ;;
            5) ejecutarScript /home/proyecto/gestionBD.sh ;;
            6) ejecutarScript /home/proyecto/gestionFirewall.sh ;;
            7) ejecutarScript /home/proyecto/gestionLogs.sh ;;
            8) ejecutarScript /home/proyecto/gestionLogsLogin.sh ;;
            0) echo "Saliendo..."; exit 0 ;;
            *) read -p "Opción no válida. Presione una tecla para continuar..." -n 1 ;;
        esac
    done
}

main
