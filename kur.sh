#!/usr/bin/env bash
# claude-kurallar — kurulum / install
# Ne yapar: kural dosyasini ~/.claude/ altina koyar ve onu system prompt'a ekleyerek
# Claude Code acan bir "ck" komutu tanimlar. Mevcut hicbir ayarini degistirmez.
#
# Dil secimi:  bash kur.sh tr   |   bash kur.sh en
# curl ile  :  curl -fsSL .../kur.sh | bash -s -- en
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/fornhere/claude-kurallar/main"

renk() { printf '\033[%sm%s\033[0m\n' "$1" "$2"; }
basarili() { renk "32" "  ✓ $1"; }
bilgi()    { renk "36" "  · $1"; }
uyari()    { renk "33" "  ! $1"; }

echo
renk "1;36" "claude-kurallar"
echo

# ── 0) Dil / language ─────────────────────────────────────────────────────────
DIL="${1:-${CLAUDE_KURALLAR_DIL:-}}"

if [ -z "$DIL" ]; then
  if [ -t 0 ]; then
    printf '  Dil / Language — [1] Türkçe  [2] English : '
    read -r SEC || SEC=""
    case "${SEC:-1}" in
      2|e|en|E|EN|English|english) DIL="en" ;;
      *)                           DIL="tr" ;;
    esac
  else
    DIL="tr"
    bilgi "dil seçilmedi, Türkçe kuruluyor · for English: bash -s -- en"
  fi
fi

case "$DIL" in
  en|EN|english|English)
    DIL="en"; KAYNAK_AD="rules.md"; HEDEF_AD="claude-rules.md"
    ANAHTAR="talk like a colleague"; YER="the user" ;;
  *)
    DIL="tr"; KAYNAK_AD="kurallar.md"; HEDEF_AD="kurallar.md"
    ANAHTAR="rapor sunma"; YER="Kullanıcı" ;;
esac

HEDEF="${CLAUDE_KURALLAR_YOL:-$HOME/.claude/$HEDEF_AD}"
mkdir -p "$(dirname "$HEDEF")"

# ── 1) Kural dosyasini yerine koy ─────────────────────────────────────────────
if [ -f "$HEDEF" ]; then
  YEDEK="$HEDEF.yedek.$(date +%Y%m%d%H%M%S)"
  cp "$HEDEF" "$YEDEK"
  uyari "$HEDEF zaten vardı, yedeği alındı: $YEDEK"
fi

# Yerel kopyayi YALNIZCA script gercekten diskten calisiyorsa kullan.
# `curl | bash` ile calisirken $0 "bash" olur, dirname "." doner ve o an
# bulundugun klasordeki bir kural dosyasi sessizce kurulurdu. Bilerek kapatildi.
YEREL=""
KAYNAK="${BASH_SOURCE[0]:-}"
if [ -n "$KAYNAK" ] && [ -f "$KAYNAK" ] && [ -f "$(dirname "$KAYNAK")/$KAYNAK_AD" ]; then
  YEREL="$(dirname "$KAYNAK")/$KAYNAK_AD"
fi

INDIR="$(mktemp)"
trap 'rm -f "$INDIR"' EXIT

if [ -n "$YEREL" ]; then
  cp "$YEREL" "$INDIR"
  bilgi "yerel kopya kullanıldı: $YEREL"
else
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REPO_RAW/$KAYNAK_AD" -o "$INDIR"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$INDIR" "$REPO_RAW/$KAYNAK_AD"
  else
    renk "31" "  ✗ curl da wget da yok / neither curl nor wget found."
    exit 1
  fi
  bilgi "$KAYNAK_AD depodan indirildi"
fi

# indirilen dosya gercekten kural dosyasi mi
if [ ! -s "$INDIR" ] || ! grep -q "$ANAHTAR" "$INDIR"; then
  renk "31" "  ✗ İndirilen dosya beklenen kural dosyası değil. Kurulum durduruldu."
  exit 1
fi

cp "$INDIR" "$HEDEF"
basarili "$KAYNAK_AD yerine kondu → $HEDEF"

# ── 2) İsim kişiselleştirme (opsiyonel) ───────────────────────────────────────
if [ -t 0 ]; then
  if [ "$DIL" = "en" ]; then
    printf '  How should the rules refer to you? (blank = "the user"): '
  else
    printf '  Kurallarda sana nasıl hitap edilsin? (boş bırak = "Kullanıcı"): '
  fi
  read -r ISIM || ISIM=""
  if [ -n "${ISIM:-}" ]; then
    # Sadece harf ve bosluk kabul et. Aksi halde girdi sed betigine kod olarak
    # sizabilir (ornegin "a/g; w /tmp/x") ve kural dosyasini bozabilirdi.
    if printf '%s' "$ISIM" | grep -qE '^[[:alpha:]][[:alpha:] ]{0,30}$'; then
      ISIM_E="$(printf '%s' "$ISIM" | sed 's/[\\&/]/\\&/g')"

      if [ "$DIL" = "en" ]; then
        sed "s/the user's/${ISIM_E}'s/g; s/The user's/${ISIM_E}'s/g; s/the user/${ISIM_E}/g; s/The user/${ISIM_E}/g" \
          "$HEDEF" > "$HEDEF.tmp" && mv "$HEDEF.tmp" "$HEDEF"
      else
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
      fi
      basarili "kurallar \"$ISIM\" adına uyarlandı"
    else
      uyari "isim yalnızca harf ve boşluk içerebilir — atlandı, \"$YER\" kaldı"
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
  if [ -f "$RC" ] && grep -Fq "# claude-kurallar" "$RC"; then
    uyari "$RC içinde başka dilde bir kurulum var — eski 'alias ck=' satırını elle sil"
  fi
  mkdir -p "$(dirname "$RC")"
  {
    echo ""
    echo "# claude-kurallar"
    echo "$SATIR"
  } >> "$RC"
  basarili "ck komutu $RC dosyasına eklendi"
fi

echo
renk "1" "  Kurulum bitti / Done."
echo
bilgi "Yeni bir terminal aç, sonra / open a new terminal, then:"
renk "1;32" "      ck"
echo
bilgi "Düzenlemek / edit:  \$EDITOR $HEDEF"
bilgi "Kaldırmak / remove: $RC içindeki 'claude-kurallar' satırlarını ve $HEDEF dosyasını sil."
echo
