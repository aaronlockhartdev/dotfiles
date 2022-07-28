#!/bin/bash

echo "🤚  This script will setup .dotfiles for you."

case "$OSTYPE" in
  darwin*) # MacOS 
    echo "🍎  Running on MacOS"

    # Install Homebrew
    command -v brew >/dev/null 2>&1 || \
      (echo "🍺  Installing Homebrew" && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")
    
    # Create install function for brew
    function install {
      which $1 &> /dev/null

      if [ $? -ne 0 ]; then
        echo "➡️  Installing ${1}..."
        brew install $1
	echo "✅  Done!"
      else
        echo "⚠️  Already installed ${1}"
      fi
    }
  ;; 
  linux*) # Linux
    echo "🐧  Running on Linux"

    # Update system
    echo "⬆️  Upgrading system..." && sudo apt update && sudo apt full-upgrade -y

    # Create install function for apt
    function install {
      which $1 &> /dev/null
    
      if [ $? -ne 0 ]; then
        echo "➡️  Installing ${1}..."
        sudo apt install -y $1
	echo "✅  Done!"
      else
       echo "⚠️  Already installed ${1}"
      fi
}    
  ;;
esac

# Install package-managed CLI utilities
install zsh
install git
install curl
install wget

# Install other CLI utilities

# Install oh-my-zsh
echo "➡️  Installing oh-my-zsh..." && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install pyenv
command -v pyenv >/dev/null 2>&1 || \
  (echo "➡️  Installing pyenv..." && (curl https://pyenv.run | bash))

# Install dotfiles with chezmoi
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
  echo "⚠️  chezmoi already initialized, reinitialize with 'chezmoi init https://github.com/aaronlockhartdev/dotfiles.git"
else
  echo "🚀  Initializing dotfiles..." && $ sh -c "$(curl -fsLS https://chezmoi.io/get)" -- init --apply aaronlockhartdev
fi

