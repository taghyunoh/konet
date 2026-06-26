# konet Git 관리 가이드 (pull / push)

> 대상 저장소: `https://github.com/taghyunoh/konet.git` (Private)
> 로컬 경로: `C:\Users\HYUN\git\konet`
> 작업 폴더: `C:\Users\HYUN\git\konet\konet_web`

konet 은 CLI(명령어)로 동기화를 관리합니다.
**받기(pull)** 와 **올리기(push)** 는 목적이 다릅니다.

---

## 📥 받기 (pull) — 작업 *시작 전*

원격(GitHub)의 최신 내용을 내 PC로 **가져옵니다**. 다른 PC에서 올린 변경을 받을 때 사용.

```powershell
git -C C:\Users\HYUN\git\konet pull
```

> 작업을 **시작할 때 한 번** 실행. (다른 PC 작업분을 먼저 받아 충돌 예방)

---

## 📤 올리기 (commit + push) — 작업 *끝난 후*

내가 수정한 내용을 **저장(commit)** 하고 원격으로 **전송(push)** 합니다. 3단계가 한 묶음.

```powershell
git -C C:\Users\HYUN\git\konet add -A                  # ① 변경파일 전체 선택(스테이징)
git -C C:\Users\HYUN\git\konet commit -m "작업 내용"     # ② 로컬 저장(메시지 필수)
git -C C:\Users\HYUN\git\konet push origin main          # ③ GitHub로 전송
```

> 작업을 **끝낼 때** ① → ② → ③ 순서대로 실행.

---

## 정리

| 구분 | 명령 | 시점 |
|---|---|---|
| **받기** | `pull` | 작업 **전** (1줄) |
| **올리기** | `add` → `commit` → `push` | 작업 **후** (3줄) |

- `add`, `commit` 은 **로컬**(내 PC)에만 저장 → 아직 GitHub엔 없음
- `push` 까지 해야 **GitHub에 반영**됨
- `pull` 은 받기 전용 — 올릴 땐 관여 안 함

**한 줄 요약**: 시작할 때 `pull`, 끝낼 때 `add → commit → push`.

---

## 자주 쓰는 보조 명령

```powershell
# 현재 상태 확인 (로컬 vs 원격, 변경 파일)
git -C C:\Users\HYUN\git\konet status -sb

# 최근 커밋 5개 보기
git -C C:\Users\HYUN\git\konet log --oneline -5

# 원격 주소 확인
git -C C:\Users\HYUN\git\konet remote -v
```

---

## 다른 PC에서 처음 받을 때 (최초 1회)

```powershell
git -C C:\Users\HYUN\git clone https://github.com/taghyunoh/konet.git
```

→ `C:\Users\HYUN\git\konet\konet_web\` 생성 (sejong 과 동일 구조).
비공개 저장소이므로 인증 시 **GitHub 사용자 `taghyunoh` + PAT(Personal Access Token)** 입력.
(PAT 발급: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) → `repo` 권한)

---

## 참고 — Eclipse(EGit) 사용 시

Eclipse 에서 Team → Pull 이 `Invalid remote: origin` 으로 실패하면 EGit 내부
메타데이터 손상 문제이며, 저장소·CLI 자체는 정상이다. 이 경우 위 CLI 명령으로
동기화하면 된다. (편집은 Eclipse, 동기화만 CLI)
