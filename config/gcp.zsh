# Brew Google Cloud SDK
# brew install google-cloud-sdk
GCLOUD_PATH_INC="$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
[[ -f $GCLOUD_PATH_INC ]] && source $GCLOUD_PATH_INC
GCLOUD_COMPLETION="$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
[[ -f $GCLOUD_COMPLETION ]] && source $GCLOUD_COMPLETION
