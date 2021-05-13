if (( $+commands[yarn] )); then
  export PATH="$(yarn global bin 2>/dev/null):$PATH"
fi

# Node
# https://github.com/tj/n
if (( $+commands[n] )); then
  export N_PREFIX="$HOME/.n"
  export PATH="$N_PREFIX/bin:$PATH"
fi
export NPM_CONFIG_FUND=false
