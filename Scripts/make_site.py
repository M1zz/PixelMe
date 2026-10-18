#!/usr/bin/env python3
"""한땀(Hantam) 소개 · 지원 · 개인정보처리방침 · 이용약관 페이지 — GitHub Pages(docs/).

사용법: python3 Scripts/make_site.py
  docs/index.html · support.html · privacy.html · terms.html   영어 (기본 언어)
  docs/ko/…   한국어
  docs/ja/…   일본어
페이지끼리 언어 전환 링크와 hreflang 을 단다. 앱 안의 약관 · 개인정보 링크는 루트(영어) 주소를 쓴다.
문구는 언어마다 따로 썼다 — 직역하지 않는다.
"""
import pathlib, html

ROOT = pathlib.Path(__file__).resolve().parent.parent / "docs"
BASE = "https://m1zz.github.io/PixelMe/"
APP_URL = "https://apps.apple.com/app/id6449769987"
EMAIL = "leeo@kakao.com"
UPDATED = {"en": "October 18, 2026", "ko": "2026년 10월 18일", "ja": "2026年10月18日"}
LANGS = {"en": "", "ko": "ko/", "ja": "ja/"}
LANG_NAME = {"en": "English", "ko": "한국어", "ja": "日本語"}

T = {
    "en": {
        "brand": "Hantam",
        "title": "Hantam — Bead & Cross-Stitch Pattern Maker",
        "desc": "Turn any photo into a fuse bead or cross-stitch pattern matched to real Perler, Hama, Artkal and DMC colors.",
        "nav": ("Home", "Support", "Privacy", "Terms"),
        "hero_h": "Turn a photo into a pattern",
        "hero_p": "Pick a photo of your pet, your face or a favorite character. Hantam turns it into a fuse bead or cross-stitch pattern, matched to colors you can actually buy.",
        "cta": "Download on the App Store",
        "features": [
            ("Real colors", "Perler, Hama and Artkal beads and DMC thread. Every square shows a real color number."),
            ("Know what to buy", "See how many beads or stitches each color needs, and copy a shopping list."),
            ("Board by board", "Big patterns split into 29 × 29 pegboards, with bold board lines."),
            ("Fix any square", "Tap a square to change it, or swap one color for another everywhere."),
            ("Print and make", "With Pro, export a printable PDF: a color list plus symbol charts, page by page."),
            ("Pixel art too", "Pixelate photos, draw along with 110 samples, and animate frame by frame."),
        ],
        "pro_h": "Hantam Pro",
        "pro_p": "Free lets you make patterns up to one pegboard (or 40 stitches), keep 3 patterns and share images with a small mark. Pro adds printable PDFs, patterns up to 4 × 4 boards or 200 stitches, unlimited saved patterns, images without the mark and every pixel art tool. Choose a monthly or yearly subscription, or pay once for lifetime access.",
        "tm": "Perler, Hama, Artkal and DMC are trademarks of their respective owners. Hantam is not affiliated with them.",
        "support_h": "Support",
        "support_p": "Questions, bug reports and ideas are all welcome. The fastest way is Settings › Send Feedback inside the app, or email us.",
        "faq": [
            ("How do I restore my purchase?", "Open Settings in the app and tap Restore Purchases. Use the same Apple Account you bought Pro with."),
            ("How do I cancel a subscription?", "Go to iPhone Settings › your name › Subscriptions and choose Hantam. Lifetime access is a one-time purchase and never renews."),
            ("The colors look a little different from my beads.", "Screens show colors differently from real plastic and thread. Tap a color in the list to swap it for a closer one from the same brand."),
            ("How big can a pattern be?", "Free patterns fit one 29 × 29 pegboard, or 40 stitches on the longest side. Pro goes up to 4 × 4 pegboards (116 beads) or 200 stitches."),
            ("Do you upload my photos?", "No. Photos and patterns are processed and saved on your iPhone only."),
        ],
        "contact": "Contact",
        "privacy_h": "Privacy Policy",
        "terms_h": "Terms of Use",
        "updated": "Last updated",
        "privacy": [
            ("Summary", ["Your photos and patterns never leave your iPhone. We collect only anonymous statistics that cannot identify you."]),
            ("Photos", ["Hantam reads a photo only when you pick it. Turning it into a pattern happens on your device.", "Photos are never uploaded, stored on a server or shared."]),
            ("Patterns you make", ["Patterns are saved in the app's storage on your iPhone. Deleting the app deletes them."]),
            ("Purchases", ["Apple handles all payments. We only learn whether Pro is active, never your payment details."]),
            ("Anonymous statistics and crash reports", ["To count users, see which features are used and fix crashes, the app sends anonymous data to Apple iCloud (CloudKit), readable only by the developer:", "a random ID created at install (not linked to you, your Apple Account or other apps; it changes if you reinstall), app and iOS version, region and language, the days the app was opened, which features were used (for example, a pattern was made or a PDF was exported, or the purchase screen was shown), and crash details.", "No name, contact details, location, photos or patterns are included. Nothing is sent if you are not signed in to iCloud."]),
            ("Feedback", ["If you send feedback from the app, we receive what you write and, only if you add it, your email address, so we can reply."]),
            ("No tracking", ["No advertising, no third-party analytics and no tracking across other apps or websites."]),
            ("Children", ["Hantam is suitable for all ages. We do not knowingly collect personal information from children."]),
            ("Changes", ["If this policy changes, we will post the new version here with a new date."]),
        ],
        "terms": [
            ("Using the app", ["By using Hantam you agree to these terms. If you do not agree, please do not use the app."]),
            ("What Hantam does", ["Hantam turns photos into fuse bead and cross-stitch patterns and includes pixel art tools. Colors on screen are close matches and may differ from the real products."]),
            ("Your content", ["You own the photos you pick and the patterns you make. Make sure you have the right to use the photos you turn into patterns, especially if you sell what you make."]),
            ("Hantam Pro", ["Pro is sold as a monthly or yearly auto-renewing subscription or as one-time lifetime access, through Apple's App Store.", "Subscriptions renew automatically unless canceled at least 24 hours before the end of the current period. Your Apple Account is charged within 24 hours before renewal. Manage or cancel in your Apple Account settings.", "If a free trial is offered, any unused part ends when you buy a subscription. Refunds follow Apple's policy."]),
            ("Rules", ["Do not reverse engineer the app or use it for anything illegal."]),
            ("No warranty", ["The app is provided as is, without warranties of any kind. To the extent the law allows, our liability is limited to what you paid for the app."]),
            ("Trademarks", ["Perler, Hama, Artkal and DMC are trademarks of their respective owners. Hantam is not affiliated with or endorsed by them."]),
            ("Law", ["These terms are governed by the laws of the Republic of Korea."]),
        ],
        "dev": "Developer: Hyunho Lee",
    },
    "ko": {
        "brand": "한땀",
        "title": "한땀 — 비즈·십자수 도안 메이커",
        "desc": "사진 한 장을 Perler, Hama, Artkal 비즈와 DMC 실 색에 맞춘 아이롱 비즈·십자수 도안으로 바꿔 드려요.",
        "nav": ("홈", "지원", "개인정보", "이용약관"),
        "hero_h": "사진 한 장이 도안이 돼요",
        "hero_p": "반려동물, 내 얼굴, 좋아하는 캐릭터 사진을 고르세요. 한땀이 실제로 살 수 있는 색으로 맞춘 아이롱 비즈·십자수 도안을 만들어 드려요.",
        "cta": "App Store에서 받기",
        "features": [
            ("실제로 파는 색", "Perler, Hama, Artkal 비즈와 DMC 실. 칸마다 실제 색 번호가 붙어요."),
            ("살 것이 한눈에", "색마다 비즈나 땀이 몇 개 필요한지 보여 주고, 구매 목록을 복사할 수 있어요."),
            ("보드 한 장씩", "큰 도안은 29 × 29 페그보드 단위로 나누고 경계선을 굵게 그려요."),
            ("칸 하나도 고치기", "칸을 눌러 바꾸거나, 한 색을 다른 색으로 한꺼번에 바꿔요."),
            ("인쇄해서 바로", "Pro에서는 색 목록과 쪽마다 나눈 기호 도안을 인쇄용 PDF로 내보내요."),
            ("픽셀 아트도", "사진 픽셀화, 110가지 예시 따라 그리기, 프레임 애니메이션까지 그대로 있어요."),
        ],
        "pro_h": "한땀 Pro",
        "pro_p": "무료로는 보드 1장(십자수 40칸)까지의 도안을 만들고, 3개까지 보관하고, 작은 표시가 든 이미지를 공유할 수 있어요. Pro는 인쇄용 PDF, 보드 4 × 4장(십자수 200칸)까지의 도안, 무제한 보관, 표시 없는 이미지, 모든 픽셀 아트 도구를 열어 줘요. 월간·연간 구독과 한 번 결제하는 평생 이용권 중에서 골라요.",
        "tm": "Perler, Hama, Artkal, DMC는 각 회사의 상표이며, 한땀은 이 회사들과 관계가 없어요.",
        "support_h": "지원",
        "support_p": "궁금한 점, 버그 제보, 기능 제안 모두 환영해요. 앱 안의 설정 › 의견 보내기가 가장 빠르고, 이메일도 괜찮아요.",
        "faq": [
            ("구입 내역은 어떻게 복원하나요?", "앱의 설정에서 '구입 복원'을 누르세요. Pro를 산 Apple 계정과 같은 계정이어야 해요."),
            ("구독은 어떻게 해지하나요?", "iPhone 설정 › 내 이름 › 구독에서 한땀을 골라 해지하세요. 평생 이용권은 한 번만 결제하며 갱신되지 않아요."),
            ("화면 색이 실제 비즈와 조금 달라요.", "화면은 플라스틱이나 실과 색이 다르게 보여요. 색 목록에서 색을 누르면 같은 브랜드의 더 가까운 색으로 바꿀 수 있어요."),
            ("도안은 얼마나 크게 만들 수 있나요?", "무료는 29 × 29 보드 1장, 십자수는 긴 변 40칸까지예요. Pro는 보드 4 × 4장(116칸), 십자수 200칸까지 만들 수 있어요."),
            ("사진이 어디로 올라가나요?", "아니요. 사진과 도안은 내 iPhone 안에서만 처리하고 저장해요."),
        ],
        "contact": "문의",
        "privacy_h": "개인정보처리방침",
        "terms_h": "이용약관",
        "updated": "최종 수정일",
        "privacy": [
            ("요약", ["사진과 도안은 iPhone 밖으로 나가지 않아요. 누구인지 알 수 없는 익명 통계만 모아요."]),
            ("사진", ["사진은 직접 고를 때만 읽어요. 도안으로 바꾸는 일은 기기 안에서 해요.", "사진을 서버에 올리거나 저장하거나 다른 곳과 나누지 않아요."]),
            ("만든 도안", ["도안은 iPhone의 앱 저장 공간에 저장돼요. 앱을 지우면 함께 지워져요."]),
            ("결제", ["결제는 모두 Apple이 처리해요. 우리는 Pro가 켜져 있는지만 알고, 결제 정보는 받지 않아요."]),
            ("익명 사용 통계와 오류 보고", ["사용자 수를 세고, 어떤 기능을 쓰는지 보고, 오류를 고치기 위해 개발자만 볼 수 있는 Apple iCloud(CloudKit)로 익명 정보를 보내요.", "설치할 때 만든 무작위 ID(나, Apple 계정, 다른 앱과 연결되지 않으며 다시 설치하면 바뀌어요), 앱과 iOS 버전, 지역과 언어, 앱을 연 날, 쓴 기능(예: 도안을 만들었는지, PDF를 내보냈는지, 결제 화면이 떴는지), 오류 정보예요.", "이름, 연락처, 위치, 사진, 도안은 들어가지 않아요. iCloud에 로그인하지 않았으면 아무것도 보내지 않아요."]),
            ("의견 보내기", ["앱에서 의견을 보내면 쓴 내용과, 직접 적은 경우에만 답장을 위한 이메일 주소를 받아요."]),
            ("추적 없음", ["광고, 다른 회사의 분석 도구, 다른 앱·웹사이트를 넘나드는 추적을 쓰지 않아요."]),
            ("어린이", ["한땀은 모든 연령이 쓸 수 있어요. 어린이의 개인정보를 알면서 모으지 않아요."]),
            ("바뀔 때", ["방침이 바뀌면 새 날짜와 함께 이 페이지에 올려요."]),
        ],
        "terms": [
            ("앱 이용", ["한땀을 쓰면 이 약관에 동의하는 것으로 봐요. 동의하지 않으면 앱을 쓰지 말아 주세요."]),
            ("한땀이 하는 일", ["한땀은 사진을 아이롱 비즈·십자수 도안으로 바꾸고, 픽셀 아트 도구도 함께 제공해요. 화면의 색은 가장 가까운 색이며 실제 제품과 다를 수 있어요."]),
            ("내 콘텐츠", ["고른 사진과 만든 도안은 내 것이에요. 도안으로 바꾸는 사진을 쓸 권리가 있는지 확인해 주세요. 만든 작품을 판매한다면 특히 그래요."]),
            ("한땀 Pro", ["Pro는 App Store에서 자동 갱신되는 월간·연간 구독 또는 한 번 결제하는 평생 이용권으로 팔아요.", "구독은 현재 기간이 끝나기 최소 24시간 전에 해지하지 않으면 자동으로 갱신되고, 갱신 전 24시간 안에 Apple 계정으로 결제돼요. Apple 계정 설정에서 관리하거나 해지할 수 있어요.", "무료 체험이 있을 때 구독을 사면 남은 체험 기간은 끝나요. 환불은 Apple 정책을 따라요."]),
            ("지켜 주세요", ["앱을 역설계하거나 불법적인 일에 쓰지 말아 주세요."]),
            ("보증의 한계", ["앱은 있는 그대로 제공돼요. 법이 허용하는 한도에서 우리의 책임은 앱에 낸 금액까지예요."]),
            ("상표", ["Perler, Hama, Artkal, DMC는 각 회사의 상표이며, 한땀은 이 회사들과 관계가 없고 보증받지 않았어요."]),
            ("준거법", ["이 약관은 대한민국 법을 따라요."]),
        ],
        "dev": "개발자: 이현호",
    },
    "ja": {
        "brand": "Hantam",
        "title": "Hantam — アイロンビーズ・クロスステッチ図案メーカー",
        "desc": "写真1枚を、パーラー・ハマ・アートカルのビーズやDMCの刺しゅう糸の色に合わせた図案にします。",
        "nav": ("ホーム", "サポート", "プライバシー", "利用規約"),
        "hero_h": "写真1枚が図案になる",
        "hero_p": "ペットや自分の顔、好きなキャラクターの写真を選ぶだけ。実際に買える色に合わせて、アイロンビーズやクロスステッチの図案を作ります。",
        "cta": "App Storeでダウンロード",
        "features": [
            ("実際に買える色", "Perler、Hama、Artkalのビーズと、DMCの刺しゅう糸。マスごとに色番号がわかります。"),
            ("そろえる数がすぐわかる", "色ごとに必要なビーズや目の数を表示。買い物リストもコピーできます。"),
            ("プレートごとに", "大きな図案は29 × 29のプレートごとに分けて、境目を太線で示します。"),
            ("1マスから直せる", "マスをタップして変えたり、ある色をまとめて別の色に置き換えたりできます。"),
            ("印刷してすぐ", "Proなら色リストとページごとの記号図案を、印刷用PDFで書き出せます。"),
            ("ドット絵も", "写真のドット絵化、110種類のお手本でなぞり描き、コマ送りアニメもそのまま使えます。"),
        ],
        "pro_h": "Hantam Pro",
        "pro_p": "無料版では、プレート1枚分（クロスステッチは40目）までの図案づくり、3個までの保存、小さなマーク入りの画像の共有ができます。Proでは印刷用PDF、プレート4 × 4枚分（200目）までの図案、無制限の保存、マークなしの画像、すべてのドット絵ツールが使えます。月額・年額のサブスクリプションか、1回払いの買い切りから選べます。",
        "tm": "Perler、Hama、Artkal、DMCは各社の商標です。Hantamはこれらの会社とは関係ありません。",
        "support_h": "サポート",
        "support_p": "ご質問、不具合のご報告、機能のご提案をお待ちしています。アプリ内の設定 › フィードバックを送るがいちばん早く、メールでも受け付けています。",
        "faq": [
            ("購入を復元するには？", "アプリの設定で「購入を復元」をタップしてください。Proを購入したときと同じApple Accountでお使いください。"),
            ("サブスクリプションを解約するには？", "iPhoneの設定 › ユーザ名 › サブスクリプションからHantamを選んで解約できます。買い切りは1回払いで、更新されません。"),
            ("画面の色が手元のビーズと少し違います。", "画面とプラスチックや糸では色の見え方が異なります。色リストで色をタップすると、同じブランドのより近い色に置き換えられます。"),
            ("どのくらい大きな図案が作れますか？", "無料版は29 × 29のプレート1枚分、クロスステッチは長い辺40目までです。Proならプレート4 × 4枚分（116粒）、クロスステッチは200目まで作れます。"),
            ("写真はアップロードされますか？", "いいえ。写真も図案も、お使いのiPhoneの中だけで処理・保存します。"),
        ],
        "contact": "お問い合わせ",
        "privacy_h": "プライバシーポリシー",
        "terms_h": "利用規約",
        "updated": "最終更新日",
        "privacy": [
            ("概要", ["写真や図案がiPhoneの外に出ることはありません。集めるのは、個人を特定できない匿名の統計だけです。"]),
            ("写真", ["写真は、選んだときにだけ読み込みます。図案への変換は端末の中で行います。", "写真をサーバにアップロード・保存したり、第三者と共有したりすることはありません。"]),
            ("作った図案", ["図案はiPhone内のアプリの保存領域に保存されます。アプリを削除すると一緒に削除されます。"]),
            ("購入", ["支払いはすべてAppleが処理します。私たちが知るのはProが有効かどうかだけで、支払い情報は受け取りません。"]),
            ("匿名の利用統計とクラッシュレポート", ["利用者数の把握、よく使われる機能の確認、不具合の修正のため、開発者だけが閲覧できるApple iCloud（CloudKit）に匿名のデータを送ります。", "インストール時に作られるランダムなID（あなた自身やApple Account、ほかのアプリとは結びつかず、再インストールで変わります）、アプリとiOSのバージョン、地域と言語、アプリを開いた日、使った機能（例：図案を作った、PDFを書き出した、購入画面が表示された）、クラッシュの情報です。", "名前、連絡先、位置情報、写真、図案は含まれません。iCloudにサインインしていない場合は何も送信しません。"]),
            ("フィードバック", ["アプリからフィードバックを送ると、書いた内容と、入力した場合に限り返信用のメールアドレスを受け取ります。"]),
            ("トラッキングなし", ["広告、第三者の解析ツール、ほかのアプリやWebサイトをまたぐトラッキングは使いません。"]),
            ("お子さま", ["Hantamはすべての年齢の方にお使いいただけます。お子さまの個人情報を意図的に集めることはありません。"]),
            ("改定", ["このポリシーを改定した場合は、新しい日付とともにこのページに掲載します。"]),
        ],
        "terms": [
            ("ご利用にあたって", ["Hantamを使うことで、この規約に同意したものとみなします。同意いただけない場合はご利用をお控えください。"]),
            ("Hantamについて", ["Hantamは写真をアイロンビーズやクロスステッチの図案にするアプリで、ドット絵ツールも備えています。画面の色は近い色で、実際の製品とは異なる場合があります。"]),
            ("あなたのコンテンツ", ["選んだ写真と作った図案はあなたのものです。図案にする写真を使う権利があるかをご確認ください。作品を販売する場合は特にご注意ください。"]),
            ("Hantam Pro", ["ProはApp Storeで、自動更新の月額・年額サブスクリプション、または1回払いの買い切りとして販売しています。", "サブスクリプションは、現在の期間が終わる24時間前までに解約しない限り自動で更新され、更新前の24時間以内にApple Accountに請求されます。Apple Accountの設定から管理・解約できます。", "無料体験がある場合、サブスクリプションを購入すると残りの体験期間は終了します。返金はAppleのポリシーに従います。"]),
            ("禁止事項", ["アプリのリバースエンジニアリングや、違法な目的での利用はご遠慮ください。"]),
            ("保証の否認", ["アプリは現状のまま提供されます。法律で認められる範囲で、当方の責任はアプリにお支払いいただいた金額を上限とします。"]),
            ("商標", ["Perler、Hama、Artkal、DMCは各社の商標です。Hantamはこれらの会社と提携しておらず、承認も受けていません。"]),
            ("準拠法", ["この規約は大韓民国の法律に準拠します。"]),
        ],
        "dev": "開発者：Hyunho Lee",
    },
}

CSS = """
:root{--bg:#faf5ee;--card:#fff;--ink:#2b211c;--muted:#7a6d64;--accent:#d9453d;--mustard:#dc9e21;--line:rgba(43,33,28,.1)}
@media (prefers-color-scheme:dark){:root{--bg:#1a1714;--card:#2b2623;--ink:#f2efec;--muted:#b3a89f;--accent:#ff7366;--line:rgba(255,255,255,.12)}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:-apple-system,BlinkMacSystemFont,"SF Pro Text","Hiragino Sans","Apple SD Gothic Neo",system-ui,sans-serif;background:var(--bg);color:var(--ink);line-height:1.7}
:lang(ko) body{word-break:keep-all}
a{color:var(--accent)}
header{display:flex;align-items:center;gap:12px;flex-wrap:wrap;max-width:960px;margin:0 auto;padding:20px 16px}
header .logo{display:flex;align-items:center;gap:10px;font-weight:800;font-size:22px;color:var(--ink);text-decoration:none}
header .logo img{width:40px;height:40px;border-radius:10px}
header nav{display:flex;gap:16px;margin-left:auto;flex-wrap:wrap;font-size:15px}
header nav a{color:var(--muted);text-decoration:none}
header nav a:hover{color:var(--accent)}
.langs{font-size:14px;color:var(--muted)}
.langs a{color:var(--muted);text-decoration:none;margin-left:8px}
.langs a[aria-current]{color:var(--ink);font-weight:700}
main{max-width:960px;margin:0 auto;padding:16px 16px 60px}
.hero{display:grid;grid-template-columns:1.1fr .9fr;gap:32px;align-items:center;padding:32px 0}
.hero h1{font-size:clamp(34px,6vw,56px);line-height:1.15;font-weight:900;letter-spacing:-.02em}
.hero p{font-size:18px;color:var(--muted);margin:18px 0 26px}
.hero img.shot{width:100%;max-width:340px;justify-self:center;border-radius:36px;box-shadow:0 30px 60px rgba(0,0,0,.18)}
.btn{display:inline-block;background:var(--accent);color:#fff;font-weight:700;padding:14px 22px;border-radius:14px;text-decoration:none}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:14px;margin:30px 0}
.card{background:var(--card);border-radius:18px;padding:20px;border:1px solid var(--line)}
.card h3{font-size:17px;margin-bottom:6px}
.card p{color:var(--muted);font-size:15px}
section.pro{background:var(--card);border:2px dashed var(--accent);border-radius:22px;padding:24px;margin:30px 0}
section.pro h2{color:var(--accent);margin-bottom:8px}
.doc h1{font-size:34px;margin:10px 0 4px}
.doc .updated{color:var(--muted);font-size:14px;margin-bottom:24px}
.doc h2{font-size:20px;margin:28px 0 8px;color:var(--accent)}
.doc p{margin-bottom:10px}
details{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:14px 16px;margin:10px 0}
summary{font-weight:700;cursor:pointer}
details p{margin-top:8px;color:var(--muted)}
footer{max-width:960px;margin:0 auto;padding:24px 16px 40px;color:var(--muted);font-size:13px;border-top:1px solid var(--line)}
@media (max-width:720px){.hero{grid-template-columns:1fr}.hero img.shot{max-width:260px}}
"""


def page(lang, name, title, body):
    t = T[lang]
    prefix = "../" if LANGS[lang] else ""
    alt = "\n".join(f'<link rel="alternate" hreflang="{l}" href="{BASE}{p}{name}">' for l, p in LANGS.items())
    alt += f'\n<link rel="alternate" hreflang="x-default" href="{BASE}{name}">'
    navfiles = ["index.html", "support.html", "privacy.html", "terms.html"]
    nav = "".join(f'<a href="{f}">{html.escape(n)}</a>' for f, n in zip(navfiles, t["nav"]))
    current = ' aria-current="page"'
    langs = "".join(
        f'<a href="{prefix}{p}{name}" lang="{l}"{current if l == lang else ""}>{LANG_NAME[l]}</a>'
        for l, p in LANGS.items())
    return f"""<!doctype html>
<html lang="{lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<meta name="description" content="{html.escape(t['desc'])}">
<meta property="og:title" content="{html.escape(t['title'])}">
<meta property="og:description" content="{html.escape(t['desc'])}">
<meta property="og:image" content="{BASE}assets/app-icon.png">
<link rel="icon" type="image/png" href="{prefix}assets/app-icon.png">
<link rel="canonical" href="{BASE}{LANGS[lang]}{name}">
{alt}
<style>{CSS}</style>
</head>
<body>
<header>
  <a class="logo" href="index.html"><img src="{prefix}assets/app-icon.png" alt="">{html.escape(t['brand'])}</a>
  <nav>{nav}</nav>
  <div class="langs">{langs}</div>
</header>
<main>
{body}
</main>
<footer>{html.escape(t['tm'])}<br>{html.escape(t['dev'])} · <a href="mailto:{EMAIL}">{EMAIL}</a></footer>
</body>
</html>
"""


def index(lang):
    t = T[lang]
    prefix = "../" if LANGS[lang] else ""
    store_lang = {"en": "en-US", "ko": "ko", "ja": "ja"}[lang]
    feats = "".join(f'<div class="card"><h3>{html.escape(h)}</h3><p>{html.escape(p)}</p></div>' for h, p in t["features"])
    body = f"""
<section class="hero">
  <div>
    <h1>{html.escape(t['hero_h'])}</h1>
    <p>{html.escape(t['hero_p'])}</p>
    <a class="btn" href="{APP_URL}">{html.escape(t['cta'])}</a>
  </div>
  <img class="shot" src="{prefix}screenshots/marketing/{store_lang}/01-photo.png" alt="">
</section>
<div class="grid">{feats}</div>
<section class="pro"><h2>{html.escape(t['pro_h'])}</h2><p>{html.escape(t['pro_p'])}</p></section>
"""
    return page(lang, "index.html", t["title"], body)


def support(lang):
    t = T[lang]
    faq = "".join(f"<details><summary>{html.escape(q)}</summary><p>{html.escape(a)}</p></details>" for q, a in t["faq"])
    body = f"""<div class="doc"><h1>{html.escape(t['support_h'])}</h1>
<p>{html.escape(t['support_p'])}</p>
<h2>{html.escape(t['contact'])}</h2><p><a href="mailto:{EMAIL}">{EMAIL}</a></p>
<h2>FAQ</h2>{faq}</div>"""
    return page(lang, "support.html", f"{t['support_h']} — {t['brand']}", body)


def doc(lang, key, head, name):
    t = T[lang]
    sections = "".join(
        f"<h2>{html.escape(h)}</h2>" + "".join(f"<p>{html.escape(p)}</p>" for p in ps) for h, ps in t[key])
    body = f"""<div class="doc"><h1>{html.escape(t[head])}</h1>
<p class="updated">{html.escape(t['updated'])}: {UPDATED[lang]}</p>{sections}
<h2>{html.escape(t['contact'])}</h2><p><a href="mailto:{EMAIL}">{EMAIL}</a></p></div>"""
    return page(lang, name, f"{t[head]} — {t['brand']}", body)


if __name__ == "__main__":
    for lang, p in LANGS.items():
        d = ROOT / p
        d.mkdir(parents=True, exist_ok=True)
        (d / "index.html").write_text(index(lang), encoding="utf-8")
        (d / "support.html").write_text(support(lang), encoding="utf-8")
        (d / "privacy.html").write_text(doc(lang, "privacy", "privacy_h", "privacy.html"), encoding="utf-8")
        (d / "terms.html").write_text(doc(lang, "terms", "terms_h", "terms.html"), encoding="utf-8")
        print("wrote", d)
