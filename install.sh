#!/bin/bash

# Check if stow is installed
if ! command -v stow &>/dev/null; then
	echo "GNU Stow could not be found, please install it first."
	exit
fi

# List of directories to stow
directories=(
	"kitty"
	"nvim"
	"p10k"
	"tmux"
	"zsh"
)

# Ask if user wants to stow all directories without asking
read -p "Do you want to stow all directories without asking? (y/n): " stow_all
echo ""

# Iterate over each directory and run stow
for dir in "${directories[@]}"; do
	if [ -d "$dir" ]; then
		if [[ "$stow_all" =~ ^[Yy]$ ]]; then
			echo "🔗 Stowing $dir..."
			stow "$dir"
			echo "✅ $dir stowed successfully!"
		else
			read -p "Do you want to stow $dir? (y/n): " choice
			case "$choice" in
			y | Y)
				echo "🔗 Stowing $dir..."
				stow "$dir"
				echo "✅ $dir stowed successfully!"
				;;
			*)
				echo "⏭️ Skipping $dir."
				;;
			esac
		fi
	else
		echo "☹️ Directory $dir does not exist."
	fi
	echo ""
done

echo ""
echo "🥳 Stowing complete!"
