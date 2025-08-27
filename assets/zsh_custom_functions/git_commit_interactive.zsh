# ---- Git Commit Interactive Function ----
git_commit_interactive() {

  # ---- Colors ----
  local GREEN="\e[32m"
  local YELLOW="\e[33m"
  local CYAN="\e[36m"
  local BLUE="\e[34m"
  local MAGENTA="\e[35m"
  local RED="\e[31m"
  local RESET="\e[0m"

  for cmd in fzf git; do
    if ! command -v $cmd &> /dev/null 2>&1; then
      echo -e "${RED}Error:${RESET} '$cmd' is not installed. Please install it to use this function."
      return 1
    fi
  done

  if command -v nvim > /dev/null 2>&1; then
    local EDITOR_CMD="nvim"
  elif command -v vim > /dev/null 2>&1; then
    local EDITOR_CMD="vim"
  else
    local EDITOR_CMD="${EDITOR_CMD:-vi}" # Fallback to vi if no editor is set
  fi

  echo -e "${CYAN}=== Git Commit Interactive ===${RESET}"

  type_label=$(printf "%s\n" \
    "feat     (Nova funcionalidade) - ex: adiciona login via Google" \
    "fix      (Correção de bug) - ex: corrige crash ao abrir perfil" \
    "docs     (Documentação) - ex: atualiza README" \
    "style    (Formatação/Estilo) - ex: ajusta indentação CSS" \
    "refactor (Refatoração) - ex: simplifica função de autenticação" \
    "perf     (Performance) - ex: otimiza loop de carregamento" \
    "test     (Testes) - ex: adiciona teste unitário" \
    "chore    (Tarefas diversas) - ex: atualiza dependências" \
    "build    (Build system) - ex: ajusta script de build" \
    "ci       (Integração contínua) - ex: atualiza pipeline CI" \
    "config   (Configurações) - ex: altera .gitignore" \
    "deploy   (Deploy) - ex: ajusta script de deploy" \
    "init     (Inicialização) - ex: cria estrutura do projeto" \
    "move     (Movimento de arquivos) - ex: move utils/ para core/" \
    "rename   (Renomear) - ex: renomeia módulo de auth" \
    "remove   (Remoção) - ex: remove código legado" \
    "update   (Atualização) - ex: atualiza lógica de cache" \
    "security (Segurança) - ex: corrige vulnerabilidade XSS" \
    "revert   (Reversão) - ex: revert commit Y" |
    fzf --prompt="Tipo de commit > " --height=20 --border --ansi --color=pointer:green,fg:cyan,bg:black)

  [ -z "$type_label" ] && echo -e "${RED}❌ Cancelado${RESET}" && return 1
  type=$(echo "$type_label" | awk '{print $1}')

  scope_options=("⏭ Pular" "✏️ Outro" "api" "ui" "db" "tests" "ci" "infra")
  scope=$(printf "%s\n" "${scope_options[@]}" | fzf --prompt="Escopo (opcional) > " --height=10 --border --ansi --color=pointer:green,fg:cyan,bg:black)

  if [[ "$scope" =~ ^⏭ ]]; then
    scope=""
  elif [[ "$scope" =~ ^✏️ ]]; then
    echo -ne "${CYAN}Defina o escopo: ${RESET}"
    read -r scope
    scope=$(echo "$scope" | xargs)
    [ -n "$scope" ] && scope="($scope)" || scope=""
  else
    scope="($scope)"
  fi

  while true; do
    echo -ne "${CYAN}Descrição curta (máx 50 chars): ${RESET}"
    read -r subject
    subject=$(echo "$subject" | xargs)

    if [ -z "$subject" ]; then
      echo -e "${RED}❌ Descrição obrigatória!${RESET}"
    elif [ ${#subject} -gt 50 ]; then
      echo -e "${YELLOW}⚠️  Descrição muito longa (${#subject} chars). Máximo: 50.${RESET}"
    else
      break
    fi
  done

  tmpfile=$(mktemp)
  cat >"$tmpfile" <<'EOF'

# ================================
# Escreva o body da mensagem aqui
# Dicas:
# - Explique o "PORQUÊ" e o "O QUE" mudou (não o "como")
# - Quebre linhas a cada ~72 caracteres
# - Use parágrafos se precisar
# - Salve e feche o editor para continuar
# ================================
EOF

  $EDITOR_CMD "$tmpfile"
  body=$(grep -v '^#' "$tmpfile" | sed '/^\s*$/d')
  rm -f "$tmpfile"

  echo -ne "${MAGENTA}Footer (refs, breaking changes, opcional): ${RESET}"
  read -r footer
  footer=$(echo "$footer" | xargs)

  commit_preview="${GREEN}$type${RESET}${YELLOW}$scope${RESET}: ${CYAN}$subject${RESET}"
  [ -n "$body" ] && commit_preview="$commit_preview\n\n${BLUE}$body${RESET}"
  [ -n "$footer" ] && commit_preview="$commit_preview\n\n${MAGENTA}$footer${RESET}"

  commit_raw="$type$scope: $subject"
  [ -n "$body" ] && commit_raw="$commit_raw"$'\n\n'"$body"
  [ -n "$footer" ] && commit_raw="$commit_raw"$'\n\n'"$footer"

  echo
  echo -e "${CYAN}=== Pré-visualização do Commit ===${RESET}"
  echo -e "---------------------------------"
  echo -e "$commit_preview"
  echo -e "---------------------------------"

  echo -ne "${CYAN}Confirmar commit? (y/n): ${RESET}"
  read -r confirm
  if [ "$confirm" = "y" ]; then
    git commit -m "$commit_raw"
    echo -e "${GREEN}✅ Commit feito com sucesso!${RESET}"
  else
    echo -e "${RED}❌ Commit cancelado.${RESET}"
  fi
}