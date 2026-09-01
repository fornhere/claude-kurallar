#!/usr/bin/env bash
# claude-kurallar — kurulum
# Ne yapar: kurallar.md'yi ~/.claude/ altına koyar ve onu system prompt'a ekleyerek
# Claude Code açan bir "ck" komutu tanımlar. Mevcut hiçbir ayarını değiştirmez.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/fornhere/claude-kurallar/main"
HEDEF="${CLAUDE_KURALLAR_YOL:-$HOME/.claude/kurallar.md}"

renk() { printf '\033[%sm%s\033[0m\n' "$1" "$2"; }
basarili() { renk "32" "  ✓ $1"; }
bilgi()    { renk "36" "  · $1"; }
uyari()    { renk "33" "  ! $1"; }

echo
renk "1;36" "claude-kurallar"
echo

# ── 1) kurallar.md'yi yerine koy ──────────────────────────────────────────────
mkdir -p "$(dirname "$HEDEF")"

if [ -f "$HEDEF" ]; then
  YEDEK="$HEDEF.yedek.$(date +%Y%m%d%H%M%S)"
  cp "$HEDEF" "$YEDEK"
  uyari "$HEDEF zaten vardı, yedeği alındı: $YEDEK"
fi

if [ -f "$(dirname "$0")/kurallar.md" ]; then
  cp "$(dirname "$0")/kurallar.md" "$HEDEF"
  basarili "kurallar.md kopyalandı → $HEDEF"
else
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REPO_RAW/kurallar.md" -o "$HEDEF"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$HEDEF" "$REPO_RAW/kurallar.md"
  else
    renk "31" "  ✗ curl da wget da yok. kurallar.md'yi elle indir."
    exit 1
  fi
  basarili "kurallar.md indirildi → $HEDEF"
fi

# ── 2) İsim kişiselleştirme (opsiyonel) ───────────────────────────────────────
if [ -t 0 ]; then
  printf '  Kurallarda sana nasıl hitap edilsin? (boş bırak = "Kullanıcı"): '
  read -r ISIM || ISIM=""
  if [ -n "${ISIM:-}" ]; then
    # BSD ve GNU sed farkını atlamak için geçici dosya üzerinden
    sed "s/Kullanıcıya/${ISIM}'a/g; s/Kullanıcının/${ISIM}'un/g; s/Kullanıcı/${ISIM}/g" \
      "$HEDEF" > "$HEDEF.tmp" && mv "$HEDEF.tmp" "$HEDEF"
    basarili "kurallar \"$ISIM\" adına uyarlandı"
  fi
fi

# ── 3) ck komutunu tanımla ────────────────────────────────────────────────────
KABUK="$(basename "${SHELL:-bash}")"
case "$KABUK" in
  zsh)  RC="$HOME/.zshrc" ;;
  fish) RC="$HOME/.config/fish/config.fish" ;;
  *)    RC="$HOME/.bashrc" ;;
esac

if [ "$KABUK" = "fish" ]; then
  SATIR="alias ck 'claude --append-system-prompt-file $HEDEF'"
else
  SATIR="alias ck='claude --append-system-prompt-file $HEDEF'"
fi

if [ -f "$RC" ] && grep -Fq "append-system-prompt-file $HEDEF" "$RC"; then
  bilgi "ck komutu zaten $RC içinde tanımlı"
else
  mkdir -p "$(dirname "$RC")"
  {
    echo ""
    echo "# claude-kurallar"
    echo "$SATIR"
  } >> "$RC"
  basarili "ck komutu $RC dosyasına eklendi"
fi

echo
renk "1" "  Kurulum bitti."
echo
bilgi "Yeni bir terminal aç, sonra:"
renk "1;32" "      ck"
echo
bilgi "Kuralları düzenlemek için:  \$EDITOR $HEDEF"
bilgi "Kaldırmak için: $RC içindeki 'claude-kurallar' satırlarını sil, $HEDEF dosyasını kaldır."
echo
