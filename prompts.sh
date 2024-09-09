source generate_wildcard.sh

prompt_variables_choice() {
    echo -e "${yellow}Do you want to continue the script? (y/n): ${reset}"
    read -r choice

    case "$choice" in
        [Yy]* )
            echo -e "${green}Continuing with the script...${reset}"
            ;;
        [Nn]* )
            echo "Exiting the script."
            exit 0
            ;;
        * )
            echo -e "${red}Invalid input. Please enter 'y' or 'n'.${reset}"
            prompt_variables_choice  # Recursively prompt the user again
            ;;
    esac
}

# Function to prompt the user for SSL generation
prompt_ssl_choice() {
    echo -e "${yellow}Do you want to generate an SSL certificate with Certbot? (y/n): ${reset}"
    read -r choice

    case "$choice" in
        [Yy]* )
            echo -e "${green}Proceeding to generate SSL certificate...${reset}"
            prompt_challenge_choice
            ;;
        [Nn]* )
            echo "Skipping SSL certificate generation."
            ;;
        * )
            echo -e "${red}Invalid input. Please enter 'y' or 'n'.${reset}"
            prompt_ssl_choice  # Recursively prompt the user again
            ;;
    esac
}

prompt_challenge_choice() {
    echo -e "${yellow}Choose the DNS challenge type:${reset}"
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
            echo -e "${red}Invalid choice. Please enter '1' or '2'.${reset}"
            prompt_challenge_choice  # Recursively prompt the user again
            ;;
    esac
}
