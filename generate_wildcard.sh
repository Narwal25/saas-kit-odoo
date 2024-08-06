##### Generate Wildcard dns tls certificate
generate_wildcard() {
    echo "certbot"
    certbot certonly --manual --preferred-challenges dns \
    -d "*."$server_domain -d $server_domain \
    --email $server_email --agree-tos --no-eff-email
}