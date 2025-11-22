export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export EDITOR='nvim'
export VISUAL="$EDITOR"
export MANPAGER='nvim +Man!'
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
