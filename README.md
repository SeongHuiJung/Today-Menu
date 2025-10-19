# 모모찌 (TodayMenu)

> 사용자의 선호도, 최근 먹은 음식, 리뷰 데이터를 분석하여  
> 음식을 추천해주는 서비스


<br>


## 프로젝트 소개

모모찌는 **Aging 가중치 알고리즘**을 활용하여 사용자의 음식 선호도와 섭취 이력을 기반으로  
개인 맞춤 음식을 추천하는 iOS 앱입니다.

단순한 기록을 넘어, 사용자가 **무엇을 먹을지 고민하는 시간을 줄이고**  
**사용자의 취향, 최근 먹은 음식에 맞는 음식**을 추천합니다.

<br>

## 제작 기간

**2024.09 ~ 2024.10 (1개월)**  
개인 프로젝트

<br>



## 주요 기능

| 개인 맞춤 메뉴 추천 | 식사 기록 달력 | 음식 카테고리 필터링 | 위치 기반 식당 조회 | 차트 기반 식당 리포트 |
|:---:|:---:|:---:|:---:|:---:|
| <img width="1173" height="2543" alt="Image" src="https://github.com/user-attachments/assets/f007fdea-082a-4191-8665-9986b7a7d148" /> | <img width="1172" height="2547" alt="Image" src="https://github.com/user-attachments/assets/b891d17a-74de-4d4d-bfd5-25a6098a4285" /> | <img width="1153" height="2506" alt="Image" src="https://github.com/user-attachments/assets/3962be99-be49-4f45-a969-90e9c2eb85d5" /> | <img width="1153" height="2507" alt="Image" src="https://github.com/user-attachments/assets/62c42512-5cde-4b16-a797-46be38b98088" />  | <img width="1173" height="2541" alt="Image" src="https://github.com/user-attachments/assets/17b63a9f-76be-471e-a1ba-e4b8abab8dee" /> |
| 사용자의 선호도와 리뷰 데이터를 분석하여 취향에 맞는 음식을 추천 | 먹은 음식을 달력 형태로 시각화하여 식습관 파악 | 한식/중식/일식/양식 등 카테고리별 음식을 선택하여 시각화 | 주변 식당을 조회하고, 방문 식당 리뷰를 기록 | 카테고리별 섭취 비율을 동적 애니메이션인 원형차트로 시각화 |



<br>

## 핵심 기술

### 1. Aging 가중치 알고리즘을 활용한 음식 추천
**단순 빈도 기반 추천에서 시간·평점·행동을 다층 평가하는 알고리즘으로 전환**

- 섭취하지 오래된 음식일수록 추천 확률이 점진적으로 상승하는 **Aging 메커니즘** 구현
- Accept/Skip 이력, 평균 평점, 최근 섭취일을 각각 차등 가중치로 적용
- 가중치 기반 확률적 선택으로 **예측 불가능성을 제공**하면서도 사용자 선호도 반영
- 단순 빈도 기반 LRU 알고리즘 대비 **사용자 만족도 향상** 및 **음식 다양성 확보**

<br>

### 2. 용도별 멀티 사이즈 이미지 최적화 시스템 구축
**고해상도 이미지 과다 로드로 인한 메모리 부족 해결**

- 지도 마커 100개 표시 시 250MB 메모리 소비로 앱 크래시 및 스크롤 지연(45fps) 문제 발생
- 화면 용도별 최적 사이즈 분석 후 **40/60/200px 3가지 버전으로 자동 리사이징 및 분리 저장**
- UIGraphicsImageRenderer 활용 고품질 렌더링 + 비율 유지 알고리즘 구현
- **메모리 95% 절감**(250MB→1MB), **렌더링 속도 97% 향상**, FPS 45→60 달성

<br>

### 3. 테스트 가능한 클린 아키텍처 설계 및 의존성 관리
**RxSwift + Protocol DI로 결합도 최소화 및 테스트 커버리지 확보**

- **Protocol 기반 Dependency Injection**으로 구체 타입 의존성 제거 및 Mock 객체 주입 가능한 구조 설계
- **Input/Output 패턴**으로 ViewModel 인터페이스를 명확히 정의하여 단방향 데이터 흐름 구현
- **Dependency Inversion Principle(DIP)** 적용으로 상위 레벨이 하위 레벨 구현에 의존하지 않도록 추상화
- Driver를 활용한 메인 스레드 보장 및 에러 핸들링 자동화로 안정적인 UI 업데이트

<br>

### 4. Back Ease Out 애니메이션 회전형 원형 차트 구현

**30프레임 키프레임 애니메이션으로 오버슈트 효과 구현**

- Robert Penner의 표준 Back Ease Out 공식 적용으로 탄성 있는 회전 애니메이션 구현
- 외적(Cross Product) 계산 기반 회전 방향 감지로 정확한 제스처 인식
- 최단 경로 알고리즘으로 360도 순환 최적화 및 불필요한 회전 방지
- RxSwift PublishSubject로 선택 이벤트를 Observable 스트림으로 방출하여 ViewModel과 느슨한 결합

<br>

## 기술 스택

### Environment
![iOS](https://img.shields.io/badge/iOS-16.0+-000000?style=flat-square&logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat-square&logo=swift&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-15.0-147EFB?style=flat-square&logo=xcode&logoColor=white)

### Architecture
![MVVM](https://img.shields.io/badge/MVVM-Architecture-6DB33F?style=flat-square)
![RxSwift](https://img.shields.io/badge/RxSwift-6.9.0-B7178C?style=flat-square)
![Input/Output](https://img.shields.io/badge/Input%2FOutput-Pattern-orange?style=flat-square)

### Network & Data
![Alamofire](https://img.shields.io/badge/Alamofire-5.10.2-EF2D5E?style=flat-square)
![Realm](https://img.shields.io/badge/Realm-20.0.3-39477F?style=flat-square&logo=realm&logoColor=white)
![Kingfisher](https://img.shields.io/badge/Kingfisher-8.5.0-FFA500?style=flat-square)

### UI/UX
![UIKit](https://img.shields.io/badge/UIKit-CodeBased-2396F3?style=flat-square)
![SnapKit](https://img.shields.io/badge/SnapKit-5.7.1-000000?style=flat-square)


### CI/CD
![Xcode Cloud](https://img.shields.io/badge/Xcode%20Cloud-CI%2FCD-147EFB?style=flat-square&logo=xcode&logoColor=white)

### Framework
![MapKit](https://img.shields.io/badge/MapKit-Location-34C759?style=flat-square&logo=apple&logoColor=white)
![CoreLocation](https://img.shields.io/badge/CoreLocation-GPS-007AFF?style=flat-square)

### Library
![IQKeyboardManager](https://img.shields.io/badge/IQKeyboardManager-8.0.1-4A90E2?style=flat-square)
![FSCalendar](https://img.shields.io/badge/FSCalendar-2.8.4-FF6B6B?style=flat-square)
![Toast](https://img.shields.io/badge/Toast-5.1.1-FFA500?style=flat-square)

### etc.
![Kakao API](https://img.shields.io/badge/Kakao-Place%20API-FFCD00?style=flat-square&logo=kakao&logoColor=black)


## AppSotre 링크
[AppSotre 바로가기](https://apps.apple.com/kr/app/모모찌-오늘-뭐-먹지/id6753621374)
