#!/bin/sh

# Vérifier si les variables d'environnement sont définies
if [ -z "$ODOO_URL" ] || [ -z "$ODOO_DB" ] || [ -z "$ODOO_MASTER_PWD" ] || [ -z "$S3_BUCKET" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Les variables d'environnement ODOO_URL, ODOO_DB, ODOO_MASTER_PWD, S3_BUCKET, AWS_SECRET_ACCESS_KEY et AWS_ACCESS_KEY_ID doivent être définies."
    exit 1
fi

# Effectuer la requête POST et enregistrer la réponse dans un fichier temporaire
response_file=$(mktemp)
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "master_pwd=$ODOO_MASTER_PWD&name=$ODOO_DB&backup_format=zip" -o "$response_file" "$ODOO_URL/web/database/backup"
# Vérifier si la requête a réussi
if [ $? -eq 0 ]; then
    filename="$(date +%Y-%m-%d-%H-%M-%S).zip"
    # Téléverser le fichier vers le bucket S3 en utilisant l'endpoint spécifié
    mc alias set s3 "$S3_ENDPOINT" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" --api S3v4
    mc cp "$response_file" "s3/$S3_BUCKET/$filename"
    if [ $? -eq 0 ]; then
        echo "Fichier envoyé avec succès vers S3"
    else
        echo "Erreur lors de l'envoi du fichier vers S3"
    fi
else
    echo "La requête POST a échoué"
fi

# Supprimer le fichier temporaire
rm "$response_file"
