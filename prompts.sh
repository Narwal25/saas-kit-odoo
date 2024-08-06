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
            generate_wildcard
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