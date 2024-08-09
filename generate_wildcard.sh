##### Generate Wildcard dns tls certificate
generate_wildcard_manual() {
    echo "certbot"
    certbot certonly --manual --preferred-challenges dns \
    -d "*."$server_domain -d $server_domain \
    --email $server_email --agree-tos --no-eff-email

    echo "Wildcard SSL certificate generation completed."
}

generate_wildcard_cloudflare() {
    sudo apt-get install certbot python3-certbot-dns-cloudflare -y
    token_file_path=/etc/letsencrypt/cloudflare.ini
    echo -n "Enter the full path of your file where token is stored (default: $token_file_path): "
    read -r new_token_file_path
    
    token_file_path=${new_token_file_path:-$token_file_path}
    
    if [ ! -f $token_file_path ]; then
        echo "Cloudflare credentials file not found. Please create /etc/letsencrypt/cloudflare.ini with your API token."
        exit 1
    fi
    
    chmod 600 $token_file_path
    
    sudo certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials $token_file_path \
    -d "*."$server_domain -d $server_domain \
    --email $server_email --agree-tos --no-eff-email

    echo "Wildcard SSL certificate generation with Cloudflare API Token completed."
    
}
