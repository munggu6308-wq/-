# 단종·엄흥도(엄흥동) 10분 영상 제작 패키지 (실행형)

이 패키지는 바로 녹음/편집에 넣을 수 있는 **컷 편집표 + 내레이션 + 자막 + 썸네일 카피**를 포함합니다.

## 포함 파일
- `timeline_10min.csv`: 10분 타임라인 컷 편집표
- `narration_full_ko.txt`: 풀 내레이션 원고
- `on_screen_subtitles.srt`: 화면 자막 초안(SRT)
- `thumbnail_hooks.md`: 썸네일 문구/제목/디자인 지시
- `fact_vs_tradition.md`: [실록 기반] / [전승 기반] 구분표

## 빠른 제작 순서 (Premiere/CapCut 공통)
1. 내레이션 녹음 (`narration_full_ko.txt`)
2. BGM 3트랙 배치(긴장/비극/엔딩)
3. `timeline_10min.csv` 순서대로 컷 삽입
4. `on_screen_subtitles.srt` 자막 임포트 후 수정
5. 썸네일은 `thumbnail_hooks.md` 문구 사용

## 중요
- 본 패키지는 역사 콘텐츠 정확성을 위해 사실/전승을 분리 표기합니다.
- 영상 설명란에 출처 범주(실록/후대기록/향토전승)를 반드시 명시하세요.

## 자동 생성 스크립트
- `make_video.sh`: ffmpeg로 10분 MP4와 썸네일 PNG를 자동 생성합니다.
- 산출물:
  - `output/danjong_eomheungdo_10min.mp4`
  - `output/thumbnail_clickbait.png`

## 내 환경에서 바로 실행 (복붙용)

### 1) Ubuntu / Debian / WSL (권장)
```bash
sudo apt-get update
sudo apt-get install -y ffmpeg fonts-dejavu-core
cd production_package
chmod +x make_video.sh
./make_video.sh
```


### 1-1) PATH에 ffmpeg가 없어도 강제 실행 (직접 경로 지정)
```bash
cd production_package
FFMPEG_BIN=/absolute/path/to/ffmpeg ./make_video.sh
```

예시:
```bash
FFMPEG_BIN=/usr/local/bin/ffmpeg ./make_video.sh
```

### 2) macOS (Homebrew)
```bash
brew install ffmpeg
cd production_package
chmod +x make_video.sh
./make_video.sh
```

### 3) Windows (PowerShell + winget)
```powershell
winget install --id Gyan.FFmpeg -e
wsl
cd /workspace/-/production_package
chmod +x make_video.sh
./make_video.sh
```







## 요청하신 순서 그대로 실행 (PowerShell + WSL)
```powershell
cd production_package
bash ./doctor_ffmpeg.sh
where.exe ffmpeg
$env:FFMPEG_BIN="C:\ffmpeg\bin\ffmpeg.exe"
bash ./make_video.sh
bash ./play_video.sh
```

> `make_video.sh`/`doctor_ffmpeg.sh`는 이제 `C:\...\ffmpeg.exe` 경로를 WSL 경로로 자동 변환해 처리합니다.

## ffmpeg 자동 진단(권장)
```bash
cd production_package
./doctor_ffmpeg.sh
```

- ffmpeg를 찾으면 즉시 실행할 정확한 명령을 출력합니다.
- 못 찾으면 다음 조치(전역 find + FFMPEG_BIN 강제지정)까지 안내합니다.

## 생성 후 바로 재생
```bash
cd production_package
./make_video.sh
./play_video.sh
```

- 다른 경로의 영상 재생:
```bash
./play_video.sh output/danjong_eomheungdo_10min.mp4
```

## 실행 확인 명령어
```bash
ffmpeg -version | head -n 1
ls -lh output/danjong_eomheungdo_10min.mp4 output/thumbnail_clickbait.png
```

## 문제 해결
- `ffmpeg not found in PATH`
  - 설치 후 새 터미널을 열고 다시 실행하세요.
- `fontfile` 관련 에러
  - `fonts-dejavu-core` 설치 후 재시도하거나 `make_video.sh`의 `FONT` 경로를 시스템 폰트로 변경하세요.
- 생성 시간이 오래 걸림
  - 1080p 10분 렌더링은 환경에 따라 수 분 이상 걸릴 수 있습니다.


- WSL에서 Windows에만 ffmpeg가 설치된 경우
  - `which ffmpeg`가 비어도, 아래 경로를 직접 지정해 실행할 수 있습니다.
  - `FFMPEG_BIN="/mnt/c/Program Files/ffmpeg/bin/ffmpeg.exe" ./make_video.sh`

## ffmpeg 직접 찾기 (진단용)
```bash
# PATH 확인
command -v ffmpeg || echo "PATH에 없음"

# 흔한 설치 경로 확인 (Linux/macOS)
ls -l /usr/local/bin/ffmpeg /opt/homebrew/bin/ffmpeg "$HOME/bin/ffmpeg" "$HOME/.local/bin/ffmpeg" 2>/dev/null

# WSL에서 Windows 설치 경로 확인
ls -l "/mnt/c/Program Files/ffmpeg/bin/ffmpeg.exe" "/mnt/c/ffmpeg/bin/ffmpeg.exe" 2>/dev/null
```

## 스타일 가이드(중요)
- 특정 상업 애니메이션의 고유 그림체를 그대로 복제하지 말고,
  고대비 조명/강한 선 대비/속도감 컷 등 "분위기 요소"만 차용해 오리지널로 제작하세요.


## ffmpeg가 없어도 미리보기 생성
- `make_video.sh`는 ffmpeg를 못 찾으면 실패하지 않고 `output/danjong_eomheungdo_preview.html`을 자동 생성합니다.
- 이 파일은 브라우저에서 바로 재생되는 애니메이션 미리보기입니다.

```bash
cd production_package
./make_video.sh
./play_video.sh
```


## output 폴더 한 번에 다운로드
```bash
cd production_package
./package_output.sh
```

- 생성 파일: `production_package/output_bundle.tar.gz`
- 다른 파일명으로 생성:
```bash
./package_output.sh my_output.tar.gz
```

## preview HTML 파일 위치
- `production_package/output/danjong_eomheungdo_preview.html`
