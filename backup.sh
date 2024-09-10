#!/bin/bash
backupDir="/root/backup"
fechaBackup=$(date +%Y-%m-%d)
logFile="/root/logsPropios/backup.log"

logEvent() {
	echo "$date +%Y-%m-%d-%H:%M:%S) - $1" >> "$logFile"
}

if [ ! -d "$backupDir" ] then
	mkdir -p "$backupDir"
	if [$? -eq 0 ]; then
		logEvent "Directorio de backup creado: $backupDir"
	else
		logEvent "Error al crear el directorio de backups: $bacupDir"
		exit 1
	fi
else
	logeEvent "El directorio de backup ya existe: $backupDir"
fi

tar -czvf "$backupDir/backupFull_$fechaBackup.tar.gz" \
	--exlude=/proc \
	--exclude=/sys \
	--exclude=/dev \
	--exclude=/tmp \
	--exclude=/run \
	--exclude=/mnt \
	--exclude=/media \
	--exclude=/lost+found \
	/ >> "$logFile" 2>&1

if [ $? -eq 0 ]; then
	logEvent "Respaldo completo realizado con exito: $backupDir/backupFull_$fechaBackup.tar.gz"
else
	logEvent "Error al realizar el respaldo completo."
fi
