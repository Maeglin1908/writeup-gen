#!/bin/bash

# Obtenir le chemin absolu du script pour localiser les templates
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Définir les chemins des templates relatifs au chemin du script
declare -A TEMPLATES
TEMPLATES=(
    ["htb"]="$SCRIPT_DIR/templates/htb/"
    ["thm"]="$SCRIPT_DIR/templates/thm/"
    ["otw"]="$SCRIPT_DIR/templates/otw/"
    ["generic"]="$SCRIPT_DIR/templates/generic/"
)

# Fonction pour l'option "init"
init() {
    if [ $# -lt 2 ] || [ $# -gt 3 ]; then
        echo "Usage: $(basename $0) init <directory_name> <challenge_name> [template_type]"
        echo "Templates disponibles: htb, thm, otw, generic"
        exit 1
    fi

    DIRECTORY=$1
    CHALLENGE_NAME=$2
    TEMPLATE_TYPE=${3:-"generic"}  # Utiliser "generic" par défaut si aucun template n'est spécifié

    # Vérifier si le type de template est valide
    TEMPLATE_PATH=${TEMPLATES[$TEMPLATE_TYPE]}
    if [ -z "$TEMPLATE_PATH" ]; then
        echo "Template type '$TEMPLATE_TYPE' inconnu."
        echo "Templates disponibles: htb, thm, otw, generic"
        exit 1
    fi

    # Créer le répertoire si n'existe pas
    mkdir -p "$DIRECTORY"
    cd "$DIRECTORY"

    # Copier le template markdown dans le nouveau répertoire
    cp "$TEMPLATE_PATH/template.md" "$DIRECTORY.md"
    cp -r "$TEMPLATE_PATH/images" "images"

    # Remplacer le titre par le nom du challenge
    sed -i "s/{{CHALL_NAME}}/$CHALLENGE_NAME/g" "$DIRECTORY.md"

    # Remplacer la date par la date actuelle
    CURRENT_DATE=$(date +%Y-%m-%d)
    sed -i "s/{{CHALL_DATE}}/$CURRENT_DATE/g" "$DIRECTORY.md"

    echo "Challenge '$CHALLENGE_NAME' initialisé dans le répertoire '$DIRECTORY' avec le template '$TEMPLATE_TYPE'."
}

# Fonction pour l'option "generate"
generate() {
    if [ $# -ne 1 ]; then
        echo "Usage: $(basename $0) generate <directory_name>"
        exit 1
    fi

    DIRECTORY=$1
    FILE_NAME=$2

    # Créer le répertoire si n'existe pas
    mkdir -p "$DIRECTORY/pdf"
    cd "$DIRECTORY"

    # Convertir le markdown en pdf
    pandoc --pdf-engine=xelatex "$DIRECTORY.md" -o "pdf/$DIRECTORY.pdf" --from markdown --template eisvogel --listings

    echo "PDF généré : $DIRECTORY/pdf/$DIRECTORY.pdf"
}

# Fonction pour l'option "protect"
protect() {
    if [ $# -ne 2 ]; then
        echo "Usage: $(basename $0) protect <directory_name> <password>"
        exit 1
    fi

    DIRECTORY=$1
    PASSWORD=$2

    # Protéger le PDF avec un mot de passe
    pdftk "$DIRECTORY/pdf/$DIRECTORY.pdf" output "$DIRECTORY/pdf/${DIRECTORY}_protected.pdf" user_pw "$PASSWORD"

    echo "PDF protégé généré : $DIRECTORY/pdf/${DIRECTORY}_protected.pdf"
}

# Vérification des arguments
if [ $# -lt 1 ]; then
    echo "Usage: $(basename $0) <option> [arguments...]"
    echo "Options disponibles: init, generate, protect"
    exit 1
fi

# Exécution de la fonction en fonction de l'option
case "$1" in
    init)
        shift
        init "$@"
        ;;
    generate)
        shift
        generate "$@"
        ;;
    protect)
        shift
        protect "$@"
        ;;
    *)
        echo "Option inconnue : $1"
        echo "Options disponibles: init, generate, protect"
        exit 1
        ;;
esac
