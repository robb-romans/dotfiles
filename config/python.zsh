# if (( $+commands[pyenv] )); then
#   export PYENV_ROOT="$HOME/.pyenv"
#   export PATH="$PYENV_ROOT/bin:$PATH
#   eval "$(pyenv init --path)"
#   eval "$(pyenv init -)"
# fi

# if (( $+commands[pyenv-virtualenv-init] )); then
#   eval "$(pyenv virtualenv-init -)"
# fi

# # Disable python virtualenv environment prompt prefix
# export VIRTUAL_ENV_DISABLE_PROMPT=true

# Use Brew Python
if (( $+commands[brew] )); then
  alias python=$(brew --prefix)/bin/python3
  alias pip=$(brew --prefix)/bin/pip3
fi
