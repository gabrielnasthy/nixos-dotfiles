# Minimal Powerlevel10k config
# Documentação: https://github.com/romkatv/powerlevel10k

# Desativa o wizard interativo
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Segmentos básicos: tempo, diretório, git, status
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status)

# Estilo compacto
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

# Cores simples
typeset -g POWERLEVEL9K_TIME_FOREGROUND=250
typeset -g POWERLEVEL9K_DIR_FOREGROUND=110
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=178
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=203
