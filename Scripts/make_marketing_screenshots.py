#!/usr/bin/env python3
"""한땀 마케팅 스크린샷: HTML → 헤드리스 Chrome. 1242×2688 (이 계정의 iPhone 제출 규격).

원본: docs/screenshots/raw/<앱 언어>/<장면>.png — Scripts/capture_screens.sh 가 DEBUG 장면을 찍은 것.
결과: docs/screenshots/marketing/<스토어 로케일>/0N-….png (파일 이름 순서 = 스토어 순서)
사용법: python3 Scripts/make_marketing_screenshots.py [언어 ...]

바탕은 앱과 같은 면천색(#FAF5EE)에 페그보드 점, 글자는 먹색, 강조는 빨간 실(#D9453D).
가격 · 할인 · 다른 회사 상표는 헤드라인에 넣지 않는다.
"""
import subprocess, sys, pathlib, tempfile, time

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw"
OUTROOT = ROOT / "docs" / "screenshots" / "marketing"
WORK = pathlib.Path(tempfile.gettempdir())
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1242, 2688

STORE = {"ko": "ko", "en": "en-US", "en-GB": "en-GB", "ja": "ja", "zh-Hans": "zh-Hans", "zh-Hant": "zh-Hant", "ru": "ru", "es": "es-ES", "de": "de-DE", "fr": "fr-FR", "it": "it", "pt-BR": "pt-BR", "th": "th", "vi": "vi", "cs": "cs", "da": "da", "el": "el", "fi": "fi", "id": "id", "nb": "nb", "nl": "nl-NL", "pl": "pl", "sv": "sv", "tr": "tr"}

# (출력 파일, 원본 장면, 배치, 헤드라인, 보조 문구)
SHOTS_BY_LANG = {
    "ko": [
        ("01-photo.png",   "maker",   "hero",   "사진 한 장이<br>비즈 도안으로", "크기와 색 수를 고르면 바로 미리 봐요"),
        ("02-colors.png",  "detail",  "left",   "실제로 파는<br>색으로 맞춰요", "색 번호와 색마다 필요한 개수까지"),
        ("03-symbols.png", "symbols", "bottom", "칸마다 기호로<br>헷갈리지 않게", "보드 경계는 굵게, 고칠 칸은 눌러서"),
        ("04-print.png",   "pdf",     "tilt",   "인쇄해서<br>바로 시작해요", "보드마다 나눈 도안과 색 목록 PDF"),
        ("05-stitch.png",  "stitch",  "hero",   "십자수 도안도<br>한 번에", "실 색 번호와 천 카운트별 완성 크기"),
        ("06-home.png",    "home",    "accent", "만든 도안은<br>한곳에 모아요", "키링, 액자, 선물까지 내 도안 목록"),
    ],
    "en": [
        ("01-photo.png",   "maker",   "hero",   "Any photo,<br>a bead pattern", "Pick a size and colors, see it instantly"),
        ("02-colors.png",  "detail",  "left",   "Matched to colors<br>you can buy", "Color numbers and counts for each one"),
        ("03-symbols.png", "symbols", "bottom", "A symbol<br>in every square", "Bold board lines, tap any square to fix"),
        ("04-print.png",   "pdf",     "tilt",   "Print it and<br>start making", "Board by board charts and a color list"),
        ("05-stitch.png",  "stitch",  "hero",   "Cross-stitch<br>patterns too", "Thread numbers and size for your fabric"),
        ("06-home.png",    "home",    "accent", "All your patterns<br>in one place", "Keychains, frames and gifts"),
    ],
    "en-GB": [
        ("01-photo.png",   "maker",   "hero",   "Any photo,<br>a bead pattern", "Pick a size and colours, see it instantly"),
        ("02-colors.png",  "detail",  "left",   "Matched to colours<br>you can buy", "Colour numbers and counts for each one"),
        ("03-symbols.png", "symbols", "bottom", "A symbol<br>in every square", "Bold board lines, tap any square to fix"),
        ("04-print.png",   "pdf",     "tilt",   "Print it and<br>start making", "Board by board charts and a colour list"),
        ("05-stitch.png",  "stitch",  "hero",   "Cross-stitch<br>patterns too", "Thread numbers and size for your fabric"),
        ("06-home.png",    "home",    "accent", "All your patterns<br>in one place", "Keyrings, frames and gifts"),
    ],
    "ja": [
        ("01-photo.png",   "maker",   "hero",   "写真1枚が<br>ビーズ図案に", "サイズと色数を選べば、すぐにプレビュー"),
        ("02-colors.png",  "detail",  "left",   "実際に買える<br>色に合わせます", "色番号と、色ごとに必要な数まで"),
        ("03-symbols.png", "symbols", "bottom", "マスごとの記号で<br>迷わない", "境目は太線、直したいマスはタップで"),
        ("04-print.png",   "pdf",     "tilt",   "印刷して<br>すぐに作れる", "プレートごとの図案と色リストをPDFで"),
        ("05-stitch.png",  "stitch",  "hero",   "クロスステッチの<br>図案も", "糸の色番号と、布ごとの仕上がりサイズ"),
        ("06-home.png",    "home",    "accent", "作った図案を<br>ひとまとめに", "キーホルダーも額もプレゼントも"),
    ],
    "zh-Hans": [
        ('01-photo.png', 'maker', 'hero', '一张照片<br>变成拼豆图纸', '选好尺寸和颜色数，马上预览'),
        ('02-colors.png', 'detail', 'left', '按买得到的<br>颜色来配', '色号和每种颜色的用量都有'),
        ('03-symbols.png', 'symbols', 'bottom', '每格一个符号<br>不会看错', '底板分界加粗，点格子就能改'),
        ('04-print.png', 'pdf', 'tilt', '打印出来<br>马上开做', '按底板分块的图纸和颜色清单 PDF'),
        ('05-stitch.png', 'stitch', 'hero', '十字绣图纸<br>也能做', '绣线色号和各 count 绣布的成品尺寸'),
        ('06-home.png', 'home', 'accent', '做过的图纸<br>集中收好', '钥匙扣、画框、礼物都在这里'),
    ],
    "zh-Hant": [
        ('01-photo.png', 'maker', 'hero', '一張照片<br>變成拼豆圖紙', '選好尺寸和顏色數，馬上預覽'),
        ('02-colors.png', 'detail', 'left', '依買得到的<br>顏色來配', '色號和每種顏色的用量都有'),
        ('03-symbols.png', 'symbols', 'bottom', '每格一個符號<br>不會看錯', '底板分界加粗，點格子就能改'),
        ('04-print.png', 'pdf', 'tilt', '列印出來<br>馬上開做', '依底板分塊的圖紙和顏色清單 PDF'),
        ('05-stitch.png', 'stitch', 'hero', '十字繡圖紙<br>也能做', '繡線色號和各 count 繡布的成品尺寸'),
        ('06-home.png', 'home', 'accent', '做過的圖紙<br>集中收好', '鑰匙圈、相框、禮物都在這裡'),
    ],
    "ru": [
        ('01-photo.png', 'maker', 'hero', 'Из одного фото —<br>схема из бусин', 'Выберите размер и цвета и сразу увидите'),
        ('02-colors.png', 'detail', 'left', 'Цвета, которые<br>можно купить', 'Номера и количество для каждого цвета'),
        ('03-symbols.png', 'symbols', 'bottom', 'Значок в каждой<br>клетке', 'Жирные границы основ, любую клетку можно поправить'),
        ('04-print.png', 'pdf', 'tilt', 'Распечатайте<br>и за дело', 'Схемы по основам и список цветов в PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'И схемы для<br>вышивки крестом', 'Номера ниток и размер на вашей канве'),
        ('06-home.png', 'home', 'accent', 'Все схемы<br>в одном месте', 'Брелоки, рамки и подарки'),
    ],
    "es": [
        ('01-photo.png', 'maker', 'hero', 'De una foto a un<br>patrón de cuentas', 'Elige tamaño y colores y míralo al instante'),
        ('02-colors.png', 'detail', 'left', 'Colores que<br>puedes comprar', 'Número y cantidad de cada color'),
        ('03-symbols.png', 'symbols', 'bottom', 'Un símbolo en<br>cada casilla', 'Líneas gruesas por placa, toca para retocar'),
        ('04-print.png', 'pdf', 'tilt', 'Imprime y<br>a trabajar', 'Patrones por placa y lista de colores en PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'También patrones<br>de punto de cruz', 'Números de hilo y tamaño según tu tela'),
        ('06-home.png', 'home', 'accent', 'Todos tus patrones<br>en un solo sitio', 'Llaveros, marcos y regalos'),
    ],
    "de": [
        ('01-photo.png', 'maker', 'hero', 'Aus einem Foto<br>eine Perlenvorlage', 'Größe und Farben wählen, sofort sehen'),
        ('02-colors.png', 'detail', 'left', 'Farben, die es<br>wirklich gibt', 'Farbnummern und Mengen für jede Farbe'),
        ('03-symbols.png', 'symbols', 'bottom', 'Ein Symbol in<br>jedem Feld', 'Fette Plattengrenzen, Felder per Tipp ändern'),
        ('04-print.png', 'pdf', 'tilt', 'Ausdrucken und<br>loslegen', 'Vorlagen pro Platte und Farbliste als PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Auch Kreuzstich-<br>Vorlagen', 'Garnnummern und Größe für deinen Stoff'),
        ('06-home.png', 'home', 'accent', 'Alle Vorlagen<br>an einem Ort', 'Schlüsselanhänger, Rahmen und Geschenke'),
    ],
    "fr": [
        ('01-photo.png', 'maker', 'hero', 'D’une photo à une<br>grille de perles', 'Choisissez taille et couleurs, aperçu immédiat'),
        ('02-colors.png', 'detail', 'left', 'Des couleurs que<br>l’on peut acheter', 'Numéros et quantités pour chaque couleur'),
        ('03-symbols.png', 'symbols', 'bottom', 'Un symbole dans<br>chaque case', 'Limites de plaque en gras, touchez pour corriger'),
        ('04-print.png', 'pdf', 'tilt', 'Imprimez et<br>lancez-vous', 'Grilles par plaque et liste des couleurs en PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Des grilles de<br>point de croix aussi', 'Numéros de fil et taille selon votre toile'),
        ('06-home.png', 'home', 'accent', 'Toutes vos grilles<br>au même endroit', 'Porte-clés, cadres et cadeaux'),
    ],
    "it": [
        ('01-photo.png', 'maker', 'hero', 'Da una foto a uno<br>schema di perline', 'Scegli dimensione e colori, anteprima subito'),
        ('02-colors.png', 'detail', 'left', 'Colori che si<br>possono comprare', 'Numeri e quantità per ogni colore'),
        ('03-symbols.png', 'symbols', 'bottom', 'Un simbolo in<br>ogni casella', 'Bordi delle basi in grassetto, tocca per correggere'),
        ('04-print.png', 'pdf', 'tilt', 'Stampa e<br>inizia', 'Schemi per base ed elenco colori in PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Anche schemi<br>a punto croce', 'Numeri dei fili e misura sulla tua tela'),
        ('06-home.png', 'home', 'accent', 'Tutti i tuoi schemi<br>in un unico posto', 'Portachiavi, cornici e regali'),
    ],
    "pt-BR": [
        ('01-photo.png', 'maker', 'hero', 'De uma foto a um<br>padrão de miçangas', 'Escolha tamanho e cores e veja na hora'),
        ('02-colors.png', 'detail', 'left', 'Cores que você<br>pode comprar', 'Número e quantidade de cada cor'),
        ('03-symbols.png', 'symbols', 'bottom', 'Um símbolo em<br>cada quadradinho', 'Divisas das placas em negrito, toque para ajustar'),
        ('04-print.png', 'pdf', 'tilt', 'Imprima e<br>mãos à obra', 'Padrões por placa e lista de cores em PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Padrões de ponto<br>cruz também', 'Números dos fios e tamanho no seu tecido'),
        ('06-home.png', 'home', 'accent', 'Todos os seus padrões<br>em um só lugar', 'Chaveiros, quadros e presentes'),
    ],
    "th": [
        ('01-photo.png', 'maker', 'hero', 'จากรูปใบเดียว<br>เป็นแพตเทิร์นลูกปัด', 'เลือกขนาดและจำนวนสี แล้วดูตัวอย่างทันที'),
        ('02-colors.png', 'detail', 'left', 'สีที่หาซื้อ<br>ได้จริง', 'เลขสีและจำนวนของแต่ละสี'),
        ('03-symbols.png', 'symbols', 'bottom', 'มีสัญลักษณ์<br>ในทุกช่อง', 'เส้นแบ่งบอร์ดหนา แตะช่องเพื่อแก้ไข'),
        ('04-print.png', 'pdf', 'tilt', 'พิมพ์แล้ว<br>ลงมือทำเลย', 'แพตเทิร์นแยกตามบอร์ดและรายการสีใน PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'มีแพตเทิร์น<br>ครอสติชด้วย', 'เลขไหมและขนาดผลงานบนผ้าของคุณ'),
        ('06-home.png', 'home', 'accent', 'แพตเทิร์นทั้งหมด<br>อยู่ในที่เดียว', 'พวงกุญแจ กรอบรูป และของขวัญ'),
    ],
    "vi": [
        ('01-photo.png', 'maker', 'hero', 'Từ một tấm ảnh<br>thành mẫu hạt', 'Chọn kích thước và màu, xem ngay'),
        ('02-colors.png', 'detail', 'left', 'Màu bạn có thể<br>mua được', 'Mã màu và số lượng của từng màu'),
        ('03-symbols.png', 'symbols', 'bottom', 'Mỗi ô một ký hiệu<br>không sợ nhầm', 'Viền đế đậm, chạm vào ô để sửa'),
        ('04-print.png', 'pdf', 'tilt', 'In ra<br>là làm được', 'Mẫu theo từng đế và danh sách màu bằng PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Có cả mẫu<br>thêu chữ thập', 'Mã chỉ và kích thước trên vải của bạn'),
        ('06-home.png', 'home', 'accent', 'Mọi mẫu của bạn<br>ở cùng một nơi', 'Móc khóa, khung ảnh và quà tặng'),
    ],
    "cs": [
        ('01-photo.png', 'maker', 'hero', 'Z fotky vzor<br>z korálků', 'Vyber velikost a barvy a hned to uvidíš'),
        ('02-colors.png', 'detail', 'left', 'Barvy, které<br>si koupíš', 'Čísla barev a počty od každé'),
        ('03-symbols.png', 'symbols', 'bottom', 'Symbol v každém<br>políčku', 'Hranice podložek tučně, klepnutím opravíš'),
        ('04-print.png', 'pdf', 'tilt', 'Vytiskni<br>a tvoř', 'Vzory po podložkách a seznam barev v PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'I vzory pro<br>křížkový steh', 'Čísla nití a velikost na tvé látce'),
        ('06-home.png', 'home', 'accent', 'Všechny vzory<br>na jednom místě', 'Klíčenky, rámečky a dárky'),
    ],
    "da": [
        ('01-photo.png', 'maker', 'hero', 'Fra foto til<br>perlemønster', 'Vælg størrelse og farver, og se det med det samme'),
        ('02-colors.png', 'detail', 'left', 'Farver, du kan<br>købe', 'Farvenumre og antal for hver farve'),
        ('03-symbols.png', 'symbols', 'bottom', 'Et symbol i<br>hver rude', 'Tykke pladeskel, tryk for at rette'),
        ('04-print.png', 'pdf', 'tilt', 'Print og<br>kom i gang', 'Mønstre pr. plade og farveliste som PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Også mønstre til<br>korssting', 'Garnnumre og størrelse på dit stof'),
        ('06-home.png', 'home', 'accent', 'Alle dine mønstre<br>samlet ét sted', 'Nøgleringe, rammer og gaver'),
    ],
    "el": [
        ('01-photo.png', 'maker', 'hero', 'Από μια φωτογραφία<br>σχέδιο με χάντρες', 'Διάλεξε μέγεθος και χρώματα και δες το αμέσως'),
        ('02-colors.png', 'detail', 'left', 'Χρώματα που<br>μπορείς να αγοράσεις', 'Αριθμοί και ποσότητες για κάθε χρώμα'),
        ('03-symbols.png', 'symbols', 'bottom', 'Ένα σύμβολο σε<br>κάθε τετραγωνάκι', 'Έντονα όρια πλακετών, πάτα για διόρθωση'),
        ('04-print.png', 'pdf', 'tilt', 'Εκτύπωσε και<br>ξεκίνα', 'Σχέδια ανά πλακέτα και λίστα χρωμάτων σε PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Και σχέδια για<br>σταυροβελονιά', 'Αριθμοί κλωστών και μέγεθος στο ύφασμά σου'),
        ('06-home.png', 'home', 'accent', 'Όλα τα σχέδιά σου<br>σε ένα μέρος', 'Μπρελόκ, κορνίζες και δώρα'),
    ],
    "fi": [
        ('01-photo.png', 'maker', 'hero', 'Kuvasta helmikuvio', 'Valitse koko ja värit, näet tuloksen heti'),
        ('02-colors.png', 'detail', 'left', 'Värit, jotka<br>voi ostaa', 'Värinumerot ja määrät jokaiselle värille'),
        ('03-symbols.png', 'symbols', 'bottom', 'Symboli jokaiseen<br>ruutuun', 'Paksut alustojen rajat, korjaa napauttamalla'),
        ('04-print.png', 'pdf', 'tilt', 'Tulosta ja<br>aloita', 'Alustakohtaiset kuviot ja värilista PDF:nä'),
        ('05-stitch.png', 'stitch', 'hero', 'Myös ristipistotyön<br>kuviot', 'Lankojen numerot ja koko kankaallesi'),
        ('06-home.png', 'home', 'accent', 'Kaikki kuviosi<br>yhdessä paikassa', 'Avaimenperät, kehykset ja lahjat'),
    ],
    "id": [
        ('01-photo.png', 'maker', 'hero', 'Dari satu foto<br>jadi pola manik', 'Pilih ukuran dan warna, langsung lihat hasilnya'),
        ('02-colors.png', 'detail', 'left', 'Warna yang<br>bisa dibeli', 'Nomor warna dan jumlah tiap warna'),
        ('03-symbols.png', 'symbols', 'bottom', 'Satu simbol di<br>tiap kotak', 'Batas papan ditebalkan, ketuk kotak untuk memperbaiki'),
        ('04-print.png', 'pdf', 'tilt', 'Cetak lalu<br>langsung buat', 'Pola per papan dan daftar warna dalam PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Ada pola<br>kristik juga', 'Nomor benang dan ukuran di kainmu'),
        ('06-home.png', 'home', 'accent', 'Semua polamu<br>di satu tempat', 'Gantungan kunci, bingkai, dan hadiah'),
    ],
    "nb": [
        ('01-photo.png', 'maker', 'hero', 'Fra bilde til<br>perlemønster', 'Velg størrelse og farger, og se det med en gang'),
        ('02-colors.png', 'detail', 'left', 'Farger du kan<br>kjøpe', 'Fargenumre og antall for hver farge'),
        ('03-symbols.png', 'symbols', 'bottom', 'Ett symbol i<br>hver rute', 'Tykke brettskiller, trykk for å rette'),
        ('04-print.png', 'pdf', 'tilt', 'Skriv ut og<br>kom i gang', 'Mønstre per brett og fargeliste som PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Også mønstre til<br>korssting', 'Garnnumre og størrelse på stoffet ditt'),
        ('06-home.png', 'home', 'accent', 'Alle mønstrene dine<br>samlet på ett sted', 'Nøkkelringer, rammer og gaver'),
    ],
    "nl": [
        ('01-photo.png', 'maker', 'hero', 'Van één foto een<br>kralenpatroon', 'Kies grootte en kleuren en zie het meteen'),
        ('02-colors.png', 'detail', 'left', 'Kleuren die je<br>kunt kopen', 'Kleurnummers en aantallen per kleur'),
        ('03-symbols.png', 'symbols', 'bottom', 'Een symbool in<br>elk vakje', 'Dikke bordgrenzen, tik om aan te passen'),
        ('04-print.png', 'pdf', 'tilt', 'Printen en<br>aan de slag', 'Patronen per bord en kleurenlijst als pdf'),
        ('05-stitch.png', 'stitch', 'hero', 'Ook patronen voor<br>kruissteek', 'Garennummers en maat op jouw stof'),
        ('06-home.png', 'home', 'accent', 'Al je patronen<br>op één plek', 'Sleutelhangers, lijstjes en cadeaus'),
    ],
    "pl": [
        ('01-photo.png', 'maker', 'hero', 'Ze zdjęcia wzór<br>z koralików', 'Wybierz rozmiar i kolory i od razu zobacz efekt'),
        ('02-colors.png', 'detail', 'left', 'Kolory, które<br>kupisz', 'Numery i ilości dla każdego koloru'),
        ('03-symbols.png', 'symbols', 'bottom', 'Symbol w każdym<br>polu', 'Pogrubione granice podkładek, dotknij, by poprawić'),
        ('04-print.png', 'pdf', 'tilt', 'Wydrukuj<br>i do dzieła', 'Wzory podkładka po podkładce i lista kolorów w PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Także wzory<br>do haftu krzyżykowego', 'Numery nici i rozmiar na Twojej tkaninie'),
        ('06-home.png', 'home', 'accent', 'Wszystkie wzory<br>w jednym miejscu', 'Breloki, ramki i prezenty'),
    ],
    "sv": [
        ('01-photo.png', 'maker', 'hero', 'Från foto till<br>pärlmönster', 'Välj storlek och färger och se det direkt'),
        ('02-colors.png', 'detail', 'left', 'Färger du kan<br>köpa', 'Färgnummer och antal för varje färg'),
        ('03-symbols.png', 'symbols', 'bottom', 'En symbol i<br>varje ruta', 'Tjocka plattgränser, tryck för att justera'),
        ('04-print.png', 'pdf', 'tilt', 'Skriv ut och<br>sätt igång', 'Mönster per platta och färglista som PDF'),
        ('05-stitch.png', 'stitch', 'hero', 'Även mönster för<br>korsstygn', 'Garnnummer och storlek på ditt tyg'),
        ('06-home.png', 'home', 'accent', 'Alla dina mönster<br>på ett ställe', 'Nyckelringar, ramar och presenter'),
    ],
    "tr": [
        ('01-photo.png', 'maker', 'hero', 'Bir fotoğraftan<br>boncuk şeması', 'Boyutu ve renkleri seç, anında gör'),
        ('02-colors.png', 'detail', 'left', 'Satın alabileceğin<br>renkler', 'Her rengin numarası ve adedi'),
        ('03-symbols.png', 'symbols', 'bottom', 'Her karede<br>bir sembol', 'Kalın plaka sınırları, düzeltmek için dokun'),
        ('04-print.png', 'pdf', 'tilt', 'Yazdır ve<br>hemen başla', "Plaka plaka şemalar ve renk listesi PDF'de"),
        ('05-stitch.png', 'stitch', 'hero', 'Kanaviçe şemaları<br>da var', 'İplik numaraları ve kumaşına göre boyut'),
        ('06-home.png', 'home', 'accent', 'Tüm şemaların<br>tek yerde', 'Anahtarlıklar, çerçeveler ve hediyeler'),
    ],
}

BASE_CSS = f"""
* {{ margin:0; padding:0; box-sizing:border-box; }}
html,body {{ width:{W}px; height:{H}px; overflow:hidden; }}
body {{ background:#faf5ee; position:relative;
  font-family:-apple-system, "SF Pro Display", "Apple SD Gothic Neo", "Hiragino Sans", sans-serif;
  background-image:radial-gradient(circle, rgba(140,115,97,.16) 7px, transparent 8px);
  background-size:62px 62px; background-position:31px 31px; }}
:lang(ko) .headline, :lang(ko) .sub {{ word-break:keep-all; }}
:lang(ja) .headline, :lang(ja) .sub {{ word-break:keep-all; line-break:strict; }}
.headline {{ font-size:112px; font-weight:900; color:#2b211c; letter-spacing:-3px; line-height:1.14; }}
.sub {{ font-size:50px; font-weight:600; color:#7a6d64; letter-spacing:-1px; line-height:1.35; }}
.thread {{ display:inline-block; width:150px; height:10px; border-radius:5px; background:#d9453d; margin-bottom:46px; }}
.phone {{ position:absolute; background:#2b211c; border-radius:118px; padding:24px;
  box-shadow: 0 50px 120px rgba(80,50,30,.28); }}
.phone img {{ width:100%; display:block; border-radius:96px; }}
.text {{ position:absolute; left:100px; right:100px; }}
"""

LAYOUTS = {
    # 가운데 정렬 글 + 정면 폰, 아래로 넘친다
    "hero": (".text{top:230px;text-align:center}",
             "left:131px;top:900px;width:980px"),
    # 왼쪽 정렬 글 + 오른쪽으로 비켜선 폰
    "left": (".text{top:230px;text-align:left}",
             "left:250px;top:930px;width:960px;transform:rotate(4deg)"),
    # 폰 위, 글 아래
    "bottom": (".text{top:2080px;text-align:center}",
               "left:181px;top:-300px;width:880px"),
    # 글 위 + 기운 폰
    "tilt": (".text{top:230px;text-align:center}",
             "left:110px;top:930px;width:1000px;transform:rotate(-5deg)"),
    # 빨간 바탕 + 흰 글 (마지막 장 포인트)
    "accent": (""".text{top:230px;text-align:center}
body{background-color:#d9453d;background-image:radial-gradient(circle, rgba(255,255,255,.14) 7px, transparent 8px)}
.headline{color:#fff}.sub{color:rgba(255,255,255,.85)}.thread{background:#fff}
.phone{background:#fff;box-shadow:0 50px 120px rgba(60,10,10,.35)}""",
               "left:131px;top:900px;width:980px"),
}


def render(lang, fname, scene, layout, headline, sub):
    css, phone_style = LAYOUTS[layout]
    img = (RAW / lang / f"{scene}.png").as_uri()
    body = (f'<div class="phone" style="{phone_style}"><img src="{img}"></div>'
            f'<div class="text"><div class="thread"></div><div class="headline">{headline}</div>'
            f'<div class="sub" style="margin-top:40px">{sub}</div></div>')
    page = (f'<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><style>{BASE_CSS}{css}</style>'
            f'</head><body>{body}</body></html>')
    html_path = WORK / f"hantam-{lang}-{fname.replace('.png', '.html')}"
    html_path.write_text(page, encoding="utf-8")
    out_dir = OUTROOT / STORE[lang]
    out_dir.mkdir(parents=True, exist_ok=True)
    out_png = out_dir / fname
    # Chrome 은 가끔 아무것도 안 그리고 끝난다 — 세 번까지
    for _ in range(3):
        try:
            r = subprocess.run([CHROME, "--headless=new", f"--screenshot={out_png}",
                                f"--window-size={W},{H}", "--force-device-scale-factor=1",
                                "--hide-scrollbars", "--disable-gpu", "--virtual-time-budget=3000",
                                "--allow-file-access-from-files", html_path.as_uri()],
                               capture_output=True, timeout=120)
        except subprocess.TimeoutExpired:
            continue
        if r.returncode == 0:
            break
    else:
        raise SystemExit(f"Chrome 이 그리지 못했다: {out_png}")
    print(f"rendered {out_png}")
    time.sleep(2)  # 맥을 같이 쓰므로 Chrome 을 연달아 띄우지 않는다


if __name__ == "__main__":
    for lang in sys.argv[1:] or list(SHOTS_BY_LANG):
        for shot in SHOTS_BY_LANG[lang]:
            render(lang, *shot)
