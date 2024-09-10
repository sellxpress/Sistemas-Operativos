#!/bin/bash
year=$(date +%Y-%m-%d)
logFile="/root/logsPropios/gestion_grupos.log"

function log_event() {
    echo "$(date +%Y-%m-%d-%H:%M:%S) - $1" >> "$logFile"
}

function menu() {
    clear
    echo "#############################"
    echo "     GESTIÓN DE GRUPOS    "
    echo "#############################"
    echo "1- Crear un grupo nuevo"
    echo "2- Listar grupos"
    echo "3- Buscar grupo"
    echo "4- Eliminar grupo"
    echo "0- Volver al menú principal"
}

function crearGrupo() {
    clear
    read -p "Ingrese el nombre del grupo nuevo (solo letras): " grupo
    if [[ ! "$grupo" =~ ^[a-zA-Z]+$ ]]; then
        echo "Error: El nombre del grupo solo debe contener letras."
        log_event "Error al crear el grupo '$grupo': Nombre inválido."
    elif getent group "$grupo" > /dev/null; then
        echo "El grupo '$grupo' ya existe."
        log_event "Intento de crear un grupo ya existente: $grupo."
    else
        if sudo groupadd "$grupo"; then
            echo "El grupo '$grupo' fue creado con éxito."
            log_event "Grupo creado con éxito: $grupo."
        else
            echo "Error al crear el grupo '$grupo'."
            log_event "Error al crear el grupo '$grupo'."
        fi
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function listarGrupos() {
    clear
    echo "Lista de grupos en el sistema:"
    cut -d ":" -f1 /etc/group
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function buscarGrupo() {
    clear
    read -p "Ingrese el nombre del grupo a buscar: " grupo
    if getent group "$grupo" > /dev/null; then
        echo "Grupo encontrado: $(getent group "$grupo")"
        log_event "Grupo encontrado: $grupo."
    else
        echo "El grupo '$grupo' no existe."
        log_event "Grupo no encontrado: $grupo."
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function eliminarGrupo() {
    clear
    read -p "Ingrese el nombre del grupo que desea eliminar: " grupo
    if getent group "$grupo" > /dev/null; then
        read -p "¿Está seguro de que desea eliminar el grupo '$grupo'? (s/n): " confirmacion
        if [[ "$confirmacion" =~ ^[sS]$ ]]; then
            if sudo groupdel "$grupo"; then
                echo "El grupo '$grupo' fue eliminado con éxito."
                log_event "Grupo eliminado con éxito: $grupo."
            else
                echo "Error al eliminar el grupo '$grupo'."
                log_event "Error al eliminar el grupo '$grupo'."
            fi
        else
            echo "Operación cancelada."
            log_event "Eliminación de grupo cancelada: $grupo."
        fi
    else
        echo "El grupo '$grupo' no existe."
        log_event "Intento de eliminar un grupo inexistente: $grupo."
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function main() {
    opc=1
    while [ $opc -ne 0 ]; do
        menu
        echo "#############################"
        read -p "Ingrese una opción: " opc
        echo "#############################"
        case $opc in
            1) crearGrupo ;;
            2) listarGrupos ;;
            3) buscarGrupo ;;
            4) eliminarGrupo ;;
            0) ./menuPrincipal ;;
            *) echo "Opción incorrecta." ;;
        esac
    done
}

main
