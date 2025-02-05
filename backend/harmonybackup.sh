#!/bin/bash

# Caminho do arquivo .env
ENV_FILE="$(dirname "$0")/.env"

# Verifica se o arquivo .env existe
if [[ ! -f "$ENV_FILE" ]]; then
    echo "Erro: Arquivo .env não encontrado em $ENV_FILE"
    exit 1
fi

# Exporta as variáveis do .env para o ambiente
export $(grep -v '^#' "$ENV_FILE" | xargs)

# Criar diretório de backup, se não existir
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
    export PGPASSWORD="$DB_PASS"
    pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -F c -d "$DB_NAME" -f "$BACKUP_FILE"

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

    export PGPASSWORD="$DB_PASS"
    gunzip -c "$BACKUP_FILE_IMP.gz" | pg_restore --clean --if-exists -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME"

    echo "Backup importado com sucesso!"

else
    echo "Opção inválida! Use -e para exportar ou -i para importar."
    exit 1
fi
