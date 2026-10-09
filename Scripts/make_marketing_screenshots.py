#!/usr/bin/env python3
"""마케팅 스크린샷 목업 생성: HTML 생성 → 헤드리스 Chrome 렌더링.

슬라이드마다 layout 이 달라 배치가 다양함:
  hero-bleed  : 헤드라인 상단 중앙 + 정면 대형 폰, 하단 블리드
  left-text   : 좌측 정렬 텍스트 + 오른쪽으로 기운 폰
  text-bottom : 폰 상단 + 텍스트 하단
  flat-rotate : 평면 회전(-5°) 폰, 하단 블리드
  dark        : 다크 배경 반전 + 정면 폰
"""
import subprocess, sys, pathlib

# 픽셀미미 — 원본: docs/screenshots/raw/<앱 언어>/ (iPhone 18 Pro Max 시뮬레이터 1320x2868, 그 언어로 띄워 찍음)
# 사용법: python3 Scripts/make_marketing_screenshots.py [언어 ...]
import tempfile
ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw"
OUTROOT = ROOT / "docs" / "screenshots" / "marketing"
WORK = pathlib.Path(tempfile.gettempdir())
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1242, 2688   # 이 계정의 iPhone 제출 규격

STORE = {"ko": "ko", "en": "en-US"}
SHOTS_BY_LANG = {
    "ko": [
        ("01-home.png",     "hero-bleed",  "사진도 그림도<br>픽셀 아트로", "사진 변환, 따라 그리기, 애니메이션까지"),
        ("02-gallery.png",  "left-text",   "110가지 예시를<br>골라 따라 그려요", "꽃, 동물, 음식, 게임 캐릭터까지"),
        ("03-trace.png",    "text-bottom", "연한 칸을 하나씩<br>채우면 완성", "연필, 채우기, 스포이드로 쉽게"),
        ("04-pixelate.png", "flat-rotate", "사진 한 장이<br>픽셀 아트로", "크기와 팔레트를 골라 바로 바꿔요"),
    ],
    "en": [
        ("01-home.png",     "hero-bleed",  "Photos and doodles,<br>all in pixels", "Pixelate, draw along and animate"),
        ("02-gallery.png",  "left-text",   "Pick from<br>110 samples", "Flowers, pets, snacks and game heroes"),
        ("03-trace.png",    "text-bottom", "Fill the faded squares,<br>dot by dot", "Pencil, fill and eyedropper made easy"),
        ("04-pixelate.png", "flat-rotate", "Turn any photo<br>into pixel art", "Pick a size and palette in a tap"),
    ],
}

BASE_CSS = f"""
* {{ margin:0; padding:0; box-sizing:border-box; }}
html,body {{ width:{W}px; height:{H}px; overflow:hidden; }}
body {{ background:#0b0b0c; font-family:-apple-system, "SF Pro Display", "Apple SD Gothic Neo", sans-serif; position:relative;
  background-image:linear-gradient(rgba(255,255,255,.035) 2px, transparent 2px), linear-gradient(90deg, rgba(255,255,255,.035) 2px, transparent 2px);
  background-size:48px 48px; }}
.headline {{ font-size:100px; font-weight:800; color:#f2f2f4; letter-spacing:-2px; line-height:1.2; word-break:keep-all; }}
.sub {{ font-size:52px; font-weight:500; color:#8e8e95; letter-spacing:-1px; word-break:keep-all; }}
.phone {{ background:#17171a; border-radius:116px; border:3px solid #55555c; padding:25px;
  box-shadow: 0 0 140px rgba(80,140,255,.18), 40px 70px 110px rgba(0,0,0,.55); }}
.phone img {{ width:100%; display:block; border-radius:92px; }}
"""

LAYOUTS = {
    # 1) 정면 대형, 하단 블리드
    "hero-bleed": """
.headline { text-align:center; margin-top:290px; padding:0 70px; }
.sub { text-align:center; margin-top:52px; }
.wrap { display:flex; justify-content:center; margin-top:150px; }
.phone { width:1000px; }
""",
    # 2) 좌측 정렬 텍스트 + 오른쪽 기울기, 오른쪽 블리드
    "left-text": """
.headline { text-align:left; margin:300px 0 0 110px; }
.sub { text-align:left; margin:48px 0 0 114px; }
.wrap { perspective:2600px; perspective-origin:30% 30%; position:absolute; left:300px; top:990px; }
.phone { width:840px; transform:rotateY(16deg) rotateX(2deg); }
""",
    # 3) 폰 상단, 텍스트 하단
    "text-bottom": """
.wrap { perspective:2800px; perspective-origin:50% 40%; display:flex; justify-content:center; margin-top:170px; }
.phone { width:880px; transform:rotateY(-10deg) rotateX(2deg); }
.headline { text-align:center; margin-top:120px; padding:0 70px; }
.sub { text-align:center; margin-top:48px; }
""",
    # 4) 평면 회전, 좌측 치우침 + 하단 블리드
    "flat-rotate": """
.headline { text-align:center; margin-top:270px; padding:0 70px; }
.sub { text-align:center; margin-top:52px; }
.wrap { position:absolute; left:120px; top:1010px; }
.phone { width:1010px; transform:rotate(-6deg); }
""",
    # 5) 다크 배경 반전 + 정면
    "dark": """
body { background:#131316; }
.headline { color:#f5f5f7; text-align:center; margin-top:290px; padding:0 70px; }
.sub { color:#77777d; text-align:center; margin-top:52px; }
.wrap { display:flex; justify-content:center; margin-top:150px; }
.phone { width:930px; border-color:#48484e;
  box-shadow: 0 0 160px rgba(80,140,255,.22), 40px 70px 110px rgba(0,0,0,.55); }
""",
}

# text-bottom 은 폰이 먼저 오는 DOM 순서
BODY_TEXT_FIRST = '<div class="headline">{headline}</div><div class="sub">{sub}</div><div class="wrap"><div class="phone"><img src="{img}"></div></div>'
BODY_PHONE_FIRST = '<div class="wrap"><div class="phone"><img src="{img}"></div></div><div class="headline">{headline}</div><div class="sub">{sub}</div>'

HTML = """<!doctype html><html><head><meta charset="utf-8"><style>
{base}{layout}
</style></head><body>{body}</body></html>"""

def main(langs):
    for lang in langs:
        SRC = RAW / lang
        OUT = OUTROOT / STORE[lang]
        OUT.mkdir(parents=True, exist_ok=True)
        for fname, layout, headline, sub in SHOTS_BY_LANG[lang]:
            render(lang, SRC, OUT, fname, layout, headline, sub)


def render(lang, SRC, OUT, fname, layout, headline, sub):
    if True:
        body_tpl = BODY_PHONE_FIRST if layout == "text-bottom" else BODY_TEXT_FIRST
        body = body_tpl.format(headline=headline, sub=sub, img=(SRC / fname).as_uri())
        html_path = WORK / f"pixelme-{lang}-{fname.replace('.png', '.html')}"
        html_path.write_text(HTML.replace("<html>", f'<html lang="{lang}">').format(base=BASE_CSS, layout=LAYOUTS[layout], body=body), encoding="utf-8")
        out_png = OUT / fname
        # Chrome 은 다른 창과 겹치면 가끔 실패한다 — 따로 쓰는 프로필로 세 번까지
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
    main(sys.argv[1:] or list(SHOTS_BY_LANG))
