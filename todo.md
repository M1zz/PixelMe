# 한땀 TODO

## 아이폰 듀오 대응 (2026-10-31, 듀오 시뮬레이터 빌드 · `-FoldPretend` 화면 확인 · 실기기 확인 안 함)
- [x] 앱 루트에 `.foldAware()` (LeeoKit Fold). 시트 · 알림창이 접힌 선을 비킨다
- [x] 홈: 펴면 고르는 쪽(가로면 왼쪽, 세로면 아래)에 홈, 결과 쪽(오른쪽, 위)에 내 도안(고른 것, 없으면 가장 최근). 도안이 없으면 세 걸음 안내 (`CreatorContentView.homeResultPane`)
- [x] 새 도안: 고르는 쪽에 재료 · 크기 · 색 · 배경, 결과 쪽에 판을 가득 채운 미리보기 (`PatternMakerView`)
- [x] 도안 보기: 고르는 쪽에 보기 · 붓 · 내보내기 · 색 목록, 결과 쪽에 도안 판. 칸 크기는 화면 폭이 아니라 판 크기로 잰다 (`PatternDetailView.chart(fit:)`)
- [x] 픽셀 아트 도구 · 온보딩 전체 화면은 `.foldConfined()`, 글자만 있던 툴바 버튼(취소 · 완료 · 고치기)에 아이콘
- [ ] 가로로 편 화면 · 실기기 확인, 결과 쪽 도안 판을 가운데에 세울지
- [ ] ⚠️ Xcode 27.0 빌드는 듀오에서 호환 틀(아이폰 크기)로 뜬다. 27.1 로 빌드해야 펼친 배치가 켜진다
- 확인: 듀오 시뮬레이터에 Debug 빌드 → `xcrun simctl launch <기기> com.leeo.PixelMe -FoldPretend` (도안 장면은 `-HantamScene detail -HantamDemoPhoto <사진>`)
