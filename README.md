# PixelMe - Premium Pixel Art Creator 🎨

<img src="appstore.png" width="200" alt="PixelMe App Icon">

## 🚀 프로젝트 개요

PixelMe는 이제 **$4.99-$9.99 프리미엄 앱**으로서 경쟁력을 갖춘 전문 픽셀 아트 생성 앱입니다.

### ✨ 새롭게 추가된 8가지 프리미엄 기능

1. **🎨 색상 팔레트 시스템** - GameBoy, NES, SNES, Vaporwave, Cyberpunk 등 9가지 팔레트
2. **🤖 AI 색상 축소 & 디더링** - 3가지 디더링 알고리즘 (Floyd-Steinberg, Atkinson, Ordered)
3. **📺 필터 효과** - CRT, 스캔라인, 글리치, VHS, 아케이드, 빈티지 6가지 필터
4. **📦 배치 처리** - 여러 이미지를 한 번에 처리
5. **💾 고급 내보내기** - PNG, SVG, PDF 포맷 지원, 4K 해상도까지
6. **📐 템플릿 & 프리셋** - NFT 아바타, 게임 스프라이트, 프로필 사진 등 15+ 템플릿
7. **🎬 GIF 애니메이션** - 픽셀 아트 GIF 생성 (progressive, glitch, color cycle)
8. **🎭 레이어 시스템** - 다중 레이어, 12가지 블렌드 모드, 전문가급 편집

---

## 📂 프로젝트 구조

```
PixelMe/
├── Manager/
│   ├── DataManager.swift          ✅ 업데이트됨 - 메인 관리자
│   ├── ColorPalette.swift         ✅ 신규 - 색상 팔레트
│   ├── ColorReduction.swift       ✅ 신규 - AI 색상 축소 & 디더링
│   ├── FilterEffects.swift        ✅ 신규 - 레트로 필터
│   ├── BatchProcessor.swift       ✅ 신규 - 배치 처리
│   ├── ExportManager.swift        ✅ 신규 - 고급 내보내기
│   ├── TemplateManager.swift      ✅ 신규 - 템플릿 & 프리셋
│   ├── GIFCreator.swift          ✅ 신규 - GIF 생성
│   └── LayerManager.swift         ✅ 신규 - 레이어 시스템
├── CreatorContentView.swift       🔄 UI 업데이트 필요
├── PixelatedPhotoView.swift       🔄 UI 업데이트 필요
├── FEATURES.md                    📖 전체 기능 설명서
├── IMPLEMENTATION_GUIDE.md        📖 구현 가이드
└── README.md                      📖 이 파일
```

---

## 🎯 빠른 시작

### 1. 기본 사용법

```swift
// DataManager를 통해 모든 기능 접근
@EnvironmentObject var manager: DataManager

// 이미지 선택
manager.selectedImage = myImage

// 프리셋 적용 (가장 쉬운 방법!)
let preset = EffectPreset.presets[2] // Vaporwave Aesthetic
manager.applyPreset(preset)

// 또는 수동으로 설정
manager.selectedColorPalette = .vaporwave
manager.ditheringType = .floydSteinberg
manager.filterEffect = .crt
manager.filterIntensity = 0.8

// 효과 적용
manager.applyPixelEffect()

// 결과 이미지는 manager.pixelatedImage에 저장됨
```

### 2. 배치 처리

```swift
// 여러 이미지 처리
let config = BatchProcessingConfig(
    pixelSize: .normal,
    colorPalette: .gameboy,
    filterEffect: .scanlines
)

manager.batchProcessor.processBatch(images: images, config: config) { results in
    print("완료: \(results.count)개 이미지")
}
```

### 3. GIF 생성

```swift
// Progressive pixelation GIF
manager.gifCreator.createProgressivePixelationGIF(
    from: image,
    frameCount: 10
) { url in
    print("GIF 생성 완료: \(url)")
}
```

---

## 💰 수익화 전략

### 가격 설정 추천

- **론칭 가격**: $4.99 (Early Bird)
- **정상 가격**: $7.99
- **프리미엄 가격**: $9.99 (모든 기능 + 평생 업데이트)

### 경쟁사 비교

| 앱 | 가격 | 기능 | 플랫폼 |
|---|------|------|--------|
| Pixaki | $26.99 | 제한적 | iPad만 |
| Aseprite | $19.99 | 데스크톱용 | PC/Mac |
| Pixel Studio | $9.99 | 기본 기능 | 모바일 |
| **PixelMe** | **$4.99-$9.99** | **8가지 프리미엄 기능** | **iPhone/iPad** |

### 예상 수익 (보수적)

- **1,000 다운로드/월** × **5% 전환율** × **$4.99** = **$250/월**
- **10,000 다운로드/월** × **7% 전환율** × **$7.99** = **$5,593/월**
- **50,000 다운로드/월** × **10% 전환율** × **$9.99** = **$49,950/월**

---

## 🎨 주요 기능 상세

### 1. 색상 팔레트 (9가지)

- **GameBoy** - 클래식 초록색 4색
- **NES** - 닌텐도 32색 팔레트
- **SNES** - 슈퍼 닌텐도 16색
- **Vaporwave** - 핑크/퍼플/시안 8색
- **Cyberpunk** - 네온 컬러 8색
- **Pastel** - 부드러운 파스텔 8색
- **8-Bit Retro** - Pico-8 스타일 16색
- **Film Noir** - 흑백 9색
- **Original** - 원본 색상 유지

### 2. 디더링 알고리즘 (3가지)

- **Floyd-Steinberg** - 부드러운 그라데이션, 사진에 최적
- **Atkinson** - 레트로 Mac 스타일, 일러스트에 최적
- **Ordered (Bayer)** - 패턴 기반, 인쇄물에 최적

### 3. 필터 효과 (6가지)

- **CRT Monitor** - 옛날 TV 효과
- **Scanlines** - 가로줄 효과
- **Glitch** - RGB 분리 글리치
- **Vintage Game** - 오래된 게임 콘솔 느낌
- **VHS Tape** - 90년대 비디오 아티팩트
- **Arcade Screen** - 아케이드 게임기 화면

### 4. 템플릿 (15+)

**프로필 사진**
- Square Profile (512x512)
- Circle Profile (512x512)
- Rounded Profile (512x512)

**NFT 아바타**
- Punk Style (24x24)
- Ape Style (16x16)
- Doodle Style (12x12)

**게임 스프라이트**
- Character (16x16)
- Item (8x8)
- Enemy (32x32)

**소셜 미디어**
- Twitter/X Banner (1500x500)
- YouTube Banner (2560x1440)
- Discord Banner (960x540)

### 5. 프리셋 (8가지)

원클릭으로 완벽한 스타일 적용:
- GameBoy Classic
- NES Retro
- Vaporwave Aesthetic
- Cyberpunk Neon
- Pastel Dream
- Arcade Cabinet
- Film Noir
- VHS Tape

---

## 📱 다음 단계

### 1. UI 구현하기

`IMPLEMENTATION_GUIDE.md`를 참고하여 UI 구현:
- 색상 팔레트 선택기
- 필터 효과 선택기
- 프리셋 브라우저
- 배치 처리 화면
- GIF 생성 화면
- 레이어 에디터

### 2. 앱스토어 준비

- [ ] 앱 아이콘 디자인
- [ ] 스크린샷 5-10장 준비
- [ ] 프리뷰 비디오 제작 (선택)
- [ ] 앱 설명 작성
- [ ] 키워드 리서치
- [ ] 가격 설정

### 3. 마케팅

**소셜 미디어**
- TikTok/Instagram Reels: Before/After 영상
- Twitter/X: NFT 커뮤니티 타겟팅
- Reddit: r/PixelArt, r/NFT

**론칭 플랫폼**
- Product Hunt
- Hacker News (Show HN)
- IndieHackers

---

## 📚 문서

- **FEATURES.md** - 전체 기능 상세 설명 및 API 문서
- **IMPLEMENTATION_GUIDE.md** - UI 구현 가이드 및 코드 예제
- **README.md** - 이 파일 (프로젝트 개요)

---

## 🎯 타겟 고객

1. **NFT 크리에이터** - 아바타 컬렉션 생성
2. **게임 개발자** - 스프라이트 에셋 제작
3. **소셜 미디어 인플루언서** - 독특한 프로필 사진
4. **픽셀 아트 애호가** - 취미 및 전문가
5. **레트로 게임 팬** - 향수를 불러일으키는 효과

---

## 🔧 기술 스택

- **Swift 5.0+**
- **SwiftUI** - 모던 UI
- **UIKit** - 이미지 처리
- **Core Image** - 필터 및 효과
- **ImageIO** - GIF 생성
- **Combine** - 반응형 업데이트

**성능 최적화**
- 백그라운드 처리
- 진행 상황 추적
- 메모리 효율적
- 빠른 렌더링

---

## 📊 예상 성과

### 6개월 목표

- **다운로드**: 50,000+
- **전환율**: 7-10%
- **월 수익**: $3,000-$5,000
- **평점**: 4.5+ ⭐

### 1년 목표

- **다운로드**: 200,000+
- **전환율**: 10%+
- **월 수익**: $15,000-$20,000
- **평점**: 4.7+ ⭐

---

## ✅ 구현 완료된 기능

- ✅ 색상 팔레트 시스템 (9개)
- ✅ AI 색상 축소 & 디더링 (3가지 알고리즘)
- ✅ 필터 효과 (6가지)
- ✅ 배치 처리
- ✅ 고급 내보내기 (PNG/SVG/PDF, 4K)
- ✅ 템플릿 & 프리셋 (15+ 템플릿, 8 프리셋)
- ✅ GIF 애니메이션 생성
- ✅ 레이어 시스템 (12 블렌드 모드)

**모든 백엔드 로직 완성! 이제 UI만 구현하면 됩니다!** 🎉

---

## 🚀 빌드 & 실행

```bash
# Xcode에서 프로젝트 열기
open PixelMe.xcodeproj

# 빌드 & 실행
Cmd + R
```

---

## 📞 지원

문의사항이나 이슈가 있으면:
- FEATURES.md - 상세 API 문서
- IMPLEMENTATION_GUIDE.md - 구현 가이드
- 각 클래스에 인라인 주석 포함

**행운을 빕니다! 🚀 유료 앱 런칭 성공하세요!** 💰
