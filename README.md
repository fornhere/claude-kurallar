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
curl -fsSL https://raw.githubusercontent.com/fornhere/claude-kurallar/v1/kur.sh | bash
```

Kurulum başında dil sorar: **[1] Türkçe · [2] English**. Doğrudan seçmek istersen:

```bash
curl -fsSL https://raw.githubusercontent.com/fornhere/claude-kurallar/v1/kur.sh | bash -s -- en
```

Türkçe kurulumda dosya `~/.claude/kurallar.md`, İngilizcede `~/.claude/claude-rules.md`
olarak durur; `ck` kısayolu hangisini kurduysan ona bağlanır.

Script ne yapıyor, önce okumak istersen (tavsiye edilir — internetten gelen hiçbir script'i
körlemesine çalıştırma):

```bash
curl -fsSL https://raw.githubusercontent.com/fornhere/claude-kurallar/v1/kur.sh | less
```

Klonlayarak kurmak istersen:

```bash
git clone https://github.com/fornhere/claude-kurallar
cd claude-kurallar && bash kur.sh
```

Kurulum üç şey yapar, fazlasını değil:

1. seçtiğin dildeki kural dosyasını `~/.claude/` içine kopyalar (üstüne yazmaz, yedeğini alır),
2. kurallardaki "Kullanıcı" / "the user" ifadesini istersen kendi adınla değiştirir
   (Türkçede ek uyumuyla: *Ahmet'e*, *Gökçe'ye*, *Batuhan'ın*),
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

İngilizce dosyada bunların karşılığı `SHORT` · `FOCUS` · `18`, referans kodları da
`R1` (risks) · `D1` (decisions) · `F1` (findings).

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

## Güvenlik

`kur.sh` ne yapıyor, tamamı bu:

- `~/.claude/kurallar.md` dosyasını yazar (varsa önce zaman damgalı yedeğini alır),
- kabuk profiline `# claude-kurallar` yorumu ve tek bir `alias ck=` satırı ekler,
- opsiyonel olarak kural metnindeki "Kullanıcı" ifadesini verdiğin isimle değiştirir.

Yapmadıkları: `sudo` çağırmaz, paket kurmaz, mevcut Claude Code ayarlarını değiştirmez,
hiçbir yere veri göndermez. Depo dışına tek bir ağ isteği bile atmaz.

İki nokta bilerek sıkılaştırıldı:

- Kural dosyası **yalnızca** script gerçekten diskten çalışıyorsa yanındaki kopyadan alınır.
  `curl | bash` ile çalışırken depodan indirilir — yoksa o an bulunduğun klasördeki bir
  `kurallar.md` sessizce kurulabilirdi.
- İsim girdisi yalnızca harf ve boşluk kabul eder; aksi halde girdi metin değiştirme
  komutuna sızıp kural dosyasını bozabilirdi.

### Sürüme sabitlenmiş kurulum

Kurulum komutundaki `v1`, `main` dalı değil sabit bir sürüm etiketi. Depoda sonradan ne
değişirse değişsin o komut hep aynı kodu indirir.

`kur.sh` tamamı bir fonksiyonun içinde ve son satırda çağrılıyor. İndirme yarıda kesilirse
`bash` yarım script'i çalıştırmaz — fonksiyon hiç tanımlanmamış olur.

### Doğrulayarak kurmak

```bash
curl -fsSL https://raw.githubusercontent.com/fornhere/claude-kurallar/v1/kur.sh -o kur.sh
echo "3b41474f6f9496053e2748bf7c562c0bf35e470a0d4429c51c23fbe844d86d4e  kur.sh" | sha256sum -c -
bash kur.sh
```

`v1` sürümünün SHA-256'sı:

```
3b41474f6f9496053e2748bf7c562c0bf35e470a0d4429c51c23fbe844d86d4e
```

Yine de: internetten gelen hiçbir script'i okumadan çalıştırma. Bu da dahil.

## English

Same thing in English: `rules.md` is the translated rule set, installed to
`~/.claude/claude-rules.md`.

```bash
curl -fsSL https://raw.githubusercontent.com/fornhere/claude-kurallar/v1/kur.sh | bash -s -- en
```

Then open Claude Code with `ck`, which is short for
`claude --append-system-prompt-file ~/.claude/claude-rules.md`. It **appends** to Claude Code's
own system prompt — tool use, safety and permissions all stay in place.

The rules fix behaviour, not knowledge: no unasked-for tables or report headings, no bold slogan
openers, no em dash chains, no "which one should I do" at the end; plain conversational
paragraphs with the important part last; no silently widened scope; and no claiming a job is
done without verifying it. Three shortcuts — `SHORT`, `FOCUS`, `18` — trigger only when the
message is nothing but that word. Reference codes (`R1`, `D1`, `F1`) let you point at one item
instead of describing it again.

Don't use it as-is. Open a session, complain about what actually bothers you, and have Claude
write the rule itself:

```
In this session I'm going to complain about how you write. For each complaint, add one short
rule to ~/.claude/claude-rules.md. That file gets appended to your system prompt next session,
so write the rules as instructions to yourself: second person, imperative, two sentences max.
No headings, no intro, no decoration.
```

The rule file is read **at session start**, so restart Claude Code after editing it.

## Lisans

MIT — bkz. [LICENSE](LICENSE).
