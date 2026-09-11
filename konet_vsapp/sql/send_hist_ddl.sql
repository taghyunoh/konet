/* =====================================================================================
   TBL_SEND_HIST — 문서 <전송이력> (MSSQL)   2026-09-10
   · 배경 : 판매등록 [거래명세표] 와 발주서(poReg) 를 카톡·이메일·링크로 보내는데,
            종전에는 전표에 **SHARE_CNT(몇 번) · LAST_SHARE_DTTM(마지막 언제)** 두 칸뿐이라
            *누구에게 · 어떤 방법으로 · 무슨 주소로* 보냈는지는 아무 데도 남지 않았다.
            "그 거래처에 명세서 보냈던가?" 를 확인할 길이 없어 이력 표를 따로 둔다.
   · ★두 화면이 <한 표>를 쓴다 — DOC_GB 로만 가른다('STMT'=거래명세표 · 'PO'=매입발주서).
     표를 두 벌로 두면 목록 화면·조회 규칙도 두 벌이 되어 조용히 달라진다.
     새 문서(견적서 등)가 생기면 DOC_GB 한 값만 늘리면 된다.
   · ★기록은 <보낸 사실>이다 — 지우지 않는다(ACTION_YN 은 잘못 남은 줄을 감추는 용도).
   · 각 구문 IF 가드로 재실행 안전.
   ===================================================================================== */
USE [KOLGSDB]
GO

IF OBJECT_ID('dbo.TBL_SEND_HIST','U') IS NULL
CREATE TABLE dbo.TBL_SEND_HIST (
    SEND_SEQ    BIGINT IDENTITY(1,1) NOT NULL,
    COMP_CD     VARCHAR(10)   NOT NULL CONSTRAINT DF_SEND_HIST_COMP DEFAULT ('W1234567'), -- 회사(멀티테넌트)
    DOC_GB      NVARCHAR(10)  NOT NULL,          -- 'STMT' 거래명세표 / 'PO' 매입발주서
    DOC_SEQ     BIGINT        NULL,              -- SALE_SEQ / PO_SEQ
    DOC_DT      NVARCHAR(8)   NULL,              -- 전표일자 'YYYYMMDD'
    DOC_NO      NVARCHAR(20)  NULL,              -- 전표번호
    VENDOR_CD   NVARCHAR(20)  NULL,
    VENDOR_NM   NVARCHAR(100) NULL,
    SEND_GB     NVARCHAR(10)  NOT NULL,          -- 'KAKAO' 카톡 / 'EMAIL' 서버발송 / 'MAILTO' 메일프로그램
                                                 -- 'GMAIL' Gmail 창 / 'COPY' 내용복사 / 'LINK' 링크복사
    SEND_TO     NVARCHAR(300) NULL,              -- 받는 곳(이메일 주소 등). 카톡·링크는 비어 있을 수 있다
    SUBJECT     NVARCHAR(300) NULL,              -- 제목(이메일)
    MEMO        NVARCHAR(500) NULL,              -- 덧붙인 말
    SHARE_URL   NVARCHAR(300) NULL,              -- 그때 보낸 공개 주소
    TOT_AMT     DECIMAL(18,2) NULL,              -- 그때 합계금액(뒤에 전표가 바뀌어도 보낸 값이 남는다)
    RESULT_GB   NVARCHAR(10)  NOT NULL CONSTRAINT DF_SEND_HIST_RES DEFAULT ('OK'),  -- 'OK' / 'FAIL'
    ERR_MSG     NVARCHAR(500) NULL,              -- 실패 사유
    /* 읽음·열람 (2026-09-10 추가 — 이미 만든 DB 는 send_hist_read_alter.sql 로) */
    TRACK_KEY      VARCHAR(32)  NULL,            -- 전송 한 건의 무작위 열쇠(링크 &s= · 그림 ?k=)
    MAIL_OPEN_DTTM NVARCHAR(19) NULL,            -- 메일을 처음 연 일시(1×1 그림)
    MAIL_OPEN_CNT  INT          NULL,
    VIEW_DTTM      NVARCHAR(19) NULL,            -- 명세서 링크를 처음 열어 본 일시
    VIEW_CNT       INT          NULL,
    ACTION_YN   CHAR(1)       NOT NULL CONSTRAINT DF_SEND_HIST_ACT DEFAULT ('Y'),
    REG_DTTM    NVARCHAR(19)  NULL,              -- 'YYYY-MM-DD HH:MM:SS'
    REG_USER    NVARCHAR(50)  NULL,
    REG_IP      NVARCHAR(50)  NULL,
    CONSTRAINT PK_SEND_HIST PRIMARY KEY CLUSTERED (SEND_SEQ)
);
GO

/* 한 전표의 이력(가장 잦은 조회) */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SEND_HIST_DOC' AND object_id=OBJECT_ID('dbo.TBL_SEND_HIST'))
    CREATE INDEX IX_SEND_HIST_DOC ON dbo.TBL_SEND_HIST (COMP_CD, DOC_GB, DOC_SEQ, SEND_SEQ DESC);
GO
/* 기간 조회(전체 이력 탭) */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SEND_HIST_DT' AND object_id=OBJECT_ID('dbo.TBL_SEND_HIST'))
    CREATE INDEX IX_SEND_HIST_DT ON dbo.TBL_SEND_HIST (COMP_CD, DOC_GB, REG_DTTM DESC);
GO
/* 읽음·열람 — 열쇠로 그 전송 한 줄을 찾는다 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SEND_HIST_KEY' AND object_id=OBJECT_ID('dbo.TBL_SEND_HIST'))
    CREATE INDEX IX_SEND_HIST_KEY ON dbo.TBL_SEND_HIST (TRACK_KEY) WHERE TRACK_KEY IS NOT NULL;
GO

/* 확인
SELECT TOP 50 SEND_SEQ, DOC_GB, DOC_DT, DOC_NO, VENDOR_NM, SEND_GB, SEND_TO, RESULT_GB, REG_DTTM, REG_USER
  FROM dbo.TBL_SEND_HIST WHERE ACTION_YN='Y' ORDER BY SEND_SEQ DESC;
*/
