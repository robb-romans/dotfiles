if (( $+commands[pyenv] )); then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

if (( $+commands[pyenv-virtualenv-init] )); then
  eval "$(pyenv virtualenv-init -)"
fi

# Disable python virtualenv environment prompt prefix
# https://stackoverflow.com/questions/10406926/how-do-i-change-the-default-virtualenv-prompt
export VIRTUAL_ENV_DISABLE_PROMPT=true

# # Use Brew Python
# if (( $+commands[brew] )); then
#   alias python=$(brew --prefix)/opt/python/libexec/bin/python
#   alias pip=$(brew --prefix)/opt/python/libexec/bin/pip
# fi

# Use Brew Python
# Set path instead of alias
if (( $+commands[brew] )); then
   typeset -U path PATH
   path=($(brew --prefix)/opt/python/libexec/bin "$path[@]")
fi
