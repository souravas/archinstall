#!/usr/bin/env zsh
# Web Application Installer
# Usage: webapp-install [app_name] [app_url] [icon_url]
# If no arguments provided, runs in interactive mode

webapp-install() {
    local app_name="$1"
    local app_url="$2"
    local icon_url="$3"

    # Interactive mode if no arguments provided
    if [[ -z "$app_name" ]]; then
        echo "🌐 Web App Installer"
        echo

        echo -n "App name: "
        read -r app_name
        [[ -z "$app_name" ]] && { echo "❌ App name cannot be empty"; return 1; }

        echo -n "App URL: "
        read -r app_url
        [[ -z "$app_url" ]] && { echo "❌ App URL cannot be empty"; return 1; }

        echo -n "Icon URL (PNG format): "
        read -r icon_url
        [[ -z "$icon_url" ]] && { echo "❌ Icon URL cannot be empty"; return 1; }
    fi

    # Validate inputs
    if [[ -z "$app_name" || -z "$app_url" || -z "$icon_url" ]]; then
        echo "Usage: webapp-install [app_name] [app_url] [icon_url]"
        echo "If no arguments provided, runs in interactive mode"
        return 1
    fi

    echo "📱 Installing webapp: $app_name"

    # Set up directories
    local icon_dir="$HOME/.local/share/applications/icons"
    local desktop_file="$HOME/.local/share/applications/$app_name.desktop"
    local icon_path="$icon_dir/$app_name.png"

    # Create icon directory if it doesn't exist
    mkdir -p "$icon_dir"

    # Download the icon
    echo "🖼️  Downloading icon..."
    if ! curl -sL -o "$icon_path" "$icon_url"; then
        echo "❌ Failed to download icon for $app_name"
        return 1
    fi

    # Determine which browser to use (prefer Brave, fallback to others)
    local browser_exec=""
    if command -v brave >/dev/null 2>&1; then
        browser_exec="brave --new-window --app=\"$app_url\" --name=\"$app_name\" --class=\"$app_name\""
        echo "🦁 Using Brave browser"
    elif command -v chromium >/dev/null 2>&1; then
        browser_exec="chromium --new-window --ozone-platform=wayland --app=\"$app_url\" --name=\"$app_name\" --class=\"$app_name\""
        echo "🔵 Using Chromium browser"
    elif command -v google-chrome-stable >/dev/null 2>&1; then
        browser_exec="google-chrome-stable --new-window --app=\"$app_url\" --name=\"$app_name\" --class=\"$app_name\""
        echo "🔴 Using Google Chrome"
    elif command -v firefox >/dev/null 2>&1; then
        browser_exec="firefox --new-window \"$app_url\""
        echo "🦊 Using Firefox"
    else
        echo "❌ No supported browser found (brave, chromium, chrome, or firefox)"
        echo "💡 Install a browser first: yay -S brave-bin"
        return 1
    fi

    # Create the desktop entry
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Name=$app_name
Comment=$app_name web application
Exec=$browser_exec
Terminal=false
Type=Application
Icon=$icon_path
StartupNotify=true
Categories=Network;WebBrowser;
EOF

    # Make the desktop file executable
    chmod +x "$desktop_file"

    echo "✅ Webapp $app_name installed successfully!"
    echo "🚀 You can now find $app_name in your application launcher"
}
