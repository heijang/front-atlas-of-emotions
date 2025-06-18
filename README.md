## 감정도감 프론트

### 서버 실행
flutter run -d chrome

## 환경변수 설정

1. `/ENV/.env_example` 파일을 참고해서
2. `/ENV/.env` 파일을 생성하고, 환경에 맞게 값을 수정하세요.

예시:
```
API_BASE_URL=http://localhost:8000
WS_BASE_URL=ws://localhost:8000
```

.env 파일은 git에 올라가지 않으니(보안/환경 분리 목적),
각 개발자/서버 환경에 맞게 직접 생성해야 합니다.