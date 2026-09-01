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

# Yerel kopyayi YALNIZCA script gercekten diskten calisiyorsa kullan.
# `curl | bash` ile calisirken $0 "bash" olur, dirname "." doner ve o an
# bulundugun klasordeki bir kurallar.md sessizce kurulurdu. Bilerek kapatildi.
YEREL=""
KAYNAK="${BASH_SOURCE[0]:-}"
if [ -n "$KAYNAK" ] && [ -f "$KAYNAK" ] && [ -f "$(dirname "$KAYNAK")/kurallar.md" ]; then
  YEREL="$(dirname "$KAYNAK")/kurallar.md"
fi

INDIR="$(mktemp)"
trap 'rm -f "$INDIR"' EXIT

if [ -n "$YEREL" ]; then
  cp "$YEREL" "$INDIR"
  bilgi "yerel kopya kullanıldı: $YEREL"
else
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REPO_RAW/kurallar.md" -o "$INDIR"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$INDIR" "$REPO_RAW/kurallar.md"
  else
    renk "31" "  ✗ curl da wget da yok. kurallar.md'yi elle indir."
    exit 1
  fi
  bilgi "kurallar.md depodan indirildi"
fi

# indirilen dosya gercekten kural dosyasi mi
if [ ! -s "$INDIR" ] || ! grep -q "rapor sunma" "$INDIR"; then
  renk "31" "  ✗ İndirilen dosya beklenen kural dosyası değil. Kurulum durduruldu."
  exit 1
fi

cp "$INDIR" "$HEDEF"
basarili "kurallar.md yerine kondu → $HEDEF"

# ── 2) İsim kişiselleştirme (opsiyonel) ───────────────────────────────────────
if [ -t 0 ]; then
  printf '  Kurallarda sana nasıl hitap edilsin? (boş bırak = "Kullanıcı"): '
  read -r ISIM || ISIM=""
  if [ -n "${ISIM:-}" ]; then
    # Sadece harf ve bosluk kabul et. Aksi halde girdi sed betigine kod olarak
    # sizabilir (ornegin "a/g; w /tmp/x") ve kural dosyasini bozabilirdi.
    if printf '%s' "$ISIM" | LC_ALL=C.UTF-8 grep -qE '^[[:alpha:]][[:alpha:] ]{0,30}$'; then
      ISIM_E="$(printf '%s' "$ISIM" | sed 's/[\\&/]/\\&/g')"
      # Turkce unlu uyumu. Not: tr/tail -c gibi BAYT tabanli araclar cok baytli
      # harflerde (ç ğ ı ö ş ü) yanlis sonuc veriyor; bash substring karakter tabanli.
      SONV=""
      for ((i=${#ISIM}-1; i>=0; i--)); do
        case "${ISIM:i:1}" in
          a|A) SONV=a; break ;; e|E) SONV=e; break ;;
          ı|I) SONV=ı; break ;; i|İ) SONV=i; break ;;
          o|O) SONV=o; break ;; ö|Ö) SONV=ö; break ;;
          u|U) SONV=u; break ;; ü|Ü) SONV=ü; break ;;
        esac
      done
      case "$SONV" in
        a|ı) EK_A="a"; EK_IN="ın" ;;
        e|i) EK_A="e"; EK_IN="in" ;;
        o|u) EK_A="a"; EK_IN="un" ;;
        ö|ü) EK_A="e"; EK_IN="ün" ;;
        *)   EK_A="a"; EK_IN="ın" ;;
      esac
      # Unluyle biten isimde kaynastirma harfi: Gökçe'ye / Gökçe'nin
      case "${ISIM: -1}" in
        a|e|ı|i|o|ö|u|ü|A|E|I|İ|O|Ö|U|Ü) EK_A="y$EK_A"; EK_IN="n$EK_IN" ;;
      esac
      sed "s/Kullanıcıya/${ISIM_E}'${EK_A}/g; s/Kullanıcının/${ISIM_E}'${EK_IN}/g; s/Kullanıcı/${ISIM_E}/g" \
        "$HEDEF" > "$HEDEF.tmp" && mv "$HEDEF.tmp" "$HEDEF"
      basarili "kurallar \"$ISIM\" adına uyarlandı"
    else
      uyari "isim yalnızca harf ve boşluk içerebilir — atlandı, \"Kullanıcı\" kaldı"
    fi
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
