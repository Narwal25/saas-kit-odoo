source generate_wildcard.sh

prompt_variables_choice() {
    echo "Do you want to continue the script? (y/n): "
    read -r choice

    case "$choice" in
        [Yy]* )
            echo "Continuing with the script..."
            ;;
        [Nn]* )
            echo "Exiting the script."
            exit 0
            ;;
        * )
            echo "Invalid input. Please enter 'y' or 'n'."
            prompt_user  # Recursively prompt the user again
            ;;
    esac
}

# Function to prompt the user for SSL generation
prompt_ssl_choice() {
    echo "Do you want to generate an SSL certificate with Certbot? (y/n): "
    read -r choice

    case "$choice" in
        [Yy]* )
            echo "Proceeding to generate SSL certificate..."
            prompt_challenge_choice
            ;;
        [Nn]* )
            echo "Skipping SSL certificate generation."
            ;;
        * )
            echo "Invalid input. Please enter 'y' or 'n'."
            prompt_ssl_choice  # Recursively prompt the user again
            ;;
    esac
}

prompt_challenge_choice() {
    echo "Choose the DNS challenge type:"
    echo "1. Manual DNS challenge"
    echo "2. Cloudflare DNS with API token"
    echo "Enter your choice (1 or 2): "
    read -r challenge_choice

    case "$challenge_choice" in
        1 )
            echo "You selected Manual DNS challenge."
            generate_wildcard_manual
            ;;
        2 )
            echo "You selected Cloudflare DNS with API token."
            generate_wildcard_cloudflare
            ;;
        * )
            echo "Invalid choice. Please enter '1' or '2'."
            prompt_challenge_choice  # Recursively prompt the user again
            ;;
    esac
}
