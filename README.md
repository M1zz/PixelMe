# 한땀 (Hantam) — 비즈·십자수 도안 메이커

사진 한 장을 아이롱 비즈·십자수 도안으로 바꾸는 iOS 앱.
번들 ID `com.leeo.PixelMe` · 상품 ID · FeedbackHub `appName`("PixelMe") 은 기존 사용자·통계와의 계약이라 그대로 둔다.

## 무엇을 하나
- 사진 → Perler · Hama Midi · Artkal S 비즈, DMC 실 색표의 가장 가까운 색으로 도안 (`Hantam/Pattern/`)
- 색 수 상한, 크기(비즈 29×29 보드 단위 / 십자수 칸), 배경 지우기, 칸 고치기, 색 통째로 바꾸기
- 실물 · 색 · 기호 보기, 색마다 개수, 구매 목록 복사, 인쇄용 PDF(보드·쪽마다 나눈 기호 도안)
- 기존 픽셀 아트 도구(사진 픽셀화, 따라 그리기, 에디터·애니메이션)는 홈 아래 '픽셀 아트 도구'

## 무료 / Pro
| | 무료 | Pro |
|---|---|---|
| 도안 크기 | 비즈 보드 1장(29) · 십자수 40칸 | 보드 4×4(116) · 200칸 |
| 인쇄용 PDF | — | ✅ |
| 저장 | 3개 | 무제한 |
| 이미지 | 한땀 표시 | 표시 없음 |

판매: 앱 다운로드 ₩6,600(유료) · 월 ₩6,600(`com.hantam.pro.monthly`) · 연 ₩44,000(`com.hantam.pro.yearly`) · 평생 ₩77,000(`com.pixelme.pro.lifetime`). 예전 `com.pixelme.pro.weekly·monthly·yearly` 는 팔지 않고 산 사람만 Pro 로 인정.
결제 화면을 띄운 계기는 `paywall_shown.<reason>` 으로 FeedbackHub 에 남는다 (`HantamAnalytics`).

## 개발
- 테스트: `HantamTests/PatternEngineTests.swift` (scheme 에 포함, `Scripts/predeploy.sh` 가 돌린다)
- 색표 원본: [beadcolors](https://github.com/maxcleme/beadcolors) (MIT), [DMC-ColorCodes](https://github.com/nathantspencer/DMC-ColorCodes)
- 스토어 그림: `sh Scripts/capture_screens.sh <Debug .app>` → `python3 Scripts/make_marketing_screenshots.py` → `python3 Scripts/make_creative_assets.py`
- 웹 페이지(en 루트 · ko · ja): `python3 Scripts/make_site.py`
- 스토어 문구 `APPSTORE.md`, 릴리즈 노트 `RELEASE_NOTES.md` — 배포는 DeployBar 가 한다.
