#!/bin/sh
# Ensure winget-installed tools (jq) are on PATH in non-interactive shells
[ -d "/c/Users/Kidriel/AppData/Local/Microsoft/WinGet/Links" ] && export PATH="$PATH:/c/Users/Kidriel/AppData/Local/Microsoft/WinGet/Links"

# --- model (Manual default as Gemini CLI doesn't call this script via hook) ---
model="Gemini 2.0 Flash"

# --- folder ---
dir=$(pwd)
dir_name=$(basename "$dir")

# --- git branch + unsynced ---
branch=""
unsynced=0
if [ -d "${dir}/.git" ] || git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  unsynced=$(git -C "$dir" log '@{u}..HEAD' --oneline 2>/dev/null | wc -l | tr -d ' ')
fi

# --- stats cache (issues, per-repo) ---
issue_count=""
remote=$(git -C "$dir" remote get-url origin 2>/dev/null)
if [ -n "$remote" ]; then
  repo_slug=$(echo "$remote" | sed 's|.*github.com[:/]||' | sed 's|\.git$||' | tr '/' '_')
  STATS_CACHE="/tmp/.gemini_stats_cache_${repo_slug}"
  [ -f "$STATS_CACHE" ] && issue_count=$(sed -n '1p' "$STATS_CACHE")
fi

# --- inbox depth (obKidian only: only present when $dir is the vault) ---
inbox_depth=0
SCRATCH="$dir/001-Inbox/Scratch Book.md"
if [ -f "$SCRATCH" ]; then
  inbox_depth=$(awk '/^## Ramblings/{found=1; next} /^## /{found=0} found && /^- /{c++} END{print c+0}' "$SCRATCH")
fi

# --- gradient_text: Chrysaki Jewel animated gradient (left-to-right flow) ---
gradient_text() {
  local text="$1"
  local len="${#text}"
  [ "$len" -eq 0 ] && return
  local r1=26  g1=138 b1=106   # #1a8a6a Emerald Lt
  local r2=28  g2=61  b2=122   # #1c3d7a Royal Blue Lt
  local r3=88  g3=48  b3=144   # #583090 Amethyst Lt
  local span=$(( len > 1 ? len - 1 : 1 ))
  local i=0 t s r g b
  while [ "$i" -lt "$len" ]; do
    t=$(( (i * 200 / span + grad_phase) % 400 ))
    if [ "$t" -lt 100 ]; then
      r=$(( r1 + (r2 - r1) * t / 100 ))
      g=$(( g1 + (g2 - g1) * t / 100 ))
      b=$(( b1 + (b2 - b1) * t / 100 ))
    elif [ "$t" -lt 200 ]; then
      s=$(( t - 100 ))
      r=$(( r2 + (r3 - r2) * s / 100 ))
      g=$(( g2 + (g3 - g2) * s / 100 ))
      b=$(( b2 + (b3 - b2) * s / 100 ))
    elif [ "$t" -lt 300 ]; then
      s=$(( t - 200 ))
      r=$(( r3 + (r2 - r3) * s / 100 ))
      g=$(( g3 + (g2 - g3) * s / 100 ))
      b=$(( b3 + (b2 - b3) * s / 100 ))
    else
      s=$(( t - 300 ))
      r=$(( r2 + (r1 - r2) * s / 100 ))
      g=$(( g2 + (g1 - g2) * s / 100 ))
      b=$(( b2 + (b1 - b2) * s / 100 ))
    fi
    printf "\033[38;2;%d;%d;%dm%s" "$r" "$g" "$b" "${text:$i:1}"
    i=$(( i + 1 ))
  done
}

# --- Chrysaki colour palette ---
R="\033[0m"
DIM="\033[2m"
BOLD="\033[1m"
C_ORANGE="\033[38;5;208m"
C_BLONDE_LT="\033[38;2;208;184;80m"
C_TEAL="\033[38;2;30;136;152m"
C_EMERALD_LT="\033[38;2;26;138;106m"
C_SEC="\033[38;2;160;164;184m"
C_MUTED="\033[38;2;106;110;130m"

# --- animation phase ---
grad_phase=$(( ($(date +%s) * 6) % 400 ))

# --- assemble output ---
SEP="${C_MUTED} • ${R}"
PIPE="${C_MUTED} | ${R}"

# line 1: model | folder • branch ↑N
printf "${BOLD}"; gradient_text "$model"; printf "${R}"
printf "${PIPE}"
printf "${BOLD}"; gradient_text "$dir_name"; printf "${R}"
if [ -n "$branch" ]; then
  printf "${SEP}"
  printf "${BOLD}"; gradient_text "$branch"; printf "${R}"
  if [ "$unsynced" -gt 0 ] 2>/dev/null; then
    printf " ${C_BLONDE_LT}↑%s${R}" "$unsynced"
  fi
fi

# line 2: issues • inbox
printf "
"
has_second_line=0
if [ -n "$issue_count" ] && [ "$issue_count" -gt 0 ] 2>/dev/null; then
  printf "${C_TEAL}issues: %s${R}" "$issue_count"
  has_second_line=1
fi
if [ "$inbox_depth" -gt 0 ] 2>/dev/null; then
  [ "$has_second_line" -eq 1 ] && printf "${SEP}"
  printf "${C_EMERALD_LT}inbox: %s${R}" "$inbox_depth"
  has_second_line=1
fi

[ "$has_second_line" -eq 1 ] && printf "
"
