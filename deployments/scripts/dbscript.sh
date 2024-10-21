# Prompt the user for input

read -p "Enter the Client ID: " CLIENT_ID
read -p "Enter the privatejwk key: " JWK_kEY
read -p "Enter the Redirect URI: " REDIRECT_URI
read -p "Enter the esignet Domain: " ESIGNET_DOMAIN
read -p "Enter the database host: " DB_HOST

authorize_endpoint="https://$ESIGNET_DOMAIN/authorize"
token_endpoint="https://$ESIGNET_DOMAIN/v1/esignet/oauth/v2/token"
validate_endpoint="https://$ESIGNET_DOMAIN/v1/esignet/oidc/userinfo"
jwks_endpoint="https://$ESIGNET_DOMAIN/v1/esignet/oauth/.well-known/jwks.json"


# Print the entered values

echo "Client ID: $CLIENT_ID"
echo "JWK Key: $JWK_KEY"
echo "Redirect URI: $REDIRECT_URI"
echo "Esignet domain: $ESIGNET_DOMAIN"
echo "authorize_endpoint: $authorize_endpoint"
echo "token_endpoint: $token_endpoint"
echo "validate_endpoint: $validate_endpoint"
echo "jwks_endpoint: $jwks_endpoint"
echo "DB Host: $DB_HOST"


# Define database credentials

DB_USER="postgres"
DB_NAME="spardb"
SSL_MODE="require"


export CLIENT_ID JWK_kEY REDIRECT_URI ESIGNET_DOMAIN authorize_endpoint token_endpoint validate_endpoint jwks_endpoint DB_HOST
envsubst < commands.sql | psql "sslmode=$SSL_MODE hostaddr=$DB_HOST user=$DB_USER dbname=$DB_NAME port=5432"
