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
STORE_LANG = {"en": "en-US", "ko": "ko", "ja": "ja"}  # 앱 언어 코드 → App Store Connect 로케일
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

LANGS["zh-Hans"] = "zh-Hans/"
LANG_NAME["zh-Hans"] = '简体中文'
UPDATED["zh-Hans"] = '2026年10月18日'
STORE_LANG["zh-Hans"] = "zh-Hans"
T["zh-Hans"] = {'brand': 'Hantam',
 'title': 'Hantam — 拼豆与十字绣图纸制作',
 'desc': '把任意照片变成与 Perler、Hama、Artkal 拼豆及 DMC 绣线真实颜色对应的拼豆或十字绣图纸。',
 'nav': ('首页', '支持', '隐私', '条款'),
 'hero_h': '一张照片，变成一份图纸',
 'hero_p': '选一张宠物、自己或喜欢角色的照片，Hantam 会把它做成拼豆或十字绣图纸，用的都是买得到的颜色。',
 'cta': '在 App Store 下载',
 'features': [('真实颜色', '支持 Perler、Hama、Artkal 拼豆和 DMC 绣线，每个格子都标有真实色号。'),
              ('该买多少一看便知', '查看每种颜色需要的拼豆数或针数，还能复制购物清单。'),
              ('按底板分块', '大图纸按 29 × 29 的底板分块，并用粗线标出分界。'),
              ('哪格都能改', '点一下格子即可修改，也可以把某种颜色整体换成另一种。'),
              ('打印后直接做', '开通 Pro 即可导出打印用 PDF：颜色清单加上逐页的符号图纸。'),
              ('也有像素画', '把照片变成像素画，对着 110 种范例描摹，还能制作逐帧动画。')],
 'pro_h': 'Hantam Pro',
 'pro_p': '免费版可制作一块底板（十字绣为 40 针）以内的图纸，最多保存 3 个图纸，分享的图片带有小标记。Pro 版增加打印用 PDF、最大 4 × 4 块底板或 200 针的图纸、无限保存、无标记图片以及全部像素画工具。可选择按月或按年订阅，也可以一次性买断。',
 'tm': 'Perler、Hama、Artkal 和 DMC 是各自所有者的商标。Hantam 与这些公司没有关联。',
 'support_h': '支持',
 'support_p': '欢迎提问、反馈问题或提出想法。最快的方式是在应用内进入“设置 › 发送反馈”，也可以给我们发邮件。',
 'faq': [('如何恢复购买？', '在应用的设置中点按“恢复购买”。请使用购买 Pro 时的同一个 Apple 账户。'),
         ('如何取消订阅？', '前往 iPhone“设置” › 你的姓名 › “订阅”，选择 Hantam。买断是一次性付费，不会续订。'),
         ('颜色和我的拼豆看起来有点不一样。', '屏幕显示的颜色与实际的塑料和线材会有差异。在颜色清单中点按某个颜色，即可换成同品牌里更接近的颜色。'),
         ('图纸最大能做多大？', '免费版的图纸限于一块 29 × 29 的底板，十字绣最长边 40 针。Pro 版最大可做 4 × 4 块底板（116 颗）或 200 针。'),
         ('会上传我的照片吗？', '不会。照片和图纸都只在你的 iPhone 上处理和保存。')],
 'contact': '联系我们',
 'privacy_h': '隐私政策',
 'terms_h': '使用条款',
 'updated': '最后更新',
 'privacy': [('概要', ['你的照片和图纸不会离开你的 iPhone。我们只收集无法识别你身份的匿名统计数据。']),
             ('照片', ['Hantam 只会在你选择照片时读取它，转换成图纸的过程在你的设备上完成。', '照片不会被上传、保存在服务器上或与他人共享。']),
             ('你制作的图纸', ['图纸保存在 iPhone 上的应用存储空间中。删除应用后，图纸也会一并删除。']),
             ('购买', ['所有付款均由 Apple 处理。我们只知道 Pro 是否已开通，不会获取你的付款信息。']),
             ('匿名统计与崩溃报告',
              ['为了统计用户数量、了解哪些功能被使用并修复崩溃，应用会把匿名数据发送到 Apple iCloud（CloudKit），仅开发者可以读取：',
               '安装时随机生成的 ID（与你、你的 Apple 账户或其他应用无关，重新安装后会改变）、应用和 iOS 版本、地区和语言、打开应用的日期、使用过的功能（例如制作了图纸、导出了 PDF 或显示了购买页面）以及崩溃详情。',
               '其中不包含姓名、联系方式、位置、照片或图纸。如果你没有登录 iCloud，则不会发送任何数据。']),
             ('反馈', ['如果你在应用中发送反馈，我们会收到你写的内容；只有在你填写时，才会收到你的邮箱地址，以便回复你。']),
             ('不做跟踪', ['没有广告，没有第三方分析工具，也不会跨其他应用或网站跟踪你。']),
             ('儿童', ['Hantam 适合所有年龄段使用。我们不会有意收集儿童的个人信息。']),
             ('变更', ['如果本政策有变更，我们会在此页面发布新版本并更新日期。'])],
 'terms': [('使用应用', ['使用 Hantam 即表示你同意本条款。如果你不同意，请不要使用本应用。']),
           ('Hantam 的功能', ['Hantam 可以把照片变成拼豆和十字绣图纸，并包含像素画工具。屏幕上的颜色只是近似匹配，可能与实际产品不同。']),
           ('你的内容', ['你选择的照片和制作的图纸归你所有。请确认你有权使用用来制作图纸的照片，尤其是在你要出售成品时。']),
           ('Hantam Pro',
            ['Pro 通过 Apple 的 App Store 销售，可选择按月或按年自动续订的订阅，或一次性买断。',
             '订阅会自动续订，除非在当前订阅期结束前至少 24 小时取消。续订前 24 小时内会从你的 Apple 账户扣款。你可以在 Apple 账户设置中管理或取消订阅。',
             '如果提供免费试用，在你购买订阅时，试用期未使用的部分将作废。退款遵循 Apple 的政策。']),
           ('规则', ['请勿对本应用进行逆向工程，也不要将其用于任何违法用途。']),
           ('免责声明', ['本应用按“现状”提供，不附带任何形式的保证。在法律允许的范围内，我们的责任以你为本应用支付的金额为限。']),
           ('商标', ['Perler、Hama、Artkal 和 DMC 是各自所有者的商标。Hantam 与这些公司没有关联，也未获得它们的认可。']),
           ('适用法律', ['本条款受大韩民国法律管辖。'])],
 'dev': '开发者：Hyunho Lee'}

LANGS["zh-Hant"] = "zh-Hant/"
LANG_NAME["zh-Hant"] = '繁體中文'
UPDATED["zh-Hant"] = '2026年10月18日'
STORE_LANG["zh-Hant"] = "zh-Hant"
T["zh-Hant"] = {'brand': 'Hantam',
 'title': 'Hantam — 拼豆與十字繡圖紙製作',
 'desc': '把任何照片變成對應 Perler、Hama、Artkal 拼豆及 DMC 繡線真實顏色的拼豆或十字繡圖紙。',
 'nav': ('首頁', '支援', '隱私權', '條款'),
 'hero_h': '一張照片，變成一份圖紙',
 'hero_p': '選一張寵物、自己或喜愛角色的照片，Hantam 會把它做成拼豆或十字繡圖紙，用的都是買得到的顏色。',
 'cta': '在 App Store 下載',
 'features': [('真實顏色', '支援 Perler、Hama、Artkal 拼豆和 DMC 繡線，每個格子都標有真實色號。'),
              ('該買多少一看便知', '查看每種顏色需要的拼豆數或針數，還能複製購物清單。'),
              ('依底板分塊', '大圖紙依 29 × 29 的底板分塊，並用粗線標出分界。'),
              ('哪一格都能改', '點一下格子即可修改，也可以把某種顏色整個換成另一種。'),
              ('列印後直接做', '開通 Pro 即可匯出列印用 PDF：顏色清單加上逐頁的符號圖紙。'),
              ('也有像素畫', '把照片變成像素畫，對著 110 種範例描繪，還能製作逐格動畫。')],
 'pro_h': 'Hantam Pro',
 'pro_p': '免費版可製作一塊底板（十字繡為 40 針）以內的圖紙，最多儲存 3 個圖紙，分享的圖片會帶有小標記。Pro 版增加列印用 PDF、最大 4 × 4 塊底板或 200 針的圖紙、無限儲存、無標記圖片以及全部像素畫工具。可選擇按月或按年訂閱，也可以一次性買斷。',
 'tm': 'Perler、Hama、Artkal 和 DMC 是各自所有者的商標。Hantam 與這些公司沒有關聯。',
 'support_h': '支援',
 'support_p': '歡迎提問、回報問題或提出想法。最快的方式是在 App 內前往「設定 › 傳送意見回饋」，也可以寄信給我們。',
 'faq': [('如何恢復購買項目？', '在 App 的設定中點一下「恢復購買項目」。請使用購買 Pro 時的同一個 Apple 帳號。'),
         ('如何取消訂閱？', '前往 iPhone「設定」› 你的姓名 ›「訂閱項目」，選擇 Hantam。買斷是一次性付費，不會續訂。'),
         ('顏色和我的拼豆看起來有點不一樣。', '螢幕顯示的顏色與實際的塑膠和線材會有差異。在顏色清單中點一下某個顏色，即可換成同品牌裡更接近的顏色。'),
         ('圖紙最大能做多大？', '免費版的圖紙限於一塊 29 × 29 的底板，十字繡最長邊 40 針。Pro 版最大可做 4 × 4 塊底板（116 顆）或 200 針。'),
         ('會上傳我的照片嗎？', '不會。照片和圖紙都只在你的 iPhone 上處理和儲存。')],
 'contact': '聯絡我們',
 'privacy_h': '隱私權政策',
 'terms_h': '使用條款',
 'updated': '最後更新',
 'privacy': [('概要', ['你的照片和圖紙不會離開你的 iPhone。我們只蒐集無法識別你身分的匿名統計資料。']),
             ('照片', ['Hantam 只會在你選擇照片時讀取它，轉換成圖紙的過程在你的裝置上完成。', '照片不會被上傳、儲存在伺服器上或與他人分享。']),
             ('你製作的圖紙', ['圖紙儲存在 iPhone 上的 App 儲存空間中。刪除 App 後，圖紙也會一併刪除。']),
             ('購買項目', ['所有付款均由 Apple 處理。我們只知道 Pro 是否已啟用，不會取得你的付款資訊。']),
             ('匿名統計與當機報告',
              ['為了統計使用者數量、了解哪些功能被使用並修正當機問題，App 會把匿名資料傳送到 Apple iCloud（CloudKit），僅開發者可以讀取：',
               '安裝時隨機產生的 ID（與你、你的 Apple 帳號或其他 App 無關，重新安裝後會改變）、App 和 iOS 版本、地區和語言、開啟 App 的日期、使用過的功能（例如製作了圖紙、匯出了 PDF 或顯示了購買畫面）以及當機詳情。',
               '其中不包含姓名、聯絡資料、位置、照片或圖紙。如果你沒有登入 iCloud，則不會傳送任何資料。']),
             ('意見回饋', ['如果你在 App 中傳送意見回饋，我們會收到你寫的內容；只有在你填寫時，才會收到你的電子郵件地址，以便回覆你。']),
             ('不做追蹤', ['沒有廣告，沒有第三方分析工具，也不會跨其他 App 或網站追蹤你。']),
             ('兒童', ['Hantam 適合所有年齡層使用。我們不會刻意蒐集兒童的個人資料。']),
             ('變更', ['如果本政策有變更，我們會在此頁面發布新版本並更新日期。'])],
 'terms': [('使用 App', ['使用 Hantam 即表示你同意本條款。如果你不同意，請不要使用本 App。']),
           ('Hantam 的功能', ['Hantam 可以把照片變成拼豆和十字繡圖紙，並包含像素畫工具。螢幕上的顏色只是近似對應，可能與實際產品不同。']),
           ('你的內容', ['你選擇的照片和製作的圖紙歸你所有。請確認你有權使用用來製作圖紙的照片，尤其是在你要販售成品時。']),
           ('Hantam Pro',
            ['Pro 透過 Apple 的 App Store 銷售，可選擇按月或按年自動續訂的訂閱，或一次性買斷。',
             '訂閱會自動續訂，除非在目前訂閱期結束前至少 24 小時取消。續訂前 24 小時內會從你的 Apple 帳號扣款。你可以在 Apple 帳號設定中管理或取消訂閱。',
             '如果提供免費試用，在你購買訂閱時，試用期未使用的部分將作廢。退款依 Apple 的政策辦理。']),
           ('規則', ['請勿對本 App 進行逆向工程，也不要將其用於任何違法用途。']),
           ('免責聲明', ['本 App 依「現況」提供，不附帶任何形式的保證。在法律允許的範圍內，我們的責任以你為本 App 支付的金額為限。']),
           ('商標', ['Perler、Hama、Artkal 和 DMC 是各自所有者的商標。Hantam 與這些公司沒有關聯，也未獲得它們的認可。']),
           ('準據法', ['本條款受大韓民國法律管轄。'])],
 'dev': '開發者：Hyunho Lee'}

LANGS["ru"] = "ru/"
LANG_NAME["ru"] = 'Русский'
UPDATED["ru"] = '18 октября 2026 г.'
STORE_LANG["ru"] = "ru"
T["ru"] = {'brand': 'Hantam',
 'title': 'Hantam — схемы для термомозаики и вышивки крестом',
 'desc': 'Превратите любое фото в схему для термомозаики или вышивки крестом в настоящих цветах Perler, Hama, Artkal и DMC.',
 'nav': ('Главная', 'Поддержка', 'Конфиденциальность', 'Условия'),
 'hero_h': 'Из фото — в схему',
 'hero_p': 'Выберите фото питомца, своё или любимого героя. Hantam превратит его в схему для термомозаики или вышивки крестом в цветах, которые можно купить.',
 'cta': 'Загрузить в App Store',
 'features': [('Настоящие цвета', 'Бусины Perler, Hama и Artkal и мулине DMC. У каждой клетки — настоящий номер цвета.'),
              ('Сколько купить — сразу видно', 'Для каждого цвета посчитано число бусин или крестиков, а список покупок можно скопировать.'),
              ('Основа за основой', 'Большие схемы делятся на основы 29 × 29 с жирными линиями границ.'),
              ('Поправить любую клетку', 'Коснитесь клетки, чтобы изменить её, или замените один цвет другим везде.'),
              ('Распечатал — и делай', 'В Pro можно экспортировать PDF для печати: список цветов и схемы со значками по страницам.'),
              ('И пиксель-арт', 'Пикселизация фото, рисование по 110 образцам и покадровая анимация.')],
 'pro_h': 'Hantam Pro',
 'pro_p': 'В бесплатной версии можно делать схемы до одной основы (или 40 крестиков), хранить 3 схемы и делиться изображениями с маленьким знаком. В Pro добавляются PDF для '
          'печати, схемы до 4 × 4 основ или 200 крестиков, неограниченное хранение, изображения без знака и все инструменты пиксель-арта. Выбирайте подписку на месяц или на год '
          'либо однократную покупку навсегда.',
 'tm': 'Perler, Hama, Artkal и DMC — товарные знаки их владельцев. Hantam не связан с этими компаниями.',
 'support_h': 'Поддержка',
 'support_p': 'Вопросы, сообщения об ошибках и идеи — всё приветствуется. Быстрее всего написать из приложения: «Настройки › Отправить отзыв». Можно и по электронной почте.',
 'faq': [('Как восстановить покупку?', 'Откройте «Настройки» в приложении и нажмите «Восстановить покупки». Используйте ту же учётную запись Apple, с которой покупали Pro.'),
         ('Как отменить подписку?', 'Откройте «Настройки» iPhone › ваше имя › «Подписки» и выберите Hantam. Покупка навсегда оплачивается один раз и не продлевается.'),
         ('Цвета немного отличаются от моих бусин.',
          'Экран показывает цвета иначе, чем настоящий пластик и нитки. Нажмите на цвет в списке, чтобы заменить его более близким из того же бренда.'),
         ('Какого размера может быть схема?',
          'Бесплатные схемы умещаются на одной основе 29 × 29 или имеют до 40 крестиков по длинной стороне. В Pro — до 4 × 4 основ (116 бусин) или 200 крестиков.'),
         ('Вы загружаете мои фото?', 'Нет. Фото и схемы обрабатываются и хранятся только на вашем iPhone.')],
 'contact': 'Связаться с нами',
 'privacy_h': 'Политика конфиденциальности',
 'terms_h': 'Условия использования',
 'updated': 'Последнее обновление',
 'privacy': [('Коротко', ['Ваши фото и схемы не покидают iPhone. Мы собираем только анонимную статистику, по которой нельзя установить вашу личность.']),
             ('Фото',
              ['Hantam считывает фото только тогда, когда вы его выбираете. Превращение в схему происходит на вашем устройстве.',
               'Фото не загружаются, не хранятся на сервере и никому не передаются.']),
             ('Ваши схемы', ['Схемы хранятся в памяти приложения на вашем iPhone. Если удалить приложение, они удалятся вместе с ним.']),
             ('Покупки', ['Все платежи обрабатывает Apple. Нам известно только, активен ли Pro, платёжные данные мы не получаем.']),
             ('Анонимная статистика и отчёты о сбоях',
              ['Чтобы считать пользователей, понимать, какими функциями пользуются, и исправлять сбои, приложение отправляет анонимные данные в Apple iCloud (CloudKit); прочитать '
               'их может только разработчик:',
               'случайный идентификатор, созданный при установке (не связан с вами, вашей учётной записью Apple и другими приложениями; при переустановке меняется), версии '
               'приложения и iOS, регион и язык, дни, когда открывалось приложение, использованные функции (например, создана схема, экспортирован PDF или показан экран покупки) '
               'и сведения о сбоях.',
               'Имя, контактные данные, местоположение, фото и схемы не передаются. Если вы не вошли в iCloud, ничего не отправляется.']),
             ('Отзывы', ['Если вы отправляете отзыв из приложения, мы получаем написанный вами текст и, только если вы его укажете, адрес электронной почты для ответа.']),
             ('Без отслеживания', ['Никакой рекламы, сторонней аналитики и отслеживания в других приложениях и на сайтах.']),
             ('Дети', ['Hantam подходит для любого возраста. Мы намеренно не собираем персональные данные детей.']),
             ('Изменения', ['Если политика изменится, мы опубликуем новую версию на этой странице с новой датой.'])],
 'terms': [('Использование приложения', ['Пользуясь Hantam, вы принимаете эти условия. Если вы не согласны, пожалуйста, не пользуйтесь приложением.']),
           ('Что делает Hantam',
            ['Hantam превращает фото в схемы для термомозаики и вышивки крестом, а также включает инструменты пиксель-арта. Цвета на экране лишь приближены к настоящим и могут '
             'отличаться от реальных товаров.']),
           ('Ваш контент',
            ['Выбранные вами фото и созданные схемы принадлежат вам. Убедитесь, что у вас есть право использовать фото, из которых вы делаете схемы, особенно если вы продаёте '
             'готовые работы.']),
           ('Hantam Pro',
            ['Pro продаётся через App Store от Apple как подписка с автоматическим продлением на месяц или на год либо как однократная покупка навсегда.',
             'Подписка продлевается автоматически, если не отменить её минимум за 24 часа до конца текущего периода. Плата списывается с вашей учётной записи Apple в течение 24 '
             'часов до продления. Управлять подпиской и отменять её можно в настройках учётной записи Apple.',
             'Если предлагается бесплатный пробный период, его неиспользованная часть заканчивается при оформлении подписки. Возврат средств регулируется правилами Apple.']),
           ('Правила', ['Не занимайтесь обратной разработкой приложения и не используйте его в незаконных целях.']),
           ('Отказ от гарантий',
            ['Приложение предоставляется «как есть», без каких-либо гарантий. В пределах, допускаемых законом, наша ответственность ограничена суммой, которую вы заплатили за '
             'приложение.']),
           ('Товарные знаки', ['Perler, Hama, Artkal и DMC — товарные знаки их владельцев. Hantam не связан с этими компаниями и не одобрен ими.']),
           ('Применимое право', ['Эти условия регулируются законодательством Республики Корея.'])],
 'dev': 'Разработчик: Hyunho Lee'}

LANGS["es"] = "es/"
LANG_NAME["es"] = 'Español'
UPDATED["es"] = '18 de octubre de 2026'
STORE_LANG["es"] = "es-ES"
T["es"] = {'brand': 'Hantam',
 'title': 'Hantam — Patrones de cuentas y punto de cruz',
 'desc': 'Convierte cualquier foto en un patrón de cuentas para planchar o de punto de cruz con los colores reales de Perler, Hama, Artkal y DMC.',
 'nav': ('Inicio', 'Soporte', 'Privacidad', 'Términos'),
 'hero_h': 'De una foto a un patrón',
 'hero_p': 'Elige una foto de tu mascota, de ti o de tu personaje favorito. Hantam la convierte en un patrón de cuentas o de punto de cruz con colores que puedes comprar.',
 'cta': 'Descargar en el App Store',
 'features': [('Colores reales', 'Cuentas Perler, Hama y Artkal e hilos DMC. Cada casilla muestra un número de color real.'),
              ('Sabes qué comprar', 'Consulta cuántas cuentas o puntos necesita cada color y copia la lista de la compra.'),
              ('Placa a placa', 'Los patrones grandes se dividen en placas de 29 × 29 con líneas de borde gruesas.'),
              ('Retoca cualquier casilla', 'Toca una casilla para cambiarla o sustituye un color por otro en todo el patrón.'),
              ('Imprime y haz', 'Con Pro, exporta un PDF para imprimir: lista de colores y patrones con símbolos, página a página.'),
              ('Y pixel art', 'Pixela fotos, calca 110 modelos y anima fotograma a fotograma.')],
 'pro_h': 'Hantam Pro',
 'pro_p': 'La versión gratuita permite patrones de hasta una placa (o 40 puntos), guardar 3 patrones y compartir imágenes con una pequeña marca. Pro añade PDF para imprimir, '
          'patrones de hasta 4 × 4 placas o 200 puntos, guardado ilimitado, imágenes sin marca y todas las herramientas de pixel art. Elige una suscripción mensual o anual, o un '
          'pago único para siempre.',
 'tm': 'Perler, Hama, Artkal y DMC son marcas comerciales de sus respectivos propietarios. Hantam no está afiliada con ellas.',
 'support_h': 'Soporte',
 'support_p': 'Preguntas, errores e ideas son siempre bienvenidos. Lo más rápido es usar Ajustes › Enviar comentarios dentro de la app, o escribirnos por correo.',
 'faq': [('¿Cómo restauro mi compra?', 'Abre Ajustes en la app y toca Restaurar compras. Usa la misma cuenta de Apple con la que compraste Pro.'),
         ('¿Cómo cancelo una suscripción?', 'Ve a Ajustes del iPhone › tu nombre › Suscripciones y elige Hantam. El acceso de por vida es un pago único y no se renueva.'),
         ('Los colores se ven un poco distintos de mis cuentas.',
          'Las pantallas muestran los colores de forma distinta al plástico y al hilo reales. Toca un color de la lista para cambiarlo por otro más parecido de la misma marca.'),
         ('¿Qué tamaño pueden tener los patrones?',
          'Los patrones gratuitos caben en una placa de 29 × 29, o tienen 40 puntos en el lado más largo. Pro llega a 4 × 4 placas (116 cuentas) o 200 puntos.'),
         ('¿Se suben mis fotos?', 'No. Las fotos y los patrones se procesan y se guardan solo en tu iPhone.')],
 'contact': 'Contacto',
 'privacy_h': 'Política de privacidad',
 'terms_h': 'Términos de uso',
 'updated': 'Última actualización',
 'privacy': [('Resumen', ['Tus fotos y tus patrones nunca salen de tu iPhone. Solo recogemos estadísticas anónimas que no permiten identificarte.']),
             ('Fotos',
              ['Hantam lee una foto solo cuando la eliges. La conversión en patrón se hace en tu dispositivo.',
               'Las fotos nunca se suben, ni se guardan en un servidor ni se comparten.']),
             ('Los patrones que creas', ['Los patrones se guardan en el almacenamiento de la app en tu iPhone. Si eliminas la app, se eliminan con ella.']),
             ('Compras', ['Apple gestiona todos los pagos. Solo sabemos si Pro está activo, nunca tus datos de pago.']),
             ('Estadísticas anónimas e informes de fallos',
              ['Para contar usuarios, saber qué funciones se usan y corregir fallos, la app envía datos anónimos a Apple iCloud (CloudKit), que solo puede leer el desarrollador:',
               'un identificador aleatorio creado al instalar (no está vinculado a ti, a tu cuenta de Apple ni a otras apps; cambia si reinstalas), la versión de la app y de iOS, '
               'la región y el idioma, los días en que se abrió la app, las funciones usadas (por ejemplo, se creó un patrón, se exportó un PDF o se mostró la pantalla de compra) '
               'y los detalles de los fallos.',
               'No se incluyen nombre, datos de contacto, ubicación, fotos ni patrones. Si no has iniciado sesión en iCloud, no se envía nada.']),
             ('Comentarios', ['Si envías comentarios desde la app, recibimos lo que escribas y, solo si lo añades, tu dirección de correo para poder responderte.']),
             ('Sin seguimiento', ['Sin publicidad, sin analítica de terceros y sin seguimiento entre otras apps o sitios web.']),
             ('Menores', ['Hantam es apto para todas las edades. No recopilamos a sabiendas datos personales de menores.']),
             ('Cambios', ['Si esta política cambia, publicaremos aquí la nueva versión con una fecha nueva.'])],
 'terms': [('Uso de la app', ['Al usar Hantam aceptas estos términos. Si no estás de acuerdo, por favor no uses la app.']),
           ('Qué hace Hantam',
            ['Hantam convierte fotos en patrones de cuentas para planchar y de punto de cruz, e incluye herramientas de pixel art. Los colores en pantalla son aproximados y '
             'pueden diferir de los productos reales.']),
           ('Tu contenido',
            ['Las fotos que eliges y los patrones que creas son tuyos. Asegúrate de tener derecho a usar las fotos que conviertes en patrones, sobre todo si vendes lo que '
             'haces.']),
           ('Hantam Pro',
            ['Pro se vende en el App Store de Apple como suscripción mensual o anual con renovación automática, o como acceso de por vida con un pago único.',
             'Las suscripciones se renuevan automáticamente salvo que se cancelen al menos 24 horas antes de que termine el periodo en curso. El cargo se hace a tu cuenta de '
             'Apple en las 24 horas previas a la renovación. Puedes gestionarlas o cancelarlas en los ajustes de tu cuenta de Apple.',
             'Si se ofrece una prueba gratuita, la parte no utilizada termina al contratar una suscripción. Los reembolsos se rigen por la política de Apple.']),
           ('Normas', ['No hagas ingeniería inversa de la app ni la uses para nada ilegal.']),
           ('Sin garantía',
            ['La app se ofrece tal cual, sin garantías de ningún tipo. En la medida que permita la ley, nuestra responsabilidad se limita a lo que hayas pagado por la app.']),
           ('Marcas comerciales', ['Perler, Hama, Artkal y DMC son marcas comerciales de sus respectivos propietarios. Hantam no está afiliada ni respaldada por ellas.']),
           ('Ley aplicable', ['Estos términos se rigen por las leyes de la República de Corea.'])],
 'dev': 'Desarrollador: Hyunho Lee'}

LANGS["de"] = "de/"
LANG_NAME["de"] = 'Deutsch'
UPDATED["de"] = '18. Oktober 2026'
STORE_LANG["de"] = "de-DE"
T["de"] = {'brand': 'Hantam',
 'title': 'Hantam — Vorlagen für Bügelperlen und Kreuzstich',
 'desc': 'Mach aus jedem Foto eine Vorlage für Bügelperlen oder Kreuzstich in den echten Farben von Perler, Hama, Artkal und DMC.',
 'nav': ('Start', 'Support', 'Datenschutz', 'Bedingungen'),
 'hero_h': 'Aus einem Foto wird eine Vorlage',
 'hero_p': 'Wähle ein Foto von deinem Haustier, von dir oder von einem Lieblingscharakter. Hantam macht daraus eine Vorlage für Bügelperlen oder Kreuzstich in Farben, die du '
           'wirklich kaufen kannst.',
 'cta': 'Im App Store laden',
 'features': [('Echte Farben', 'Bügelperlen von Perler, Hama und Artkal und DMC-Garn. Jedes Feld zeigt eine echte Farbnummer.'),
              ('Du weißt, was du kaufen musst', 'Sieh, wie viele Perlen oder Stiche jede Farbe braucht, und kopiere eine Einkaufsliste.'),
              ('Platte für Platte', 'Große Vorlagen werden in Steckplatten à 29 × 29 mit fetten Plattenlinien aufgeteilt.'),
              ('Jedes Feld korrigieren', 'Tippe ein Feld an, um es zu ändern, oder ersetze eine Farbe überall durch eine andere.'),
              ('Ausdrucken und basteln', 'Mit Pro exportierst du ein druckbares PDF: Farbliste und Symbolvorlagen, Seite für Seite.'),
              ('Auch Pixelart', 'Fotos in Pixelart verwandeln, 110 Vorlagen nachzeichnen und Bild für Bild animieren.')],
 'pro_h': 'Hantam Pro',
 'pro_p': 'Die kostenlose Version erlaubt Vorlagen bis zu einer Steckplatte (oder 40 Stichen), 3 gespeicherte Vorlagen und das Teilen von Bildern mit einem kleinen Zeichen. Pro '
          'bietet druckbare PDFs, Vorlagen bis 4 × 4 Platten oder 200 Stiche, unbegrenztes Speichern, Bilder ohne Zeichen und alle Pixelart-Werkzeuge. Wähle ein Monats- oder '
          'Jahresabo oder einen einmaligen Kauf.',
 'tm': 'Perler, Hama, Artkal und DMC sind Marken ihrer jeweiligen Inhaber. Hantam steht in keiner Verbindung zu diesen Unternehmen.',
 'support_h': 'Support',
 'support_p': 'Fragen, Fehlermeldungen und Ideen sind jederzeit willkommen. Am schnellsten geht es über Einstellungen › Feedback senden in der App, oder schreib uns eine E-Mail.',
 'faq': [('Wie stelle ich meinen Kauf wieder her?',
          'Öffne die Einstellungen in der App und tippe auf „Käufe wiederherstellen“. Verwende denselben Apple-Account, mit dem du Pro gekauft hast.'),
         ('Wie kündige ich ein Abo?',
          'Gehe in den iPhone-Einstellungen auf deinen Namen › Abonnements und wähle Hantam. Der lebenslange Zugang ist ein Einmalkauf und verlängert sich nie.'),
         ('Die Farben sehen etwas anders aus als meine Perlen.',
          'Bildschirme zeigen Farben anders als echtes Plastik und Garn. Tippe in der Liste auf eine Farbe, um sie durch eine ähnlichere derselben Marke zu ersetzen.'),
         ('Wie groß darf eine Vorlage sein?',
          'Kostenlose Vorlagen passen auf eine Steckplatte à 29 × 29 oder haben 40 Stiche an der längsten Seite. Pro reicht bis 4 × 4 Platten (116 Perlen) oder 200 Stiche.'),
         ('Werden meine Fotos hochgeladen?', 'Nein. Fotos und Vorlagen werden nur auf deinem iPhone verarbeitet und gespeichert.')],
 'contact': 'Kontakt',
 'privacy_h': 'Datenschutzerklärung',
 'terms_h': 'Nutzungsbedingungen',
 'updated': 'Zuletzt aktualisiert',
 'privacy': [('Kurzfassung', ['Deine Fotos und Vorlagen verlassen dein iPhone nie. Wir erfassen nur anonyme Statistiken, die dich nicht identifizieren.']),
             ('Fotos',
              ['Hantam liest ein Foto nur, wenn du es auswählst. Die Umwandlung in eine Vorlage geschieht auf deinem Gerät.',
               'Fotos werden nie hochgeladen, auf einem Server gespeichert oder weitergegeben.']),
             ('Deine Vorlagen', ['Vorlagen werden im Speicher der App auf deinem iPhone abgelegt. Löschst du die App, werden sie mitgelöscht.']),
             ('Käufe', ['Apple wickelt alle Zahlungen ab. Wir erfahren nur, ob Pro aktiv ist – niemals deine Zahlungsdaten.']),
             ('Anonyme Statistiken und Absturzberichte',
              ['Um Nutzer zu zählen, zu sehen, welche Funktionen genutzt werden, und Abstürze zu beheben, sendet die App anonyme Daten an Apple iCloud (CloudKit), die nur der '
               'Entwickler lesen kann:',
               'eine bei der Installation erzeugte zufällige ID (nicht mit dir, deinem Apple-Account oder anderen Apps verknüpft; sie ändert sich bei einer Neuinstallation), App- '
               'und iOS-Version, Region und Sprache, die Tage, an denen die App geöffnet wurde, genutzte Funktionen (zum Beispiel: eine Vorlage wurde erstellt, ein PDF exportiert '
               'oder der Kaufbildschirm angezeigt) sowie Absturzdetails.',
               'Name, Kontaktdaten, Standort, Fotos und Vorlagen sind nicht enthalten. Ohne iCloud-Anmeldung wird nichts gesendet.']),
             ('Feedback', ['Wenn du Feedback aus der App sendest, erhalten wir deinen Text und – nur wenn du sie angibst – deine E-Mail-Adresse, damit wir antworten können.']),
             ('Kein Tracking', ['Keine Werbung, keine Analysetools von Drittanbietern und kein Tracking über andere Apps oder Websites hinweg.']),
             ('Kinder', ['Hantam ist für alle Altersgruppen geeignet. Wir erheben wissentlich keine personenbezogenen Daten von Kindern.']),
             ('Änderungen', ['Wenn sich diese Erklärung ändert, veröffentlichen wir die neue Fassung hier mit neuem Datum.'])],
 'terms': [('Nutzung der App', ['Mit der Nutzung von Hantam stimmst du diesen Bedingungen zu. Wenn du nicht einverstanden bist, nutze die App bitte nicht.']),
           ('Was Hantam macht',
            ['Hantam verwandelt Fotos in Vorlagen für Bügelperlen und Kreuzstich und enthält Pixelart-Werkzeuge. Die Farben auf dem Bildschirm sind nur Näherungen und können von '
             'den echten Produkten abweichen.']),
           ('Deine Inhalte',
            ['Die Fotos, die du auswählst, und die Vorlagen, die du erstellst, gehören dir. Stelle sicher, dass du die Rechte an den Fotos hast, aus denen du Vorlagen machst – '
             'besonders wenn du deine Arbeiten verkaufst.']),
           ('Hantam Pro',
            ['Pro wird über Apples App Store als automatisch verlängertes Monats- oder Jahresabo oder als einmaliger lebenslanger Zugang verkauft.',
             'Abos verlängern sich automatisch, sofern sie nicht mindestens 24 Stunden vor Ende des laufenden Zeitraums gekündigt werden. Dein Apple-Account wird innerhalb von 24 '
             'Stunden vor der Verlängerung belastet. Verwalten oder kündigen kannst du in den Einstellungen deines Apple-Accounts.',
             'Wird eine kostenlose Testphase angeboten, verfällt der ungenutzte Teil, sobald du ein Abo abschließt. Rückerstattungen richten sich nach Apples Richtlinien.']),
           ('Regeln', ['Betreibe kein Reverse Engineering der App und nutze sie nicht für rechtswidrige Zwecke.']),
           ('Keine Gewährleistung',
            ['Die App wird ohne jede Gewährleistung „wie besehen“ bereitgestellt. Soweit gesetzlich zulässig, ist unsere Haftung auf den Betrag begrenzt, den du für die App '
             'bezahlt hast.']),
           ('Marken', ['Perler, Hama, Artkal und DMC sind Marken ihrer jeweiligen Inhaber. Hantam steht mit diesen nicht in Verbindung und wird nicht von ihnen unterstützt.']),
           ('Anwendbares Recht', ['Diese Bedingungen unterliegen dem Recht der Republik Korea.'])],
 'dev': 'Entwickler: Hyunho Lee'}

LANGS["fr"] = "fr/"
LANG_NAME["fr"] = 'Français'
UPDATED["fr"] = '18 octobre 2026'
STORE_LANG["fr"] = "fr-FR"
T["fr"] = {'brand': 'Hantam',
 'title': 'Hantam — Grilles de perles à repasser et de point de croix',
 'desc': 'Transformez n’importe quelle photo en grille de perles à repasser ou de point de croix, aux vraies couleurs Perler, Hama, Artkal et DMC.',
 'nav': ('Accueil', 'Assistance', 'Confidentialité', 'Conditions'),
 'hero_h': 'D’une photo à une grille',
 'hero_p': 'Choisissez une photo de votre animal, de vous ou d’un personnage préféré. Hantam en fait une grille de perles à repasser ou de point de croix, avec des couleurs que '
           'vous pouvez acheter.',
 'cta': 'Télécharger sur l’App Store',
 'features': [('De vraies couleurs', 'Perles Perler, Hama et Artkal et fils DMC. Chaque case affiche un vrai numéro de couleur.'),
              ('Vous savez quoi acheter', 'Voyez combien de perles ou de points chaque couleur demande, et copiez une liste de courses.'),
              ('Plaque par plaque', 'Les grandes grilles sont découpées en plaques de 29 × 29, avec des traits épais aux limites.'),
              ('Corrigez chaque case', 'Touchez une case pour la modifier, ou remplacez une couleur par une autre partout.'),
              ('Imprimez et réalisez', 'Avec Pro, exportez un PDF à imprimer : liste des couleurs et grilles à symboles, page par page.'),
              ('Du pixel art aussi', 'Pixelisez des photos, calquez 110 modèles et animez image par image.')],
 'pro_h': 'Hantam Pro',
 'pro_p': 'La version gratuite permet des grilles jusqu’à une plaque (ou 40 points), 3 grilles enregistrées et le partage d’images avec une petite marque. Pro ajoute les PDF à '
          'imprimer, des grilles jusqu’à 4 × 4 plaques ou 200 points, l’enregistrement illimité, les images sans marque et tous les outils de pixel art. Choisissez un abonnement '
          'mensuel ou annuel, ou un achat unique à vie.',
 'tm': 'Perler, Hama, Artkal et DMC sont des marques de leurs propriétaires respectifs. Hantam n’est affilié à aucune de ces sociétés.',
 'support_h': 'Assistance',
 'support_p': 'Questions, signalements de bugs et idées sont les bienvenus. Le plus rapide : Réglages › Envoyer des commentaires dans l’app, ou nous écrire par e-mail.',
 'faq': [('Comment restaurer mon achat ?',
          'Ouvrez les Réglages de l’app et touchez Restaurer les achats. Utilisez le même compte Apple que celui avec lequel vous avez acheté Pro.'),
         ('Comment résilier un abonnement ?',
          'Allez dans Réglages de l’iPhone › votre nom › Abonnements, puis choisissez Hantam. L’accès à vie est un achat unique et ne se renouvelle jamais.'),
         ('Les couleurs diffèrent un peu de mes perles.',
          'Les écrans affichent les couleurs autrement que le plastique et le fil réels. Touchez une couleur dans la liste pour la remplacer par une teinte plus proche de la même '
          'marque.'),
         ('Quelle taille peut avoir une grille ?',
          'Les grilles gratuites tiennent sur une plaque de 29 × 29, ou 40 points sur le plus grand côté. Pro va jusqu’à 4 × 4 plaques (116 perles) ou 200 points.'),
         ('Mes photos sont-elles envoyées sur un serveur ?', 'Non. Les photos et les grilles sont traitées et enregistrées uniquement sur votre iPhone.')],
 'contact': 'Contact',
 'privacy_h': 'Politique de confidentialité',
 'terms_h': 'Conditions d’utilisation',
 'updated': 'Dernière mise à jour',
 'privacy': [('En bref',
              ['Vos photos et vos grilles ne quittent jamais votre iPhone. Nous ne recueillons que des statistiques anonymes qui ne permettent pas de vous identifier.']),
             ('Photos',
              ['Hantam ne lit une photo que lorsque vous la choisissez. La transformation en grille se fait sur votre appareil.',
               'Les photos ne sont jamais envoyées, stockées sur un serveur ni partagées.']),
             ('Les grilles que vous créez',
              ['Les grilles sont enregistrées dans l’espace de stockage de l’app sur votre iPhone. Si vous supprimez l’app, elles sont supprimées avec elle.']),
             ('Achats', ['Apple gère tous les paiements. Nous savons seulement si Pro est actif, jamais vos coordonnées de paiement.']),
             ('Statistiques anonymes et rapports de plantage',
              ['Pour compter les utilisateurs, savoir quelles fonctions sont utilisées et corriger les plantages, l’app envoie des données anonymes à Apple iCloud (CloudKit), '
               'lisibles uniquement par le développeur :',
               'un identifiant aléatoire créé à l’installation (non lié à vous, à votre compte Apple ni à d’autres apps ; il change si vous réinstallez), la version de l’app et '
               'd’iOS, la région et la langue, les jours d’ouverture de l’app, les fonctions utilisées (par exemple, une grille créée, un PDF exporté ou l’écran d’achat affiché) '
               'et les détails des plantages.',
               'Aucun nom, coordonnée, position, photo ou grille n’est inclus. Rien n’est envoyé si vous n’êtes pas connecté à iCloud.']),
             ('Commentaires',
              ['Si vous envoyez un commentaire depuis l’app, nous recevons ce que vous écrivez et, seulement si vous l’ajoutez, votre adresse e-mail pour pouvoir vous répondre.']),
             ('Aucun suivi', ['Pas de publicité, pas d’outil d’analyse tiers et aucun suivi entre d’autres apps ou sites web.']),
             ('Enfants', ['Hantam convient à tous les âges. Nous ne recueillons pas sciemment de données personnelles d’enfants.']),
             ('Modifications', ['Si cette politique change, nous publierons ici la nouvelle version avec une nouvelle date.'])],
 'terms': [('Utilisation de l’app', ['En utilisant Hantam, vous acceptez ces conditions. Si vous n’êtes pas d’accord, merci de ne pas utiliser l’app.']),
           ('Ce que fait Hantam',
            ['Hantam transforme des photos en grilles de perles à repasser et de point de croix, et comprend des outils de pixel art. Les couleurs à l’écran sont approchantes et '
             'peuvent différer des produits réels.']),
           ('Votre contenu',
            ['Les photos que vous choisissez et les grilles que vous créez vous appartiennent. Assurez-vous d’avoir le droit d’utiliser les photos que vous transformez en '
             'grilles, surtout si vous vendez vos créations.']),
           ('Hantam Pro',
            ['Pro est vendu via l’App Store d’Apple, sous forme d’abonnement mensuel ou annuel à renouvellement automatique, ou d’accès à vie en achat unique.',
             'Les abonnements se renouvellent automatiquement, sauf annulation au moins 24 heures avant la fin de la période en cours. Votre compte Apple est débité dans les 24 '
             'heures précédant le renouvellement. Vous pouvez gérer ou annuler dans les réglages de votre compte Apple.',
             'Si un essai gratuit est proposé, sa partie inutilisée prend fin dès que vous souscrivez un abonnement. Les remboursements suivent la politique d’Apple.']),
           ('Règles', ['Ne faites pas de rétro-ingénierie de l’app et ne l’utilisez pas à des fins illégales.']),
           ('Absence de garantie',
            ['L’app est fournie en l’état, sans garantie d’aucune sorte. Dans la mesure permise par la loi, notre responsabilité est limitée au montant que vous avez payé pour '
             'l’app.']),
           ('Marques', ['Perler, Hama, Artkal et DMC sont des marques de leurs propriétaires respectifs. Hantam n’est ni affilié à ces sociétés ni approuvé par elles.']),
           ('Droit applicable', ['Ces conditions sont régies par les lois de la République de Corée.'])],
 'dev': 'Développeur : Hyunho Lee'}

LANGS["it"] = "it/"
LANG_NAME["it"] = 'Italiano'
UPDATED["it"] = '18 ottobre 2026'
STORE_LANG["it"] = "it"
T["it"] = {'brand': 'Hantam',
 'title': 'Hantam — Schemi per perline da stirare e punto croce',
 'desc': 'Trasforma qualsiasi foto in uno schema per perline da stirare o punto croce con i colori veri di Perler, Hama, Artkal e DMC.',
 'nav': ('Home', 'Assistenza', 'Privacy', 'Condizioni'),
 'hero_h': 'Da una foto a uno schema',
 'hero_p': 'Scegli la foto del tuo animale, di te o di un personaggio preferito. Hantam la trasforma in uno schema per perline da stirare o punto croce, con colori che puoi '
           'comprare.',
 'cta': 'Scarica dall’App Store',
 'features': [('Colori veri', 'Perline Perler, Hama e Artkal e fili DMC. Ogni casella mostra un vero numero di colore.'),
              ('Sai cosa comprare', 'Vedi quante perline o punti servono per ogni colore e copia una lista della spesa.'),
              ('Base per base', 'Gli schemi grandi sono divisi in basi da 29 × 29, con linee di bordo spesse.'),
              ('Correggi ogni casella', 'Tocca una casella per cambiarla, oppure sostituisci un colore con un altro ovunque.'),
              ('Stampa e realizza', 'Con Pro esporti un PDF da stampare: elenco dei colori e schemi con simboli, pagina per pagina.'),
              ('Anche pixel art', 'Pixela le foto, ricalca 110 modelli e anima fotogramma per fotogramma.')],
 'pro_h': 'Hantam Pro',
 'pro_p': 'La versione gratuita consente schemi fino a una base (o 40 punti), 3 schemi salvati e la condivisione di immagini con un piccolo marchio. Pro aggiunge PDF da stampare, '
          'schemi fino a 4 × 4 basi o 200 punti, salvataggio illimitato, immagini senza marchio e tutti gli strumenti per il pixel art. Scegli un abbonamento mensile o annuale, '
          'oppure un acquisto unico a vita.',
 'tm': 'Perler, Hama, Artkal e DMC sono marchi dei rispettivi proprietari. Hantam non è affiliata a queste aziende.',
 'support_h': 'Assistenza',
 'support_p': 'Domande, segnalazioni di bug e idee sono sempre benvenute. Il modo più veloce è Impostazioni › Invia feedback nell’app, oppure scrivici via e-mail.',
 'faq': [('Come ripristino il mio acquisto?', 'Apri le Impostazioni nell’app e tocca Ripristina acquisti. Usa lo stesso account Apple con cui hai acquistato Pro.'),
         ('Come annullo un abbonamento?', 'Vai in Impostazioni di iPhone › il tuo nome › Abbonamenti e scegli Hantam. L’accesso a vita è un acquisto unico e non si rinnova mai.'),
         ('I colori sembrano un po’ diversi dalle mie perline.',
          'Gli schermi mostrano i colori in modo diverso dalla plastica e dal filo reali. Tocca un colore nell’elenco per sostituirlo con uno più simile della stessa marca.'),
         ('Quanto può essere grande uno schema?',
          'Gli schemi gratuiti stanno su una base da 29 × 29, oppure arrivano a 40 punti sul lato più lungo. Pro arriva a 4 × 4 basi (116 perline) o 200 punti.'),
         ('Caricate le mie foto?', 'No. Foto e schemi vengono elaborati e salvati solo sul tuo iPhone.')],
 'contact': 'Contatti',
 'privacy_h': 'Informativa sulla privacy',
 'terms_h': 'Condizioni d’uso',
 'updated': 'Ultimo aggiornamento',
 'privacy': [('In sintesi', ['Le tue foto e i tuoi schemi non lasciano mai il tuo iPhone. Raccogliamo solo statistiche anonime che non permettono di identificarti.']),
             ('Foto',
              ['Hantam legge una foto solo quando la scegli. La trasformazione in schema avviene sul tuo dispositivo.',
               'Le foto non vengono mai caricate, salvate su un server né condivise.']),
             ('Gli schemi che crei', ['Gli schemi sono salvati nell’archivio dell’app sul tuo iPhone. Se elimini l’app, vengono eliminati con essa.']),
             ('Acquisti', ['Apple gestisce tutti i pagamenti. Sappiamo solo se Pro è attivo, mai i tuoi dati di pagamento.']),
             ('Statistiche anonime e rapporti sugli arresti anomali',
              ['Per contare gli utenti, vedere quali funzioni vengono usate e correggere gli arresti anomali, l’app invia dati anonimi ad Apple iCloud (CloudKit), leggibili solo '
               'dallo sviluppatore:',
               'un ID casuale creato all’installazione (non collegato a te, al tuo account Apple o ad altre app; cambia se reinstalli), versione dell’app e di iOS, area '
               'geografica e lingua, i giorni in cui l’app è stata aperta, le funzioni usate (ad esempio, è stato creato uno schema, esportato un PDF o mostrata la schermata di '
               'acquisto) e i dettagli degli arresti anomali.',
               'Non sono inclusi nome, recapiti, posizione, foto o schemi. Se non hai effettuato l’accesso a iCloud, non viene inviato nulla.']),
             ('Feedback', ['Se invii un feedback dall’app, riceviamo ciò che scrivi e, solo se lo aggiungi, il tuo indirizzo e-mail per poterti rispondere.']),
             ('Nessun tracciamento', ['Nessuna pubblicità, nessuna analisi di terze parti e nessun tracciamento tra altre app o siti web.']),
             ('Minori', ['Hantam è adatta a tutte le età. Non raccogliamo consapevolmente dati personali di minori.']),
             ('Modifiche', ['Se questa informativa cambia, pubblicheremo qui la nuova versione con una nuova data.'])],
 'terms': [('Uso dell’app', ['Usando Hantam accetti queste condizioni. Se non sei d’accordo, ti preghiamo di non usare l’app.']),
           ('Cosa fa Hantam',
            ['Hantam trasforma le foto in schemi per perline da stirare e punto croce e include strumenti per il pixel art. I colori sullo schermo sono approssimativi e possono '
             'differire dai prodotti reali.']),
           ('I tuoi contenuti',
            ['Le foto che scegli e gli schemi che crei sono tuoi. Assicurati di avere il diritto di usare le foto che trasformi in schemi, soprattutto se vendi ciò che '
             'realizzi.']),
           ('Hantam Pro',
            ['Pro viene venduto tramite l’App Store di Apple come abbonamento mensile o annuale a rinnovo automatico oppure come accesso a vita con acquisto unico.',
             'Gli abbonamenti si rinnovano automaticamente, a meno che non vengano annullati almeno 24 ore prima della fine del periodo in corso. Il tuo account Apple viene '
             'addebitato nelle 24 ore precedenti il rinnovo. Puoi gestire o annullare dalle impostazioni del tuo account Apple.',
             'Se viene offerta una prova gratuita, la parte non utilizzata termina quando sottoscrivi un abbonamento. I rimborsi seguono la politica di Apple.']),
           ('Regole', ['Non effettuare il reverse engineering dell’app e non usarla per scopi illeciti.']),
           ('Esclusione di garanzia',
            ['L’app è fornita così com’è, senza garanzie di alcun tipo. Nei limiti consentiti dalla legge, la nostra responsabilità è limitata a quanto hai pagato per l’app.']),
           ('Marchi', ['Perler, Hama, Artkal e DMC sono marchi dei rispettivi proprietari. Hantam non è affiliata né approvata da queste aziende.']),
           ('Legge applicabile', ['Queste condizioni sono regolate dalle leggi della Repubblica di Corea.'])],
 'dev': 'Sviluppatore: Hyunho Lee'}

LANGS["pt-BR"] = "pt-BR/"
LANG_NAME["pt-BR"] = 'Português (Brasil)'
UPDATED["pt-BR"] = '18 de outubro de 2026'
STORE_LANG["pt-BR"] = "pt-BR"
T["pt-BR"] = {'brand': 'Hantam',
 'title': 'Hantam — Padrões de miçangas de passar e ponto cruz',
 'desc': 'Transforme qualquer foto em um padrão de miçangas de passar ou de ponto cruz com as cores reais de Perler, Hama, Artkal e DMC.',
 'nav': ('Início', 'Suporte', 'Privacidade', 'Termos'),
 'hero_h': 'De uma foto a um padrão',
 'hero_p': 'Escolha a foto do seu pet, a sua ou a de um personagem favorito. O Hantam transforma em um padrão de miçangas de passar ou de ponto cruz, com cores que você pode '
           'comprar.',
 'cta': 'Baixar na App Store',
 'features': [('Cores reais', 'Miçangas Perler, Hama e Artkal e fios DMC. Cada quadradinho mostra um número de cor real.'),
              ('Você sabe o que comprar', 'Veja quantas miçangas ou pontos cada cor exige e copie uma lista de compras.'),
              ('Placa por placa', 'Padrões grandes são divididos em placas de 29 × 29, com linhas grossas nas divisas.'),
              ('Ajuste qualquer quadradinho', 'Toque em um quadradinho para alterá-lo ou troque uma cor por outra em todo o padrão.'),
              ('Imprima e faça', 'Com o Pro, exporte um PDF para imprimir: lista de cores e padrões com símbolos, página por página.'),
              ('Pixel art também', 'Pixele fotos, desenhe por cima de 110 modelos e anime quadro a quadro.')],
 'pro_h': 'Hantam Pro',
 'pro_p': 'A versão gratuita permite padrões de até uma placa (ou 40 pontos), 3 padrões salvos e o compartilhamento de imagens com uma pequena marca. O Pro adiciona PDFs para '
          'imprimir, padrões de até 4 × 4 placas ou 200 pontos, salvamento ilimitado, imagens sem marca e todas as ferramentas de pixel art. Escolha uma assinatura mensal ou '
          'anual, ou um pagamento único vitalício.',
 'tm': 'Perler, Hama, Artkal e DMC são marcas registradas de seus respectivos proprietários. O Hantam não é afiliado a essas empresas.',
 'support_h': 'Suporte',
 'support_p': 'Dúvidas, relatos de erros e ideias são sempre bem-vindos. O jeito mais rápido é em Ajustes › Enviar feedback, dentro do app, ou por e-mail.',
 'faq': [('Como restauro minha compra?', 'Abra os Ajustes no app e toque em Restaurar Compras. Use a mesma conta Apple com a qual você comprou o Pro.'),
         ('Como cancelo uma assinatura?', 'Vá em Ajustes do iPhone › seu nome › Assinaturas e escolha o Hantam. O acesso vitalício é um pagamento único e nunca é renovado.'),
         ('As cores parecem um pouco diferentes das minhas miçangas.',
          'As telas mostram as cores de modo diferente do plástico e da linha reais. Toque em uma cor da lista para trocá-la por uma mais próxima da mesma marca.'),
         ('Qual o tamanho máximo de um padrão?',
          'Os padrões gratuitos cabem em uma placa de 29 × 29, ou têm 40 pontos no lado maior. O Pro vai até 4 × 4 placas (116 miçangas) ou 200 pontos.'),
         ('Vocês enviam minhas fotos para algum servidor?', 'Não. Fotos e padrões são processados e salvos apenas no seu iPhone.')],
 'contact': 'Contato',
 'privacy_h': 'Política de Privacidade',
 'terms_h': 'Termos de Uso',
 'updated': 'Última atualização',
 'privacy': [('Resumo', ['Suas fotos e seus padrões nunca saem do seu iPhone. Coletamos apenas estatísticas anônimas que não identificam você.']),
             ('Fotos',
              ['O Hantam só lê uma foto quando você a escolhe. A transformação em padrão acontece no seu aparelho.',
               'As fotos nunca são enviadas, armazenadas em servidor nem compartilhadas.']),
             ('Os padrões que você cria', ['Os padrões ficam salvos no armazenamento do app, no seu iPhone. Se você apagar o app, eles são apagados junto.']),
             ('Compras', ['A Apple cuida de todos os pagamentos. Só sabemos se o Pro está ativo, nunca seus dados de pagamento.']),
             ('Estatísticas anônimas e relatórios de falhas',
              ['Para contar usuários, ver quais recursos são usados e corrigir falhas, o app envia dados anônimos ao Apple iCloud (CloudKit), que só o desenvolvedor pode ler:',
               'um ID aleatório criado na instalação (não vinculado a você, à sua conta Apple nem a outros apps; muda se você reinstalar), versão do app e do iOS, região e '
               'idioma, os dias em que o app foi aberto, os recursos usados (por exemplo, um padrão foi criado, um PDF foi exportado ou a tela de compra foi exibida) e detalhes '
               'de falhas.',
               'Nome, dados de contato, localização, fotos e padrões não são incluídos. Se você não estiver conectado ao iCloud, nada é enviado.']),
             ('Feedback', ['Se você enviar um feedback pelo app, recebemos o que escrever e, somente se você informar, seu e-mail para podermos responder.']),
             ('Sem rastreamento', ['Sem publicidade, sem análise de terceiros e sem rastreamento entre outros apps ou sites.']),
             ('Crianças', ['O Hantam é adequado para todas as idades. Não coletamos intencionalmente dados pessoais de crianças.']),
             ('Alterações', ['Se esta política mudar, publicaremos aqui a nova versão com uma nova data.'])],
 'terms': [('Uso do app', ['Ao usar o Hantam, você concorda com estes termos. Se não concordar, por favor, não use o app.']),
           ('O que o Hantam faz',
            ['O Hantam transforma fotos em padrões de miçangas de passar e de ponto cruz e inclui ferramentas de pixel art. As cores na tela são aproximadas e podem diferir dos '
             'produtos reais.']),
           ('Seu conteúdo',
            ['As fotos que você escolhe e os padrões que você cria são seus. Certifique-se de ter o direito de usar as fotos que transforma em padrões, principalmente se vender o '
             'que fizer.']),
           ('Hantam Pro',
            ['O Pro é vendido pela App Store da Apple como assinatura mensal ou anual com renovação automática, ou como acesso vitalício com pagamento único.',
             'As assinaturas são renovadas automaticamente, a menos que sejam canceladas pelo menos 24 horas antes do fim do período atual. A cobrança é feita na sua conta Apple '
             'nas 24 horas anteriores à renovação. Gerencie ou cancele nos ajustes da sua conta Apple.',
             'Se for oferecido um teste gratuito, a parte não utilizada termina quando você assina. Os reembolsos seguem a política da Apple.']),
           ('Regras', ['Não faça engenharia reversa do app nem o use para fins ilegais.']),
           ('Sem garantia',
            ['O app é fornecido no estado em que se encontra, sem garantias de qualquer tipo. Na medida permitida por lei, nossa responsabilidade se limita ao valor que você '
             'pagou pelo app.']),
           ('Marcas registradas',
            ['Perler, Hama, Artkal e DMC são marcas registradas de seus respectivos proprietários. O Hantam não é afiliado a essas empresas nem endossado por elas.']),
           ('Lei aplicável', ['Estes termos são regidos pelas leis da República da Coreia.'])],
 'dev': 'Desenvolvedor: Hyunho Lee'}

LANGS["th"] = "th/"
LANG_NAME["th"] = 'ไทย'
UPDATED["th"] = '18 ตุลาคม 2569'
STORE_LANG["th"] = "th"
T["th"] = {'brand': 'Hantam',
 'title': 'Hantam — แพตเทิร์นลูกปัดรีดและครอสติช',
 'desc': 'เปลี่ยนรูปถ่ายใดๆ ให้เป็นแพตเทิร์นลูกปัดรีดหรือครอสติชด้วยสีจริงของ Perler, Hama, Artkal และ DMC',
 'nav': ('หน้าแรก', 'ช่วยเหลือ', 'ความเป็นส่วนตัว', 'เงื่อนไข'),
 'hero_h': 'จากรูปใบเดียวเป็นแพตเทิร์น',
 'hero_p': 'เลือกรูปสัตว์เลี้ยง รูปตัวเอง หรือตัวละครที่ชอบ แล้ว Hantam จะเปลี่ยนเป็นแพตเทิร์นลูกปัดรีดหรือครอสติชด้วยสีที่หาซื้อได้จริง',
 'cta': 'ดาวน์โหลดบน App Store',
 'features': [('สีจริง', 'ลูกปัด Perler, Hama และ Artkal กับไหม DMC ทุกช่องแสดงเลขสีจริง'),
              ('รู้ว่าต้องซื้อเท่าไร', 'ดูว่าแต่ละสีต้องใช้ลูกปัดหรือเข็มกี่จุด และคัดลอกรายการซื้อของได้'),
              ('ทีละแผ่นบอร์ด', 'แพตเทิร์นใหญ่ถูกแบ่งเป็นแผ่นบอร์ด 29 × 29 พร้อมเส้นแบ่งหนา'),
              ('แก้ได้ทุกช่อง', 'แตะช่องเพื่อเปลี่ยน หรือเปลี่ยนสีหนึ่งเป็นอีกสีทั้งแพตเทิร์น'),
              ('พิมพ์แล้วทำเลย', 'ด้วย Pro ส่งออก PDF สำหรับพิมพ์ได้ ประกอบด้วยรายการสีและแพตเทิร์นสัญลักษณ์ทีละหน้า'),
              ('มีพิกเซลอาร์ตด้วย', 'เปลี่ยนรูปเป็นพิกเซลอาร์ต วาดตามตัวอย่าง 110 แบบ และทำแอนิเมชันทีละเฟรม')],
 'pro_h': 'Hantam Pro',
 'pro_p': 'เวอร์ชันฟรีทำแพตเทิร์นได้ไม่เกิน 1 แผ่นบอร์ด (หรือ 40 เข็ม) บันทึกได้ 3 แบบ และแชร์รูปที่มีเครื่องหมายเล็กๆ ส่วน Pro เพิ่ม PDF สำหรับพิมพ์ แพตเทิร์นสูงสุด 4 × 4 '
          'แผ่นบอร์ดหรือ 200 เข็ม บันทึกไม่จำกัด รูปที่ไม่มีเครื่องหมาย และเครื่องมือพิกเซลอาร์ตทั้งหมด เลือกสมัครรายเดือนหรือรายปี หรือจ่ายครั้งเดียวใช้ได้ตลอด',
 'tm': 'Perler, Hama, Artkal และ DMC เป็นเครื่องหมายการค้าของเจ้าของแต่ละราย Hantam ไม่มีส่วนเกี่ยวข้องกับบริษัทเหล่านี้',
 'support_h': 'ช่วยเหลือ',
 'support_p': 'ยินดีรับทั้งคำถาม การแจ้งปัญหา และไอเดีย วิธีที่เร็วที่สุดคือไปที่ การตั้งค่า › ส่งความคิดเห็น ในแอป หรืออีเมลหาเรา',
 'faq': [('กู้คืนการซื้อได้อย่างไร', 'เปิดการตั้งค่าในแอปแล้วแตะ กู้คืนการซื้อ โดยใช้บัญชี Apple เดียวกับที่ซื้อ Pro'),
         ('ยกเลิกการสมัครสมาชิกได้อย่างไร', 'ไปที่ การตั้งค่า iPhone › ชื่อของคุณ › การสมัครสมาชิก แล้วเลือก Hantam การซื้อแบบใช้ได้ตลอดเป็นการจ่ายครั้งเดียวและไม่ต่ออายุ'),
         ('สีดูต่างจากลูกปัดของฉันเล็กน้อย', 'หน้าจอแสดงสีต่างจากพลาสติกและเส้นไหมจริง แตะสีในรายการเพื่อเปลี่ยนเป็นสีที่ใกล้กว่าจากแบรนด์เดียวกัน'),
         ('แพตเทิร์นใหญ่ได้แค่ไหน', 'แพตเทิร์นฟรีอยู่ในแผ่นบอร์ด 29 × 29 หนึ่งแผ่น หรือด้านยาวสุด 40 เข็ม ส่วน Pro ได้สูงสุด 4 × 4 แผ่นบอร์ด (116 เม็ด) หรือ 200 เข็ม'),
         ('อัปโหลดรูปของฉันไหม', 'ไม่อัปโหลด รูปและแพตเทิร์นถูกประมวลผลและบันทึกใน iPhone ของคุณเท่านั้น')],
 'contact': 'ติดต่อเรา',
 'privacy_h': 'นโยบายความเป็นส่วนตัว',
 'terms_h': 'เงื่อนไขการใช้งาน',
 'updated': 'อัปเดตล่าสุด',
 'privacy': [('สรุป', ['รูปและแพตเทิร์นของคุณไม่เคยออกจาก iPhone เรารวบรวมเฉพาะสถิติแบบไม่ระบุตัวตนที่ไม่สามารถระบุว่าเป็นใคร']),
             ('รูปถ่าย', ['Hantam อ่านรูปเฉพาะเมื่อคุณเลือกเท่านั้น การแปลงเป็นแพตเทิร์นเกิดขึ้นบนอุปกรณ์ของคุณ', 'รูปจะไม่ถูกอัปโหลด เก็บไว้บนเซิร์ฟเวอร์ หรือแชร์ให้ใคร']),
             ('แพตเทิร์นที่คุณสร้าง', ['แพตเทิร์นถูกบันทึกในพื้นที่เก็บข้อมูลของแอปบน iPhone หากลบแอป แพตเทิร์นจะถูกลบไปด้วย']),
             ('การซื้อ', ['Apple จัดการการชำระเงินทั้งหมด เรารู้เพียงว่า Pro เปิดใช้งานอยู่หรือไม่ ไม่เคยได้รับรายละเอียดการชำระเงินของคุณ']),
             ('สถิติแบบไม่ระบุตัวตนและรายงานการหยุดทำงาน',
              ['เพื่อนับจำนวนผู้ใช้ ดูว่าฟีเจอร์ใดถูกใช้ และแก้ไขปัญหาแอปหยุดทำงาน แอปจะส่งข้อมูลแบบไม่ระบุตัวตนไปยัง Apple iCloud (CloudKit) '
               'ซึ่งมีเพียงนักพัฒนาเท่านั้นที่อ่านได้:',
               'รหัสสุ่มที่สร้างตอนติดตั้ง (ไม่เชื่อมโยงกับคุณ บัญชี Apple หรือแอปอื่น และเปลี่ยนไปเมื่อติดตั้งใหม่) เวอร์ชันของแอปและ iOS ภูมิภาคและภาษา วันที่เปิดแอป '
               'ฟีเจอร์ที่ใช้ (เช่น สร้างแพตเทิร์น ส่งออก PDF หรือแสดงหน้าจอการซื้อ) และรายละเอียดการหยุดทำงาน',
               'ไม่มีชื่อ ข้อมูลติดต่อ ตำแหน่งที่ตั้ง รูป หรือแพตเทิร์นรวมอยู่ด้วย หากไม่ได้ลงชื่อเข้าใช้ iCloud จะไม่มีการส่งข้อมูลใดๆ']),
             ('ความคิดเห็น', ['หากคุณส่งความคิดเห็นจากแอป เราจะได้รับข้อความที่คุณเขียน และอีเมลของคุณเฉพาะเมื่อคุณกรอกเอง เพื่อใช้ตอบกลับ']),
             ('ไม่มีการติดตาม', ['ไม่มีโฆษณา ไม่มีเครื่องมือวิเคราะห์ของบุคคลที่สาม และไม่มีการติดตามข้ามแอปหรือเว็บไซต์อื่น']),
             ('เด็ก', ['Hantam เหมาะกับทุกวัย เราไม่เก็บข้อมูลส่วนบุคคลของเด็กโดยเจตนา']),
             ('การเปลี่ยนแปลง', ['หากนโยบายนี้เปลี่ยนแปลง เราจะประกาศฉบับใหม่ที่นี่พร้อมวันที่ใหม่'])],
 'terms': [('การใช้แอป', ['การใช้ Hantam ถือว่าคุณยอมรับเงื่อนไขเหล่านี้ หากไม่ยอมรับ โปรดอย่าใช้แอป']),
           ('Hantam ทำอะไรได้บ้าง', ['Hantam เปลี่ยนรูปถ่ายเป็นแพตเทิร์นลูกปัดรีดและครอสติช และมีเครื่องมือพิกเซลอาร์ต สีบนหน้าจอเป็นเพียงสีที่ใกล้เคียง อาจต่างจากผลิตภัณฑ์จริง']),
           ('เนื้อหาของคุณ', ['รูปที่คุณเลือกและแพตเทิร์นที่คุณสร้างเป็นของคุณ โปรดตรวจสอบว่าคุณมีสิทธิ์ใช้รูปที่นำมาทำแพตเทิร์น โดยเฉพาะถ้าคุณขายผลงาน']),
           ('Hantam Pro',
            ['Pro จำหน่ายผ่าน App Store ของ Apple ทั้งแบบสมัครสมาชิกรายเดือนหรือรายปีที่ต่ออายุอัตโนมัติ และแบบจ่ายครั้งเดียวใช้ได้ตลอด',
             'การสมัครสมาชิกจะต่ออายุอัตโนมัติ เว้นแต่จะยกเลิกก่อนสิ้นสุดรอบปัจจุบันอย่างน้อย 24 ชั่วโมง โดยเรียกเก็บเงินจากบัญชี Apple ของคุณภายใน 24 ชั่วโมงก่อนต่ออายุ '
             'จัดการหรือยกเลิกได้ในการตั้งค่าบัญชี Apple',
             'หากมีการให้ทดลองใช้ฟรี ส่วนที่ยังไม่ได้ใช้จะสิ้นสุดเมื่อคุณสมัครสมาชิก การคืนเงินเป็นไปตามนโยบายของ Apple']),
           ('กฎ', ['ห้ามย้อนวิศวกรรมแอป หรือนำไปใช้ในทางผิดกฎหมาย']),
           ('ไม่มีการรับประกัน', ['แอปให้บริการตามสภาพ โดยไม่มีการรับประกันใดๆ ภายในขอบเขตที่กฎหมายอนุญาต ความรับผิดของเราจำกัดเพียงจำนวนเงินที่คุณชำระสำหรับแอป']),
           ('เครื่องหมายการค้า', ['Perler, Hama, Artkal และ DMC เป็นเครื่องหมายการค้าของเจ้าของแต่ละราย Hantam ไม่มีส่วนเกี่ยวข้องและไม่ได้รับการรับรองจากบริษัทเหล่านี้']),
           ('กฎหมายที่ใช้บังคับ', ['เงื่อนไขเหล่านี้อยู่ภายใต้กฎหมายของสาธารณรัฐเกาหลี'])],
 'dev': 'นักพัฒนา: Hyunho Lee'}

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
    alt += f'\n<link rel="alternate" hreflang="en-GB" href="{BASE}{LANGS["en"]}{name}">'  # en-GB 는 영어 페이지를 같이 쓴다
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
    store_lang = STORE_LANG.get(lang, "en-US")
    if not (ROOT / "screenshots" / "marketing" / store_lang).exists():
        store_lang = "en-US"  # 아직 스크린샷이 없는 언어는 영어 그림을 쓴다
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
