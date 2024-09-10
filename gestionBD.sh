#!/bin/bash
backupDir="/root/respaldos"
year=$(date +%Y-%m-%d-backup_bd)
logFile="/root/logsPropios/backup.log"

function log_event() {
    echo "$(date +%Y-%m-%d-%H:%M:%S) - $1" >> "$logFile"
}

sudo mkdir -p "$backupDir/bd" "$backupDir/remotos"

function menu() {
    clear
    echo "##############################################"
    echo "  GESTIÓN DE RESPALDOS DE LA BASE DE DATOS    "
    echo "##############################################"
    echo "1- Realizar un respaldo completo"
    echo "2- Respaldar a servidor remoto"
    echo "3- Restaurar base de datos"
    echo "4- Realizar una consulta"
    echo "5- Listar todas las bases de datos"
    echo "6- Listar usuarios de la base de datos"
    echo "7- Listar tablas de una base de datos"
    echo "0- Salir"
}

function validarBD() {
    local bdName="$1"
    local pass="$2"
    echo "SHOW DATABASES;" | mysql -u root -p"$pass" | grep -c "^$bdName$"
}

function realizarRespaldo() {
    local bdName="$1"
    local pass="$2"
    local rutaDestino="$3"
    local tipoRespaldo="$4"
    local opcionesDump="$5"

    mysqldump -u root -p"$pass" $opcionesDump "$bdName" > "$bdName.sql"
    if [ $? -ne 0 ]; then
        echo "Error al realizar el respaldo de la base de datos."
        log_event "Error al realizar respaldo de la base de datos $bdName."
        return 1
    fi

    mv "$bdName.sql" "$rutaDestino/"
    log_event "Respaldo $tipoRespaldo realizado: $bdName"
    echo "Respaldo $tipoRespaldo realizado exitosamente."
}


function realizarRespaldoCompleto() {
    clear
    echo "Ingrese el nombre de la base de datos: "
    read bdName
    echo "Ingrese la contraseña del usuario root de MySQL: "
    read -s pass

    if [ -z "$bdName" ] || [ $(validarBD "$bdName" "$pass") -eq 0 ]; then
        echo "Error: La base de datos '$bdName' no existe o el nombre está vacío."
        log_event "Error: La base de datos no existe  '$bdName'."
    else
        realizarRespaldo "$bdName" "$pass" "$backupDir/bd" "completo" ""
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}


function respaldoRemoto() {
    clear
    echo "Ingrese el nombre de la base de datos: "
    read bdName
    echo "Ingrese la contraseña del usuario root de MySQL: "
    read -s pass

    if [ -z "$bdName" ] || [ $(validarBD "$bdName" "$pass") -eq 0 ]; then
        echo "Error: La base de datos '$bdName' no existe o el nombre está vacío."
        log_event "Error: No existe la base de datos '$bdName'."
    else
        realizarRespaldo "$bdName" "$pass" "$backupDir/remotos" "remoto" ""
        echo "Ingrese la dirección IP del servidor remoto:"
        read ipRemota
        echo "Ingrese el usuario del servidor remoto: "
        read usuarioRemoto
        echo "Ingrese la ruta remota donde se guardará el respaldo: "
        read rutaRemota
        ssh "$usuarioRemoto@$ipRemota" "mkdir -p $rutaRemota"
        scp "$backupDir/remotos/$bdName.sql" "$usuarioRemoto@$ipRemota:$rutaRemota/"
        rm "$backupDir/remotos/$bdName.sql"
        echo "Respaldo remoto realizado exitosamente."
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function restaurarBD() {
    clear
    echo "Ingrese el nombre del archivo de respaldo (con extensión .sql): "
    read archivoRespaldo
    echo "Ingrese el nombre de la base de datos en la que restaurar: "
    read bdName
    echo "Ingrese la contraseña del usuario root de MySQL: "
    read -s pass

    # Ruta del archivo donde va a estar el respaldo
    archivoRespaldo="/root/respaldos/bd/$archivoRespaldo"

    if [ -z "$archivoRespaldo" ] || [ ! -f "$archivoRespaldo" ]; then
        echo "Error: El archivo '$archivoRespaldo' no existe o el nombre está vacío."
        return 1
    fi

    # Verifica si la base de datos existe
    if [ $(validarBD "$bdName" "$pass") -eq 0 ]; then
        echo "La base de datos '$bdName' no existe."
        echo "Creando la base de datos '$bdName'..."
        mysql -u root -p"$pass" -e "CREATE DATABASE IF NOT EXISTS $bdName;"

        if [ $? -ne 0 ]; then
            echo "Error al crear la base de datos '$bdName'."
            log_event "Error al crear la base de datos '$bdName'."
            return 1
        else
            echo "Base de datos '$bdName' creada exitosamente."
            log_event "la base de datos '$bdName' fue creada."
        fi
    fi

    # Restaura la base de datos desde el archivo de respaldo
    mysql -u root -p"$pass" "$bdName" < "$archivoRespaldo"
    if [ $? -eq 0 ]; then
        echo "Base de datos '$bdName' restaurada exitosamente desde '$archivoRespaldo'."
        log_event "La base de datos '$bdName' fue restaurada desde '$archivoRespaldo'."
    else
        echo "Error al restaurar la base de datos '$bdName' desde '$archivoRespaldo'."
        log_event "Error al restaurar la base de datos '$bdName'."
        return 1
    fi

    read -p "Presione cualquier tecla para continuar..." -n 1
}



function consultaPersonalizada() {
    clear
    echo "Ingrese la consulta SQL que desea realizar:"
    read consultaSql
    if [ -z "$consultaSql" ]; then
        echo "Error: La consulta no puede estar vacía."
        read -p "Presione cualquier tecla para continuar..." -n 1
        return
    fi
    echo "$consultaSql" | mysql -u root -p
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function listarTodasBD() {
    clear
    echo "Mostrando todas las bases de datos en el sistema."
    echo "SHOW DATABASES;" | mysql -u root -p
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function listarUsuariosBD() {
    clear
    echo "Mostrando todos los usuarios de MySQL."
    echo "SELECT User, Host FROM mysql.user;" | mysql -u root -p
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function listarTablasBD() {
    clear
    echo "Ingrese el nombre de la base de datos para listar sus tablas: "
    read bdName
    echo "Ingrese la contraseña del usuario root de MySQL: "
    read -s pass

    if [ -z "$bdName" ] || [ $(validarBD "$bdName" "$pass") -eq 0 ]; then
        echo "Error: La base de datos '$bdName' no existe o el nombre está vacío."
        log_event "Error: No existe la base de datos '$bdName'."
    else
        echo "Mostrando todas las tablas de la base de datos '$bdName'."
        echo "SHOW TABLES;" | mysql -u root -p"$pass" "$bdName"
    fi
    read -p "Presione cualquier tecla para continuar..." -n 1
}

function main() {
    local opc=1
    while [ $opc -ne 0 ]; do
        clear
        menu
        read -p "Seleccione una opción: " opc
        case $opc in
            1) realizarRespaldoCompleto ;;
            2) respaldoRemoto ;;
            3) restaurarBD ;;
            4) consultaPersonalizada ;;
            5) listarTodasBD ;;
            6) listarUsuariosBD ;;
            7) listarTablasBD ;;
            0) ./menuPrincipal ;;
            *) echo "Opción no válida." ;;
        esac
    done
}
main
