# 로컬 톰캣(9071) 기동 — 사용자 터미널에서 돌려야 JVM 이 살아남는다 (도구 셸에서 띄우면 호출이 끝날 때 함께 죽는다 · 2026-10-26 실측)
# 쓰는 법 : & .\docs\tools\tomcat-start.ps1
$env:CATALINA_HOME = 'C:\egv\Servers\konet_vsweb-tomcat'
$env:CATALINA_BASE = $env:CATALINA_HOME
$env:JRE_HOME = 'C:\Program Files\Java\jre-1.8'
Remove-Item Env:JAVA_HOME -ErrorAction SilentlyContinue
$busy = Get-NetTCPConnection -LocalPort 9071,9013 -State Listen -ErrorAction SilentlyContinue
if ($busy) { "이미 9071/9013 을 쥔 PID : " + (($busy.OwningProcess | Select-Object -Unique) -join ',') + " — 먼저 내리세요 (catalina.bat stop 또는 taskkill)"; return }
& "$env:CATALINA_HOME\bin\catalina.bat" start
"기동 명령을 보냈습니다. 30~60초 뒤 로그 : " + "$env:CATALINA_HOME\logs\catalina." + (Get-Date -Format yyyy-MM-dd) + ".log"
