#!/bin/bash

# Definir una variable de entorno para indicar el modo
if [ -z "$FROM_MENU_PRINCIPAL" ]; then
    # Si la variable no está definida, el script se ejecuta de manera independiente
    FROM_MENU_PRINCIPAL="false"
else
    # Si la variable está definida, el script se ejecuta desde el menú principal
    FROM_MENU_PRINCIPAL="true"
fi

year=$(date +%Y-%m-%d)
logDir="/root/logsPropios"
logFile="$logDir/usuarios.txt"
mkdir -p $logDir

function menu() {
    clear
    echo "#########################"
    echo "  GESTIÓN DE USUARIOS    "
    echo "#########################"
    echo "1- Agregar usuario"
    echo "2- Borrar usuario"
    echo "3- Listar usuarios"
    echo "4- Buscar usuario"
    echo "5- Cambiar contraseña"
    echo "6- Bloquear usuario"
    echo "7- Desbloquear usuario"
    echo "0- Volver al menú principal"
}

function validarNombre() {
    [[ -z "$1" || "$1" =~ [^a-zA-Z] ]] && echo "Error: Nombre inválido." && return 1
    return 0
}

function logAccion() {
    echo "$(date +%Y-%m-%d-%H:%M:%S) - $1" >> $logFile
}

function agregarUsuario() {
    clear
    read -p "Ingrese el nombre (todo junto): " nombre
    validarNombre "$nombre" || return
    usuario="${nombre,,}"
    
    if id "$usuario" &>/dev/null; then
        logAccion "Intento fallido: El usuario '$usuario' ya existe."
    else
        read -p "Ingrese el grupo: " grupo
        [[ -z "$grupo" ]] && echo "Error: Grupo vacío." && return
        
        user_group="${grupo,,}"
        if getent group "$user_group" &>/dev/null; then
            sudo useradd -g "$user_group" -m -s /bin/bash "$usuario"
            logAccion "Usuario '$usuario' agregado al grupo '$user_group'."
            sudo passwd -e -d "$usuario"
            echo "Usuario '$usuario' creado correctamente."
        else
            logAccion "Error: El grupo '$user_group' no existe."
        fi
    fi
}

function borrarUsuario() {
    clear
    read -p "Ingrese el nombre (todo junto): " nombre
    validarNombre "$nombre" || return
    usuario="${nombre,,}"

    if id "$usuario" &>/dev/null; then
        read -p "¿Está seguro de eliminar a '$usuario'? (S/N): " conf
        [[ "$conf" =~ ^[Ss]$ ]] && sudo userdel "$usuario" && logAccion "Usuario '$usuario' eliminado."
    else
        echo "El usuario no existe."
    fi
}

function listarUsuarios() {
    clear
    cut -d: -f1 /etc/passwd
}

function buscarUsuario() {
    clear
    read -p "Ingrese el nombre (todo junto): " nombre
    validarNombre "$nombre" || return
    usuario="${nombre,,}"
    id "$usuario" &>/dev/null && echo "Usuario '$usuario' existe." || echo "El usuario no existe."
}

function cambiarContraseña() {
    clear
    read -p "Ingrese el nombre (todo junto): " nombre
    validarNombre "$nombre" || return
    usuario="${nombre,,}"
    id "$usuario" &>/dev/null && sudo passwd "$usuario" || echo "El usuario no existe."
}

function bloquearUsuario() {
    clear
    read -p "Ingrese el nombre (todo junto): " nombre
    validarNombre "$nombre" || return
    usuario="${nombre,,}"
    id "$usuario" &>/dev/null && sudo usermod -L "$usuario" && echo "Usuario bloqueado." || echo "El usuario no existe."
}

function desbloquearUsuario() {
    clear
    read -p "Ingrese el nombre (todo junto): " nombre
    validarNombre "$nombre" || return
    usuario="${nombre,,}"
    id "$usuario" &>/dev/null && sudo usermod -U "$usuario" && echo "Usuario desbloqueado." || echo "El usuario no existe."
}

function main() {
    while true; do
        menu
        echo "#########################"
        read -p "Ingrese una opción: " opc
        case $opc in
            1) agregarUsuario ;;
            2) borrarUsuario ;;
            3) listarUsuarios ;;
            4) buscarUsuario ;;
            5) cambiarContraseña ;;
            6) bloquearUsuario ;;
            7) desbloquearUsuario ;;
            0)
                if [ "$FROM_MENU_PRINCIPAL" = "true" ]; then
                    ./menuPrincipal
                    exit
                else
                    exit
                fi
                ;;
            *) echo "Opción incorrecta." ;;
        esac
    done
}

main
