
#!/bin/bash

# User configuration options
DOWNLOAD_DIR="$HOME/Downloads"  # Change this to your preferred download directory
EDITOR="nano"  # Change this to your preferred text editor

# Function to confirm with the user before proceeding
confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# Function to download and install packages from GitHub
github_pkg() {
    PKG_URL="$1"
    PKG_NAME=$(basename "$PKG_URL")
    PKG_DIR="$DOWNLOAD_DIR/$PKG_NAME"
    if [ -d "$PKG_DIR" ]; then
        echo "Package $PKG_NAME already exists in $DOWNLOAD_DIR. Skipping download."
    else
        echo "Downloading package $PKG_NAME from GitHub..."
        git clone "$PKG_URL" "$PKG_DIR"
    fi
    cd "$PKG_DIR"
    $EDITOR PKGBUILD  # Edit the PKGBUILD file
    if confirm "Install $PKG_NAME from GitHub? [y/N]"; then
        makepkg -si
    else
        echo "Installation of $PKG_NAME cancelled."
    fi
}

# Function to download and install packages from AUR
aur_pkg() {
    PKG_NAME="$1"
    PKG_DIR="$DOWNLOAD_DIR/$PKG_NAME"
    if [ -d "$PKG_DIR" ]; then
        echo "Package $PKG_NAME already exists in $DOWNLOAD_DIR. Skipping download."
    else
        echo "Downloading package $PKG_NAME from AUR..."
        git clone "https://aur.archlinux.org/$PKG_NAME.git" "$PKG_DIR"
    fi
    cd "$PKG_DIR"
    $EDITOR PKGBUILD  # Edit the PKGBUILD file
    if confirm "Install $PKG_NAME from AUR? [y/N]"; then
        makepkg -si
    else
        echo "Installation of $PKG_NAME cancelled."
    fi
}

# Function to delete a package
delete_pkg() {
    PKG_NAME="$1"
    PKG_DIR="$DOWNLOAD_DIR/$PKG_NAME"
    if [ ! -d "$PKG_DIR" ]; then
        echo "Package $PKG_NAME not found in $DOWNLOAD_DIR. Nothing to delete."
    else
        if confirm "Are you sure you want to delete $PKG_NAME from $DOWNLOAD_DIR? [y/N]"; then
            rm -rf "$PKG_DIR"
            echo "Package $PKG_NAME deleted from $DOWNLOAD_DIR."
        else
            echo "Deletion of $PKG_NAME cancelled."
        fi
    fi
}

# Parse command-line arguments
if [ "$1" == "-install" ]; then
    PKG_NAME="$2"
    aur_pkg "$PKG_NAME"
elif [ "$1" == "-uninstall" ]; then
    PKG_NAME="$2"
    delete_pkg "$PKG_NAME"
else
    echo "Usage: bah [-install|-uninstall] [pkg_name]"
    exit 1
fi

# Build and run script if present
SCRIPT="$DOWNLOAD_DIR/$PKG_NAME/run.sh"
if [ -f "$SCRIPT" ]; then
    echo "Running script $SCRIPT..."
    chmod +x "$SCRIPT"
    "$SCRIPT"
fi
