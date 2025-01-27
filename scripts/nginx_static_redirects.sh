#!/bin/bash

# Set the base directory where the HTML files are located
BASE_DIR="../html/"
OUTPUT_FILE="nginx_redirects.conf"

# Start writing to the Nginx configuration file
echo "# Nginx redirects generated from meta tags" > "$OUTPUT_FILE"

# Find files containing <meta http-equiv="refresh"
grep -rl '<meta http-equiv="refresh"' "$BASE_DIR" | while read -r file; do
    # Extract the URL from the string format url='...'
    redirect_url=$(grep -oP "url='[^']+'" "$file" | grep -oP "http[^']+")

    # Check if a redirect URL was found
    if [ -n "$redirect_url" ]; then
        # Determine the clean URL path based on the file's directory
        clean_url=$(dirname "${file#$BASE_DIR}")
        # Handle the special case where the directory is the root
        if [ "$clean_url" == "." ]; then
            clean_url="/"
        else
            clean_url="/$clean_url/"
        fi
        # Write the Nginx redirect rule
        echo "rewrite ^$clean_url$ $redirect_url permanent;" >> "$OUTPUT_FILE"
    fi
done

echo "Nginx redirects written to $OUTPUT_FILE"
