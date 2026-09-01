# claude-kurallar

Claude Code'un **zekâsına değil, huyuna** dokunan bir kural dosyası.

Opus 5 doğru bilgiyi veriyor ama bir insan gibi vermiyor: basit soruya danışman raporu, sormadan
genişletilen kapsam, kanıtsız "bitti", ve her seferinde baştan anlatılan aynı şey. Bu depodaki
`kurallar.md` bu dört huyu düzeltiyor — modelin ne bildiğine değil, nasıl davrandığına.

Kuralların hiçbiri elle yazılmadı. Her biri bir şikâyetten çıktı ve **Claude'un kendisi** yazdı;
dosyaya tek harf müdahale edilmedi. Videodaki oturumun çıktısı bu.

> Video: *(link videoda)* · Kanal: [Forn AI](https://youtube.com/@fornai)

---

## Kurulum — tek komut

```bash
curl -fsSL https://raw.githubusercontent.com/fornhere/claude-kurallar/main/kur.sh | bash
```

Script ne yapıyor, önce okumak istersen (tavsiye edilir — internetten gelen hiçbir script'i
körlemesine çalıştırma):

```bash
curl -fsSL https://raw.githubusercontent.com/fornhere/claude-kurallar/main/kur.sh | less
```

Klonlayarak kurmak istersen:

```bash
git clone https://github.com/fornhere/claude-kurallar
cd claude-kurallar && bash kur.sh
```

Kurulum üç şey yapar, fazlasını değil:

1. `kurallar.md`'yi `~/.claude/kurallar.md` içine kopyalar (üstüne yazmaz, yedeğini alır),
2. kurallardaki "Kullanıcı" ifadesini istersen kendi adınla değiştirir,
3. kabuk profiline `ck` diye bir kısayol ekler.

Sonra:

```bash
ck
```

Bu, şunun kısaltması:

```bash
claude --append-system-prompt-file ~/.claude/kurallar.md
```

**`append` kelimesi önemli.** Claude Code'un kendi system prompt'unu değiştirmiyor, üstüne
ekliyor. Araç kullanımı, güvenlik, izinler — hepsi yerinde kalıyor.

---

## Kurallar ne yapıyor

| # | Kural | Neyi düzeltiyor |
|---|---|---|
| 1 | İş arkadaşı gibi konuş, rapor sunma | Basit soruya danışman raporu gelmesi |
| 2 | İstenmedikçe tablo, rapor başlığı, kalın slogan, em dash zinciri yok | Cevabın sunum slaytına dönmesi |
| 3 | Sonda "hangisini yapayım" diye iş dağıtma | İstenmemiş kapanış teklifleri |
| 4 | Düz paragraf, konuşur gibi | Madde madde parçalanmış anlatım |
| 5 | En önemli şeyi sona koy | Terminalde en son satırın ilk görülmesi |
| 6 | Sorulmayan işi yapma, kapsamı kendin genişletme | "Şuna bak" deyince dosyanın yeniden düzenlenmesi |
| 7 | Muğlaksa tek soru sor, ama tahminini de söyle | Her şeye "ne açıdan?" diye cevap verilmesi |
| 8 | "Bitti" demeden önce sonucu kendin doğrula | Kanıtsız tamamlandı beyanı |
| 9–12 | `SIK` · `ODAK` · `18` kısayolları | Her seferinde "kısalt" yazmak |
| 13–14 | Referans kodları (`R1`, `K1`, `B2`) | Aynı şeyi üç kere anlatmak |

### Kısayollar

Mesaj **yalnızca** o kelimeden ibaretse çalışır — cümle içinde geçerse normal metindir.

| Yaz | Ne olur |
|---|---|
| `SIK` | Son cevabı aynı bilgiyle sıkıştırır |
| `ODAK` | Asıl meseleyi tek paragrafta söyler |
| `18` | Konuyu 18 yaşındakine anlatır gibi anlatır |

### Referans kodları

Üç veya daha fazla madde sunarken her birine kod verir: riskler `R1`, `R2`; kararlar `K1`;
bulgular `B1`. Sen sonra sadece `R2'yi aç` yazarsın, o hangisi olduğunu bilir.

---

## Neden system prompt, neden `CLAUDE.md` değil

İkisine de davranış yazılabilir ve ikisi de çalışır. Ama iş bölümü şu:

- **`CLAUDE.md` bağlam taşır** — modelin *ne bildiği*. Proje değişince o bilgi de değişir.
- **System prompt davranış taşır** — modelin *nasıl davrandığı*. Her mesajda en önde durur ve
  yüzlerce satır proje bilgisinin arasında kaybolmaz.

Davranış kuralını bağlam dosyasına yazmak, ev kuralını misafir odasına asmaya benziyor: o odada
geçerli, mutfağa geçince kimse uymuyor.

---

## Kendine göre değiştir

Bu dosya bir manifesto değil, bir başlangıç. **Olduğu gibi kullanma** — kendi şikâyetlerinden
kendi kurallarını çıkar. Yöntem şu: bir oturum aç, şikâyet et, kuralı Claude'un kendisine
yazdır, sonra oturumu kapatıp yeniden aç.

```bash
claude --append-system-prompt-file ~/.claude/kurallar.md
```

```
Bu oturumda senden şikâyetlerim olacak. Her şikâyetimde ~/.claude/kurallar.md dosyasına kısa
bir kural ekle. Bu dosya bir sonraki oturumda system prompt'una eklenecek — yani kuralları
kendine talimat yazar gibi yaz: ikinci tekil, emir kipi, kural başına en fazla iki cümle.
Dosyaya başlık, giriş, süsleme koyma.
```

> Kural dosyası **oturum açılırken** okunuyor. Yeni kural ekledikten sonra oturumu kapatıp
> yeniden açman gerekiyor.

### Az yaz

Anthropic kendi system prompt'una tek bir kısalık talimatı ekledi, bazı modellerde kod kalitesi
düştü ve değişikliği geri aldılar. Buradan çıkan ders "çok kural yaz" değil: **az yaz, tam kendi
derdine yaz, ve yazdığın kuralın işini bozup bozmadığına bak.**

Bu dosyada bilerek "hep kısa yaz" yok. Varsayılan zengin kalıyor, kısalık `SIK` yazınca geliyor.

---

## Gereksinimler

- [Claude Code](https://claude.com/claude-code)
- `bash` · `curl` veya `wget`
- Sonnet, Opus, Haiku — hepsinde çalışır. System prompt modele bağlı değil; ama her modelin
  tikleri farklı, kendi listeni yap.

## Kaldırma

```bash
rm ~/.claude/kurallar.md
```

Sonra kabuk profilinden (`~/.bashrc` · `~/.zshrc` · `~/.config/fish/config.fish`)
`# claude-kurallar` yorumunu ve altındaki `alias ck=` satırını sil.

## Lisans

MIT — bkz. [LICENSE](LICENSE).
