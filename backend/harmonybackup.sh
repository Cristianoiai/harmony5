#!/bin/bash

# Configurações do PostgreSQL
PG_USER="harmony"
PG_HOST="localhost"
PG_DB="harmony"
PG_PORT="5432"
PG_PASSWORD="pereira1976"

# Diretório de backup
BACKUP_DIR="/home/deploy/backups"
mkdir -p "$BACKUP_DIR"

DATE=$(date +%Y%m%d)

# Verifica se os argumentos foram passados corretamente
if [[ $# -lt 2 ]]; then
    echo "Uso: $0 -e <nome_do_arquivo>  (Para exportar)"
    echo "     $0 -i <nome_do_arquivo>  (Para importar)"
    exit 1
fi

# Define a ação com base no primeiro argumento
ACTION="$1"
FILE_NAME="$2"

# Caminho completo do arquivo
BACKUP_FILE="$BACKUP_DIR/${DATE}-$FILE_NAME.dump"
BACKUP_FILE_IMP="$BACKUP_DIR/$FILE_NAME.dump"

# Exportando o banco de dados
if [[ "$ACTION" == "-e" ]]; then
    export PGPASSWORD="$PG_PASSWORD"
    pg_dump -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -F c -d "$PG_DB" -f "$BACKUP_FILE"

    # Compactando o backup
    gzip -f "$BACKUP_FILE"
    echo "Backup exportado com sucesso: ${BACKUP_FILE}.gz"

# Importando um banco de dados
elif [[ "$ACTION" == "-i" ]]; then
    # Verifica se o arquivo existe
    if [[ ! -f "$BACKUP_FILE_IMP.gz" ]]; then
        echo "Erro: Arquivo de backup não encontrado em $BACKUP_FILE_IMP.gz"
        exit 1
    fi

    export PGPASSWORD="$PG_PASSWORD"
    gunzip -c "$BACKUP_FILE_IMP.gz" | pg_restore --clean --if-exists -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB"

    echo "Backup importado com sucesso!"

else
    echo "Opção inválida! Use -e para exportar ou -i para importar."
    exit 1
fi
