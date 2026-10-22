#!/usr/bin/env python3
"""한땀 마케팅 스크린샷: HTML → 헤드리스 Chrome. 1242×2688 (이 계정의 iPhone 제출 규격).

원본: docs/screenshots/raw/<앱 언어>/<장면>.png — Scripts/capture_screens.sh 가 DEBUG 장면을 찍은 것.
결과: docs/screenshots/marketing/<스토어 로케일>/0N-….png (파일 이름 순서 = 스토어 순서)
사용법: python3 Scripts/make_marketing_screenshots.py [언어 ...]

바탕은 앱과 같은 면천색(#FAF5EE)에 페그보드 점, 글자는 먹색, 강조는 빨간 실(#D9453D).
가격 · 할인 · 다른 회사 상표는 헤드라인에 넣지 않는다.
"""
import subprocess, sys, pathlib, tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw"
OUTROOT = ROOT / "docs" / "screenshots" / "marketing"
WORK = pathlib.Path(tempfile.gettempdir())
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1242, 2688

STORE = {"ko": "ko", "en": "en-US", "ja": "ja", "zh-Hans": "zh-Hans", "zh-Hant": "zh-Hant", "ru": "ru", "es": "es-ES"}

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


if __name__ == "__main__":
    for lang in sys.argv[1:] or list(SHOTS_BY_LANG):
        for shot in SHOTS_BY_LANG[lang]:
            render(lang, *shot)
