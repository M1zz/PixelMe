# 한땀 (Hantam) — 비즈·십자수 도안 메이커

사진 한 장을 아이롱 비즈·십자수 도안으로 바꾸는 iOS 앱.
번들 ID `com.leeo.PixelMe` · 상품 ID · FeedbackHub `appName`("PixelMe") 은 기존 사용자·통계와의 계약이라 그대로 둔다.

## 무엇을 하나
- 사진 → Perler · Hama Midi · Artkal S 비즈, DMC 실 색표의 가장 가까운 색으로 도안 (`Hantam/Pattern/`)
- 색 수 상한, 크기(비즈 29×29 보드 단위 / 십자수 칸), 배경 지우기, 칸 고치기, 색 통째로 바꾸기
- 실물 · 색 · 기호 보기, 색마다 개수, 구매 목록 복사, 인쇄용 PDF(보드·쪽마다 나눈 기호 도안)
- 기존 픽셀 아트 도구(사진 픽셀화, 따라 그리기, 에디터·애니메이션)는 홈 아래 '픽셀 아트 도구'

## 무료 / Plus / Pro
| | 무료 | Plus | Pro |
|---|---|---|---|
| 도안 크기 | 비즈 보드 1장(29) · 십자수 40칸 | 보드 4×4(116) · 200칸 | 보드 4×4(116) · 200칸 |
| 저장 | 3개 | 무제한 | 무제한 |
| 이미지 | 한땀 표시 | 표시 없음 | 표시 없음 |
| 픽셀 아트 칸 크기 · 팔레트 · 디더링 · 필터 | 기본 | 전부 | 전부 |
| 인쇄용 PDF | — | — | ✅ |
| 전후 영상 문구 없이 · 필터 팩 3종 | — | — | ✅ |

판매(2026-11부터 무료 다운로드): 칸마다 주 · 월 · 연 자동 갱신 구독(한 구독 그룹, Pro 가 위 단계)과 평생, Plus 평생 → Pro 올리기, 구독 졸업 Pro 평생.
상품 ID 와 칸은 `HantamPlan` (`Manager/SubscriptionManager.swift`), 시험용 상품은 `Hantam/Hantam.storekit`(스킴에 연결).
Pro 월 · 연 · 평생은 2.1.x 의 `com.hantam.pro.monthly` · `com.hantam.pro.yearly` · `com.pixelme.pro.lifetime` 을 그대로 잇는다.
예전 `com.pixelme.pro.weekly·monthly·yearly` · `PixelNFT.Premium` 은 팔지 않고 산 사람만 Pro 로 인정.
유료 다운로드(₩6,600) 시절에 받은 사람(처음 받은 빌드 5 이하)은 Pro 평생(`AppConfig.lastPaidDownloadBuild`).
결제 화면을 띄운 계기는 `paywall_shown.<reason>` 으로 FeedbackHub 에 남는다 (`HantamAnalytics`).

## 개발
- 테스트: `HantamTests/PatternEngineTests.swift` (scheme 에 포함, `Scripts/predeploy.sh` 가 돌린다)
- 색표 원본: [beadcolors](https://github.com/maxcleme/beadcolors) (MIT), [DMC-ColorCodes](https://github.com/nathantspencer/DMC-ColorCodes)
- 스토어 그림: `sh Scripts/capture_screens.sh <Debug .app>` → `python3 Scripts/make_marketing_screenshots.py` → `python3 Scripts/make_creative_assets.py`
- 웹 페이지(en 루트 · ko · ja): `python3 Scripts/make_site.py`
- 스토어 문구 `APPSTORE.md`, 릴리즈 노트 `RELEASE_NOTES.md` — 배포는 DeployBar 가 한다.
