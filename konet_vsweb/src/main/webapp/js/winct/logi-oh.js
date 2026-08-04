/* ============================================================================
   출고현황표 셸(logistics_demo2.jsp) 의 화면 스크립트 — 2026-08-02 외부 파일로 분리.

   ★왜 뺐나 (재발 방지를 위해 반드시 읽을 것)
     JSP 는 **정적 텍스트가 전부 _jspService() 한 메서드**로 들어간다. 자바 메서드는
     바이트코드 65,535 바이트가 상한이라, 이 JS(38만 자)가 JSP 안에 있는 동안 한계에 걸려
     "The code of method _jspService(...) is exceeding the 65535 bytes limit" 로
     컴파일이 통째로 실패했다(증상 = 로그인 후 빈 화면).
   ★그러므로 이 파일의 내용을 JSP 로 되돌리지 말 것. JSP 쪽에 JS 를 몇 KB만 더 넣어도 재발한다.

   ★컨텍스트 경로
     JSP 의 EL(pageContext.request.contextPath)은 .js 에서 쓸 수 없으므로,
     JSP 가 먼저 window.KONET_CTX 에 넣어 주고 여기서는 그 값을 쓴다.
     (로컬은 루트'', 운영은 '/konet' 처럼 다를 수 있어 절대 하드코딩하면 안 된다)
   ★이 파일은 JSP 안에 있던 그 자리(문서 순서)에 그대로 로드된다 —
     defer/async 를 붙이면 실행 순서가 바뀌어 앞 블록의 전역을 못 찾는다.
   ========================================================================== */
var KONET_CTX = window.KONET_CTX || '';

  /* ===================================================================
     출고현황표 — 발주현황표(엑셀) 업로드 → 출고량/재고량 자동작성
     · 원천: 발주현황표 노란칸 [품목명 · 사업장명 · 존(출고장) · 수량]
     · 출고장 = 입고장 기준 존 그룹 (1→A존 / 2→C존 / 3→D존 / 4→F존)
     · 업로드 없이도 시연되도록 실제 2026.06.19 발주 127행을 내장
     =================================================================== */
  var SHIP_DATA = [{"code":"1000800551","item":"(PAZAC)박스대,제이투팩,11.2KG(400EA/BOX)","biz":"new파작(종로점) [A0403307]","bizCode":"A0403307","inb":"3","zone":"D7","qty":2},{"code":"1000800551","item":"(PAZAC)박스대,제이투팩,11.2KG(400EA/BOX)","biz":"new파작(여의도점) [A0405159]","bizCode":"A0405159","inb":"3","zone":"D8","qty":1},{"code":"1000800552","item":"(PAZAC)박스소,제이투팩,8.4KG(400EA/BOX)","biz":"new파작(종로점) [A0403307]","bizCode":"A0403307","inb":"3","zone":"D7","qty":1},{"code":"1000797636","item":"(PAZAC)홀더,대승씨엔씨,7.35KG(1,000EA/BOX)","biz":"new파작(여의도점) [A0405159]","bizCode":"A0405159","inb":"3","zone":"D8","qty":1},{"code":"1000781893","item":"(뜨돈)195파이용기뚜껑,검정,구형,PP,300EA/BOX","biz":"뜨돈 수원 영통점 [A0361355]","bizCode":"A0361355","inb":"1","zone":"A3","qty":1},{"code":"1000781893","item":"(뜨돈)195파이용기뚜껑,검정,구형,PP,300EA/BOX","biz":"뜨돈 동탄 성공 본점 [A0361331]","bizCode":"A0361331","inb":"2","zone":"C2","qty":1},{"code":"1000781894","item":"(뜨돈)195파이용기몸체,소,검정,구형,PP,300EA/BOX","biz":"뜨돈 수원 영통점 [A0361355]","bizCode":"A0361355","inb":"1","zone":"A3","qty":1},{"code":"1000781894","item":"(뜨돈)195파이용기몸체,소,검정,구형,PP,300EA/BOX","biz":"뜨돈 동탄 성공 본점 [A0361331]","bizCode":"A0361331","inb":"2","zone":"C2","qty":1},{"code":"1000782041","item":"(뜨돈)5칸돈가스도시락세트,검정,240*180*35MM,몸체PP,뚜껑PE","biz":"뜨돈 시흥 배곧점 [A0361335]","bizCode":"A0361335","inb":"3","zone":"D7","qty":1},{"code":"1000779754","item":"(뜨돈)각대봉투,소,120*60*220MM,무지크라프트,1000EA/BO","biz":"뜨돈 시흥 배곧점 [A0361335]","bizCode":"A0361335","inb":"3","zone":"D7","qty":1},{"code":"1000779736","item":"(뜨돈)소스용기뚜껑,95파이,PP,1000EA/BOX","biz":"뜨돈 동탄 카림애비뉴점 [A0361421]","bizCode":"A0361421","inb":"2","zone":"C2","qty":1},{"code":"1000736180","item":"(런던&레이&하이)74Ø3.25온스,크림치즈용,소,용기,740*500*3","biz":"성수CC [A0370886]","bizCode":"A0370886","inb":"3","zone":"D2","qty":3},{"code":"1000736181","item":"(런던&레이&하이)F74Ø크림치즈용,소,무타공뚜껑,F74Ø(무타공)뚜껑,","biz":"성수CC [A0370886]","bizCode":"A0370886","inb":"3","zone":"D2","qty":2},{"code":"1000730573","item":"(런던&레이&하이)노루지코팅깔개,소,130*100MM,10000EA/BO","biz":"런베잠실_홀1층 [A0307398]","bizCode":"A0307398","inb":"2","zone":"C5","qty":1},{"code":"1000736204","item":"(런던&레이&하이)보냉팩,소,180*240MM+50MM,600EA/BOX","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000736204","item":"(런던&레이&하이)보냉팩,소,180*240MM+50MM,600EA/BOX","biz":"런베도산 [A0276902]","bizCode":"A0276902","inb":"4","zone":"F2","qty":1},{"code":"1000736213","item":"(런던&레이&하이)보냉팩,중,240*350MM+40MM,400EA/BOX","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000730576","item":"(런던&레이&하이)줄무늬크라프트유산지,350*250MM,3000EA/BO","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000730576","item":"(런던&레이&하이)줄무늬크라프트유산지,350*250MM,3000EA/BO","biz":"런베여의도_창고-B6층 [A0347927]","bizCode":"A0347927","inb":"2","zone":"C7","qty":1},{"code":"1000730576","item":"(런던&레이&하이)줄무늬크라프트유산지,350*250MM,3000EA/BO","biz":"레이안국 [A0329858]","bizCode":"A0329858","inb":"4","zone":"F1","qty":1},{"code":"1000730576","item":"(런던&레이&하이)줄무늬크라프트유산지,350*250MM,3000EA/BO","biz":"런베수원_홀 [A0331220]","bizCode":"A0331220","inb":"4","zone":"F7","qty":1},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베잠실_홀1층 [A0307398]","bizCode":"A0307398","inb":"2","zone":"C5","qty":1},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":2},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베여의도_창고-B6층 [A0347927]","bizCode":"A0347927","inb":"2","zone":"C7","qty":3},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베도산 [A0276902]","bizCode":"A0276902","inb":"4","zone":"F2","qty":1},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베수원_홀 [A0331220]","bizCode":"A0331220","inb":"4","zone":"F7","qty":3},{"code":"1000792544","item":"(런던베이글)아돌이종이컵,16온스,2도인쇄,1000EA/BOX","biz":"런베여의도_창고-B6층 [A0347927]","bizCode":"A0347927","inb":"2","zone":"C7","qty":1},{"code":"1000730686","item":"(런던베이글)칵테일냅킨,W230mm,L230mm,1도인쇄,10000EA/","biz":"런베여의도_창고-B6층 [A0347927]","bizCode":"A0347927","inb":"2","zone":"C7","qty":1},{"code":"1000792545","item":"(런던베이글)필로소피종이컵,16온스,1도인쇄,1000EA/BOX","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000718241","item":"(레이어드)친환경종이컵,16OZ,무지,1000EA/BOX","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000719149","item":"(레이어드)하이웨스트&베이글박스,소,130*100*115MM,200EA/","biz":"하웨판교 [A0326700]","bizCode":"A0326700","inb":"4","zone":"F5","qty":1},{"code":"1000715525","item":"(명동피자)물티슈,1도인쇄,1000EA/BOX,D-2","biz":"명동피자(명동본점-창고) [A0316597]","bizCode":"A0316597","inb":"3","zone":"D3","qty":2},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(세종아름점)25년 [A0376445]","bizCode":"A0376445","inb":"1","zone":"A8","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(신관점) [A0359235]","bizCode":"A0359235","inb":"1","zone":"A9","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(오산시청점) [A0343969]","bizCode":"A0343969","inb":"2","zone":"C1","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(봉천) [A0273035]","bizCode":"A0273035","inb":"3","zone":"D1","qty":2},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈 덮밥이 마포점(26) [A0400921]","bizCode":"A0400921","inb":"3","zone":"D1","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(분당수내)25 [A0370059]","bizCode":"A0370059","inb":"","zone":"","qty":0},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(세종보람점)26 [A0401387]","bizCode":"A0401387","inb":"3","zone":"D6","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(세종조치원25년) [A0367700]","bizCode":"A0367700","inb":"3","zone":"D6","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"파스타입니다(왕십리점) [A0278710]","bizCode":"A0278710","inb":"3","zone":"D7","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(길동점) [A0294143]","bizCode":"A0294143","inb":"4","zone":"F2","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"파스타입니다(수유점) [A0383456]","bizCode":"A0383456","inb":"4","zone":"F8","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(세종아름점)25년 [A0376445]","bizCode":"A0376445","inb":"1","zone":"A8","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(신관점) [A0359235]","bizCode":"A0359235","inb":"1","zone":"A9","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(오산시청점) [A0343969]","bizCode":"A0343969","inb":"2","zone":"C1","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(봉천) [A0273035]","bizCode":"A0273035","inb":"3","zone":"D1","qty":2},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈 덮밥이 마포점(26) [A0400921]","bizCode":"A0400921","inb":"3","zone":"D1","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(세종조치원25년) [A0367700]","bizCode":"A0367700","inb":"3","zone":"D6","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"파스타입니다(왕십리점) [A0278710]","bizCode":"A0278710","inb":"3","zone":"D7","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(길동점) [A0294143]","bizCode":"A0294143","inb":"4","zone":"F2","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"파스타입니다(수유점) [A0383456]","bizCode":"A0383456","inb":"4","zone":"F8","qty":1},{"code":"1000791735","item":"(스프링롤명가)WL-F800SET(흰색),198*116*53MM,150S","biz":"스프링롤 명가_수원영통점 [A0368222]","bizCode":"A0368222","inb":"1","zone":"A7","qty":1},{"code":"1000791735","item":"(스프링롤명가)WL-F800SET(흰색),198*116*53MM,150S","biz":"스프링롤 명가_답십리 [A0381705]","bizCode":"A0381705","inb":"3","zone":"D7","qty":2},{"code":"1000795136","item":"(아벡쉐리)컵홀더,12/16/20,SC합지인쇄,코네트,9.62KG(100","biz":"아벡쉐리 한남점(홀) [A0383277]","bizCode":"A0383277","inb":"4","zone":"F7","qty":2},{"code":"1000793901","item":"(아임도넛)각대봉투,피앤텍,8KG(1000EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":1},{"code":"1000793900","item":"(아임도넛)슬리브인박스,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000793900","item":"(아임도넛)슬리브인박스,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(성수점) [A0379537]","bizCode":"A0379537","inb":"2","zone":"C5","qty":3},{"code":"1000793899","item":"(아임도넛)슬리브터널형,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000793899","item":"(아임도넛)슬리브터널형,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(성수점) [A0379537]","bizCode":"A0379537","inb":"2","zone":"C5","qty":2},{"code":"1000802403","item":"(아임도넛)에스파콜라보박스,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000802403","item":"(아임도넛)에스파콜라보박스,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(성수점) [A0379537]","bizCode":"A0379537","inb":"2","zone":"C5","qty":2},{"code":"1000802405","item":"(아임도넛)옐로우비닐,그린팩코리아,11.8KG(500EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000802405","item":"(아임도넛)옐로우비닐,그린팩코리아,11.8KG(500EA/BOX)","biz":"아임도넛(성수점) [A0379537]","bizCode":"A0379537","inb":"2","zone":"C5","qty":2},{"code":"1000804387","item":"(아임도넛)원형간지,325MM,대영전산,10KG(3000EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000768163","item":"(오베이글)각대봉투,대,흰색,180*110*430MM,2도,1000EA/","biz":"오베이글(카페) [A0339710]","bizCode":"A0339710","inb":"2","zone":"C4","qty":1},{"code":"1000758525","item":"(주니아)랩지,크라프트,330*330MM,코팅,1도,1000EA/BOX","biz":"주니아_약수점 [A0372844]","bizCode":"A0372844","inb":"2","zone":"C5","qty":1},{"code":"1000755871","item":"(주니아)아이스컵,뚜껑,돔리드,DIA92MM,1000EA/BOX","biz":"주니아_판교IT센터점 [A0358217]","bizCode":"A0358217","inb":"2","zone":"C5","qty":1},{"code":"1000755863","item":"(주니아)파니니용기,크라프트,도시락2호,600EA/BOX","biz":"주니아_판교IT센터점 [A0358217]","bizCode":"A0358217","inb":"2","zone":"C5","qty":1},{"code":"1000757230","item":"(주니아)포켓(반)봉투,200*240MM,무지,코팅,1000EA/BOX","biz":"주니아_길음역점 [A0343453]","bizCode":"A0343453","inb":"3","zone":"D2","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(중랑상봉점) [A0356265]","bizCode":"A0356265","inb":"1","zone":"A9","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(송파점_신) [A0381595]","bizCode":"A0381595","inb":"2","zone":"C5","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(서울역점) [A0346656]","bizCode":"A0346656","inb":"3","zone":"D3","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(분당점) [A0357188]","bizCode":"A0357188","inb":"3","zone":"D5","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(성남점_新) [A0383113]","bizCode":"A0383113","inb":"4","zone":"F4","qty":1},{"code":"1000767816","item":"(포엠)사각죽용기몸체,대,180*130*H65MM,1000ML,PP,50","biz":"파스타예요(분당점) [A0357188]","bizCode":"A0357188","inb":"3","zone":"D5","qty":1},{"code":"1000767817","item":"(포엠)사각죽용기몸체,중,180*130*H55MM,850ML,PP,500","biz":"파스타예요(중랑상봉점) [A0356265]","bizCode":"A0356265","inb":"1","zone":"A9","qty":1},{"code":"1000767817","item":"(포엠)사각죽용기몸체,중,180*130*H55MM,850ML,PP,500","biz":"파스타예요(서울역점) [A0346656]","bizCode":"A0346656","inb":"3","zone":"D3","qty":1},{"code":"1000767817","item":"(포엠)사각죽용기몸체,중,180*130*H55MM,850ML,PP,500","biz":"파스타예요(강서본점) [A0383157]","bizCode":"A0383157","inb":"4","zone":"F4","qty":1},{"code":"1000767817","item":"(포엠)사각죽용기몸체,중,180*130*H55MM,850ML,PP,500","biz":"파스타예요(성남점_新) [A0383113]","bizCode":"A0383113","inb":"4","zone":"F4","qty":1},{"code":"1000771713","item":"(포케올데이)랩샌드위치노루지,30*30CM,1도인쇄,코팅40G,1000E","biz":"POKE 분당야탑점 [A0354014]","bizCode":"A0354014","inb":"3","zone":"D5","qty":1},{"code":"1000767985","item":"(포케올데이)스프용기뚜껑,330CC,100파이*15MM,두겹,무지,500","biz":"POKE 안암점 [A0349142]","bizCode":"A0349142","inb":"4","zone":"F7","qty":1},{"code":"1000758813","item":"(프로티너)냅킨,흰색,115*115MM,크라프트,삼양앤컴퍼니,10000E","biz":"잠실방이점_프로티너 [A0406254]","bizCode":"A0406254","inb":"3","zone":"D8","qty":1},{"code":"1000758814","item":"(프로티너)물티슈,무지,100*70MM(포장지),200*130MM(속지)","biz":"잠실방이점_프로티너 [A0406254]","bizCode":"A0406254","inb":"3","zone":"D8","qty":1},{"code":"1000759547","item":"(프로티너)소스컵뚜껑,1OZ,45파이,무타공,평리드,DIA45MM,PET","biz":"홍대입구역점_프로티너 [A0395443]","bizCode":"A0395443","inb":"4","zone":"F7","qty":1},{"code":"1000759544","item":"(프로티너)소스컵뚜껑,2OZ,62파이,무타공,평리드,DIA62MM,PET","biz":"홍대입구역점_프로티너 [A0395443]","bizCode":"A0395443","inb":"4","zone":"F7","qty":1},{"code":"1000759541","item":"(프로티너)소스컵몸체,2OZ,62파이,DIA62MM,PET,2000EA/","biz":"홍대입구역점_프로티너 [A0395443]","bizCode":"A0395443","inb":"4","zone":"F7","qty":1},{"code":"1000759549","item":"(프로티너)펄프용기뚜껑,PET,500EA/BOX","biz":"판교역점_프로티너 [A0401308]","bizCode":"A0401308","inb":"3","zone":"D8","qty":1},{"code":"1000759548","item":"(프로티너)펄프용기몸체,1칸,210X130X70MM,1000ML,500E","biz":"판교역점_프로티너 [A0401308]","bizCode":"A0401308","inb":"3","zone":"D8","qty":1},{"code":"1000794792","item":"(허그런치)1350CC컵지용기,300EA/BOX,180*155*73MM","biz":"허그런치(시흥) [A0280723]","bizCode":"A0280723","inb":"2","zone":"C3","qty":3},{"code":"1000794793","item":"(허그런치)180ǾPET뚜껑,300EA/BOX","biz":"허그런치(시흥) [A0280723]","bizCode":"A0280723","inb":"2","zone":"C3","qty":3},{"code":"1000773313","item":"(허그런치)대나무젓가락,현대산업,개별포장,인쇄,2000EA/BOX","biz":"허그런치(시흥) [A0280723]","bizCode":"A0280723","inb":"2","zone":"C3","qty":7},{"code":"1000773313","item":"(허그런치)대나무젓가락,현대산업,개별포장,인쇄,2000EA/BOX","biz":"허그런치(성남) [A0338096]","bizCode":"A0338096","inb":"3","zone":"D5","qty":2},{"code":"1000774531","item":"(허그런치)일회용숟가락,개별포장,백색,L175MM,1500EA/BOX","biz":"허그런치(시흥) [A0280723]","bizCode":"A0280723","inb":"2","zone":"C3","qty":8},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울 강서점) [A0396385]","bizCode":"A0396385","inb":"3","zone":"D6","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울역삼점) [A0345675]","bizCode":"A0345675","inb":"3","zone":"D7","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(수원 영통점) [A0376534]","bizCode":"A0376534","inb":"3","zone":"D8","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(화성 동탄점) [A0403097]","bizCode":"A0403097","inb":"3","zone":"D8","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울 서대문점) [A0401568]","bizCode":"A0401568","inb":"4","zone":"F7","qty":1},{"code":"1000783957","item":"(호호솥밥)비닐쇼핑백,중,그린팩,37(M16*2)*50MM,2도,500E","biz":"호호솥밥(안양 만안점) [A0403098]","bizCode":"A0403098","inb":"3","zone":"D8","qty":1},{"code":"1000783957","item":"(호호솥밥)비닐쇼핑백,중,그린팩,37(M16*2)*50MM,2도,500E","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(분당 판교점) [A0366132]","bizCode":"A0366132","inb":"2","zone":"C5","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(경기 안산점) [A0403069]","bizCode":"A0403069","inb":"3","zone":"D7","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(서울역삼점) [A0345675]","bizCode":"A0345675","inb":"3","zone":"D7","qty":2},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(서울 송파점) [A0398066]","bizCode":"A0398066","inb":"3","zone":"D8","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(화성 동탄점) [A0403097]","bizCode":"A0403097","inb":"3","zone":"D8","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(분당 판교점) [A0366132]","bizCode":"A0366132","inb":"2","zone":"C5","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(경기 안산점) [A0403069]","bizCode":"A0403069","inb":"3","zone":"D7","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(서울역삼점) [A0345675]","bizCode":"A0345675","inb":"3","zone":"D7","qty":2},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(서울 송파점) [A0398066]","bizCode":"A0398066","inb":"3","zone":"D8","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(화성 동탄점) [A0403097]","bizCode":"A0403097","inb":"3","zone":"D8","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000771765","item":"(호호솥밥)원형스티커,80MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울 강서점) [A0396385]","bizCode":"A0396385","inb":"3","zone":"D6","qty":1},{"code":"1000771765","item":"(호호솥밥)원형스티커,80MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000771765","item":"(호호솥밥)원형스티커,80MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울 서대문점) [A0401568]","bizCode":"A0401568","inb":"4","zone":"F7","qty":1},{"code":"1000775934","item":"(화계전통)타원찜용기,소,뚜껑,100EA/BOX","biz":"화계전통_서울시립대점 [A0359892]","bizCode":"A0359892","inb":"2","zone":"C3","qty":1},{"code":"1000775933","item":"(화계전통)타원찜용기,소,몸체,100EA/BOX","biz":"화계전통_서울시립대점 [A0359892]","bizCode":"A0359892","inb":"2","zone":"C3","qty":1},{"code":"1000743500","item":"냉면용기뚜껑,중,DIA200MM,PP,200EA/BOX","biz":"헬키푸키 석촌점 [A0302818]","bizCode":"A0302818","inb":"2","zone":"C3","qty":1},{"code":"1000743500","item":"냉면용기뚜껑,중,DIA200MM,PP,200EA/BOX","biz":"혜준당_보문점 [A0404129]","bizCode":"A0404129","inb":"3","zone":"D8","qty":1},{"code":"1000743499","item":"냉면용기몸체,중,DIA200MM*H70MM,PP,200EA/BOX","biz":"헬키푸키 석촌점 [A0302818]","bizCode":"A0302818","inb":"2","zone":"C3","qty":1},{"code":"1000743499","item":"냉면용기몸체,중,DIA200MM*H70MM,PP,200EA/BOX","biz":"혜준당_보문점 [A0404129]","bizCode":"A0404129","inb":"3","zone":"D8","qty":1},{"code":"1000765857","item":"수저세트,무지,검정,숟가락(L170MM,PP),젓가락(L180MM,대나무","biz":"뜨돈 시흥 배곧점 [A0361335]","bizCode":"A0361335","inb":"3","zone":"D7","qty":1},{"code":"1000765857","item":"수저세트,무지,검정,숟가락(L170MM,PP),젓가락(L180MM,대나무","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000455371","item":"종이컵,10OZ,로앤그린,친환경,DIA85*H95MM,1000EA/BOX","biz":"블루엘리펀트 성수 [A0388469]","bizCode":"A0388469","inb":"1","zone":"A9","qty":1},{"code":"1000756544","item":"종이컵,92파이,20OZ,대크린상,DIA92MM,1000EA/BOX","biz":"블루엘리펀트 성수 [A0388469]","bizCode":"A0388469","inb":"1","zone":"A9","qty":1}];

  function ssBrand(item){ var m=/^\(([^)]+)\)/.exec(item||''); return m?m[1]:'기타·공통'; }
  // 행 분류(묶음): 사업장코드가 TBL_BIZI_MST(ssBiziMap)에 있으면 그 사업장명으로, 없으면 품목명 () 접두어로
  function ssRowBrand(r){
    var bc=(''+((r&&r.bizCode)||'')).trim();
    var m=window.ssBiziMap||{};
    if(bc && m[bc]) return m[bc];
    return ssBrand(r&&r.item);
  }
  // TBL_BIZI_MST 조회 → ssBiziMap{사업장코드:사업장명}. 분류 직전 항상 최신화(수정 즉시 반영)
  function ssLoadBiziMst(cb){
    fetch(KONET_CTX+'/shipout/selectBiziMst.do', { method:'POST', credentials:'same-origin' })
    .then(function(res){ return res.text(); })
    .then(function(txt){
      try{ var j=JSON.parse(txt); var m={}; (j.data||[]).forEach(function(o){ var c=(''+(o.bizCd||'')).trim(); if(c) m[c]=(''+(o.bizNm||'')).trim(); }); window.ssBiziMap=m; }
      catch(e){ if(!window.ssBiziMap) window.ssBiziMap={}; }
      if(cb) cb();
    })
    .catch(function(){ if(!window.ssBiziMap) window.ssBiziMap={}; if(cb) cb(); });
  }
  // 품목명에서 앞쪽 (사업장/브랜드) 접두 제거 — 상단 그룹헤더와 중복 방지
  function ssShortName(item){ return (''+(item||'')).trim(); }   // 품목명 () 접두 포함해서 그대로 표시
  function ssHash(s){ var h=5381,i; for(i=0;i<s.length;i++) h=((h<<5)+h+s.charCodeAt(i))>>>0; return h; }
  function ssNum(n){ return (Math.round(n||0)).toLocaleString(); }
  function ssSet(id,html){ var e=document.getElementById(id); if(e) e.innerHTML=html; }

  // 발주현황표 → 집계 (출고장=행, 품목=열 / 품목코드 매칭 / 선택일=당일 필터)
  function ssAggregate(){
    var from=(document.getElementById('ssDateFrom')||{}).value||'';
    var to=(document.getElementById('ssDateTo')||{}).value||'';
    var zoneTot={}, zoneInb={}, items={}, bizSet={}, matrix={}, zoneSet={}, unassigned=0, totQty=0, unassignedList=[], unMatrix={}, unCnt={}, unNames=[], unTot=0;
    var brandCodes={}, brandBiz={};   // 브랜드(열 묶음) → 사업장코드/사업장명 집합
    SHIP_DATA.forEach(function(r){
      var d=r.date||SS_TODAY;
      if(from && d<from) return;          // ★ 시작일자 이전 제외
      if(to && d>to) return;              // ★ 종료일자 이후 제외
      var q = +r.qty||0;
      if(r.biz) bizSet[r.biz]=1;
      // 브랜드별 사업장코드/사업장명 수집(존 지정·미지정 모두 포함)
      var _br0=ssRowBrand(r), _bc0=(''+(r.bizCode||'')).trim();
      if(_bc0){ (brandCodes[_br0]=brandCodes[_br0]||{})[_bc0]=1; }
      if(r.biz){ (brandBiz[_br0]=brandBiz[_br0]||{})[r.biz]=1; }
      if(!r.zone){                         // 존 미지정 → 미배정 집계
        var sn=ssShortName(r.item);
        unassigned++; unassignedList.push((r.biz||'')+' · '+sn);
        var uk=(''+(r.code||'')).trim() ? (''+(r.code||'')).trim() : ('NM:'+r.item);
        unMatrix[uk]=(unMatrix[uk]||0)+q; unCnt[uk]=(unCnt[uk]||0)+1; unTot+=q;
        if(unNames.indexOf(sn)<0) unNames.push(sn);
        return;
      }
      totQty += q;
      var code=(''+(r.code||'')).trim();
      var key = code ? code : ('NM:'+r.item);   // ★ 품목코드로 매칭
      var br=ssRowBrand(r);
      if(!items[key]) items[key]={code:code, name:r.item, brand:br, qty:0};
      items[key].qty+=q;
      zoneSet[r.zone]=1; zoneTot[r.zone]=(zoneTot[r.zone]||0)+q; zoneInb[r.zone]=(r.inb||'');
      matrix[r.zone]=matrix[r.zone]||{};
      matrix[r.zone][key]=(matrix[r.zone][key]||0)+q;
    });
    // 직접 추가한 품목을 빈 열로 포함(데이터 없어도 열 표시)
    (ssExtraItems||[]).forEach(function(e){ if(!items[e.key]) items[e.key]={code:e.code||'', name:e.name, brand:ssBrand(e.name), qty:0}; });
    // 직접 추가한 존을 빈 행으로 포함
    (ssExtraZones||[]).forEach(function(z){ z=(''+z).trim().toUpperCase(); if(!z) return; zoneSet[z]=1; if(!(z in zoneTot)) zoneTot[z]=0; if(!zoneInb[z]) zoneInb[z]=({A:'1',C:'2',D:'3',F:'4'})[z.charAt(0)]||''; });
    return {items:items,matrix:matrix,zoneTot:zoneTot,zoneInb:zoneInb,zoneSet:zoneSet,bizSet:bizSet,brandCodes:brandCodes,brandBiz:brandBiz,unassigned:unassigned,unassignedList:unassignedList,unMatrix:unMatrix,unCnt:unCnt,unNames:unNames,unTot:unTot,totQty:totQty};
  }

  var SS_MONTHS=['5월','4월','3월','2월','1월'];  // 데모용 과거 월

  // 화면 표시용 물류센터 그룹/순서 (데시보드2와 동일 — 특정 코드는 오산센터로 묶고 지정순서로). DB 저장 무관
  var SS_DCGROUP={ 'E200':'오산센터','E400':'오산센터','E300':'오산센터','E600':'오산센터','E700':'오산센터' };   // E600=제주
  var SS_ZONEORDER=['E200','E400','E300','E600','E700'];
  function ssRender(){
    var tbl=document.getElementById('ssWideTbl'); if(!tbl) return;
    var ag=ssAggregate();
    var _cb=document.getElementById('ssSumFront'); ssSumFront=!!(_cb&&_cb.checked);
    // 합계 셀을 맨앞/끝 위치에 맞춰 배치
    function wrapSum(stickHtml, dataCells, sumCell){ return stickHtml + (ssSumFront?sumCell:'') + dataCells + (ssSumFront?'':sumCell); }
    // 칸 직접수정 → 해당 (일자·존·품목) 데이터 재작성 → 합계 자동 재계산
    window.ssEditKey=function(e,td){ if(e.key==='Enter'){ e.preventDefault(); td.blur(); } };
    window.ssEditCell=function(td){
      var z=td.getAttribute('data-z'), k=td.getAttribute('data-k');
      var v=parseFloat((td.textContent||'').replace(/[^0-9.\-]/g,''))||0; if(v<0) v=0;
      var d=(document.getElementById('ssDateFrom')||{}).value||SS_TODAY;
      var meta=ssItemMeta[k]||{name:k,code:''};
      var inb=({A:'1',C:'2',D:'3',F:'4'})[(z.charAt(0)||'').toUpperCase()]||'';
      SHIP_DATA=SHIP_DATA.filter(function(r){
        var rk=(''+(r.code||'')).trim()?(''+(r.code||'')).trim():('NM:'+r.item);
        return !(((r.date||SS_TODAY)===d) && r.zone===z && rk===k);
      });
      if(v>0) SHIP_DATA.push({code:(meta.code||''), item:meta.name, biz:'', inb:inb, zone:z, qty:v, date:d});
      ssRender();
    };

    // ── KPI (당일=선택일 기준) — 컴팩트 숫자
    ssSet('ssKpiItem', ssNum(Object.keys(ag.items).length));
    ssSet('ssKpiQty',  ssNum(ag.totQty));
    ssSet('ssKpiZone', ssNum(Object.keys(ag.zoneTot).length));
    // 사업장 = 헤더 그룹과 동일(브랜드 묶음) 기준
    var _brs={}; Object.keys(ag.items).forEach(function(k){ _brs[ag.items[k].brand]=1; });
    ssSet('ssKpiBiz',  ssNum(Object.keys(_brs).length));

    // ── 기간 정보 밴드
    var from=(document.getElementById('ssDateFrom')||{}).value||'';
    var to=(document.getElementById('ssDateTo')||{}).value||'';
    var dts=ssAllDates(); var hasData=(ag.totQty>0 || Object.keys(ag.items).length>0);
    var prefix = (from && from===to) ? (from===SS_TODAY?'당일':'선택일') : '기간';
    ssSet('ssKpiPrefix', prefix);
    // 당일/당월 버튼 선택 표시 + 활성 규칙
    var single = !!(from && from===to);
    var ym2=SS_TODAY.slice(0,7), monFrom=ym2+'-01';
    var _md=new Date(); var monLast=ym2+'-'+ssPad(new Date(_md.getFullYear(), _md.getMonth()+1, 0).getDate());
    var isToday = single && from===SS_TODAY;
    var isMonth = (from===monFrom && to===monLast);
    var bt=document.getElementById('ssBtnToday'); if(bt) bt.className = isToday?'btn-teal':'btn-line';
    var bm=document.getElementById('ssBtnMonth'); if(bm) bm.className = isMonth?'btn-teal':'btn-line';
    // 매출·매입/저장 버튼: 일자별(시작=종료 단일 일자)일 때만 활성 — 당월·기간(시작≠종료) 모드면 비활성
    ['ssBtnSales','ssBtnCost','ssBtnSave'].forEach(function(id){
      var b=document.getElementById(id); if(!b) return;
      b.disabled=!single; b.title = single ? '' : '일자별(시작=종료 단일 일자) 조건에서만 가능합니다';
    });
    // 발주현황표 업로드는 조회 기간과 무관하게 항상 활성 (출고일자는 미리보기에서 지정)
    var bu=document.getElementById('ssBtnUpload'); if(bu){ bu.disabled=false; bu.title=''; }
    var bd=document.getElementById('ssBtnDownload'); if(bd){ bd.disabled=false; bd.title=''; }
    var range = (from && from===to) ? (from + (from===SS_TODAY?' <b>(금일)</b>':'')) : (from||'~')+' ~ '+(to||'~');
    var info='<span class="ss-srcbadge'+(window.ssSrcUp?' up':'')+'">'+(window.ssSrcInfo||'내장 샘플')+'</span> 📅 '+range
      + (hasData ? '' : ' &nbsp;|&nbsp; <span style="color:#c0392b">해당 기간 데이터 없음</span>')
      + (dts.length>1 ? ' &nbsp;|&nbsp; 파일 출고일자 '+dts.length+'개: '+dts.map(function(x){return x.d+'('+x.n+')';}).join(', ') : '')
      + (ag.unassigned>0 ? ' &nbsp;|&nbsp; <span style="color:#c0392b; cursor:help" title="출고장 미지정 발주 — 출고장이 비어 집계 제외&#10;'+(ag.unassignedList||[]).join('&#10;').replace(/"/g,'&quot;')+'">미배정 '+ag.unassigned+'건 ⓘ</span>' : '');
    ssSet('ssDateInfo', info);

    // ── 사업장(브랜드) 선택 옵션
    var brands={}; Object.keys(ag.items).forEach(function(k){ brands[ag.items[k].brand]=1; });
    var brandList=Object.keys(brands).sort(function(a,b){ return a.localeCompare(b,'ko'); });
    var sel=document.getElementById('ssBizSel');
    var keep = sel.value || '__ALL__';
    if(sel.options.length !== brandList.length+1){
      sel.innerHTML='<option value="__ALL__">전체 ('+brandList.length+' 사업장)</option>'
        + brandList.map(function(b){ return '<option value="'+b+'">'+b+'</option>'; }).join('');
      sel.value = brandList.indexOf(keep)>=0 ? keep : '__ALL__';
    }
    // 사업장 찾기 자동완성 목록 동기화
    var dl=document.getElementById('ssBizFindList');
    if(dl){ dl.innerHTML = brandList.map(function(b){ return '<option value="'+b.replace(/"/g,'&quot;')+'">'; }).join(''); }
    var pick=sel.value;

    // ── 품목(열) 순서: 사업장 → 품목명
    var keys=Object.keys(ag.items);
    if(pick && pick!=='__ALL__') keys=keys.filter(function(k){ return ag.items[k].brand===pick; });
    keys.sort(function(a,b){
      var A=ag.items[a],B=ag.items[b];
      return A.brand.localeCompare(B.brand,'ko') || A.name.localeCompare(B.name,'ko');
    });
    keys=keys.filter(function(k){ return !ssBizHidden[ag.items[k].brand]; });  // 숨긴 사업장 제외
    // 숨긴 사업장 복원 바
    var hb=document.getElementById('ssHiddenBar');
    if(hb){ var hd=Object.keys(ssBizHidden).filter(function(b){return ssBizHidden[b];});
      if(hd.length){ hb.style.display='flex';
        hb.innerHTML='<span class="hb-lbl">🙈 숨긴 사업장:</span>'
          + hd.map(function(b){ return '<span class="hb-chip" data-br="'+b.replace(/"/g,'&quot;')+'" onclick="ssBizShowName(this.getAttribute(\'data-br\'))">'+b+' ↩</span>'; }).join('')
          + '<button class="btn-line" style="padding:3px 11px; margin-left:4px" onclick="ssBizShowAll()">전체 펼치기</button>';
      } else { hb.style.display='none'; hb.innerHTML=''; }
    }
    var zones=Object.keys(ag.zoneSet).sort();
    window.ssZoneList=zones.slice();
    var INB={'1':'1입고장','2':'2입고장','3':'3입고장','4':'4입고장'};
    var ncol=keys.length+2;

    if(!keys.length){ tbl.innerHTML='<tbody><tr><td style="padding:24px;color:#9aa7b3">표시할 품목이 없습니다.</td></tr></tbody>'; return; }

    // 사업장(브랜드) 그룹의 첫 열 = 구분선 위치
    var gstartKeys={}, groupIdxOf={}, _pb=null, _giSeq=-1;
    keys.forEach(function(k){ var br=ag.items[k].brand; if(br!==_pb){ gstartKeys[k]=true; _pb=br; _giSeq++; } groupIdxOf[k]=_giSeq; });
    function gs(k){ return (gstartKeys[k]?' gstart':'')+' bg'+groupIdxOf[k]; }
    // 직접 수정용 메타 + 편집가능 여부(당일 모드만)
    ssItemMeta={}; keys.forEach(function(k){ ssItemMeta[k]={name:ag.items[k].name, code:ag.items[k].code}; });
    var _bl={}; keys.forEach(function(k){ _bl[ag.items[k].brand]=1; }); window.ssBrandList=Object.keys(_bl).sort();
    window.ssItemList=keys.map(function(k){ return {name:ssShortName(ag.items[k].name), full:ag.items[k].name, code:ag.items[k].code||'', brand:ag.items[k].brand}; });
    var ssEditable = single;   // 시작=종료(당일)일 때만 칸 직접수정

    // ── thead : 1행 사업장 / 2행 품목명(코드)
    var _itemCnt=keys.length, _brSet={}; keys.forEach(function(k){ _brSet[ag.items[k].brand]=1; }); var _brCnt=Object.keys(_brSet).length;
    var sumTh='<th class="colsum" rowspan="2">합계<span class="sumcnt">사업장 '+_brCnt+'<br>품목 '+_itemCnt+'</span></th>';
    var th1='<tr><th class="stick" rowspan="2">출고장 \\ 품목</th>'+(ssSumFront?sumTh:'');
    var th2='<tr>';
    var groupsArr=[];   // 그룹별 열 수 (배너행 구분선용)
    var i=0;
    while(i<keys.length){
      var br=ag.items[keys[i]].brand, j=i;
      while(j<keys.length && ag.items[keys[j]].brand===br) j++;
      groupsArr.push(j-i);
      // 브랜드 헤더에 사업장코드 표시 (여러 개면 앞 3개 + '외 N', 전체는 툴팁)
      var _codes=Object.keys((ag.brandCodes||{})[br]||{}).sort();
      var _bizs=Object.keys((ag.brandBiz||{})[br]||{}).sort();
      var _codeHtml = _codes.length ? ('<span class="bizcode">['+_codes.slice(0,3).join(', ')+(_codes.length>3?(' 외 '+(_codes.length-3)):'')+']</span>') : '';
      var _ttl = _codes.length ? ('사업장코드 '+_codes.length+'개\n'+_bizs.join('\n')+'\n(클릭 시 이 사업장 열 숨기기)') : '클릭 시 이 사업장 열 숨기기';
      th1+='<th class="bizh gstart bg'+groupIdxOf[keys[i]]+'" colspan="'+(j-i)+'" data-br="'+br.replace(/"/g,'&quot;')+'" onclick="ssBizHideName(this.getAttribute(\'data-br\'))" title="'+_ttl.replace(/"/g,'&quot;')+'">'+br+_codeHtml+' <span class="bx">✕</span></th>';
      for(var p=i;p<j;p++){ var it=ag.items[keys[p]];
        var _isEx=(ssExtraItems||[]).some(function(e){return e.key===keys[p];}), _q0=((it.qty||0)===0);
        var _delx=(_isEx&&_q0)?'<span class="delx" data-dk="'+(''+keys[p]).replace(/"/g,'&quot;')+'" onclick="ssDelItem(event,this)" title="추가 품목 삭제(수량 없음)">✕</span>':'';
        th2+='<th class="prodh'+gs(keys[p])+'" title="'+it.name.replace(/"/g,'&quot;')+'">'+ssShortName(it.name)+'<span class="pc">'+(it.code||'-')+'</span>'+_delx+'</th>';
      }
      i=j;
    }
    th1+=(ssSumFront?'':sumTh)+'</tr>'; th2+='</tr>';
    // 배너행(머리줄/구분줄): 그룹 경계마다 구분선이 지나가도록 분할 셀 생성
    function ssBannerCells(descHtml){
      var h='';
      groupsArr.forEach(function(sz,gi){
        h+='<td colspan="'+sz+'"'+(gi>0?' class="gstart"':'')+(gi===0?' style="text-align:left"':'')+'>'+(gi===0?descHtml:'')+'</td>';
      });
      return h;
    }

    // ── tbody : 출고장(존) 행 — A존~F존(영문) 그룹별 + 그룹 합계
    var LETTER_INB={'A':'1입고장','B':'','C':'2입고장','D':'3입고장','E':'','F':'4입고장'};
    // 출고장→물류센터코드 맵 + 그룹키(오산센터 묶음)·정렬순서 (데시보드2와 동일 규칙)
    var ssZoneDcCd={};
    (SHIP_DATA||[]).forEach(function(r){ if(r&&r.zone&&r.dcCd && !ssZoneDcCd[r.zone]) ssZoneDcCd[r.zone]=r.dcCd; });
    function ssGrpKey(z){ var cd=ssZoneDcCd[z]||''; if(SS_DCGROUP[cd] || /제주/.test(z)) return 'OSAN'; return (z.charAt(0)||'').toUpperCase(); }
    function ssZoneRank(z){ var cd=ssZoneDcCd[z]||''; var i=SS_ZONEORDER.indexOf(cd); if(i<0 && /제주/.test(z)) i=SS_ZONEORDER.indexOf('E600'); return i<0?999:i; }
    var byL={}, letters=[];
    zones.forEach(function(z){ var L=ssGrpKey(z); if(!byL[L]){ byL[L]=[]; letters.push(L); } byL[L].push(z); });
    // 그룹 내 정렬: 오산센터는 지정순서(E200·E400·E300·제주·E700), 그 외는 이름순
    Object.keys(byL).forEach(function(L){ byL[L].sort(function(a,b){ var ra=ssZoneRank(a), rb=ssZoneRank(b); if(ra!==rb) return ra-rb; return a.localeCompare(b,'ko'); }); });
    // 그룹키(L) → 표시라벨(물류센터명) 매핑 — 데시보드2와 공유하는 순서 기준(라벨)
    window.ssGroupLabels={};
    letters.forEach(function(L){ if(L==='OSAN'){ window.ssGroupLabels[L]='오산센터'; return; } var _n=(''+(byL[L][0]||'')).replace(/\s*\d+\s*$/,'').trim(); window.ssGroupLabels[L]=(_n.length>1)?_n:(L+'출고장'); });
    ssGroupOrder=ssGordLoad();   // 최신 공유 순서 반영(데시보드2에서 바꾼 것도 즉시 적용)
    // 그룹 순서: 저장된 사용자 지정 순서(물류센터명 기준) 우선, 미지정 그룹은 ㄱㄴㄷ순 뒤에 (데시보드2와 동일 규칙)
    letters.sort(function(a,b){
      var la=window.ssGroupLabels[a], lb=window.ssGroupLabels[b];
      var ia=ssGroupOrder.indexOf(la), ib=ssGroupOrder.indexOf(lb);
      if(ia>=0 && ib>=0) return ia-ib;
      if(ia>=0) return -1;
      if(ib>=0) return 1;
      return la.localeCompare(lb,'ko');
    });
    window.ssLetters=letters.slice();
    ssGordRenderPop(letters);
    // 출고장별 납기일자 — 출고일자와 같든 다르든 항상 표시
    var zoneDlv={};
    (SHIP_DATA||[]).forEach(function(r){ if(!r||!r.zone) return; var d=(''+(r.dlvDt||'')).trim(); if(!d) return; (zoneDlv[r.zone]=zoneDlv[r.zone]||{})[d]=1; });
    function zoneDlvNote(z){
      var a=Object.keys(zoneDlv[z]||{}).filter(function(d){ return !!d; }).sort();
      return a.length ? ' <span class="sub2" style="color:#c47f17;font-weight:700">(납기일자 '+a.join(', ')+')</span>' : '';
    }
    var colTot={}, grand=0, tb='';
    letters.forEach(function(L){
      var col; if(L in ssZoneCollapsed){ col=!!ssZoneCollapsed[L]; } else { col=ssZoneDefaultCollapsed; ssZoneCollapsed[L]=col; }   // 기본=펼침
      // 그룹 라벨: OSAN→'오산센터', 그 외는 출고장명 끝 숫자 떼어 물류센터명 (ssGroupLabels 재사용)
      var _glabel=window.ssGroupLabels[L] || ((''+(byL[L][0]||'')).replace(/\s*\d+\s*$/,'').trim() || (L+'출고장'));
      var lgDesc=byL[L].length+'개 출고장'+(col?' <span style="color:#9aa7b3">— 접힘(클릭하여 펼치기)</span>':'');
      tb+='<tr class="lgrp" onclick="ssToggleZone(\''+L+'\')">'
        + wrapSum('<td class="stick"><span class="zcaret" id="zc_'+L+'">'+(col?'▶':'▼')+'</span> '+_glabel+'</td>', ssBannerCells(lgDesc), '<td class="colsum"></td>') + '</tr>';
      var lCol={}, lSum=0;
      byL[L].forEach(function(z){
        var rowSum=0, cells='';
        keys.forEach(function(k){
          var v=(ag.matrix[z]&&ag.matrix[z][k])||0; rowSum+=v; colTot[k]=(colTot[k]||0)+v; lCol[k]=(lCol[k]||0)+v;
          if(ssEditable){
            cells+='<td class="num edit'+gs(k)+(v>0?'':' zero')+'" contenteditable="true" data-z="'+z+'" data-k="'+(''+k).replace(/"/g,'&quot;')+'" onblur="ssEditCell(this)" onkeydown="ssEditKey(event,this)">'+(v>0?ssNum(v):'')+'</td>';
          } else {
            cells+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>';
          }
        });
        grand+=rowSum; lSum+=rowSum;
        var _isExZ=(ssExtraZones||[]).indexOf(z)>=0, _zdelx=(_isExZ&&rowSum===0)?' <span class="delx" data-dz="'+z+'" onclick="ssDelZone(event,this)" title="추가 출고장 삭제(수량 없음)">✕</span>':'';
        tb+='<tr class="zg_'+L+'"'+(col?' style="display:none"':'')+'>'+wrapSum('<td class="stick">&nbsp;&nbsp;'+z+' 출고장'+zoneDlvNote(z)+_zdelx+'</td>', cells, '<td class="num colsum">'+ssNum(rowSum)+'</td>')+'</tr>';
      });
      var lc=''; keys.forEach(function(k){ lc+='<td class="num'+gs(k)+'">'+ssNum(lCol[k]||0)+'</td>'; });
      tb+='<tr class="lsub">'+wrapSum('<td class="stick">'+_glabel+' 합계</td>', lc, '<td class="num colsum">'+ssNum(lSum)+'</td>')+'</tr>';
    });
    // 전체 출고장 합계
    var ztc=''; keys.forEach(function(k){ ztc+='<td class="num'+gs(k)+'">'+ssNum(colTot[k]||0)+'</td>'; });
    tb+='<tr class="ztot">'+wrapSum('<td class="stick">전체 출고장 합계</td>', ztc, '<td class="num colsum">'+ssNum(grand)+'</td>')+'</tr>';
    // 미배정(존 미지정) 행 — 존이 비어 집계에서 빠진 발주
    if(ag.unassigned>0){
      var uTitle=('출고장 미지정 발주\n'+(ag.unassignedList||[]).join('\n')).replace(/"/g,'&quot;');
      var uLbl='⚠ 미배정 '+ag.unassigned+'건';
      var uc=''; keys.forEach(function(k){ var c=ag.unCnt[k]||0, v=ag.unMatrix[k]||0; uc+= c>0?'<td class="num uhl'+gs(k)+'" title="미배정 '+c+'건 (출고장·수량 미지정)">'+(v>0?ssNum(v):'0')+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
      tb+='<tr class="unrow">'+wrapSum('<td class="stick" title="'+uTitle+'">'+uLbl+'</td>', uc, '<td class="num colsum">'+ssNum(ag.unTot)+'</td>')+'</tr>';
    }

    // ── 하단 출고내역 · 재고량
    tb+='<tr class="sec">'+wrapSum('<td class="stick">📦 출고내역·재고</td>', ssBannerCells('<span style="font-weight:400;color:#aef0e7">선택일=선택기간 출고 / 당월=이번달 전체 / 월별·재고량 데모값</span>'), '<td class="colsum"></td>')+'</tr>';
    // 재고량(기초)
    var sc='',st=0;
    keys.forEach(function(k){ var it=ag.items[k]; var base=30+(ssHash(it.code||it.name)%150); it._base=base; st+=base; sc+='<td class="num'+gs(k)+'">'+ssNum(base)+'</td>'; });
    tb+='<tr class="r-stock">'+wrapSum('<td class="stick">재고량(기초)</td>', sc, '<td class="num colsum">'+ssNum(st)+'</td>')+'</tr>';
    // ★ 선택일(당일/기간) 출고 = 현재 선택 범위 집계 (colTot) — 강조
    var selLbl=(from&&from===to)?(from===SS_TODAY?'당일 출고':'선택일 출고'):'기간 출고';
    var nc='',nt=0;
    keys.forEach(function(k){ var v=colTot[k]||0; nt+=v; nc+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
    tb+='<tr class="r-sel">'+wrapSum('<td class="stick">▶ '+selLbl+'</td>', nc, '<td class="num colsum">'+ssNum(nt)+'</td>')+'</tr>';
    // ★ 매출액(납품매출액) — 출고량 바로 아래. 매입단가 엑셀의 품목코드별 매입금액 합
    var hasSales=Object.keys(ssSalesMap).length>0;
    var vc='', vt=0;
    keys.forEach(function(k){ var code=(''+(ag.items[k].code||'')).trim(); var v=(code&&ssSalesMap[code])||0; vt+=v; vc+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
    var salesLbl='💰 매출액'+(hasSales?'':' <span style="font-weight:400;color:#a85700">(매출금액 업로드 시 표시)</span>');
    tb+='<tr class="r-sales" title="'+(ssSalesSrc?('출처: '+ssSalesSrc).replace(/"/g,'&quot;'):'매출금액 엑셀을 업로드하세요')+'">'+wrapSum('<td class="stick">'+salesLbl+'</td>', vc, '<td class="num colsum">'+ssNum(vt)+'</td>')+'</tr>';
    // ★ 매입액 — 매출액 바로 아래. 매입금액 엑셀의 품목코드별 매입금액 합
    var hasCost=Object.keys(ssCostMap).length>0;
    var cc2='', ct2=0;
    keys.forEach(function(k){ var code=(''+(ag.items[k].code||'')).trim(); var v=(code&&ssCostMap[code])||0; ct2+=v; cc2+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
    var costLbl='🧾 매입액'+(hasCost?'':' <span style="font-weight:400;color:#5b6775">(매입금액 업로드 시 표시)</span>');
    tb+='<tr class="r-cost" title="'+(ssCostSrc?('출처: '+ssCostSrc).replace(/"/g,'&quot;'):'매입금액 엑셀을 업로드하세요')+'">'+wrapSum('<td class="stick">'+costLbl+'</td>', cc2, '<td class="num colsum">'+ssNum(ct2)+'</td>')+'</tr>';
    // ★ 마진 = 매출액 − 매입액 (품목별, 합계) — 매입액 없으면 0으로 보고 마진=매출액 표시
    var gc='', gt=0;
    keys.forEach(function(k){ var code=(''+(ag.items[k].code||'')).trim(); var sv=(code&&ssSalesMap[code])||0, cv2=(code&&ssCostMap[code])||0; var mg=sv-cv2; gt+=mg;
      gc+= (sv||cv2)?('<td class="num'+(mg<0?' neg':'')+gs(k)+'">'+ssNum(mg)+'</td>'):('<td class="num zero'+gs(k)+'">·</td>'); });
    var marginLbl='📊 마진(매출−매입)'+(hasCost?'':' <span style="font-weight:400;color:#5b6775">(매입 미반영 — 매출액 기준)</span>');
    tb+='<tr class="r-margin">'+wrapSum('<td class="stick">'+marginLbl+'</td>', gc, '<td class="num colsum'+(gt<0?' neg':'')+'">'+ssNum(gt)+'</td>')+'</tr>';
    // 당월 출고 = 이번달 전체(선택범위와 무관, 월 기준)
    var ym=SS_TODAY.slice(0,7), mTot={};
    SHIP_DATA.forEach(function(r){ if(!r.zone) return; var d=(''+(r.date||SS_TODAY)); if(d.slice(0,7)!==ym) return; var c=(''+(r.code||'')).trim(), kk=c?c:('NM:'+r.item); mTot[kk]=(mTot[kk]||0)+(+r.qty||0); });
    var mc2='', mAll=0;
    keys.forEach(function(k){ var v=mTot[k]||0; mAll+=v; mc2+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
    tb+='<tr class="r-now">'+wrapSum('<td class="stick">당월 출고('+ym+')</td>', mc2, '<td class="num colsum">'+ssNum(mAll)+'</td>')+'</tr>';
    // 현재고 = 기초 - 선택일 출고
    var cc='',ct=0;
    keys.forEach(function(k){ var it=ag.items[k]; var cur=(it._base||0)-(colTot[k]||0); ct+=cur; cc+='<td class="num'+(cur<0?' neg':'')+gs(k)+'">'+ssNum(cur)+'</td>'; });
    tb+='<tr class="r-stock">'+wrapSum('<td class="stick">현재고</td>', cc, '<td class="num colsum">'+ssNum(ct)+'</td>')+'</tr>';
    // 월별(데모) — 접기/펼치기 가능 (헤더 클릭 토글)
    var _mcol=ssMonthCollapsed;
    tb+='<tr class="lgrp" onclick="ssToggleMonth()">'
      + wrapSum('<td class="stick"><span class="zcaret" id="zc_month">'+(_mcol?'▶':'▼')+'</span> 월별 출고(데모)'+(_mcol?' <span style="color:#9aa7b3">— 접힘(클릭하여 펼치기)</span>':'')+'</td>', ssBannerCells(SS_MONTHS.length+'개월'), '<td class="colsum"></td>') + '</tr>';
    SS_MONTHS.forEach(function(mn){
      var mc='',mt=0;
      keys.forEach(function(k){ var it=ag.items[k]; var v=ssHash((it.code||it.name)+mn)%9; mt+=v; mc+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
      tb+='<tr class="r-month"'+(_mcol?' style="display:none"':'')+'>'+wrapSum('<td class="stick">'+mn+' 출고</td>', mc, '<td class="num colsum">'+ssNum(mt)+'</td>')+'</tr>';
    });

    tbl.innerHTML='<thead>'+th1+th2+'</thead><tbody>'+tb+'</tbody>';
    tbl.classList.toggle('sumfront', ssSumFront);   // 맨앞이면 합계를 출고장 옆 좌측고정
    if(ssSumFront){ var swc=tbl.querySelector('thead th.stick'); if(swc) tbl.style.setProperty('--stickw', swc.offsetWidth+'px'); }
    if(ssBizAnim){ tbl.classList.add('ssc-on'); _ssAnimFocus(); }   // 재렌더 후 현재 사업장 초점 복원
  }

  // ── 사업장 찾기 — 전체는 그대로 보이면서, 찾은 사업장 헤더를 강조 + 그 위치로 스크롤 ──
  //  exactOnly=true : 정확히 일치하는 사업장명일 때만 동작(타이핑 중 과도한 동작 방지)
  function ssBizFind(q, exactOnly){
    q=(q||'').trim(); if(!q) return;
    var sel=document.getElementById('ssBizSel'); if(!sel) return;
    var name=null, part=null;
    for(var i=0;i<sel.options.length;i++){
      var v=sel.options[i].value; if(v==='__ALL__') continue;
      if(v===q){ name=v; break; }
      if(!part && v.indexOf(q)>=0){ part=v; }
    }
    if(!name && !exactOnly) name=part;
    if(!name){ if(!exactOnly) ssToast('🔎 "'+q+'" 사업장을 찾을 수 없습니다.'); return; }
    // 전체가 보이도록 보장 — 필터 해제 + 해당 사업장 숨김 해제 (변경 있을 때만 재렌더)
    var need=false;
    if(sel.value!=='__ALL__'){ sel.value='__ALL__'; need=true; }
    if(ssBizHidden[name]){ delete ssBizHidden[name]; need=true; }
    if(need) ssRender();
    _ssHighlightBiz(name);
  }
  // 찾은 사업장 헤더 강조 + 가운데로 수평 스크롤
  function _ssHighlightBiz(name){
    var box=_ssScrollBox(), tbl=document.getElementById('ssWideTbl');
    if(!box||!tbl) return;
    var ths=tbl.querySelectorAll('thead th.bizh'), hit=null;
    for(var i=0;i<ths.length;i++){
      ths[i].classList.remove('ss-find-hit','ss-find-pulse');
      if(ths[i].getAttribute('data-br')===name) hit=ths[i];
    }
    if(!hit){ return; }
    hit.classList.add('ss-find-hit');
    // 가운데로 수평 스크롤
    var rb=box.getBoundingClientRect(), rt=hit.getBoundingClientRect();
    box.scrollLeft += (rt.left + rt.width/2) - (rb.left + box.clientWidth/2);
    // 펄스 강조(잠깐 깜빡)
    void hit.offsetWidth; hit.classList.add('ss-find-pulse');
  }
  function ssBizFindClear(){
    var inp=document.getElementById('ssBizFind'); if(inp) inp.value='';
    var tbl=document.getElementById('ssWideTbl');
    if(tbl){ var ths=tbl.querySelectorAll('thead th.bizh.ss-find-hit'); for(var i=0;i<ths.length;i++) ths[i].classList.remove('ss-find-hit','ss-find-pulse'); }
    var sel=document.getElementById('ssBizSel'); if(sel && sel.value!=='__ALL__'){ sel.value='__ALL__'; ssRender(); }
  }

  // ── 확대/축소(줌) — 기본화면·전체화면 양쪽에서 표 영역(.ss-scroll) 확대·축소 ──
  var ssZoom=1;
  function _ssApplyZoom(){
    var b=_ssScrollBox(); if(b) b.style.zoom=ssZoom;
    var l=document.getElementById('ssZoomLbl'); if(l) l.textContent=Math.round(ssZoom*100)+'%';
  }
  // 현재 모드(전체화면 vs 기본화면) 선택표시 갱신
  function _ssUpdateModeBtns(){
    var c=_ssFsCard();
    var on = !!(c && (c.classList.contains('ss-fullscreen') || document.fullscreenElement===c));
    var bf=document.getElementById('ssBtnFull'), bb=document.getElementById('ssBtnBasic');
    if(bf) bf.classList.toggle('seg-on', on);
    if(bb) bb.classList.toggle('seg-on', !on);
  }
  function ssZoomIn(){ ssZoom=Math.min(2.5, Math.round((ssZoom+0.1)*10)/10); _ssApplyZoom(); }
  function ssZoomOut(){ ssZoom=Math.max(0.5, Math.round((ssZoom-0.1)*10)/10); _ssApplyZoom(); }
  function ssZoomReset(){ ssZoom=1; _ssApplyZoom(); }

  // ── 전체화면(출고현황표가 화면 전체를 덮음) / 기본화면(복귀) ──
  function _ssFsCard(){ return document.getElementById('ssCard'); }
  function ssFullExpand(){
    var c=_ssFsCard(); if(!c) return;
    // 브라우저 Fullscreen API 우선(진짜 전체화면), 막히면 CSS 오버레이로 화면 덮기
    if(c.requestFullscreen){ c.requestFullscreen().then(function(){ c.classList.add('ss-fullscreen'); _ssUpdateModeBtns(); }).catch(function(){ _ssCoverOn(c); }); }
    else { _ssCoverOn(c); }
  }
  function ssFullExit(){
    if(document.fullscreenElement){ if(document.exitFullscreen) document.exitFullscreen(); }
    _ssCoverOff();
    ssZoomReset();   // 기본화면 = 전체화면 해제 + 원래 크기로
  }
  function _ssCoverOn(c){ c.classList.add('ss-fullscreen'); document.body.style.overflow='hidden'; _ssUpdateModeBtns(); }
  function _ssCoverOff(){ var c=_ssFsCard(); if(c) c.classList.remove('ss-fullscreen'); document.body.style.overflow=''; _ssUpdateModeBtns(); }
  document.addEventListener('fullscreenchange', function(){
    var c=_ssFsCard(); if(!c) return;
    if(document.fullscreenElement===c){ c.classList.add('ss-fullscreen'); }
    else { c.classList.remove('ss-fullscreen'); document.body.style.overflow=''; }
    _ssUpdateModeBtns();
  });

  // ── 사업장 회전 캐러셀 (옵션 체크 시: 사업장을 가운데로 두고 5초마다 좌→우, 끝나면 우→좌로 왕복) ──
  var ssBizAnim=false, _ssAnimTimer=null, _ssAnimIdx=-1, _ssAnimDir=1;
  function _ssScrollBox(){ var t=document.getElementById('ssWideTbl'); return t ? t.closest('.ss-scroll') : null; }
  // 각 사업장(bizh) 그룹을 가시영역 '가운데'로 보내는 스크롤 위치(그룹 순서대로)
  function _ssGroupCenters(){
    var box=_ssScrollBox(), tbl=document.getElementById('ssWideTbl');
    if(!box||!tbl) return [];
    var max=box.scrollWidth-box.clientWidth; if(max<=1) return [];
    var stickW=0;   // 좌측 고정열 폭 — 가운데 계산 시 가시영역에서 제외
    var sc=tbl.querySelector('thead th.stick'); if(sc) stickW+=sc.offsetWidth;
    if(tbl.classList.contains('sumfront')){ var cs=tbl.querySelector('thead th.colsum'); if(cs) stickW+=cs.offsetWidth; }
    var viewCenter=stickW+(box.clientWidth-stickW)/2;
    var arr=[];
    tbl.querySelectorAll('thead th.bizh').forEach(function(th){
      var center=th.offsetLeft+th.offsetWidth/2;
      var left=Math.round(center-viewCenter); if(left<0) left=0; if(left>max) left=max;
      arr.push(left);
    });
    return arr;   // index = 사업장 그룹 인덱스(좌→우)
  }
  // 현재 _ssAnimIdx 사업장만 또렷하게(초점), 나머지는 흐리게
  function _ssAnimFocus(){
    var tbl=document.getElementById('ssWideTbl'); if(!tbl) return;
    tbl.querySelectorAll('.ssc-focus').forEach(function(c){ c.classList.remove('ssc-focus'); });
    if(_ssAnimIdx<0) return;
    tbl.querySelectorAll('.bg'+_ssAnimIdx).forEach(function(c){ c.classList.add('ssc-focus'); });
  }
  function _ssAnimStep(){
    var box=_ssScrollBox(); if(!box) return;
    var centers=_ssGroupCenters(); var n=centers.length; if(n<=0) return;
    if(_ssAnimIdx<0 || _ssAnimIdx>=n){ _ssAnimIdx=0; _ssAnimDir=1; }   // 시작 → 맨 좌측에서 우측으로
    else if(n>1){
      if(_ssAnimIdx+_ssAnimDir>n-1 || _ssAnimIdx+_ssAnimDir<0) _ssAnimDir=-_ssAnimDir;   // 끝 도달 → 방향 반전(왕복)
      _ssAnimIdx+=_ssAnimDir;
    }
    box.scrollTo({left:centers[_ssAnimIdx], behavior:'smooth'});
    _ssAnimFocus();
  }
  function ssToggleBizAnim(){
    var cb=document.getElementById('ssBizAnim'); ssBizAnim=!!(cb&&cb.checked);
    if(_ssAnimTimer){ clearInterval(_ssAnimTimer); _ssAnimTimer=null; }
    var tbl=document.getElementById('ssWideTbl');
    _ssAnimIdx=-1; _ssAnimDir=1;
    if(ssBizAnim){
      if(tbl) tbl.classList.add('ssc-on');
      var centers=_ssGroupCenters();   // 시작은 맨 좌측 사업장에서 우측으로
      if(centers.length){ _ssAnimIdx=0; var box=_ssScrollBox(); if(box) box.scrollTo({left:centers[_ssAnimIdx], behavior:'smooth'}); _ssAnimFocus(); }
      _ssAnimTimer=setInterval(_ssAnimStep, 5000);
    } else {
      if(tbl){ tbl.classList.remove('ssc-on'); tbl.querySelectorAll('.ssc-focus').forEach(function(c){ c.classList.remove('ssc-focus'); }); }
    }
  }

  // 합계 열 위치 (기본=끝)
  var ssSumFront=true;   // 합계 맨앞 기본 체크
  // 매출금액(매입단가 엑셀) — 품목코드별 매출액(매입금액 합)
  //   구조: ssSalesMap[품목코드] = 금액합
  var ssSalesMap={}, ssSalesCnt=0, ssSalesSrc='';
  // 매입금액 — 품목코드별 매입액 합 (엑셀 나중 제공). 마진 = 매출액 − 매입액
  var ssCostMap={}, ssCostCnt=0, ssCostSrc='';
  // 직접 수정용 품목 메타(키→이름/코드)
  var ssItemMeta={};
  // 직접 추가한 사업장·품목(빈 열) / 존(빈 행)
  var ssExtraItems=[];
  var ssExtraZones=[];

  // 사업장(열 그룹) 숨기기/보이기 — 헤더 클릭으로 숨김, 복원바로 펼침
  var ssBizHidden={};
  function ssBizHideName(b){ if(b){ ssBizHidden[b]=true; ssRender(); } }
  function ssBizShowName(b){ if(b){ delete ssBizHidden[b]; ssRender(); } }
  function ssBizShowAll(){ ssBizHidden={}; ssRender(); }

  // 월별(데모) 출고 접기/펼치기 — 상태 유지(재렌더에도 보존)
  var ssMonthCollapsed=true;   // 기본 접힘
  function ssToggleMonth(){
    ssMonthCollapsed=!ssMonthCollapsed;
    var rows=document.querySelectorAll('#ssWideTbl tr.r-month');
    for(var i=0;i<rows.length;i++) rows[i].style.display = ssMonthCollapsed?'none':'';
    var c=document.getElementById('zc_month'); if(c) c.textContent = ssMonthCollapsed?'▶':'▼';
  }
  // 존 그룹(A존~F존) 접기/펼치기 — 상태 유지(재렌더에도 보존)
  var ssZoneCollapsed={}, ssZoneDefaultCollapsed=false;   // 출고장 기본 펼침
  function ssToggleZone(L){
    ssZoneCollapsed[L]=!ssZoneCollapsed[L];
    var col=ssZoneCollapsed[L];
    var rows=document.querySelectorAll('#ssWideTbl tr.zg_'+L);
    for(var i=0;i<rows.length;i++) rows[i].style.display = col?'none':'';
    var c=document.getElementById('zc_'+L); if(c) c.textContent = col?'▶':'▼';
  }
  function ssAllZones(collapse){
    (window.ssLetters||[]).forEach(function(L){
      ssZoneCollapsed[L]=collapse;
      var rows=document.querySelectorAll('#ssWideTbl tr.zg_'+L);
      for(var i=0;i<rows.length;i++) rows[i].style.display = collapse?'none':'';
      var c=document.getElementById('zc_'+L); if(c) c.textContent = collapse?'▶':'▼';
    });
  }
  // 출고장 전체 펼치기/접기 — 단일 토글 버튼
  var ssAllCollapsed=false;   // 기본 펼침 상태와 동기화
  function ssToggleAllZones(){
    ssAllCollapsed=!ssAllCollapsed;
    ssAllZones(ssAllCollapsed);
    var b=document.getElementById('ssBtnZoneToggle');
    if(b) b.textContent = ssAllCollapsed ? '＋ 출고장 펼치기' : '－ 출고장 접기';
  }

  // ── 출고장 그룹(물류센터) 순서 설정 — 데시보드2와 공유(localStorage 'logiGroupOrder', 물류센터명 배열)
  var ssGroupOrder=[];
  function ssGordLoad(){ try{ ssGroupOrder=JSON.parse(localStorage.getItem('logiGroupOrder')||'[]')||[]; }catch(e){ ssGroupOrder=[]; } return ssGroupOrder; }
  function ssGordSave(){ try{ localStorage.setItem('logiGroupOrder', JSON.stringify(ssGroupOrder)); }catch(e){} }
  ssGordLoad();
  function ssGordOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('ssGordPop'); if(p) p.classList.toggle('open'); }
  function ssGordMove(L, dir){
    var lettersNow=(window.ssLetters||[]).slice();   // 현재 화면 표시 순서 기준으로 스왑
    var i=lettersNow.indexOf(L), j=i+dir;
    if(i<0 || j<0 || j>=lettersNow.length) return;
    var tmp=lettersNow[i]; lettersNow[i]=lettersNow[j]; lettersNow[j]=tmp;
    // 저장은 물류센터명(라벨) 배열로 — 데시보드2와 공유
    var lbl=window.ssGroupLabels||{};
    ssGroupOrder=lettersNow.map(function(x){ return lbl[x]||x; });
    ssGordSave(); ssRender();
  }
  function ssGordReset(){ ssGroupOrder=[]; ssGordSave(); ssRender(); }
  // 데시보드2(iframe)에서 순서를 바꾸면 즉시 반영 (같은 출처 localStorage 공유)
  window.addEventListener('storage', function(e){ if(e.key==='logiGroupOrder'){ ssGordLoad(); ssRender(); } });
  function ssGordRenderPop(letters){
    var pop=document.getElementById('ssGordPop'); if(!pop) return;
    var lbl=window.ssGroupLabels||{};
    var h=letters.map(function(L,ix){
      return '<div class="go-row"><span>'+(ix+1)+'. '+(lbl[L]||L)+'</span>'
        +'<span class="go-btns">'
        +'<button class="btn-line" style="padding:1px 8px" data-l="'+(''+L).replace(/"/g,'&quot;')+'" onclick="event.stopPropagation(); ssGordMove(this.getAttribute(\'data-l\'),-1)" title="위로">▲</button>'
        +'<button class="btn-line" style="padding:1px 8px" data-l="'+(''+L).replace(/"/g,'&quot;')+'" onclick="event.stopPropagation(); ssGordMove(this.getAttribute(\'data-l\'),1)" title="아래로">▼</button>'
        +'</span></div>';
    }).join('');
    h+='<div class="go-foot"><button class="btn-line" style="padding:3px 12px" onclick="event.stopPropagation(); ssGordReset()">↺ 순서 초기화 (ㄱㄴㄷ순)</button></div>';
    pop.innerHTML=h;
  }
  // 팝업 바깥 클릭 시 닫기
  document.addEventListener('click', function(e){
    var w=document.getElementById('ssGordWrap'), p=document.getElementById('ssGordPop');
    if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
  });

  // 토스트
  function ssToast(msg){
    var t=document.getElementById('ssToast');
    if(!t){ t=document.createElement('div'); t.id='ssToast'; t.className='ss-toast'; document.body.appendChild(t); }
    t.innerHTML=msg; t.classList.add('on');
    clearTimeout(t._tm); t._tm=setTimeout(function(){ t.classList.remove('on'); }, 3200);
  }

  // ── 발주현황표 업로드: 파일선택 → 미리보기 모달(시트선택) → 작성
  var ssPvWb=null, ssPvName='';

  // 엑셀 읽기 — 일부 ERP(코네트 등)가 생성한 비표준 xlsx 보정
  //   · sharedStrings.xml 의 <si > (꼬리 공백) → <si> 로 교정해야 SheetJS 가 문자열 셀(품목코드·품목명·헤더)을 읽음
  //   · JSZip 있으면 보정 후 읽고, 없으면(차단 등) 일반 읽기로 폴백
  function ssReadXlsx(arrayBuffer, onWb, onErr){
    function direct(){ try{ onWb(XLSX.read(new Uint8Array(arrayBuffer), {type:'array', cellDates:true})); }catch(e){ if(onErr) onErr(e); } }
    if(typeof JSZip==='undefined'){ direct(); return; }
    JSZip.loadAsync(arrayBuffer).then(function(zip){
      var f=zip.file('xl/sharedStrings.xml');
      if(!f){ direct(); return null; }
      return f.async('string').then(function(ss){
        if(ss.indexOf('<si ')<0 && ss.indexOf('</si ')<0){ direct(); return null; }  // 정상 파일은 그대로
        ss=ss.replace(/<si(\s+)>/g,'<si>').replace(/<\/si(\s+)>/g,'</si>');
        zip.file('xl/sharedStrings.xml', ss);
        return zip.generateAsync({type:'arraybuffer'}).then(function(buf){
          onWb(XLSX.read(new Uint8Array(buf), {type:'array', cellDates:true}));
        });
      });
    }).catch(function(){ direct(); });
  }

  // ── 업로드 자료 폴더 (File System Access API · Chrome/Edge). 폴더 지정 → 그 폴더의 xlsx 를 좌측에 나열, 클릭 → 우측 미리보기 ──
  var ssDirHandle=null, ssDirFiles=[], ssAutoPick=false;   // 모달 재오픈 시 최신 파일 자동선택
  var ssPvSkipAutoPick=false;   // [작성]·[초기화] 뒤 자동선택을 한 번 건너뛴다
  /* 인식결과 줄 오른쪽 끝의 [초기화] — float:right 라 문장보다 먼저 넣어야 첫 줄에 붙는다 */
  var SS_PV_RST='<span class="ss-pvrst" onclick="ssPvResetAsk()" title="올려 둔 엑셀을 화면에서 내립니다. 서버에 저장된 자료는 그대로입니다.">✕ 초기화</span>';
  function ssHistEsc(s){ return (''+(s==null?'':s)).replace(/[&<>"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c];}); }
  function ssFmtSize(n){ return n>=1048576 ? (n/1048576).toFixed(1)+'MB' : Math.max(1,Math.round(n/1024))+'KB'; }
  function ssFmtTime(ms){ var d=new Date(ms),p=function(n){return(n<10?'0':'')+n;}; return d.getFullYear()+'-'+p(d.getMonth()+1)+'-'+p(d.getDate())+' '+p(d.getHours())+':'+p(d.getMinutes()); }
  // 지정 폴더를 IndexedDB에 기억 → 다음 실행 때 경로 유지(권한만 재허용)
  function ssIdb(){ return new Promise(function(res,rej){ var r=indexedDB.open('ss_fs',1); r.onupgradeneeded=function(){ try{ r.result.createObjectStore('h'); }catch(e){} }; r.onsuccess=function(){ res(r.result); }; r.onerror=function(){ rej(r.error); }; }); }
  function ssIdbPut(h){ return ssIdb().then(function(db){ return new Promise(function(res){ var t=db.transaction('h','readwrite'); t.objectStore('h').put(h,'dir'); t.oncomplete=function(){ res(); }; t.onerror=function(){ res(); }; }); }).catch(function(){}); }
  function ssIdbGet(){ return ssIdb().then(function(db){ return new Promise(function(res){ var t=db.transaction('h','readonly'); var g=t.objectStore('h').get('dir'); g.onsuccess=function(){ res(g.result||null); }; g.onerror=function(){ res(null); }; }); }).catch(function(){ return null; }); }

  function ssPickDir(){
    if(!window.showDirectoryPicker){
      ssToast('⚠️ 이 접속에서는 폴더 지정을 쓸 수 없습니다(https/localhost 필요). <b>📄 파일 선택</b>으로 진행하세요.');
      return;
    }
    var p;
    // startIn:'downloads' = 다운로드에서 열림 / id = 지정한 폴더를 다음부터 기억(같은 위치에서 열림)
    //  ★다운로드 '루트' 는 브라우저가 막는다(시스템 폴더 취급) → 그 안에 전용 하위폴더를 만들어 지정해야 한다
    try{ p=window.showDirectoryPicker({mode:'readwrite', startIn:'downloads', id:'ssOrderDir'}); }
    catch(e){ ssToast('⚠️ 폴더 지정 오류: '+ssHistEsc(e&&e.message||'')); return; }
    p.then(function(h){ ssDirHandle=h; ssIdbPut(h); ssAutoPick=true; ssDirList(); })   // readwrite = 목록 + 삭제
     .catch(function(e){ if(e && e.name==='AbortError') return;   // 취소는 무시
       ssToast('⚠️ 폴더 지정 실패: '+ssHistEsc((e&&(e.name+': '+e.message))||'')
         +'<br><b>다운로드 폴더 자체</b>는 브라우저가 막습니다. 그 안에 <b>「코네트_발주현황표」</b> 같은 하위폴더를 만들어 지정하세요.'); });
  }
  function ssDirRestore(){ if(ssDirHandle) return Promise.resolve(); return ssIdbGet().then(function(h){ if(h) ssDirHandle=h; }); }
  // 목록 표시 — 권한 확인은 queryPermission(제스처 불필요)만. 권한 없으면 '이 폴더 열기' 버튼 표시.
  function ssDirList(){
    var box=document.getElementById('ssPvHist'), nm=document.getElementById('ssPvDirName'); if(!box) return;
    if(!window.showDirectoryPicker){ if(nm) nm.textContent=''; box.innerHTML='<div style="padding:12px;color:#9aa7b3;font-size:13px;line-height:1.6">이 브라우저는 폴더 지정을<br>지원하지 않습니다.<br>위쪽 <b>📄 파일 선택</b>으로 진행하세요.<br>(Chrome/Edge 권장)</div>'; return; }
    if(!ssDirHandle){ if(nm) nm.textContent='';
      /* 종전엔 여기에 '다운로드 폴더는 못 지정한다 / 하위폴더를 만들어라' 안내 상자가 붙어 있었다.
         화면을 차지해 지웠다(2026-08-01 요청). 같은 내용은 두 곳에 남아 있다 —
           · [📂 폴더 지정] 버튼 hover(title)
           · ℹ️ 도움말 ▸ ⚙️ 받은 파일이 바로 그 폴더에 쌓이게 하기 */
      box.innerHTML='<div style="padding:12px;color:#9aa7b3;font-size:13px;line-height:1.6">위쪽 <b>📂 폴더 지정</b>을 눌러<br>자료 폴더를 선택하면<br>파일이 여기 표시됩니다.<br><span style="color:#b6c0c9">자세한 설명은 위쪽 <b>ℹ️ 도움말</b>.</span></div>'; return; }
    if(nm) nm.textContent='📂 '+ssDirHandle.name;
    ssDirHandle.queryPermission({mode:'readwrite'}).then(function(p){
      if(p==='granted'){ box.innerHTML='<div style="padding:10px;color:#9aa7b3;font-size:13px">불러오는 중…</div>'; ssDirScan(); }
      else { box.innerHTML='<div style="padding:12px;color:#b3760f;font-size:13px;line-height:1.6">저장된 폴더(<b>'+ssHistEsc(ssDirHandle.name)+'</b>)를<br>다시 사용하려면 권한이 필요합니다.<br><button class="btn-teal" style="margin-top:8px;padding:4px 12px" onclick="ssGrantDir()">📂 이 폴더 열기</button></div>'; }
    }).catch(function(e){ box.innerHTML='<div style="padding:12px;color:#c0392b;font-size:12px">폴더 오류: '+ssHistEsc(e&&e.message||'')+'</div>'; });
  }
  // 사용자 클릭(제스처) 안에서만 권한 요청 — requestPermission 을 즉시 호출해야 'User activation' 오류가 안 남
  function ssGrantDir(){
    if(!ssDirHandle) return;
    ssDirHandle.requestPermission({mode:'readwrite'}).then(function(p){ if(p==='granted') ssDirList(); else ssToast('폴더 접근이 거부되었습니다. [폴더 지정]으로 다시 선택하세요.'); }).catch(function(){});
  }
  // 발주 파일: 'YYYY.MM.DD_HH.MM.SS' 날짜시각으로 시작하는 xlsx — 뒤에 붙는 이름은 무엇이든 상관없음(2026-07-26 사용자).
  //   포함: 2026.07.04_13.25.10.xlsx , … - 복사본.xlsx , … (1).xlsx(같은 파일 재다운로드) , …(출고장).xlsx
  //   제외: 매출장·메인웰스토리 등 한글로 시작하는 것(앞 날짜시각이 없음)
  //   ※ 종전엔 '(' 가 든 이름을 통째로 뺐는데, 재다운로드분 ' (1)' 까지 목록에서 사라져 제거함
  var SS_NAME_RE=/^\d{4}\.\d{2}\.\d{2}_\d{2}\.\d{2}\.\d{2}/;
  function ssDirScan(){
    var autoPick=ssAutoPick; ssAutoPick=false;   // 이번 스캔에서만 소비(삭제/새로고침 스캔엔 자동선택 안 함)
    ssDirFiles=[];
    var it=ssDirHandle.values(), tasks=[];
    function step(){ return it.next().then(function(res){
      if(res.done) return;
      var h=res.value;
      if(h.kind==='file' && /\.xlsx?$/i.test(h.name) && SS_NAME_RE.test(h.name)){
        tasks.push(h.getFile().then(function(f){ ssDirFiles.push({name:h.name, time:f.lastModified, size:f.size, handle:h}); }));
      }
      return step();
    }); }
    step().then(function(){ return Promise.all(tasks); }).then(function(){
      ssDirFiles.sort(function(a,b){ return b.time-a.time; });   // 최신순
      ssHistRenderList();
      // 재오픈 시 최신 파일을 우측에 자동 표시(이미 그 파일이 열려 있으면 재파싱 생략)
      if(autoPick && ssDirFiles.length && ssDirFiles[0].name!==ssPvName) ssDirOpen(0);
    }).catch(function(){ ssHistRenderList(); });
  }
  function ssHistRenderList(){
    var box=document.getElementById('ssPvHist'); if(!box) return;
    if(!ssDirFiles.length){ box.innerHTML='<div style="padding:12px;color:#9aa7b3;font-size:13px">폴더에 엑셀(xlsx) 파일이<br>없습니다.</div>'; return; }
    box.innerHTML=ssDirFiles.map(function(x,i){
      var cur=(x.name===ssPvName), m=ssDirMetaGet(x) || (i>=SS_DIRMETA_MAX ? {skip:1} : null);
      return '<div onclick="ssDirOpen('+i+')" title="'+ssHistEsc(x.name)+ssDirMetaTip(m)+'&#10;클릭하면 우측에 표시" '
        +'style="padding:5px 9px 6px;border-bottom:1px solid #eef3f1;cursor:pointer;font-size:13px'+(cur?';background:#e7f3ef':'')+'">'
        +'<div style="display:flex;align-items:center;gap:8px">'
          +'<span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;'+(cur?'font-weight:700;color:#137a6c':'color:#28323c')+'">📄 '+ssHistEsc(x.name)+'</span>'
          +'<span style="flex:0 0 auto;color:#9aa7b3;white-space:nowrap;font-size:12px">'+ssFmtTime(x.time)+' · <b style="color:#6b7a89">'+ssFmtSize(x.size)+'</b></span>'
          +'<span onclick="event.stopPropagation();ssDirDelete('+i+')" title="이 파일 삭제" style="flex:0 0 auto;cursor:pointer;color:#c0392b;font-size:14px;padding:0 2px">🗑</span>'
        +'</div>'
        // 2행 = 파일을 실제로 읽어 뽑은 출고장 묶음(아래 '올린 이력'과 같은 형식)
        +'<div id="ssDirMeta'+i+'" style="display:flex;align-items:center;gap:5px;color:#9aa7b3;font-size:11.5px;margin-top:1px">'+ssDirMetaHtml(m)+'</div>'
      +'</div>';
    }).join('');
    ssDirMetaScan();     // 아직 안 읽은 파일은 뒤에서 하나씩 열어 출고장을 채운다
  }
  /* ══ 폴더 엑셀의 출고장 미리읽기 (2026-07-27 사용자 지시) ═════════════════════════════
       아래 '올린 이력'처럼 위 목록에도 출고장을 보여 달라는 요청. 서버엔 아직 없는 자료라
       파일을 직접 읽어야 한다 → 목록을 먼저 그린 뒤 백그라운드로 한 파일씩 파싱해 2행을 채운다.
        · 캐시키 = 파일명|수정시각|크기 → localStorage 보관(같은 파일을 다시 파싱하지 않는다).
          파일이 바뀌면 수정시각·크기가 달라져 자동으로 다시 읽는다.
        · 파싱은 무겁다(1건 수십~수백ms) → 순차 + setTimeout 으로 UI를 막지 않고,
          목록이 아주 길면 최신 SS_DIRMETA_MAX 개까지만 읽는다(나머지는 '—' 로 둔다).       */
  var ssDirMeta=(function(){ try{ return JSON.parse(localStorage.getItem('ssDirMeta')||'{}')||{}; }catch(e){ return {}; } })();
  var ssDirMetaBusy=false;
  var SS_DIRMETA_MAX=60;
  function ssDirMetaKey(x){ return x.name+'|'+x.time+'|'+x.size; }
  function ssDirMetaGet(x){ return ssDirMeta[ssDirMetaKey(x)]||null; }
  function ssDirMetaSave(){
    try{
      var ks=Object.keys(ssDirMeta);
      if(ks.length>300){ var d={}; ks.slice(-300).forEach(function(k){ d[k]=ssDirMeta[k]; }); ssDirMeta=d; }
      localStorage.setItem('ssDirMeta', JSON.stringify(ssDirMeta));
    }catch(e){}
  }
  // 워크북 → {dcs:[출고장], dcRow:{출고장:행수}, cnt:행수, dlvMin, dlvMax}
  function ssDirMetaOf(wb){
    var ws=wb.Sheets[(wb.SheetNames||[])[0]];
    var aoa=ws?XLSX.utils.sheet_to_json(ws,{header:1,defval:''}):[];
    var m=ssMapCols(aoa);
    if(!m) return { bad:1 };                                  // 발주현황표 양식이 아님
    var rows=ssExtractRows(aoa,m);
    var o={ dcs:[], dcRow:{}, cnt:rows.length, dlvMin:'', dlvMax:'' }, seen={};
    rows.forEach(function(r){
      // '용인물류센터1' → '용인' / 예전 2행헤더 양식은 존이 코드('E100')로 들어와 그것도 이름으로 바꾼다
      var dc=konetDcNmOf({ dcCd:r.zone, dcNm:r.zone })||'미기재';
      if(!seen[dc]){ seen[dc]=1; o.dcs.push(dc); }
      o.dcRow[dc]=(o.dcRow[dc]||0)+1;
      var d=(''+(r.dlvDt||'')).replace(/-/g,'');
      if(d){ if(!o.dlvMin||d<o.dlvMin) o.dlvMin=d; if(!o.dlvMax||d>o.dlvMax) o.dlvMax=d; }
    });
    return o;
  }
  function ssDirMetaHtml(m){
    if(!m)     return '<span style="flex:1;color:#b6c0c9">출고장 확인 중…</span>';
    if(m.skip) return '<span style="flex:1;color:#b6c0c9">—</span>';
    if(m.bad)  return '<span style="flex:1;color:#c0392b">발주현황표 양식이 아닙니다</span>';
    if(m.err)  return '<span style="flex:1;color:#c0392b">파일을 읽지 못했습니다</span>';
    var dcTxt=(m.dcs&&m.dcs.length) ? (m.dcs.length+'곳 · '+m.dcs.join('·')) : '미기재';
    var dl = m.dlvMin ? (m.dlvMin===m.dlvMax ? ssUpHistMd(m.dlvMin) : (ssUpHistMd(m.dlvMin)+'~'+ssUpHistMd(m.dlvMax).slice(3))) : '-';
    // 행수도 함께 — 아래 '올린 이력'의 '147행' 과 같은 표기(2026-07-27 사용자)
    return '<span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">출고장 '+ssHistEsc(dcTxt)+'</span>'
         + '<span style="flex:0 0 auto;color:#6b7a89"><b>'+(+m.cnt||0).toLocaleString()+'</b>행</span>'
         + '<span style="flex:0 0 auto">납기 '+dl+'</span>';
  }
  // 툴팁은 두 갈래 — 처음 그릴 때는 HTML 속성(&#10;), 나중에 JS 로 title 을 갈아끼울 때는 생문자(\n).
  //   JS 로 '&#10;' 를 넣으면 글자 그대로 보인다(속성 파싱이 아니라 프로퍼티 대입이라서).
  function ssDirMetaTipTxt(m){
    if(!m || m.skip || m.bad || m.err) return '';
    var det=(m.dcs||[]).map(function(d){ return d+' '+(m.dcRow[d]||0); }).join(' · ');
    return '\n출고장 '+det+' (행)\n데이터 '+(+m.cnt||0).toLocaleString()+'건';
  }
  function ssDirMetaTip(m){ return ssHistEsc(ssDirMetaTipTxt(m)).replace(/\n/g,'&#10;'); }
  function ssDirMetaScan(){
    if(ssDirMetaBusy || typeof XLSX==='undefined') return;
    var todo=[];
    ssDirFiles.forEach(function(x,i){
      if(ssDirMetaGet(x) || i>=SS_DIRMETA_MAX) return;   // 이미 읽음 / 너무 많으면 최신것만(skip 은 캐시에 남기지 않는다)
      todo.push({x:x, i:i});
    });
    if(!todo.length) return;
    ssDirMetaBusy=true;
    var n=0;
    var put=function(t,m){
      ssDirMeta[ssDirMetaKey(t.x)]=m;
      var el=document.getElementById('ssDirMeta'+t.i);
      if(el) el.innerHTML=ssDirMetaHtml(m);
      var row=el&&el.parentNode; if(row) row.title=t.x.name+ssDirMetaTipTxt(m)+'\n클릭하면 우측에 표시';
      setTimeout(step, 0);
    };
    var step=function(){
      if(n>=todo.length){ ssDirMetaBusy=false; ssDirMetaSave(); return; }
      var t=todo[n++];
      t.x.handle.getFile().then(function(f){ return f.arrayBuffer(); }).then(function(buf){
        ssReadXlsx(buf, function(wb){ var m; try{ m=ssDirMetaOf(wb); }catch(e){ m={err:1}; } put(t,m); },
                        function(){ put(t,{err:1}); });
      }).catch(function(){ put(t,{err:1}); });
    };
    setTimeout(step, 300);  // 목록·자동펼침(최신 파일 미리보기)이 먼저 끝난 뒤 시작
  }
  // 목록의 파일을 '_삭제됨' 하위폴더로 이동(소프트 삭제 — 복구 가능). readwrite 권한 필요
  var SS_TRASH='_삭제됨';
  function ssDirDelete(i){
    var x=ssDirFiles[i]; if(!x || !ssDirHandle) return;
    ssConfirm('「'+SS_TRASH+'」 폴더로 이동합니다 <span style="color:#9aa7b3">(복구 가능)</span><br><b style="word-break:break-all">'+ssHistEsc(x.name)+'</b>',
      function(){
        ssDirHandle.requestPermission({mode:'readwrite'}).then(function(p){
          if(p!=='granted'){ ssToast('삭제하려면 쓰기 권한이 필요합니다. [폴더 지정]으로 다시 선택하세요.'); return; }
          return ssMoveToTrash(x);
        }).catch(function(e){ ssToast('⚠️ 이동 실패: '+ssHistEsc(e&&e.message||'')); });
      }, {title:'🗑 파일 이동', yes:'이동'});
  }
  // 원본 읽기 → 대상 하위폴더에 쓰기 → 원본 제거 (= 이동). dest 없으면 _삭제됨
  function ssMoveToTrash(x, dest, icon){
    var dir=dest||SS_TRASH, ic=icon||'🗑';
    return x.handle.getFile().then(function(f){ return f.arrayBuffer(); }).then(function(buf){
      return ssDirHandle.getDirectoryHandle(dir, {create:true}).then(function(trash){
        return ssTrashName(trash, x.name).then(function(finalName){
          return trash.getFileHandle(finalName, {create:true}).then(function(fh){
            return fh.createWritable().then(function(w){ return w.write(buf).then(function(){ return w.close(); }); });
          });
        });
      });
    }).then(function(){
      return ssDirHandle.removeEntry(x.name);   // 원본 제거(복사본은 대상 폴더에 남음)
    }).then(function(){ ssToast(ic+' 「'+dir+'」 폴더로 이동: '+x.name); ssDirList(); })
      .catch(function(e){ ssToast('⚠️ 이동 실패: '+ssHistEsc(e&&e.message||'')); });
  }
  /* ══ 작성(대시보드 반영) 성공 → 그 엑셀을 상단 목록에서 치운다 (2026-07-27 사용자 지시) ══════
       "반영하면 위에서 없어지고 아래 이력에 최신으로 올라오게" — 이미 올린 파일이 목록에 남아
       또 올리는 일을 막는 것이 목적이다.
        ★브라우저는 지정 폴더의 <상위>(다운로드)로는 못 옮긴다 — 우리가 가진 건 지정 폴더 핸들뿐이고
          File System Access API 는 부모 디렉터리 접근을 주지 않는다. 그래서 지정 폴더 안의
          「_반영됨」 하위폴더로 옮긴다(파일은 그대로 남아 되찾을 수 있다).
        · 📄 파일 선택으로 연 폴더 밖 파일은 핸들이 없어 건너뛴다(조용히).
        · 쓰기 권한이 없으면 반영은 그대로 두고 이동만 못 했다고 알린다(제스처 없이 요청 불가).      */
  var SS_DONE='_반영됨';
  function ssArchiveApplied(fileName){
    if(!fileName || !ssDirHandle) return;
    var x=null;
    for(var k=0;k<ssDirFiles.length;k++){ if(ssDirFiles[k].name===fileName){ x=ssDirFiles[k]; break; } }
    if(!x) return;                                     // 폴더 밖 파일(📄 파일 선택) → 옮길 게 없다
    ssDirHandle.queryPermission({mode:'readwrite'}).then(function(p){
      if(p!=='granted'){ ssToast('반영은 끝났습니다. 다만 파일 이동은 <b>쓰기 권한</b>이 없어 못 했습니다 — 위쪽 <b>📂 폴더 지정</b>으로 폴더를 다시 골라 주세요.'); return; }
      return ssMoveToTrash(x, SS_DONE, '📦');          // 이동 후 ssDirList() 로 상단 목록 갱신
    }).catch(function(){});
  }
  // 대상 폴더에 같은 이름 있으면 시각 접미사 붙여 충돌 방지
  function ssTrashName(trash, name){
    return trash.getFileHandle(name).then(function(){
      var dot=name.lastIndexOf('.'), base=dot>0?name.slice(0,dot):name, ext=dot>0?name.slice(dot):'';
      return base+'_'+ssFmtTime(+new Date()).replace(/[^0-9]/g,'')+ext;
    }, function(){ return name; });
  }
  // 큰 파일도 그대로 수용(수가업로드처럼 대용량 가능). 파싱 중엔 "불러오는 중" 표시로 멈춘 듯 안 보이게
  function ssBusy(on, msg){
    var el=document.getElementById('ssBusyOv');
    if(on){
      if(!el){ el=document.createElement('div'); el.id='ssBusyOv';
        el.style.cssText='position:fixed;inset:0;z-index:99999;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.35)';
        el.innerHTML='<div style="background:#fff;padding:18px 26px;border-radius:10px;box-shadow:0 8px 30px rgba(0,0,0,.3);font-size:15px;font-weight:600;color:#137a6c;max-width:80vw;text-align:center">⏳ <span id="ssBusyMsg"></span></div>';
        document.body.appendChild(el);
      }
      document.getElementById('ssBusyMsg').textContent=msg||'불러오는 중…';
      el.style.display='flex';
    } else if(el){ el.style.display='none'; }
  }
  function ssDirOpen(i){
    var x=ssDirFiles[i]; if(!x) return;
    ssBusy(true,'엑셀 불러오는 중…');
    x.handle.getFile().then(function(f){ return f.arrayBuffer(); }).then(function(buf){ ssLoadWorkbookBuf(buf, x.name, true); }).catch(function(){ ssBusy(false); ssToast('⚠️ 파일 열기 실패'); });
  }
  // 모달 열릴 때 저장된 폴더 복원 + 목록 갱신
  function ssHistRefresh(){ ssDirRestore().then(function(){ ssDirList(); }); }

  /* ══ 좌측 하단 : 서버 업로드 이력 (기본=오늘 · 최신이 위) — 2026-07-27 사용자 요청 ═══════
       좌측을 위/아래 반반으로 나눠 위=폴더의 엑셀, 아래=서버(TBL_SHIPOUT_MST)에 실제로
       반영된 배치를 업로드 시각 최신순으로 보여준다. 기본은 '오늘 올린 것'(3일 전환 가능).
        · 엔드포인트는 업로드이력 화면(shipoutHist)과 같은 것을 재사용 → 서버 수정 없음
          /shipout/selectShipoutUploadHist.do  (배치 1건 = SHPOUT_DT+DLV_DT+DC_CD+JOB_SEQ 그룹)
        · ★그 SQL은 '출고일자' 범위만 걸 수 있고 '업로드 시각'으로는 못 거른다 → 출고일자 ±120일을
          읽어 화면에서 업로드 날짜로 거른다. 하루에 두 달 전 출고일자(예: 07-26에 출고 05-30)까지
          같이 올리는 일이 있어 창을 넉넉히 잡았다. 그보다 먼 자료는 목록에 안 뜬다(정확히 하려면
          User_SQL 에 UPLOAD_DTTM 조건 추가 필요 = 재배포).
        · 지금 펼쳐 둔 파일과 같은 파일명은 초록 강조 — 이미 올린 자료를 또 올리는 것을 막는다.
        · 줄을 누르면 그 파일을 다시 펼친다(지정 폴더에 남아 있을 때).                      */
  var ssUpHistDays=1;       // 1=오늘만(기본) / 3=최근 3일 (2026-07-27 사용자: 7일→3일)
  var ssUpHist=null;        // 조회 결과 캐시(모달 열 때·저장 후 1회)
  var ssUpHistView=[];      // 화면에 그린 순서(줄 클릭 → 인덱스로 되찾기)
  function ssUpHistSetDays(n){ ssUpHistDays=n; ssUpHistRender(); }   // 조회는 그대로 두고 화면에서만 거른다
  function ssUpHistYmd(shift){ var d=new Date(); d.setDate(d.getDate()+(shift||0)); return d.getFullYear()+'-'+ssPad(d.getMonth()+1)+'-'+ssPad(d.getDate()); }
  function ssUpHistMd(v){    // 'yyyymmdd' 또는 'yyyy-mm-dd' → 'MM-DD'
    var s=(''+(v==null?'':v)).replace(/-/g,'');
    return /^\d{8}$/.test(s) ? (s.slice(4,6)+'-'+s.slice(6,8)) : (s||'-');
  }
  function ssUpHistDayLab(d){
    var W=['일','월','화','수','목','금','토'];
    var m=/^(\d{4})-(\d{2})-(\d{2})$/.exec(d); if(!m) return d;
    var w=W[new Date(+m[1],+m[2]-1,+m[3]).getDay()];
    var tag = (d===ssUpHistYmd(0)) ? ' <span style="color:#137a6c;font-weight:700">오늘</span>'
            : (d===ssUpHistYmd(-1) ? ' <span style="color:#6b7a89">어제</span>' : '');
    return m[2]+'-'+m[3]+'('+w+')'+tag;
  }
  function ssUpHistLoad(){
    var box=document.getElementById('ssPvUpHist'); if(!box) return;
    box.innerHTML='<div style="padding:10px;color:#9aa7b3;font-size:13px">업로드 이력 불러오는 중…</div>';
    fetch(KONET_CTX+'/shipout/selectShipoutUploadHist.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin',
      body:'shpoutDtFrom='+encodeURIComponent(ssUpHistYmd(-120))+'&shpoutDtTo='+encodeURIComponent(ssUpHistYmd(120))
    })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){
      if(!r.ok){ box.innerHTML='<div style="padding:10px;color:#c0392b;font-size:13px">업로드 이력 조회 실패 (HTTP '+r.status+')</div>'; return; }
      var j; try{ j=JSON.parse(r.t); }catch(e){ box.innerHTML='<div style="padding:10px;color:#c0392b;font-size:13px">업로드 이력 응답형식 오류(로그인 만료일 수 있습니다)</div>'; return; }
      ssUpHist=(j&&j.data)||[];
      ssUpHistRender();
    })
    .catch(function(){ box.innerHTML='<div style="padding:10px;color:#c0392b;font-size:13px">업로드 이력 통신오류 — ↻ 로 다시 시도하세요.</div>'; });
  }
  function ssUpHistRender(){
    if(window.ssBackMsgUpd) ssBackMsgUpd();     // 이력이 늦게 도착해도 하단 알림이 맞게(모달 열자마자 파일이 펼쳐지는 경우)
    var box=document.getElementById('ssPvUpHist'); if(!box || ssUpHist==null) return;
    var only1=(ssUpHistDays===1);
    var lim=ssUpHistYmd(-(ssUpHistDays-1));                         // 오늘 포함 N일
    var rows=(ssUpHist||[]).filter(function(o){ var u=(''+(o.uploadDttm||'')).slice(0,10); return u && u>=lim; });
    rows.sort(function(a,b){ return (''+(b.uploadDttm||'')).localeCompare(''+(a.uploadDttm||'')); });   // 최근이 위
    // 머리글 — 제목·건수·기간 전환 링크
    var titEl=document.getElementById('ssPvUpHistTit'); if(titEl) titEl.textContent = only1 ? '오늘' : '최근 3일';
    var tabEl=document.getElementById('ssPvUpHistTab');
    if(tabEl) tabEl.innerHTML = only1
      ? '<span onclick="ssUpHistSetDays(3)" title="최근 3일치를 날짜별로 봅니다(오늘·어제·그저께)" style="cursor:pointer;text-decoration:underline">3일</span>'
      : '<span onclick="ssUpHistSetDays(1)" title="오늘 올린 것만 봅니다" style="cursor:pointer;text-decoration:underline">오늘만</span>';
    // ★한 번에 올린 것은 한 줄로 — 출고장 묶음 (2026-07-27 사용자 지시)
    var ups=ssUpHistPack(rows);
    var cntEl=document.getElementById('ssPvUpHistCnt');
    if(cntEl){ var tot=0; ups.forEach(function(g){ tot+=g.rowCnt; });
      cntEl.textContent = ups.length ? (ups.length+'회 · '+tot.toLocaleString()+'행') : ''; }
    if(!rows.length){
      ssUpHistView=[];
      box.innerHTML='<div style="padding:12px;color:#9aa7b3;font-size:13px;line-height:1.6">'
        +(only1?'오늘':'최근 3일 안에')+' 서버에 반영한<br>자료가 없습니다.<br>'
        +'<span style="color:#b6c0c9">파일을 열어 <b>✔ 작성</b>을 누르면 여기에 쌓입니다.'
        +(only1?'<br>지난 자료는 위 <b>3일</b>을 누르세요.':'')+'</span></div>';
      return;
    }
    ssUpHistView=[]; var out=[];
    if(only1){
      // 오늘만 — 날짜 머리글 없이 시각순으로 쭉 (같은 날이라 머리글이 군더더기)
      ups.forEach(function(g){ out.push(ssUpHistRowHtml(g, ssUpHistView.length)); ssUpHistView.push(g); });
    } else {
      // 업로드 날짜로 묶기 (ups 가 이미 내림차순이라 그룹 순서도 최신일부터)
      var days={}, order=[];
      ups.forEach(function(g){ if(!days[g.day]){ days[g.day]=[]; order.push(g.day); } days[g.day].push(g); });
      order.forEach(function(d){
        var gs=days[d], cnt=0; gs.forEach(function(g){ cnt+=g.rowCnt; });
        out.push('<div style="display:flex;align-items:center;gap:6px;padding:4px 9px;background:#eef4f3;border-bottom:1px solid #e2ebe8;font-size:12.5px;position:sticky;top:0">'
          +'<span style="flex:1;font-weight:700;color:#37475a">'+ssUpHistDayLab(d)+'</span>'
          +'<span style="color:#9aa7b3">'+gs.length+'회 · '+cnt.toLocaleString()+'행</span></div>');
        gs.forEach(function(g){ out.push(ssUpHistRowHtml(g, ssUpHistView.length)); ssUpHistView.push(g); });
      });
    }
    box.innerHTML=out.join('');
  }
  /* 배치(출고장×납기일자×버전) → '업로드 1회' 로 묶기.
       발주현황표 한 장에 물류센터 7곳이 들어 있어 저장하면 배치가 출고장별로 갈린다.
       그대로 늘어놓으면 한 번 올린 것이 7줄(7일치 605줄)이 되어 읽을 수 없다.
       묶음키 = 파일명 + 업로드시각(분). 같은 분에 다른 파일을 올렸으면 파일별로 나뉜다.  */
  function ssUpHistPack(rows){
    var map={}, order=[];
    rows.forEach(function(o){
      var up=(''+(o.uploadDttm||''));
      var file=(''+(o.srcFile||'')).trim();
      var key=file+'|'+up.slice(0,16);
      var g=map[key];
      if(!g){ g={ file:file, up:up, day:up.slice(0,10), hm:up.slice(11,16), user:(''+(o.regUser||'')).trim(),
                  n:0, nHist:0, rowCnt:0, qtySum:0, dcs:[], _seen:{}, dcRow:{}, sdMin:'', sdMax:'' };
              map[key]=g; order.push(g); }
      var dc=konetDcShort(o.dcNm||'')||(''+(o.dcCd||'')).trim()||'미기재';   // '평택물류센터'→'평택'
      if(!g._seen[dc]){ g._seen[dc]=1; g.dcs.push(dc); }
      g.dcRow[dc]=(g.dcRow[dc]||0)+(+o.rowCnt||0);
      g.n++; g.rowCnt+=(+o.rowCnt||0); g.qtySum+=(+o.qtySum||0);
      if((''+(o.actionYn||'')).toUpperCase()==='N') g.nHist++;
      var sd=(''+(o.shpoutDt||'')).replace(/-/g,'');
      if(sd){ if(!g.sdMin||sd<g.sdMin) g.sdMin=sd; if(!g.sdMax||sd>g.sdMax) g.sdMax=sd; }
      if(up>g.up) g.up=up;
    });
    return order;   // rows 가 업로드시각 내림차순이라 그룹 순서도 최신부터
  }
  function ssUpHistRowHtml(g, i){
    var cur = !!(ssPvName && g.file===ssPvName);                    // 지금 펼쳐 둔 파일
    var dcTxt = g.dcs.length ? (g.dcs.length+'곳 · '+g.dcs.join('·')) : '출고장 미기재';
    var sdTxt = g.sdMin ? (g.sdMin===g.sdMax ? ssUpHistMd(g.sdMin) : (ssUpHistMd(g.sdMin)+'~'+ssUpHistMd(g.sdMax).slice(3))) : '-';
    var histTag = g.nHist===0 ? '' : (g.nHist===g.n ? '이력' : '일부 이력');
    var dcDetail = g.dcs.map(function(d){ return d+' '+(g.dcRow[d]||0); }).join(' · ');
    return '<div onclick="ssUpHistPick('+i+')" title="'+ssHistEsc(g.file||'(파일명 없음)')+'&#10;업로드 '+ssHistEsc(g.up)+(g.user?(' · '+ssHistEsc(g.user)):'')
      +'&#10;출고장 '+ssHistEsc(dcDetail)+' (행)'
      +'&#10;출고일자 '+sdTxt+' · 합계 '+g.rowCnt.toLocaleString()+'행 · 수량 '+g.qtySum.toLocaleString()
      +(histTag?('&#10;※ '+(g.nHist===g.n?'이 업로드는 뒤에 올린 자료로 덮여 이력으로 남았습니다':'일부 출고장이 뒤에 올린 자료로 덮였습니다')):'')
      +'&#10;클릭하면 이 파일을 다시 펼칩니다(지정 폴더에 있을 때)" '
      +'style="padding:5px 9px 6px;border-bottom:1px solid #eef3f1;cursor:pointer;font-size:12.5px'+(cur?';background:#e7f3ef':'')+'">'
      +'<div style="display:flex;align-items:center;gap:5px">'
        +'<span style="flex:0 0 auto;color:#9aa7b3">'+g.hm+'</span>'
        +'<span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-weight:700;color:'+(cur?'#137a6c':'#37475a')+'">'+ssHistEsc(g.file||'(파일명 없음)')+'</span>'
        +(histTag?'<span style="flex:0 0 auto;color:#9aa7b3;border:1px solid #e0e6ea;border-radius:3px;padding:0 3px;font-size:11px">'+histTag+'</span>':'')
        +'<span style="flex:0 0 auto;color:#6b7a89"><b>'+g.rowCnt.toLocaleString()+'</b>행</span>'
      +'</div>'
      +'<div style="display:flex;align-items:center;gap:5px;color:#9aa7b3;font-size:11.5px;margin-top:1px">'
        +'<span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">출고장 '+ssHistEsc(dcTxt)+'</span>'
        +'<span style="flex:0 0 auto">출고 '+sdTxt+'</span>'
      +'</div></div>';
  }
  // 이력 줄 클릭 → 같은 이름의 파일이 지정 폴더에 있으면 우측에 다시 펼친다
  function ssUpHistPick(i){
    var g=ssUpHistView[i]; if(!g) return;
    var file=(''+(g.file||'')).trim();
    if(!file){ ssToast('이 업로드에는 파일명이 기록되어 있지 않습니다.'); return; }
    for(var k=0;k<ssDirFiles.length;k++){ if(ssDirFiles[k].name===file){ ssDirOpen(k); return; } }
    ssToast('📄 <b>'+ssHistEsc(file)+'</b> — 지정 폴더에 없습니다<br><span style="font-size:11px">이미 옮겼거나 다른 PC에서 올린 자료입니다.</span>');
  }

  /* ══ 역순 업로드 알림 — 올리려는 자료가 '마지막에 올린 자료'보다 이전이면 알린다 (2026-07-27 사용자 요청) ══
       · ★막지 않는다. 알리고 그대로 진행한다 — 지난 날짜를 뒤늦게 올리는 정상 업무가 있다.
       · 비교기준 = 출고일자(SHPOUT_DT). '마지막에 올린 자료' = ssUpHist 중 업로드시각이 가장 늦은 묶음
         (묶음키는 목록과 같은 ssUpHistPack = 파일명+업로드시각(분) → 한 번에 올린 7개 출고장이 한 건).
       · ssUpHist 는 모달 열 때 1회 조회분(출고일자 ±120일). 아직 안 왔거나 창 밖이면 조용히 넘어간다(헛경고 방지). */
  function ssBackNorm(v){ var s=(''+(v==null?'':v)).replace(/-/g,''); return /^\d{8}$/.test(s)?s:''; }
  function ssLastUpGrp(){
    var rows=(ssUpHist||[]).filter(function(o){ return (''+(o.uploadDttm||'')).length>=10; });
    if(!rows.length) return null;
    rows=rows.slice().sort(function(a,b){ return (''+(b.uploadDttm||'')).localeCompare(''+(a.uploadDttm||'')); });
    var ups=ssUpHistPack(rows);
    return ups.length ? ups[0] : null;     // 업로드시각 내림차순이라 맨 앞 = 마지막에 올린 묶음
  }
  // null = 알릴 것 없음 / {cur,prev,g} = 이전 자료
  function ssBackChk(shpDt){
    var cur=ssBackNorm(shpDt); if(!cur) return null;
    var g=ssLastUpGrp(); if(!g || !g.sdMax) return null;
    if(cur>=g.sdMax) return null;
    return { cur:cur, prev:g.sdMax, g:g };
  }
  function ssBackTxt(c){
    return '이전 자료입니다 — 마지막 업로드(<b>'+ssHistEsc((c.g.day||'').slice(5))+' '+ssHistEsc(c.g.hm||'')+'</b> · '
         + ssHistEsc(c.g.file||'파일명 없음')+')의 출고일자 <b>'+ssUpHistMd(c.prev)+'</b> 보다 <b>'+ssUpHistMd(c.cur)+'</b> 가 이전입니다.';
  }
  // 깜박임 다시 시작 — 클래스를 뗐다 붙이면 애니메이션이 처음부터 돈다(reflow 강제 필요)
  function ssBlinkOn(el){ if(!el) return; el.classList.remove('ss-blink'); void el.offsetWidth; el.classList.add('ss-blink'); }
  // 미리보기 하단 알림 — 파일을 펼쳤을 때·출고일자를 고쳤을 때·이력이 늦게 도착했을 때 갱신
  function ssBackMsgUpd(){
    var el=document.getElementById('ssPvBackMsg'); if(!el) return;
    var dt=document.getElementById('ssPvShpoutDt');
    var c=(ssPvCur&&ssPvCur.map) ? ssBackChk((dt&&dt.value)||'') : null;
    if(!c){ el.style.display='none'; el.innerHTML=''; el.classList.remove('ss-blink'); return; }
    var h='⚠️ '+ssBackTxt(c)+' <span style="font-weight:400;color:#8a6b6b">— 그대로 진행할 수 있습니다</span>';
    var same=(el.innerHTML===h && el.style.display!=='none');
    el.style.display=''; el.innerHTML=h;
    if(!same) ssBlinkOn(el);        // 내용이 바뀔 때만 다시 깜박(이력 재렌더마다 재시작 방지)
  }
  // 반영 확인창 안의 알림 — 확인창에서 출고일자를 고치면 즉시 다시 판정한다
  function ssConfirmBackUpd(){
    var box=document.getElementById('ssConfirmBack'); if(!box) return;
    var dt=document.getElementById('ssConfirmShpDt');
    var c=ssBackChk((dt&&dt.value)||'');
    var h = c ? ('<div class="ss-blink" style="margin-top:12px;padding:9px 11px;border:1px solid #f3c9c3;background:#fff6f5;border-radius:6px;'
        +'font-size:12.5px;color:#c0392b;font-weight:700;line-height:1.55;text-align:left">⚠️ '+ssBackTxt(c)
        +'<br><span style="color:#8a6b6b;font-weight:400">그래도 반영하려면 <b>반영</b>을 누르세요 — 막지 않습니다.</span></div>') : '';
    if(box.innerHTML!==h) box.innerHTML=h;   // 같은 내용이면 그대로 둔다(깜박임이 처음부터 다시 돌지 않게)
  }

  // ArrayBuffer(엑셀) → 미리보기 모달에 로드 (수동선택·폴더선택 공용). 이후 작성/저장은 기존 ssPvApply 재사용
  function ssLoadWorkbookBuf(buf, fileName, skipHist){
    if(typeof XLSX==='undefined'){ ssBusy(false); ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); return; }
    ssPvName=fileName;
    ssBusy(true,'엑셀 불러오는 중… ('+fileName+')');
    // 스피너를 먼저 화면에 그린 뒤 무거운 동기 파싱 실행(대용량도 멈춘 듯 안 보이게)
    setTimeout(function(){
    ssReadXlsx(buf, function(wb){
    try{
      ssPvWb=wb;
      var names=ssPvWb.SheetNames||[];
      document.getElementById('ssPvFile').textContent=fileName;
      var sel=document.getElementById('ssPvSheet');
      sel.innerHTML=names.map(function(n,i){ return '<option value="'+i+'">'+n+'</option>'; }).join('');
      sel.value='0';
      document.getElementById('ssPvSheetWrap').style.display = names.length>1 ? '' : 'none';
      ssPvRender();
      ssPvOpen(true);
      ssHistRenderList();   // 현재 파일 강조 갱신(폴더 목록)
      ssUpHistRender();     // 현재 파일 강조 갱신(업로드 이력 — 이미 올린 파일인지 바로 보이게)
    }catch(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); }
    ssBusy(false);
    }, function(err){ ssBusy(false); ssToast('⚠️ 엑셀 처리 오류: '+err.message); });
    }, 30);
  }

  // 수동 파일 선택(<input type=file>) — 폴더 접근이 안 되는 환경용 fallback
  function ssUpload(input){
    var f=input.files && input.files[0]; if(!f) return;
    ssBusy(true,'파일 읽는 중… ('+f.name+')');
    var rd=new FileReader();
    rd.onload=function(e){ ssLoadWorkbookBuf(e.target.result, f.name); input.value=''; };
    rd.onerror=function(){ ssBusy(false); ssToast('⚠️ 파일 읽기 실패'); input.value=''; };
    rd.readAsArrayBuffer(f);
  }

  // ── 매출금액 업로드 (발주현황표 업로드와 동일 UX: 파일선택 → 미리보기 모달 → 작성/반영)
  //   매입단가 엑셀(품목코드·입고일자·입고량·단가·매입금액) → 품목코드별 매출액(매입금액 합)
  var ssSalesPvWb=null, ssSalesPvName='', ssSalesPvCur=null;

  function ssSalesUpload(input){
    var f=input.files && input.files[0]; if(!f) return;
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); input.value=''; return; }
    ssSalesPvName=f.name;
    var rd=new FileReader();
    rd.onload=function(e){
      ssReadXlsx(e.target.result, function(wb){
      try{
        ssSalesPvWb=wb;
        var names=ssSalesPvWb.SheetNames||[];
        document.getElementById('ssSalesPvFile').textContent=f.name;
        var sel=document.getElementById('ssSalesPvSheet');
        sel.innerHTML=names.map(function(n,i){ return '<option value="'+i+'">'+n+'</option>'; }).join('');
        sel.value='0';
        document.getElementById('ssSalesPvSheetWrap').style.display = names.length>1 ? '' : 'none';
        ssSalesPvRender();
        ssSalesPvOpen(true);
      }catch(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); }
      }, function(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); });
      input.value='';
    };
    rd.readAsArrayBuffer(f);
  }
  function ssSalesPvOpen(show){ document.getElementById('ssSalesPvOverlay').classList.toggle('on', !!show); }

  // 선택 시트의 2차원 배열
  function ssSalesPvAoa(){
    var idx=+(document.getElementById('ssSalesPvSheet').value||0);
    var ws=ssSalesPvWb.Sheets[ssSalesPvWb.SheetNames[idx]];
    return ws ? XLSX.utils.sheet_to_json(ws,{header:1,defval:''}) : [];
  }

  // 매입단가 엑셀 컬럼 자동 인식 (단일행 헤더)
  function ssSalesMapCols(aoa){
    function findIn(arr,name){ for(var k=0;k<arr.length;k++){ if((''+arr[k]).trim()===name) return k; } return -1; }
    for(var i=0;i<Math.min(aoa.length,8);i++){
      var h=(aoa[i]||[]).map(function(s){return (''+s).trim();});
      var cCode=findIn(h,'품목코드'), cDate=findIn(h,'입고일자');
      var cAmt=findIn(h,'매입금액'), cPrice=findIn(h,'단가'), cInQty=findIn(h,'입고량');
      if(cCode>=0 && (cAmt>=0 || cPrice>=0)){
        return { h:i, cCode:cCode, cName:findIn(h,'품목명'), cDate:cDate, cAmt:cAmt, cPrice:cPrice, cInQty:cInQty };
      }
    }
    return null;
  }

  // 추출: 품목코드별 매출액(매입금액 합) — 금액 = 매입금액(없으면 입고량×단가)
  function ssSalesExtract(aoa,m){
    var map={}, cnt=0, sum=0, dset={};
    for(var r=m.h+1; r<aoa.length; r++){
      var row=aoa[r]||[];
      var code=(''+(m.cCode>=0?row[m.cCode]:'')).trim(); if(!code) continue;
      var amt=m.cAmt>=0 ? (+(''+(row[m.cAmt]||'')).replace(/[^0-9.\-]/g,'')||0) : 0;
      if(!amt && m.cPrice>=0){
        var price=+(''+(row[m.cPrice]||'')).replace(/[^0-9.\-]/g,'')||0;
        var inq=m.cInQty>=0 ? (+(''+(row[m.cInQty]||'')).replace(/[^0-9.\-]/g,'')||0) : 1;
        amt=price*(inq||1);
      }
      if(!amt) continue;
      map[code]=(map[code]||0)+amt; cnt++; sum+=amt;
      var d=m.cDate>=0?ssFmtDate(row[m.cDate]):''; if(d) dset[d]=1;
    }
    return { map:map, cnt:cnt, sum:sum, dates:Object.keys(dset).sort() };
  }

  // 미리보기 렌더 (엑셀 내용 그대로 + 인식컬럼 하이라이트) — 발주현황표 미리보기와 동일 스타일
  function ssSalesPvRender(){
    var aoa=ssSalesPvAoa();
    var m=ssSalesMapCols(aoa);
    ssSalesPvCur={aoa:aoa, map:m};
    var info=document.getElementById('ssSalesPvInfo');
    var btn=document.getElementById('ssSalesPvApplyBtn');
    var hlCols={};
    if(m){
      [m.cCode,m.cName,m.cDate,m.cInQty,m.cPrice,m.cAmt].forEach(function(c){ if(c>=0) hlCols[c]=1; });
      var ex=ssSalesExtract(aoa,m);
      info.className='ss-pvinfo';
      info.innerHTML='✅ 인식 완료 — <span class="tag">품목코드</span>'
        + (m.cDate>=0?'<span class="tag">입고일자</span>':'')
        + (m.cInQty>=0?'<span class="tag">입고량</span>':'')
        + (m.cPrice>=0?'<span class="tag">단가</span>':'')
        + (m.cAmt>=0?'<span class="tag">매입금액</span>':'')
        + ' · 품목 <b>'+Object.keys(ex.map).length+'</b>종 · 매출액 합 <b>'+ssNum(ex.sum)+'</b>원 (노란 칸이 반영 대상)';
      btn.removeAttribute('disabled'); btn.style.opacity='1';
    } else {
      info.className='ss-pvinfo warn';
      info.innerHTML='⚠️ 매입단가 형식이 아닙니다 — 헤더에 <b>품목코드</b> 와 <b>매입금액(또는 단가)</b> 이 있어야 합니다. 시트를 바꿔 보세요.';
      btn.setAttribute('disabled','disabled'); btn.style.opacity='.5';
    }
    var maxR=Math.min(aoa.length,30), maxC=0;
    for(var i=0;i<maxR;i++) maxC=Math.max(maxC,(aoa[i]||[]).length);
    maxC=Math.min(maxC,40);
    var html='';
    for(var r=0;r<maxR;r++){
      var isHdr = m && (r===m.h);
      html+= isHdr ? '<tr class="hdr">' : '<tr>';
      html+='<td class="rn">'+(r+1)+'</td>';
      for(var c=0;c<maxC;c++){
        var v=ssCellDisp(aoa[r]&&aoa[r][c]);
        html+='<td'+(hlCols[c]?' class="hl"':'')+' title="'+v.replace(/"/g,'&quot;')+'">'+v+'</td>';
      }
      html+='</tr>';
    }
    if(aoa.length>30) html+='<tr><td class="rn">…</td><td colspan="'+maxC+'" style="color:#9aa7b3">이하 '+(aoa.length-30)+'행 생략 (작성 시 전체 반영)</td></tr>';
    document.getElementById('ssSalesPvTbl').innerHTML=html;
  }

  // 작성(반영): 확인 메시지 후 실행
  function ssSalesPvApply(){
    if(!ssSalesPvCur || !ssSalesPvCur.map){ ssToast('⚠️ 인식 가능한 매입단가 표가 아닙니다.'); return; }
    var ex=ssSalesExtract(ssSalesPvCur.aoa, ssSalesPvCur.map);
    if(!ex.cnt){ ssToast('⚠️ 매출금액 데이터 행이 없습니다.'); return; }
    var sheetNm=ssSalesPvWb.SheetNames[+(document.getElementById('ssSalesPvSheet').value||0)];
    var items=Object.keys(ex.map).length;
    ssConfirm('파일 <b>'+ssSalesPvName+'</b> · 시트 "<b>'+sheetNm+'</b>"<br>품목 <b style="color:#137a6c">'+items+'</b>종 · 매출액 합 <b style="color:#137a6c">'+ssNum(ex.sum)+'</b>원을 출고현황표에 반영하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 품목코드 기준으로 매칭되어 ‘매출액’ 행에 표시됩니다. 기존 매출금액은 이 파일로 교체됩니다.</span>',
      function(){
        ssSalesMap=ex.map; ssSalesCnt=ex.cnt;
        ssSalesSrc=ssSalesPvName+' · 품목 '+items+'종 · '+ssNum(ex.sum)+'원'+(ex.dates.length?(' · 입고일자 '+ex.dates[0]+(ex.dates.length>1?(' ~ '+ex.dates[ex.dates.length-1]):'')):'');
        ssSalesPvOpen(false);
        ssRender(); ssFlash();
        ssToast('💰 <b>'+ssSalesPvName+'</b> · 시트["'+sheetNm+'"] — 품목 '+items+'종 · 매출액 '+ssNum(ex.sum)+'원 <b>반영</b> 완료');
      });
  }

  // ── 매입금액 업로드 (매출금액 업로드와 동일 UX — 엑셀은 추후 제공) → 품목코드별 매입액
  var ssCostPvWb=null, ssCostPvName='', ssCostPvCur=null;
  function ssCostUpload(input){
    var f=input.files && input.files[0]; if(!f) return;
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); input.value=''; return; }
    ssCostPvName=f.name;
    var rd=new FileReader();
    rd.onload=function(e){
      ssReadXlsx(e.target.result, function(wb){
      try{
        ssCostPvWb=wb;
        var names=ssCostPvWb.SheetNames||[];
        document.getElementById('ssCostPvFile').textContent=f.name;
        var sel=document.getElementById('ssCostPvSheet');
        sel.innerHTML=names.map(function(n,i){ return '<option value="'+i+'">'+n+'</option>'; }).join('');
        sel.value='0';
        document.getElementById('ssCostPvSheetWrap').style.display = names.length>1 ? '' : 'none';
        ssCostPvRender();
        ssCostPvOpen(true);
      }catch(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); }
      }, function(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); });
      input.value='';
    };
    rd.readAsArrayBuffer(f);
  }
  function ssCostPvOpen(show){ document.getElementById('ssCostPvOverlay').classList.toggle('on', !!show); }
  function ssCostPvAoa(){
    var idx=+(document.getElementById('ssCostPvSheet').value||0);
    var ws=ssCostPvWb.Sheets[ssCostPvWb.SheetNames[idx]];
    return ws ? XLSX.utils.sheet_to_json(ws,{header:1,defval:''}) : [];
  }
  function ssCostPvRender(){
    var aoa=ssCostPvAoa();
    var m=ssSalesMapCols(aoa);   // 동일 컬럼 인식(품목코드·매입금액/단가)
    ssCostPvCur={aoa:aoa, map:m};
    var info=document.getElementById('ssCostPvInfo');
    var btn=document.getElementById('ssCostPvApplyBtn');
    var hlCols={};
    if(m){
      [m.cCode,m.cName,m.cDate,m.cInQty,m.cPrice,m.cAmt].forEach(function(c){ if(c>=0) hlCols[c]=1; });
      var ex=ssSalesExtract(aoa,m);
      info.className='ss-pvinfo';
      info.innerHTML='✅ 인식 완료 — <span class="tag">품목코드</span>'
        + (m.cInQty>=0?'<span class="tag">입고량</span>':'')
        + (m.cPrice>=0?'<span class="tag">단가</span>':'')
        + (m.cAmt>=0?'<span class="tag">매입금액</span>':'')
        + ' · 품목 <b>'+Object.keys(ex.map).length+'</b>종 · 매입액 합 <b>'+ssNum(ex.sum)+'</b>원 (노란 칸이 반영 대상)';
      btn.removeAttribute('disabled'); btn.style.opacity='1';
    } else {
      info.className='ss-pvinfo warn';
      info.innerHTML='⚠️ 매입금액 형식이 아닙니다 — 헤더에 <b>품목코드</b> 와 <b>매입금액(또는 단가)</b> 이 있어야 합니다. 시트를 바꿔 보세요.';
      btn.setAttribute('disabled','disabled'); btn.style.opacity='.5';
    }
    var maxR=Math.min(aoa.length,30), maxC=0;
    for(var i=0;i<maxR;i++) maxC=Math.max(maxC,(aoa[i]||[]).length);
    maxC=Math.min(maxC,40);
    var html='';
    for(var r=0;r<maxR;r++){
      var isHdr = m && (r===m.h);
      html+= isHdr ? '<tr class="hdr">' : '<tr>';
      html+='<td class="rn">'+(r+1)+'</td>';
      for(var c=0;c<maxC;c++){
        var v=ssCellDisp(aoa[r]&&aoa[r][c]);
        html+='<td'+(hlCols[c]?' class="hl"':'')+' title="'+v.replace(/"/g,'&quot;')+'">'+v+'</td>';
      }
      html+='</tr>';
    }
    if(aoa.length>30) html+='<tr><td class="rn">…</td><td colspan="'+maxC+'" style="color:#9aa7b3">이하 '+(aoa.length-30)+'행 생략 (작성 시 전체 반영)</td></tr>';
    document.getElementById('ssCostPvTbl').innerHTML=html;
  }
  function ssCostPvApply(){
    if(!ssCostPvCur || !ssCostPvCur.map){ ssToast('⚠️ 인식 가능한 매입금액 표가 아닙니다.'); return; }
    var ex=ssSalesExtract(ssCostPvCur.aoa, ssCostPvCur.map);
    if(!ex.cnt){ ssToast('⚠️ 매입금액 데이터 행이 없습니다.'); return; }
    var sheetNm=ssCostPvWb.SheetNames[+(document.getElementById('ssCostPvSheet').value||0)];
    var items=Object.keys(ex.map).length;
    ssConfirm('파일 <b>'+ssCostPvName+'</b> · 시트 "<b>'+sheetNm+'</b>"<br>품목 <b style="color:#137a6c">'+items+'</b>종 · 매입액 합 <b style="color:#137a6c">'+ssNum(ex.sum)+'</b>원을 출고현황표에 반영하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 품목코드 기준으로 ‘매입액’ 행에 표시되고 마진(매출−매입)이 자동 계산됩니다. 기존 매입금액은 이 파일로 교체됩니다.</span>',
      function(){
        ssCostMap=ex.map; ssCostCnt=ex.cnt;
        ssCostSrc=ssCostPvName+' · 품목 '+items+'종 · '+ssNum(ex.sum)+'원';
        ssCostPvOpen(false);
        ssRender(); ssFlash();
        ssToast('🧾 <b>'+ssCostPvName+'</b> · 시트["'+sheetNm+'"] — 품목 '+items+'종 · 매입액 '+ssNum(ex.sum)+'원 <b>반영</b> 완료');
      });
  }

  // 선택 시트의 2차원 배열
  function ssPvAoa(){
    var idx=+(document.getElementById('ssPvSheet').value||0);
    var ws=ssPvWb.Sheets[ssPvWb.SheetNames[idx]];
    return ws ? XLSX.utils.sheet_to_json(ws,{header:1,defval:''}) : [];
  }

  /* ── 출고일자 규칙 (2026-07-29 사용자 확정) ──────────────────────────────────
       ★출고장에 상관없이 <엑셀의 납기일자를 그대로> 출고일자(SHPOUT_DT)로 쓴다.
         프리뷰 하단 '출고일자' 칸이 그 값이고(수정 가능), 전 행이 그 하나의 날짜로 저장된다.
       [이력] 2026-07-26~07-28 에는 <김해·제주 = 납기일자 2일 전>(조기출고) 예외가 있었으나
         사용자 요청으로 제거했다(ssIsEarlyZone/ssShiftYmd/ssRowShpoutDt/_ssShpOverride 삭제).
         그 기간에 올린 자료에는 2일 당겨진 출고일자가 남아 있다 — 다시 올리면 엑셀 날짜로 대체된다.
         예외를 되살리자는 얘기가 나오면 이 이력부터 확인할 것.                                */

  // 컬럼 자동 인식 — 매핑화면 없이 내부 처리
  //  · (신규) 코네트 발주현황표: 단일 헤더행. 출고장=물류센터명, 사업장=품목명 () 접두,
  //    품목코드=품목코드, 출고량=현 발주
  //  · (기존) 2행 헤더 발주현황표: 출고장=존, 수량=수량
  function ssMapCols(aoa){
    function findEq(arr,name){ for(var k=0;k<arr.length;k++){ if((''+arr[k]).trim()===name) return k; } return -1; }
    // ── (신규) 코네트 발주현황표(출고장): 헤더 2줄
    //    1행=물류센터명/품목명/품목코드/사업장명 , 2행=입고장/존/수량
    //    · 출고장 = 물류센터명 + 입고장(1~4)  예) 평택물류센터1
    //    · 사업장 = 품목명의 () 접두 , 품목명 = () 뒤 , 출고량 = 수량
    for(var i=0;i<Math.min(aoa.length,8);i++){
      var r1=(aoa[i]||[]).map(function(c){return (''+c).trim();});
      if(findEq(r1,'물류센터명')>=0 && findEq(r1,'품목명')>=0){
        var r2=(aoa[i+1]||[]).map(function(c){return (''+c).trim();});
        function pick(n){ var k=findEq(r2,n); return k>=0?k:findEq(r1,n); }
        var cInb=pick('입고장');
        var cQk=pick('수량'); if(cQk<0){ cQk=pick('현 발주'); if(cQk<0) cQk=pick('현발주'); }
        if(cInb>=0){   // 입고장 컬럼이 있어야 코네트 출고장 양식으로 확정
          return { fmt:'konet', h:i, dataRow:i+2, zoneJoin:true,
                   cItem:findEq(r1,'품목명'), cCode:findEq(r1,'품목코드'),
                   cBiz:findEq(r1,'사업장명'), cBizCode:findEq(r1,'사업장코드'),
                   cCenter:findEq(r1,'물류센터명'), cInb:cInb, cQty:cQk,
                   cZone:findEq(r1,'물류센터명'),
                   cDate:findEq(r1,'납기일자'), cDlv:findEq(r1,'납기일자') };
        }
      }
    }
    // ── (기존) 2행 헤더 발주현황표
    var h=-1;
    for(var i=0;i<Math.min(aoa.length,6);i++){
      var row=(aoa[i]||[]).map(function(c){return (''+c).trim();});
      if(row.indexOf('품목명')>=0 && row.indexOf('사업장명')>=0){ h=i; break; }
    }
    if(h<0) return null;
    var h1=(aoa[h]||[]).map(function(s){return (''+s).trim();});
    var h2=(aoa[h+1]||[]).map(function(s){return (''+s).trim();});
    function findIn(arr,name){ for(var k=0;k<arr.length;k++){ if(arr[k]===name) return k; } return -1; }
    var cInb=findIn(h2,'입고장'), cZone=findIn(h2,'존'), cQty=findIn(h2,'수량');
    if(cZone<0){ cInb=findIn(h1,'입고장'); cZone=findIn(h1,'존'); cQty=findIn(h1,'수량'); }
    // 출고일자 = 엑셀의 '18차 가마감 일시'(처리일) 우선, 없으면 '납기일자'
    var cDate=findIn(h1,'18차 가마감 일시'); if(cDate<0) cDate=findIn(h1,'납기일자'); if(cDate<0) cDate=findIn(h2,'18차 가마감 일시');
    var cDlv=findIn(h1,'납기일자'); if(cDlv<0) cDlv=findIn(h2,'납기일자');
    return { fmt:'old', h:h, dataRow:h+2, cItem:findIn(h1,'품목명'), cBiz:findIn(h1,'사업장명'), cBizCode:findIn(h1,'사업장코드'), cCode:findIn(h1,'품목코드'), cInb:cInb, cZone:cZone, cQty:cQty, cDate:cDate, cDlv:cDlv };
  }

  function ssExtractRows(aoa,m){
    var rows=[];
    var _start = (m.dataRow!=null) ? m.dataRow : (m.h+2);   // 코네트=단일헤더(h+1) / 기존=2행헤더(h+2)
    for(var r=_start; r<aoa.length; r++){
      var row=aoa[r]||[]; var nm=(''+(row[m.cItem]||'')).trim(); if(!nm) continue;
      var bizNm=(''+(m.cBiz>=0?row[m.cBiz]:'')).trim();
      var bizCd=(''+(m.cBizCode>=0?row[m.cBizCode]:'')).trim();
      // 사업장 명칭에 사업장코드 부가: "사업장명 [코드]"
      var bizLbl = bizCd ? (bizNm ? (bizNm+' ['+bizCd+']') : ('['+bizCd+']')) : bizNm;
      var inbVal=(''+(m.cInb>=0?row[m.cInb]:'')).trim();
      // 출고장: 코네트 = 물류센터명 + 입고장(예: 평택물류센터1) / 기존 = 존 값 그대로
      var zoneVal;
      if(m.zoneJoin){
        // 출고장(행) = 물류센터명 + 입고장 (예: 평택물류센터1~4) — 묶음(그룹)은 물류센터명으로 표시
        var ctr=(''+(m.cCenter>=0?row[m.cCenter]:'')).trim();
        zoneVal=(ctr+inbVal).trim();
      } else {
        zoneVal=(''+(row[m.cZone]||'')).trim();
      }
      rows.push({
        ln:r+1,                                   // 엑셀 행번호(오류내역 표시용)
        code:(''+(m.cCode>=0?row[m.cCode]:'')).trim(),
        item:nm,
        biz:bizLbl,
        bizName:bizNm,
        bizCode:bizCd,
        inb:inbVal,
        zone:zoneVal,
        qty:(+(''+(row[m.cQty]||'')).replace(/[^0-9.\-]/g,''))||0,
        dlvDt:(m.cDlv>=0?ssFmtDate(row[m.cDlv]):''),
        date:(m.cDate>=0?ssFmtDate(row[m.cDate]):'') || SS_TODAY
      });
    }
    return rows;
  }

  var ssPvCur=null, ssPvBadFile=null;

  /* ══ 업로드 오류내역 (발주현황표) — 2026-07-26 요청 ══════════════════════════
       종전에는 양식이 다르면 "형식이 맞지 않는 자료입니다" 한 줄만 떴다 → 어디가 다른지 알 수 없었다.
       이제 두 가지를 나눠 보여준다.
         ① 양식 대조 : 기대 컬럼 중 무엇이 없는지 · 이 파일에 실제로 있는 머리글은 무엇인지
         ② 행 대조   : 양식은 맞지만 값이 빠져 집계가 어긋날 행(출고장·수량·품목코드·사업장·납기일자)
       ②는 저장을 막지 않는다(경고) — 막으면 정상 자료 대부분이 함께 걸리기 때문. 빨간 행으로 함께 표시.  */
  var SS_FMT_SPEC=[
    { key:'konet', name:'코네트 발주현황표(출고장)', req:['물류센터명','품목명','입고장'], qty:['수량','현 발주','현발주'],
      opt:['품목코드','사업장명','사업장코드','납기일자'] },
    { key:'old',   name:'기존 발주현황표(2행 헤더)', req:['품목명','사업장명','존'],       qty:['수량'],
      opt:['품목코드','사업장코드','납기일자','18차 가마감 일시'] }
  ];
  // 앞쪽 몇 행에서 머리글 후보(짧은 문자열)를 모은다 — 파일에 뭐가 들었는지 보여주려는 것
  function ssHdrCells(aoa, maxRow){
    var set={}, list=[];
    for(var i=0;i<Math.min(aoa.length, maxRow||8);i++){
      (aoa[i]||[]).forEach(function(c){
        var s=(''+(c==null?'':c)).trim();
        if(s && s.length<=20 && !set[s]){ set[s]=1; list.push(s); }
      });
    }
    // has() = 실제 파서(findIn)와 같은 부분일치. '수량(EA)' 같은 머리글을 '없다'고 잘못 적지 않으려는 것
    var has=function(n){
      if(set[n]) return true;
      for(var i=0;i<list.length;i++){ if(list[i].indexOf(n)>=0) return true; }
      return false;
    };
    return { set:set, list:list, has:has };
  }
  // 양식별 대조 — 맞은 개수가 많은 쪽을 '가장 가까운 양식'으로 앞에 놓는다
  function ssFmtDiag(aoa){
    var hd=ssHdrCells(aoa,8);
    var cand=SS_FMT_SPEC.map(function(sp){
      var miss=sp.req.filter(function(n){ return !hd.has(n); });
      if(!sp.qty.some(function(n){ return hd.has(n); })) miss=miss.concat([sp.qty[0]]);
      return { spec:sp, miss:miss, optMiss:sp.opt.filter(function(n){ return !hd.has(n); }), hit:(sp.req.length+1)-miss.length };
    });
    cand.sort(function(a,b){ return b.hit-a.hit; });
    return { hdr:hd, cand:cand };
  }
  // 양식 자체가 안 맞을 때의 오류내역 HTML
  function ssFmtErrHtml(aoa){
    var h='<div class="ss-pverr"><div class="eh">⚠️ 오류내역 — 이 엑셀은 <b>발주현황표 양식</b>이 아닙니다</div><ol>';
    if(!aoa.length){
      h+='<li>선택한 시트가 <b class="bad">비어 있습니다</b> (읽은 행 0). 다른 시트를 골라 보세요.</li>';
    } else {
      var d=ssFmtDiag(aoa);
      d.cand.forEach(function(c,i){
        h+='<li>'+(i===0?'<b>[가장 가까운 양식]</b> ':'')+'<b>'+_cesc(c.spec.name)+'</b> 기준 — '
          + (c.miss.length ? '없는 컬럼 <b class="bad">'+c.miss.map(_cesc).join(' · ')+'</b>'
                           : '<span class="ok">필수 컬럼은 모두 있음</span>')
          + (c.optMiss.length ? ' <span class="dim">(선택 컬럼 없음: '+c.optMiss.map(_cesc).join(' · ')+')</span>' : '')
          + '</li>';
      });
      h+='<li>이 시트에서 찾은 머리글 <span class="dim">'
        + (d.hdr.list.length ? _cesc(d.hdr.list.slice(0,25).join(' · '))+(d.hdr.list.length>25?(' … 외 '+(d.hdr.list.length-25)+'개'):'') : '없음')
        + '</span></li>';
      h+='<li class="dim">시트가 여러 개면 위 <b>시트</b> 선택을 바꿔 보고, 그래도 같으면 출고장에서 받은 <b>원본 파일</b>이 맞는지 확인하세요.</li>';
    }
    return h+'</ol></div>';
  }
  // 양식은 맞을 때 — 값이 빠진 행 찾기. 반환 bad = { 엑셀행index0 : 1 } (미리보기 빨간 행)
  function ssRowDiag(aoa, m){
    var _start=(m.dataRow!=null)?m.dataRow:(m.h+2);
    var d={ skip:[], zone:[], qty:[], code:[], biz:[], dlv:[], bad:{}, n:0 };
    for(var r=_start;r<aoa.length;r++){
      var row=aoa[r]||[];
      var nm=(''+(row[m.cItem]||'')).trim();
      if(!nm){
        // 품목명이 빈 행 — 완전 빈 행은 무시, 다른 칸에 값이 있으면 '반영 안 되는 행'(합계행 등)
        var any=false;
        for(var c=0;c<row.length;c++){ if((''+(row[c]==null?'':row[c])).trim()!==''){ any=true; break; } }
        if(any){ d.skip.push(r+1); d.bad[r]=1; }
        continue;
      }
      d.n++;
      var zone;
      if(m.zoneJoin) zone=((''+(m.cCenter>=0?row[m.cCenter]:'')).trim()+(''+(m.cInb>=0?row[m.cInb]:'')).trim()).trim();
      else zone=(''+(row[m.cZone]||'')).trim();
      var qraw=(''+(m.cQty>=0?(row[m.cQty]==null?'':row[m.cQty]):'')).trim();
      var qok=(qraw!=='' && !isNaN(+qraw.replace(/[^0-9.\-]/g,'')) && qraw.replace(/[^0-9.\-]/g,'')!=='');
      if(!zone){ d.zone.push(r+1); d.bad[r]=1; }
      if(!qok){ d.qty.push(r+1); d.bad[r]=1; }
      if(m.cCode>=0 && !(''+(row[m.cCode]||'')).trim()) d.code.push(r+1);
      if(m.cBiz >=0 && !(''+(row[m.cBiz ]||'')).trim()) d.biz.push(r+1);
      if(m.cDlv >=0 && !ssFmtDate(row[m.cDlv]))         d.dlv.push(r+1);
    }
    return d;
  }
  // 행번호 목록을 짧게 — "12, 13, 14 … 외 20행"
  function ssLnList(arr, max){
    max=max||8;
    var s=arr.slice(0,max).join(', ');
    return '<span class="ln">엑셀 '+s+(arr.length>max?(' … 외 '+(arr.length-max)+'행'):'')+' 행</span>';
  }
  // 행 오류내역 HTML — 없으면 빈 문자열
  function ssRowErrHtml(d){
    var e=[], w=[];
    if(d.zone.length) e.push({t:'<b class="bad">출고장이 비어 있음</b> — 이 행은 집계·저장에서 빠집니다', a:d.zone});
    if(d.qty.length)  e.push({t:'<b class="bad">수량이 비었거나 숫자가 아님</b> — 0 으로 저장됩니다',      a:d.qty});
    if(d.skip.length) w.push({t:'품목명이 없어 <b>반영되지 않는 행</b> (합계행·소계행일 수 있음)',          a:d.skip});
    if(d.code.length) w.push({t:'품목코드 없음 — 품목명으로만 매칭됩니다',                                  a:d.code});
    if(d.biz.length)  w.push({t:'사업장명 없음 — 사업장별 집계에서 빠집니다',                               a:d.biz});
    if(d.dlv.length)  w.push({t:'납기일자를 날짜로 못 읽음 — 출고일자 자동계산에서 빠집니다',               a:d.dlv});
    if(!e.length && !w.length) return '';
    var cls=e.length?'ss-pverr':'ss-pverr warn';
    var tot=e.reduce(function(s,x){return s+x.a.length;},0), wtot=w.reduce(function(s,x){return s+x.a.length;},0);
    var h='<div class="'+cls+'"><div class="eh">⚠️ 오류내역 — 데이터 '+d.n.toLocaleString()+'행 중 '
        + (tot?('<b>오류 '+tot.toLocaleString()+'행</b>'):'')+(tot&&wtot?' · ':'')+(wtot?('주의 '+wtot.toLocaleString()+'행'):'')
        + ' <span class="dim">(미리보기에서 <b>빨간 행</b>)</span></div><ul>';
    e.concat(w).forEach(function(x){ h+='<li>'+x.t+' '+ssLnList(x.a)+'</li>'; });
    return h+'</ul></div>';
  }

  // 도움말의 chrome://settings/downloads 복사 — 설정 주소는 링크로 못 열어(브라우저가 막음) 복사해서 주소창에 붙여넣게 한다.
  //   navigator.clipboard 는 https/localhost 에서만 되므로 execCommand 폴백을 함께 둔다(사내 http 접속 대비).
  function ssCopyTxt(txt, btn){
    function done(ok){
      if(btn){ var _o=btn.innerHTML; btn.innerHTML = ok?'✔ 복사됨':'복사 실패'; setTimeout(function(){ btn.innerHTML=_o; }, 1500); }
      ssToast(ok ? '📋 복사했습니다 — 크롬 <b>주소창</b>에 붙여넣고 Enter: <b>'+ssHistEsc(txt)+'</b>'
                 : '⚠️ 복사가 막혔습니다. 주소창에 직접 입력하세요: <b>'+ssHistEsc(txt)+'</b>');
    }
    try{
      if(navigator.clipboard && navigator.clipboard.writeText){
        navigator.clipboard.writeText(txt).then(function(){ done(true); }, function(){ done(ssCopyFallback(txt)); });
        return;
      }
    }catch(e){}
    done(ssCopyFallback(txt));
  }
  function ssCopyFallback(txt){
    try{
      var ta=document.createElement('textarea'); ta.value=txt;
      ta.style.cssText='position:fixed;left:-9999px;top:0'; document.body.appendChild(ta);
      ta.select(); var ok=document.execCommand('copy'); document.body.removeChild(ta); return ok;
    }catch(e){ return false; }
  }

  // 상단 [ℹ️ 도움말] 토글 — 기본 접힘. 접힘 상태를 브라우저에 기억(한번 읽은 사람은 계속 접힌 채로)
  function ssPvHelp(force){
    var box=document.getElementById('ssPvHelpBox'), btn=document.getElementById('ssPvHelpBtn'); if(!box) return;
    var on = (force===undefined) ? (box.style.display==='none') : !!force;
    box.style.display = on ? '' : 'none';
    if(btn) btn.innerHTML = on ? '✕ 도움말 닫기' : 'ℹ️ 도움말';
    if(force===undefined){ try{ localStorage.setItem('ssPvHelpOpen', on?'1':'0'); }catch(e){} }
  }

  /* ★작성(반영)이 끝나면 읽어 둔 엑셀을 버린다 (2026-08-01 요청).
       종전에는 `ssPvWb` 가 남아 있어 모달을 다시 열면 방금 반영한 파일이 그대로 떠 있었다.
       이미 처리한 자료인데 화면만 보면 '아직 안 올린 것' 과 구별이 안 돼, 같은 파일을 또
       [작성] 하기 쉬웠다. 반영이 끝나면 처음 상태(파일 고르라는 안내)로 돌아간다.
       ※취소·✕ 로 나갈 때는 지우지 않는다 — 잠깐 닫았다 다시 보는 경우다. */
  function ssPvReset(){
    ssPvWb=null; ssPvName=''; ssPvCur=null; ssPvBadFile=null;
    ssXrefUnmap=[]; ssXrefLinked=[]; ssXrefSeen=0; ssXrefBadSet={}; ssXrefPendClear();
    _sxLastNew=-1;
    var _f=document.getElementById('ssPvFile');  if(_f) _f.textContent='-';
    var _t=document.getElementById('ssPvTbl');   if(_t) _t.innerHTML='';
    var _e=document.getElementById('ssPvErr');   if(_e) _e.innerHTML='';
    var _x=document.getElementById('ssPvXref');  if(_x) _x.innerHTML='';
    var _w=document.getElementById('ssPvSheetWrap'); if(_w) _w.style.display='none';
    var _s=document.getElementById('ssPvSheet'); if(_s) _s.innerHTML='';
    var _d=document.getElementById('ssPvShpoutDt');
    if(_d){ _d.removeAttribute('data-touched'); _d.removeAttribute('data-file'); }
    ssPvHintInfo();
    if(typeof ssDirList==='function' && ssDirHandle) ssDirList();   // 좌측 목록의 '지금 열린 파일' 표시 해제
  }
  /* 아무 파일도 안 읽은 상태의 안내문 — 모달을 처음 열 때와 [초기화] 뒤에 같은 화면이 되게 한곳에 둔다 */
  function ssPvHintInfo(){
    var _i=document.getElementById('ssPvInfo'); if(!_i) return;
    _i.className='ss-pvinfo';
    _i.innerHTML='📂 왼쪽 <b>업로드 파일</b> 목록에서 파일을 누르면 내용이 여기 표시됩니다. '
      +'<span style="color:#6b7a89">폴더를 아직 지정하지 않았다면 위쪽 <b>📂 폴더 지정</b>, 폴더 밖 파일이면 <b>📄 파일 선택</b>. 자세한 설명은 <b>ℹ️ 도움말</b>.</span>';
  }
  /* ★[초기화] — 사용자가 직접 내린다 (2026-08-01 요청).
       [작성] 하지 않고 닫으면 그 파일은 일부러 남겨 둔다(이어서 보려던 경우). 그래서 지우는 길이
       따로 있어야 한다. 연결 '예정' 이 있으면 그것도 함께 사라지므로 먼저 묻는다. */
  function ssPvResetAsk(){
    if(!ssPvWb) return;
    var nP=Object.keys(ssXrefPend).length;
    ssConfirm('올려 둔 <b>'+ssEscHtml(ssPvName)+'</b> 를 화면에서 내릴까요?'
      + '<div style="margin-top:6px;font-size:12.5px;color:#5a6b7a">서버에 저장된 자료는 그대로입니다 — 이 미리보기 화면만 비웁니다.'
      + (nP ? '<br><b style="color:#c0392b">아직 저장하지 않은 연결 '+nP+'건도 함께 사라집니다.</b>' : '')
      + '</div>',
      function(){
        ssPvSkipAutoPick=true;      // 다시 열 때 최신 파일이 자동으로 불려 오지 않게
        ssPvReset();
        if(window._toast) _toast('미리보기를 비웠습니다','ok');
      }, { title:'🗑️ 미리보기 초기화', yes:'초기화' });
  }
  function ssPvOpen(show){
    var ov=document.getElementById('ssPvOverlay'); if(!ov) return;
    var wasOpen=ov.classList.contains('on');
    ov.classList.toggle('on', !!show);
    /* 닫으면(취소·✕) 연결 '예정' 은 버린다 — 저장하지 않고 나갔으니 아무것도 남으면 안 된다 */
    if(!show){ ssXrefPendClear(); ssXrefPopClose(); }
    if(show && !wasOpen){
      // 아직 아무 파일도 안 읽은 상태로 열릴 수 있다(버튼이 곧바로 이 모달을 연다) → 우측 빈칸 대신 안내
      if(!ssPvWb){
        var _t=document.getElementById('ssPvTbl'), _f=document.getElementById('ssPvFile');
        var _e=document.getElementById('ssPvErr'); if(_e) _e.innerHTML='';
        var _x=document.getElementById('ssPvXref'); if(_x) _x.innerHTML=''; ssXrefUnmap=[]; ssXrefPendClear();
        _sxLastNew=-1;   // 파일이 바뀌면 미연결 알림을 처음부터 다시 깜박인다
        if(_f) _f.textContent='-';
        if(_t) _t.innerHTML='';
        ssPvHintInfo();
      }
      try{ ssPvHelp(localStorage.getItem('ssPvHelpOpen')==='1'); }catch(e){ ssPvHelp(false); }   // 도움말은 기본 접힘(지난번 펼쳐 뒀으면 그대로)
      /* ★[작성] 직후·[초기화] 직후 한 번은 자동선택을 건너뛴다 — 안 그러면 방금 내린 그 파일이
           폴더에서 '최신' 이라 다시 열자마자 그대로 불려 와, 비워 둔 뜻이 없어진다(2026-08-01 요청). */
      ssAutoPick = !ssPvSkipAutoPick; ssPvSkipAutoPick=false;
      ssHistRefresh();                    // 열 때만 폴더 목록 로드(파일 클릭마다 재스캔 방지)
      ssUpHistLoad();                     // 좌측 하단 업로드 이력(오늘·3일)도 열 때 1회 갱신
      /* 해석 가능한 코드 집합(XREF ∪ 우리 품목코드) — 모달 열 때 1회.
         늦게 도착해도 되도록 도착 시 미리보기를 한 번 다시 그린다(파일이 이미 골라져 있으면). */
      ssXrefLoad(function(){ ssXrefRefresh(); });
    }
  }

  // 셀 표시값 — 날짜는 엑셀처럼 YYYY-MM-DD(시간 있으면 포함)
  function ssCellDisp(v){
    if(v instanceof Date && !isNaN(v)){
      var Y=v.getFullYear(), M=ssPad(v.getMonth()+1), D=ssPad(v.getDate());
      var h=v.getHours(), m=v.getMinutes(), s=v.getSeconds();
      return (h||m||s) ? (Y+'-'+M+'-'+D+' '+ssPad(h)+':'+ssPad(m)+':'+ssPad(s)) : (Y+'-'+M+'-'+D);
    }
    return (v==null?'':(''+v));
  }
  /* ===== 거래처 코드 점검 리포트 (2026-08-01) =============================================
     매핑이 틀리면 ①재고에서 빠지고 ②단가가 튀고 ③확인 없이 출고가 나가고 ④재고가 음수가 된다.
     그 네 신호를 서버(selectXrefAudit)에서 한 번에 받아 그대로 보여 준다. 고치는 곳은
     상품관리 [거래처 코드] 탭 / 업로드 프리뷰의 [연결] 이고, 여기는 조회 전용이다.
     ========================================================================================= */
  var xaAll=[], xaView=[], xaShown=0, XA_PAGE=200, xaBound=false;
  function xaLoad(){
    var days=((document.getElementById('xaDays')||{}).value)||'30';
    var tb=document.getElementById('xaBody');
    if(!tb) return;
    tb.innerHTML='<tr><td colspan="10" style="text-align:center;color:#8a97a3;padding:14px">조회 중…</td></tr>';
    fetch(KONET_CTX+'/prod/xrefAudit.do', { method:'POST', credentials:'same-origin',
        headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'matchScore='+encodeURIComponent(days) })
      .then(function(r){ return r.json(); })
      .then(function(j){ xaAll=(j&&j.data)||[]; xaDraw(); xaBind(); })
      .catch(function(e){ xaAll=[]; tb.innerHTML='<tr><td colspan="10" style="text-align:center;color:#c0392b;padding:14px">조회 오류: '+ssEscHtml(e.message)+'</td></tr>'; });
  }
  /* 구분·검색으로 거르고 처음 200건만 그린다 — 수백 건을 한 번에 그리면 화면이 굳는다.
     바닥에 닿으면 다음 묶음을 이어붙인다(이 프로젝트의 목록 화면들과 같은 방식). */
  function xaDraw(){
    var gb=((document.getElementById('xaGb')||{}).value)||'';
    var q=(((document.getElementById('xaFind')||{}).value)||'').trim().toLowerCase();
    xaView = xaAll.filter(function(o){
      if(gb && String(o.matchWhy||'').indexOf(gb)!==0) return false;
      if(!q) return true;
      return [o.extItemCd,o.extItemNm,o.prodCd,o.prodNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
    });
    /* ★구분 이름 그대로 센다 — ①이 '미매핑' 과 '재집계 대기' 로 갈리므로 첫 글자로 묶으면
         전혀 다른 두 가지가 한 숫자로 합쳐진다(2026-08-01). */
    var c={}; xaAll.forEach(function(o){ var k=(o.matchWhy||'-'); c[k]=(c[k]||0)+1; });
    var sum=document.getElementById('xaSum');
    if(sum){
      sum.innerHTML = xaAll.length
        ? Object.keys(c).sort().map(function(k){
            var col = (k.indexOf('미매핑')>=0) ? '#c0392b'
                    : (k.indexOf('재집계')>=0) ? '#1f6fb3'
                    : (k.indexOf('연결 처리')>=0) ? '#137a6c'
                    : (k.indexOf('재고 음수')>=0) ? '#b3760f' : '#5a6b7a';
            return '<span style="margin-right:16px;color:'+col+'">'+ssEscHtml(k)+' <b>'+c[k]+'</b>건</span>'; }).join('')
        : '<span style="color:#137a6c">✅ 이상 없습니다</span>';
    }
    xaShown = 0;
    document.getElementById('xaBody').innerHTML='';
    if(!xaView.length){
      document.getElementById('xaBody').innerHTML='<tr><td colspan="10" style="text-align:center;color:#8a97a3;padding:14px">'
        + (xaAll.length?'조건에 맞는 항목이 없습니다.':'✅ 이상 없습니다.')+'</td></tr>';
      xaPager(); return;
    }
    xaMore();
    var w=document.getElementById('xaWrap'); if(w) w.scrollTop=0;
  }
  function xaRowHtml(o){
    var urgent = (o.matchWhy||'').indexOf('①')===0;
    return '<tr id="xa-r-'+xaAll.indexOf(o)+'"'+(urgent?' style="background:#fff6f6"':'')+'>'
      + '<td>'+ssEscHtml(o.matchWhy)+'</td>'
      + '<td><b>'+ssEscHtml(o.extItemCd)+'</b></td>'
      + '<td style="text-align:left">'+ssEscHtml(o.extItemNm)+'</td>'
      + '<td>'+ssEscHtml(o.prodCd||'')+'</td>'
      + '<td style="text-align:left">'+ssEscHtml(o.prodNm||'')+'</td>'
      + '<td>'+ssEscHtml(o.vendorNm||'')+'</td>'
      + '<td>'+ssEscHtml(o.lastDt||'')+'</td>'
      + '<td style="text-align:right">'+ssEscHtml(o.useQty||'')+'</td>'
      + '<td style="text-align:left;color:#5a6b7a">'+ssEscHtml(o.remark||'')+'</td>'
      + '<td style="white-space:nowrap">'+xaActHtml(o)+'</td></tr>';
  }
  /* 구분에 따라 할 수 있는 일이 다르다 — 아무 데나 같은 버튼을 두면 헷갈린다 */
  function xaActHtml(o){
    if(o._done) return '<span style="color:#137a6c;font-weight:700">✔ 완료</span>';   // 이미 처리한 줄
    var i=xaAll.indexOf(o), gb=(o.matchWhy||'').slice(0,1);
    var B=function(act,txt,col){ return '<span class="xa-b" data-act="'+act+'"'+(col?' style="color:'+col+'"':'')
        +' onclick="xaAct('+i+',\''+act+'\')">'+txt+'</span>'; };
    /* ★①이라도 상품마스터에 같은 코드가 있으면(우리 코드가 채워져 있으면) 연결할 일이 아니다 —
         [출고반영 재집계] 한 번이면 해결된다. 버튼 대신 그렇게 안내한다(2026-08-01 지적). */
    if(gb==='①'){
      return o.prodCd
        ? '<span style="color:#1f6fb3;font-size:11.5px" title="상품마스터에 같은 코드가 있습니다. 연결할 필요 없이 재고 관리 ▸ 재고현황 ▸ [🔄 출고반영 재집계] 한 번이면 해석됩니다.">재집계로 해결</span>'
        : B('link','연결 ▾');
    }
    if(gb==='②') return (o.xrefSeq ? B('link','수정 ▾')+' '+B('unlink','해제','#c0392b') : '');
    if(gb==='③') return B('confirm','확인','#137a6c')+' '+B('link','수정 ▾')+' '+B('unlink','해제','#c0392b');
    return '';   // ④ 재고 음수 — 매핑 문제가 아닐 수 있다(입고 누락). 버튼을 주지 않는다
  }
  function xaMore(all){
    if(xaShown>=xaView.length) return;
    var to = all ? xaView.length : Math.min(xaShown+XA_PAGE, xaView.length), h='';
    for(var i=xaShown;i<to;i++) h += xaRowHtml(xaView[i]);
    document.getElementById('xaBody').insertAdjacentHTML('beforeend', h);
    xaShown = to; xaPager();
  }
  function xaPager(){
    var el=document.getElementById('xaPager'); if(!el) return;
    if(xaShown>=xaView.length){
      el.innerHTML = xaView.length ? ('총 <b>'+xaView.length+'</b>건 — 모두 표시됨'
        + (xaView.length<xaAll.length ? ' <span style="color:#9aa7b3">(전체 '+xaAll.length+'건 중)</span>' : '')) : '';
      return;
    }
    el.innerHTML = xaShown+' / <b>'+xaView.length+'</b>건 — 아래로 스크롤하면 이어서 나옵니다'
      + ' <button class="btn-line" style="height:24px;margin-left:8px;font-size:12px" onclick="xaMore(true)">모두 표시</button>';
  }
  /* ===== 점검 화면에서 바로 고치기 (2026-08-01 요청) =====================================
     종전에는 '현상만' 보여 주고 고치려면 상품관리로 옮겨 가야 했다. 여기서 끝내게 한다.
       ① 미매핑   → [연결]           (연결 팝업 · 즉시 저장)
       ② 단가 이탈 → [수정]·[해제]    (매핑이 틀렸을 가능성)
       ③ 확인 필요 → [확인] + [수정]·[해제]
       ④ 재고 음수 → 매핑 문제가 아닐 수 있어(입고 누락) 버튼을 주지 않는다
     ======================================================================================== */
  function _xaPost(url, body){
    return fetch(KONET_CTX+''+url, { method:'POST', credentials:'same-origin',
             headers:{'Content-Type':'application/json'}, body: JSON.stringify(body) })
      .then(function(r){ return r.text().then(function(t){ return {ok:r.ok,t:t}; }); });
  }
  /* after 를 주면 목록 전체를 다시 읽지 않는다 — 63건을 연달아 처리할 때 매번 재조회하면
     화면이 튀고 느리다. 처리한 줄만 '완료'로 바꾸고, 숫자는 [새로고침] 때 맞춘다. */
  function ssXrefSaveNow(u, prodSeq, prodCd, prodNm, after){
    var first = u.xrefSeq ? _xaPost('/prod/xrefDelete.do', { xrefSeq:u.xrefSeq })
                          : Promise.resolve({ok:true});
    first.then(function(x0){
      if(!x0.ok){ ssToast('⚠️ 기존 연결 해제 실패 — '+x0.t); return; }
      return _xaPost('/prod/xrefSave.do', { prodSeq:prodSeq, prodCd:prodCd,
               extItemCd:u.code, extItemNm:u.item, confirmYn:'N' })
        .then(function(x){
          if(!x.ok){ ssToast('⚠️ 연결 저장 실패 — '+x.t); return; }
          ssXrefPopClose();
          if(window._toast) _toast('연결했습니다 — '+u.code+' → '+prodCd+' (과거분도 반영)','ok');
          if(after) after(); else xaLoad();
        });
    });
  }
  /* 처리한 줄 — 지우지 않고 '완료'로 바꿔 둔다. 몇 개를 처리했는지 눈으로 보이는 게 낫다. */
  function xaRowDone(i, prodCd){
    xaSubRemove(i);
    var o=xaAll[i]; if(o) o._done=prodCd;
    var tr=document.getElementById('xa-r-'+i); if(!tr) return;
    tr.style.background='#f2faf7'; tr.style.opacity='.75';
    var td=tr.children;
    if(td.length>=10){
      td[3].innerHTML='<b>'+ssEscHtml(prodCd)+'</b>';
      td[8].innerHTML='<span style="color:#137a6c">연결 완료 — [새로고침] 하면 목록에서 빠집니다</span>';
      td[9].innerHTML='<span style="color:#137a6c;font-weight:700">✔ 완료</span>';
    }
  }
  /* ★후보를 그 행 '밑에' 펼친다 (2026-08-01 요청) — 63건을 팝업 63번 여는 건 못 할 일이다.
       한 번 조회한 후보는 캐시해 두고, 다시 누르면 접는다. 팝업(직접 찾기)은 후보가 없을 때만 쓴다. */
  var xaCand={};
  function xaSubRemove(i){
    Array.prototype.forEach.call(document.querySelectorAll('tr.xa-sub[data-for="'+i+'"]'), function(t){ t.parentNode.removeChild(t); });
  }
  function xaSubDraw(i, cands){
    xaSubRemove(i);
    var tr=document.getElementById('xa-r-'+i); if(!tr) return;
    var o=xaAll[i], html;
    if(cands===null){
      html='<tr class="xa-sub" data-for="'+i+'"><td colspan="10" style="padding:6px 26px;color:#8a97a3">후보 찾는 중…</td></tr>';
    } else if(!cands.length){
      html='<tr class="xa-sub" data-for="'+i+'"><td colspan="10" style="padding:6px 26px;color:#8a97a3">'
        +'비슷한 품목을 못 찾았습니다 — <span class="xa-b" onclick="xaAct('+i+',\'find\')">직접 찾기</span></td></tr>';
    } else {
      /* 펼친 후보 묶음 맨 위에 접기 줄 — 후보가 여러 개면 아래 버튼이 화면 밖으로 나갈 수 있다 */
      html='<tr class="xa-sub" data-for="'+i+'"><td colspan="10" style="padding:3px 26px;background:#f7fafb">'
        + '<span style="display:inline-block;width:14px;color:#9aa7b3">┌</span>'
        + '<span style="color:#6b7a89;font-size:12px">비슷한 품목 '+cands.length+'개 — 단가·재고를 보고 고르세요</span>'
        + ' <span class="xa-b" style="margin-left:8px" onclick="xaAct('+i+',\'link\')">접기 ▴</span></td></tr>'
        + cands.map(function(c){
        var dead=(!c.curQty||Number(c.curQty)===0) && !c.lastOutDt;
        return '<tr class="xa-sub" data-for="'+i+'"'+(dead?' style="opacity:.6"':'')+'>'
          + '<td colspan="10" style="padding:4px 26px;text-align:left">'
          +   '<span style="display:inline-block;width:14px;color:#9aa7b3">└</span>'
          +   '<span style="display:inline-block;width:110px;color:#137a6c;font-weight:700">'+ssEscHtml(c.prodCd)+'</span>'
          +   '<span style="display:inline-block;width:330px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;vertical-align:bottom" title="'+ssEscHtml(c.prodNm)+'">'+ssEscHtml(c.prodNm)+'</span>'
          +   '<span style="display:inline-block;width:170px;color:#6b7a89;font-size:12px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;vertical-align:bottom">'+ssEscHtml(c.extSpec||'')+'</span>'
          +   '<span style="display:inline-block;width:80px;text-align:right" title="판매단가">'+_num(c.salePrice)+'</span>'
          +   '<span style="display:inline-block;width:70px;text-align:right" title="현재고">'+_num(c.curQty)+'</span>'
          +   '<span style="display:inline-block;width:60px;text-align:right;color:#6b7a89" title="최근 출고">'+_dt(c.lastOutDt)+'</span>'
          +   '<span style="display:inline-block;width:100px;color:#b3760f;font-size:12px;font-weight:600;padding-left:10px">'+ssEscHtml(c.matchWhy||'')+'</span>'
          +   '<span class="xa-b" onclick="xaPick('+i+','+c.prodSeq+',\''+ssEscHtml(c.prodCd)+'\')">연결</span>'
          + '</td></tr>';
      }).join('')
      + '<tr class="xa-sub" data-for="'+i+'"><td colspan="10" style="padding:2px 26px 6px">'
      +   '<span style="display:inline-block;width:14px"></span>'
      +   '<span class="xa-b" onclick="xaAct('+i+',\'find\')">직접 찾기…</span></td></tr>';
    }
    tr.insertAdjacentHTML('afterend', html);
  }
  /* 펼침/접힘에 따라 버튼 글자를 바꾼다 — 같은 버튼이 토글이라는 걸 글자로 보여 준다 */
  function xaBtnState(i, open){
    var tr=document.getElementById('xa-r-'+i); if(!tr) return;
    var b=tr.querySelector('.xa-b[data-act="link"]'); if(!b) return;
    var gb=((xaAll[i]||{}).matchWhy||'').slice(0,1);
    b.textContent = open ? '접기 ▴' : (gb==='①' ? '연결 ▾' : '수정 ▾');
  }
  /* 도움말 — 접힘이 기본, 펼쳐 뒀으면 다음에도 그대로(업로드 모달 도움말과 같은 방식) */
  function xaHelp(show){
    var box=document.getElementById('xaHelp'), btn=document.getElementById('xaHelpBtn'); if(!box) return;
    var on = (show===undefined) ? (box.style.display==='none') : !!show;
    box.style.display = on ? 'block' : 'none';
    if(btn) btn.textContent = on ? '✕ 도움말 닫기' : 'ℹ️ 도움말';
    try{ localStorage.setItem('xaHelpOpen', on?'1':'0'); }catch(e){}
  }
  function xaCollapseAll(){
    Array.prototype.forEach.call(document.querySelectorAll('tr.xa-sub'), function(t){ t.parentNode.removeChild(t); });
    Array.prototype.forEach.call(document.querySelectorAll('#xaBody .xa-b[data-act="link"]'), function(b){
      var tr=b.closest ? b.closest('tr') : null; if(!tr) return;
      var i=+String(tr.id||'').replace('xa-r-','');
      var gb=((xaAll[i]||{}).matchWhy||'').slice(0,1);
      b.textContent = (gb==='①' ? '연결 ▾' : '수정 ▾');
    });
  }
  function xaExpand(i){
    if(document.querySelector('tr.xa-sub[data-for="'+i+'"]')){ xaSubRemove(i); xaBtnState(i,false); return; }   // 토글 = 접기
    var o=xaAll[i]; if(!o) return;
    xaBtnState(i,true);
    if(xaCand[o.extItemCd]){ xaSubDraw(i, xaCand[o.extItemCd]); return; }
    xaSubDraw(i, null);
    fetch(KONET_CTX+'/prod/xrefCandidates.do', { method:'POST', credentials:'same-origin',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'extItemCd='+encodeURIComponent(o.extItemCd)+'&extItemNm='+encodeURIComponent(o.extItemNm||'') })
      .then(function(r){ return r.json(); })
      .then(function(j){ var c=(j&&j.data)||[]; xaCand[o.extItemCd]=c; xaSubDraw(i, c); })
      .catch(function(){ xaCand[o.extItemCd]=[]; xaSubDraw(i, []); });
  }
  /* 펼쳐진 후보에서 바로 연결 */
  function xaPick(i, prodSeq, prodCd){
    var o=xaAll[i]; if(!o) return;
    ssXrefSaveNow({ code:o.extItemCd, item:o.extItemNm||'', xrefSeq:o.xrefSeq||null }, prodSeq, prodCd, '',
                  function(){ xaRowDone(i, prodCd); });
  }
  /* 처리한 줄 공통 표시 — 확인/해제도 연결과 같은 방식으로 제자리에서 끝낸다 */
  function xaRowMark(i, txt, col){
    xaSubRemove(i);
    var o=xaAll[i]; if(o) o._done=txt;
    var tr=document.getElementById('xa-r-'+i); if(!tr) return;
    tr.style.background='#f7f9fa'; tr.style.opacity='.75';
    var td=tr.children;
    if(td.length>=10){
      td[8].innerHTML='<span style="color:'+(col||'#137a6c')+'">'+txt+' — [새로고침] 하면 목록에서 빠집니다</span>';
      td[9].innerHTML='<span style="color:'+(col||'#137a6c')+';font-weight:700">✔ 완료</span>';
    }
  }
  function xaAct(i, act){
    var o=xaAll[i]; if(!o) return;
    if(act==='link'){ xaExpand(i); return; }              // 팝업 대신 행 밑에 펼친다
    if(act==='find'){                                     // 후보가 없거나 더 찾고 싶을 때만 팝업
      ssXrefOpenFor({ code:o.extItemCd, item:o.extItemNm||'', zone:o.vendorNm||'',
                      xrefSeq:o.xrefSeq || null,
                      cur: o.prodCd ? { prodCd:o.prodCd, prodNm:o.prodNm||'' } : null }, true);
      return;
    }
    if(act==='confirm'){
      _xaPost('/prod/xrefConfirm.do', { xrefSeq:o.xrefSeq }).then(function(x){
        if(!x.ok){ ssToast('⚠️ '+x.t); return; }
        if(window._toast) _toast('확인했습니다 — '+o.extItemCd,'ok');
        xaRowMark(i, '확인 완료');
      });
      return;
    }
    if(act==='unlink'){
      ssConfirm('연결을 해제할까요?<br><b>'+ssEscHtml(o.extItemCd)+'</b> → '+ssEscHtml(o.prodCd||'')
        +'<div style="margin-top:6px;font-size:12.5px;color:#5a6b7a">이 코드로 반영된 출고·정산도 함께 되돌리고 재고를 다시 계산합니다.</div>',
        function(){
          _xaPost('/prod/xrefDelete.do', { xrefSeq:o.xrefSeq }).then(function(x){
            if(!x.ok){ ssToast('⚠️ '+x.t); return; }
            if(window._toast) _toast('해제했습니다 — '+o.extItemCd,'ok');
            xaRowMark(i, '연결 해제됨', '#c0392b');
          });
        });
    }
  }
  function xaBind(){
    var w=document.getElementById('xaWrap'); if(!w||xaBound) return; xaBound=true;
    w.addEventListener('scroll', function(){
      if(xaShown>=xaView.length) return;
      if(w.scrollTop + w.clientHeight >= w.scrollHeight - 40) xaMore();
    });
  }

  /* ===== 미매핑 품목 연결 (2026-08-01) =====================================================
     거래처(출고장)는 같은 물건을 자기 코드·자기 품명으로 요청한다. 종전에는 그 표기마다
     상품마스터에 '가상코드'를 새로 등록해야 했고 그래서 재고가 갈라졌다.
     이제 코네트 품목은 하나로 두고 (거래처 코드 → 우리 품목) 매핑만 TBL_PROD_XREF 에 쌓는다.

     화면이 하는 일은 '해석되지 않는 코드를 저장 전에 알려주고 그 자리에서 연결'하는 것뿐이다.
       · 해석 규칙은 서버와 동일 : ① XREF 에 등록된 거래처 코드 ② 우리 PROD_CD 와 같은 코드
         → 둘 다 아니면 미매핑. (②가 있어서 코드가 같은 품목은 등록이 아예 필요 없다)
       · ★저장을 막지 않는다. 원본은 그대로 들어가고 그 행만 재고 반영이 보류된다.
       · 연결하면 서버(saveXref)가 과거 업로드분까지 소급으로 채우고 재고를 다시 만든다.
     ========================================================================================= */
  var ssXrefSet=null;      // 해석 가능한 코드 집합 (XREF 등록분 ∪ 우리 품목코드)
  var ssXrefUnmap=[];      // 이번 파일의 미매핑 [{code,item}]
  var ssXrefProds=null;    // 우리 품목 목록(연결 팝업 검색용 — 처음 열 때 1회)

  /* ssXrefSet = 해석 가능한 코드 전체(연결분 ∪ 우리 품목코드) — 미매핑 판정용
     ssXrefMap = 그중 **연결(XREF)로 잡힌 것만** — 이 파일에서 연결해 둔 내역을 보여주고
                 거기서 바로 수정·해제하려면 xrefSeq 까지 들고 있어야 한다(2026-08-01 요청) */
  var ssXrefMap={};
  /* ssXrefExt = 상품코드등록 화면에서 붙여 둔 **거래처 매칭코드**(TBL_EXT_ITEM_MST) — 2026-08-01 추가.
     서버 해석이 XREF → 매칭코드 → 코드직결 3패스로 바뀌었으므로, 미리보기도 매칭코드를 알아야
     '해석될 코드'를 미연결이라고 잘못 경고하지 않는다. 여기 있는 코드는 '연결됨'으로 본다. */
  var ssXrefExt={};
  function ssXrefLoad(cb){
    var ctx=KONET_CTX+'', set={}, map={}, ext={}, left=3;
    function done(){ if(--left===0){ ssXrefSet=set; ssXrefMap=map; ssXrefExt=ext; if(cb) cb(); } }
    fetch(ctx+'/prod/extItemList.do', { method:'POST', credentials:'same-origin',
             headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
      .then(function(r){ return r.json(); })
      .then(function(j){
        ((j&&j.data)||[]).forEach(function(o){
          var k=String(o.extItemCd||'').trim();
          if(!k || !o.prodCd) return;              // 상품을 안 고른 줄은 해석에 안 쓰인다(미연결 그대로)
          set[k]=1;
          ext[k]={ prodCd:o.prodCd, prodNm:o.prodNm||'', vendorNm:o.vendorNm||'', extItemNm:o.extItemNm||'' };
        });
        done();
      })
      .catch(function(){ done(); });
    fetch(ctx+'/prod/xrefList.do', { method:'POST', credentials:'same-origin',
             headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
      .then(function(r){ return r.json(); })
      .then(function(j){
        ((j&&j.data)||[]).forEach(function(o){
          var k=String(o.extItemCd||'').trim(); if(!k) return;
          set[k]=1;
          map[k]={ xrefSeq:o.xrefSeq, prodCd:o.prodCd, prodNm:o.prodNm||'', confirmYn:o.confirmYn,
                   vendorNm:o.vendorNm||'', extItemNm:o.extItemNm||'' };
        });
        done();
      })
      .catch(function(){ done(); });   // 조회 실패해도 화면은 살려 둔다
    fetch(ctx+'/prod/prodList.do', { method:'POST', credentials:'same-origin',
             headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'findData=' })
      .then(function(r){ return r.json(); })
      .then(function(j){ ((j&&j.data)||[]).forEach(function(o){ var k=String(o.prodCd||'').trim(); if(k) set[k]=1; }); done(); })
      .catch(function(){ done(); });
  }

  /* 이번 파일에서 해석 안 되는 코드만 (코드별 1건으로 묶는다 — 행 단위로 늘어놓으면 수백 줄이 된다) */
  var ssXrefSeen=0;        // 이번 파일의 품목코드 종수(중복 제외) — 결과를 눈으로 확인시키기 위한 값
  var ssXrefLinked=[];     // 이 파일의 코드 중 '연결(XREF)로 잡힌 것' — 여기서 수정·해제한다
  var ssXrefExtHit=[];     // 이 파일의 코드 중 '거래처 매칭코드'로 해석되는 것 (2026-08-01)
                           //   ★수정·해제는 여기서 안 한다 — 상품코드등록 화면이 주인이다. 숫자로만 알린다.
  function ssXrefScan(rows){
    ssXrefUnmap=[]; ssXrefLinked=[]; ssXrefExtHit=[]; ssXrefSeen=0;
    if(!ssXrefSet) return;                       // 아직 목록이 안 왔으면 조용히 넘어간다
    var seen={}, all={};
    (rows||[]).forEach(function(r){
      var cd=(r.code||'').trim();
      if(!cd) return;                            // 품목코드가 없는 양식은 이 기능 대상이 아니다
      if(all[cd]) { if(seen[cd]) seen[cd].n++; return; }
      all[cd]=1; ssXrefSeen++;
      /* 연결로 잡힌 코드 — 우리 코드와 같아서 그냥 붙는 것(코드 직결)은 대상이 아니다.
         '사람이 이어 붙인 것'만 보여줘야 수정할 거리가 눈에 띈다. */
      if(ssXrefMap[cd]){ ssXrefLinked.push({code:cd, item:r.item||'', info:ssXrefMap[cd]}); return; }
      /* 거래처 매칭코드로 해석되는 코드 — 서버가 2차 패스에서 이 코드로 상품을 찾는다.
         미연결 경고 대상이 아니다(경고하면 '이미 등록했는데 또 물어본다'가 된다). */
      if(ssXrefExt[cd]){ ssXrefExtHit.push({code:cd, item:r.item||'', info:ssXrefExt[cd]}); return; }
      if(ssXrefSet[cd] || ssXrefPend[cd]) return;   // 코드 직결이거나 이번에 연결하기로 한 코드
      seen[cd]={code:cd, item:r.item||'', zone:r.zone||'', n:1};
      ssXrefUnmap.push(seen[cd]);
    });
  }

  /* ★연결용 그리드를 없애고 '미리보기 표' 안에서 끝낸다 (2026-08-01 요청).
       종전에는 위에 연결 전용 그리드가 따로 있어, 같은 품목코드를 위·아래 두 표에서 두 번 봐야 했다.
       이제 위에는 **숫자 한 줄**만 남기고, 아래 미리보기 표의 **품목코드 칸을 직접 누른다.**
         · 미연결   = 빨강 + 밑줄 (누를 수 있다는 신호)
         · 연결 예정 = 초록
         · 연결됨    = 옅은 청록 (수정·해제하러 들어갈 수 있다)
         · 코드직결  = 아무 표시 없음 — 우리 코드와 같아 그냥 붙는 것이라 손댈 거리가 아니다
       누르면 그 행 밑에 후보가 펼쳐진다(품목코드(매핑) 화면과 같은 방식). */
  /* '미연결 행만' 은 한 번 켜면 다음 파일·다음 날에도 켜져 있다 — 매일 하는 일이라 매번 다시 켜게 하면 번거롭다 */
  var ssXrefOnlyNew=(function(){ try{ return localStorage.getItem('sxOnlyNew')==='1'; }catch(e){ return false; } })();
  var ssXrefBadSet={};   // 미연결 코드 집합 — 미리보기 표가 칸을 칠할 때 본다
  var _sxLastNew=-1;     // 직전 미연결 종수 — 숫자가 바뀔 때만 깜박이게 하려고 기억한다
  var ssPvMaxC=0;        // 펼침 줄의 colspan 계산용

  /* 위쪽 한 줄 — 숫자와 '미연결 행만' 체크만 있다. 표는 아래 미리보기가 겸한다. */
  function ssXrefRender(){
    var box=document.getElementById('ssPvXref'); if(!box) return;
    if(!ssXrefSet){ box.innerHTML='<div style="font-size:12.5px;color:#8a9199;margin-bottom:8px">⏳ 품목 목록을 불러오는 중…</div>'; return; }

    ssXrefBadSet={};
    ssXrefUnmap.forEach(function(u){ ssXrefBadSet[u.code]=1; });
    var nNew=ssXrefUnmap.length, nPend=Object.keys(ssXrefPend).length, nLink=ssXrefLinked.length,
        nExt=ssXrefExtHit.length;

    if(!ssXrefSeen){
      box.innerHTML='<div class="ss-pverr dim" style="color:#8a9199">ℹ️ 품목코드 칸을 찾지 못해 매핑 검사를 건너뜁니다</div>';
      return;
    }
    /* ★숫자는 언제나 '이 파일 전체' 기준이다 — 체크를 켜도 그대로 (2026-08-01 요청).
         걸러진 목록 기준으로 바뀌면 '몇 개 남았나'를 볼 수가 없다. */
    var head = '<span style="font-weight:700">🔗 품목코드 연결</span>'
      + ' <span style="color:#8a97a3">이 파일 '+ssXrefSeen+'종</span>'
      /* ★미연결이 있으면 살짝 깜박인다 (2026-08-01 요청) — 이 줄은 '인식 완료' 초록 알림 바로 밑이라
           그냥 두면 다 잘된 줄 알고 [작성] 을 눌러 버린다. 이 프로젝트의 '이전 자료' 알림과 같은 방식:
           .ss-blink = 1초 × 10회 뒤 빨강 그대로 멈춘다(계속 깜박이면 눈에 거슬린다). */
      + (nNew  ? ' <span'+(nNew!==_sxLastNew?' class="ss-blink"':'')+' style="color:#c0392b;font-weight:700;margin-left:10px">⚠ 미연결 '+nNew+'</span>' : '')
      + (nPend ? ' <span style="color:#137a6c;font-weight:700;margin-left:10px">저장 예정 '+nPend+'</span>' : '')
      + (nLink ? ' <span style="color:#6b7a89;margin-left:10px">연결됨 '+nLink+'</span>' : '')
      /* 상품코드등록 화면에 붙여 둔 매칭코드로 풀리는 것 — 여기서 손댈 거리가 아니라 숫자로만 알린다 */
      + (nExt  ? ' <span style="color:#274b8f;margin-left:10px" title="상품코드등록 화면의 [거래처 매칭코드]로 상품이 정해집니다.">매칭코드 '+nExt+'</span>' : '')
      + (nNew  ? ' <span style="color:#7a3b34;margin-left:12px;font-size:13px">— 아래 표의 <b style="color:#c0392b">빨간 품목코드</b>를 누르면 연결합니다</span>'
               : ' <span style="color:#137a6c;margin-left:12px;font-size:13px">— 모두 우리 품목으로 연결됩니다</span>')
      + '<label style="margin-left:auto;font-size:13px;color:#5a6b7a;cursor:pointer;white-space:nowrap"'
      +   ' title="품목코드가 미연결·연결예정인 행만 남기고 감춥니다. 위 숫자는 파일 전체 기준 그대로입니다.">'
      +   '<input type="checkbox" id="sxOnlyNew"'+(ssXrefOnlyNew?' checked':'')+' onchange="ssXrefOnlyToggle(this)"'
      +   ' style="vertical-align:-2px;margin-right:5px;width:14px;height:14px">미연결 행만</label>';

    /* ★글자를 한 단계 키운다 (2026-08-01 요청) — .ss-pverr 기본 12.5px 는 오류내역 목록용 크기라
         이 줄처럼 '숫자를 읽는' 용도에는 작았다. 이 줄만 키우고 오류내역은 그대로 둔다. */
    box.innerHTML = '<div class="ss-pverr'+(nNew?' warn':' good')+'" style="margin-bottom:8px;font-size:14px">'
      + '<div style="display:flex;align-items:center;gap:8px">'+head+'</div></div>';
    /* 숫자가 바뀔 때만 다시 깜박인다 — '미연결 행만' 체크를 껐다 켤 때마다 재시작하면 거슬린다
       (이력 재렌더마다 재시작하지 않는 ssBackMsgUpd 와 같은 규칙). */
    _sxLastNew = nNew;
  }
  function ssXrefOnlyToggle(el){ ssXrefOnlyNew = !!(el && el.checked);
    try{ localStorage.setItem('sxOnlyNew', ssXrefOnlyNew?'1':'0'); }catch(e){}
    ssPvRender();          // 걸러내기는 미리보기 표가 한다
  }

  /* ===== 품목코드 칸을 누르면 그 행 밑에 후보가 펼쳐진다 =====================================
     품목코드(매핑) 화면(xaExpand)과 같은 방식이다. 매일 올리는 파일에서 서너 개씩 붙이는 일이라
     팝업을 띄우고·고르고·닫는 반복이 번거롭다는 지적(2026-08-01).
     후보가 마땅치 않을 때만 [직접 찾기…] 로 팝업을 연다.
     한 번 조회한 후보는 코드별로 캐시한다 — 같은 코드가 다음 파일에도 또 온다. */
  var ssXrefCand={};
  function ssXrefSubRemove(code){
    Array.prototype.forEach.call(document.querySelectorAll('#ssPvTbl tr.xrsub'+(code?'[data-code="'+code+'"]':'')),
      function(t){ t.parentNode.removeChild(t); });
  }
  function _sxQ(s){ return String(s==null?'':s).replace(/\\/g,'\\\\').replace(/'/g,"\\'"); }
  function _sxSub(code, inner){
    return '<tr class="xrsub" data-code="'+ssEscHtml(code)+'"><td class="rn"></td>'
         + '<td colspan="'+Math.max(1,ssPvMaxC)+'">'+inner+'</td></tr>';
  }
  function ssXrefSubDraw(r, code, cands){
    ssXrefSubRemove(code);
    var tr=document.getElementById('sspv-r-'+r); if(!tr) return;
    var pend=ssXrefPend[code], link=ssXrefMap[code], html;

    if(pend){                                     // 이미 고른 것 — 되돌리거나 다시 고른다
      var pl=(pend.op==='unlink')?'해제 예정':(pend.op==='relink'?'변경 예정':'연결 예정');
      html=_sxSub(code, '<span style="color:#137a6c;font-weight:700">'+pl+'</span>'
        + (pend.op==='unlink' ? ' <span style="color:#c0392b">연결 없음</span>'
                              : ' → <b style="color:#137a6c">'+ssEscHtml(pend.prodCd)+'</b> '+ssEscHtml(pend.prodNm))
        + ' <span style="color:#8a97a3;font-size:11.5px">· [작성] 할 때 저장됩니다</span>'
        + ' <span class="xr-b" style="margin-left:10px" onclick="ssXrefUndo(\''+_sxQ(code)+'\')">되돌리기</span>'
        + ' <span class="xr-b" onclick="ssXrefRepick('+r+',\''+_sxQ(code)+'\')">다시 고르기</span>');
      tr.insertAdjacentHTML('afterend', html); return;
    }
    if(link && !ssXrefBadSet[code]){               // 이미 연결된 코드 — 수정·해제
      html=_sxSub(code, '<span style="color:#137a6c">🔗 연결됨</span>'
        + ' → <b style="color:#137a6c">'+ssEscHtml(link.prodCd)+'</b> '+ssEscHtml(link.prodNm)
        + ' <span class="xr-b" style="margin-left:10px" onclick="ssXrefRepick('+r+',\''+_sxQ(code)+'\')">수정</span>'
        + ' <span class="xr-b" style="color:#c0392b" onclick="ssXrefUnlink(\''+_sxQ(code)+'\')">해제</span>');
      tr.insertAdjacentHTML('afterend', html); return;
    }
    if(cands===null){
      html=_sxSub(code, '<span style="color:#8a97a3">후보 찾는 중…</span>');
    } else if(!cands.length){
      html=_sxSub(code, '<span style="color:#8a97a3">비슷한 품목을 못 찾았습니다 — </span>'
        + '<span class="xr-b" onclick="ssXrefFindOpen(\''+_sxQ(code)+'\')">직접 찾기…</span>');
    } else {
      html=_sxSub(code, '<span style="color:#6b7a89">비슷한 품목 '+cands.length+'개 — 단가·재고를 보고 고르세요</span>'
            + ' <span class="xr-b" style="margin-left:8px" onclick="ssXrefSubRemove(\''+_sxQ(code)+'\')">접기 ▴</span>')
        + cands.map(function(c){
            var dead=(!c.curQty||Number(c.curQty)===0) && !c.lastOutDt;   // 재고도 거래도 없으면 옛 가상코드일 수 있다
            return _sxSub(code, (dead?'<span style="opacity:.55">':'<span>')
              +   '<span class="sx-c" style="width:14px;color:#9aa7b3">└</span>'
              +   '<span class="sx-c" style="width:106px;color:#137a6c;font-weight:700">'+ssEscHtml(c.prodCd)+'</span>'
              +   '<span class="sx-c" style="width:280px" title="'+ssEscHtml(c.prodNm)+'">'+ssEscHtml(c.prodNm)+'</span>'
              +   '<span class="sx-c" style="width:150px;color:#6b7a89">'+ssEscHtml(c.extSpec||'')+'</span>'
              +   '<span class="sx-c" style="width:76px;text-align:right" title="판매단가">'+_num(c.salePrice)+'</span>'
              +   '<span class="sx-c" style="width:64px;text-align:right" title="현재고">'+_num(c.curQty)+'</span>'
              +   '<span class="sx-c" style="width:56px;text-align:right;color:#6b7a89" title="최근 출고">'+_dt(c.lastOutDt)+'</span>'
              +   '<span class="sx-c" style="width:92px;color:#b3760f;font-weight:600;padding-left:10px">'+ssEscHtml(c.matchWhy||'')+'</span>'
              + '</span>'
              + '<span class="xr-b" onclick="ssXrefPick(\''+_sxQ(code)+'\','+c.prodSeq+',\''+_sxQ(c.prodCd)+'\',\''+_sxQ(c.prodNm)+'\')">연결</span>');
          }).join('')
        + _sxSub(code, '<span class="sx-c" style="width:14px"></span>'
            + '<span class="xr-b" onclick="ssXrefFindOpen(\''+_sxQ(code)+'\')">직접 찾기…</span>');
    }
    tr.insertAdjacentHTML('afterend', html);
  }
  /* 품목코드 칸 클릭 — 같은 코드가 이미 펼쳐져 있으면 접는다(토글).
     ★다른 코드는 접지 않는다 — 미연결은 열자마자 전부 펼쳐 두므로(ssXrefAutoExpand),
       하나 누를 때마다 나머지가 접히면 오히려 손이 더 간다. */
  function ssXrefCellClick(r, code){
    if(document.querySelector('#ssPvTbl tr.xrsub[data-code="'+code+'"]')){ ssXrefSubRemove(code); return; }
    if(ssXrefPend[code] || (ssXrefMap[code] && !ssXrefBadSet[code])){ ssXrefSubDraw(r, code, null); return; }
    if(ssXrefCand[code]){ ssXrefSubDraw(r, code, ssXrefCand[code]); return; }
    ssXrefSubDraw(r, code, null);
    var it=''; for(var i=0;i<ssXrefUnmap.length;i++) if(ssXrefUnmap[i].code===code) it=ssXrefUnmap[i].item||'';
    fetch(KONET_CTX+'/prod/xrefCandidates.do', { method:'POST', credentials:'same-origin',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'extItemCd='+encodeURIComponent(code)+'&extItemNm='+encodeURIComponent(it) })
      .then(function(x){ return x.json(); })
      .then(function(j){ var c=(j&&j.data)||[]; ssXrefCand[code]=c; ssXrefSubDraw(r, code, c); })
      .catch(function(){ ssXrefCand[code]=[]; ssXrefSubDraw(r, code, []); });
  }
  /* ★「미연결 행만」을 켰을 때는 후보를 미리 펼쳐 둔다 (2026-08-01 요청).
       그 상태의 표에는 손볼 행밖에 없으니 후보로 덮일 원본 자료가 없다 — 빨간 칸을 하나씩
       찾아 누를 이유가 없고, 바로 고르기만 하면 된다.
       체크를 끄면(전체 보기) 펼치지 않는다 — 208행 사이에 후보가 끼어들면 원본을 못 읽는다.
       한 번 펼친 후보는 코드별로 캐시되므로 다시 그려도 서버를 또 부르지 않는다. */
  var SX_AUTO_MAX=20;   // 미연결이 이보다 많으면 펼치지 않는다(첫 업로드·대량 이관 때)
  function ssXrefAutoExpand(firstRow){
    if(!ssXrefOnlyNew) return;
    var codes=ssXrefUnmap.map(function(u){ return u.code; }).filter(function(c){ return firstRow[c]!=null; });
    if(!codes.length || codes.length>SX_AUTO_MAX) return;
    codes.forEach(function(c){ ssXrefCellClick(firstRow[c], c); });
  }
  /* 이미 고른 것을 다시 고른다 — 예정을 지우고 후보를 새로 펼친다 */
  function ssXrefRepick(r, code){
    delete ssXrefPend[code]; ssXrefSubRemove(code);
    if(ssXrefCand[code]) ssXrefSubDraw(r, code, ssXrefCand[code]);
    else ssXrefCellClick(r, code);
  }
  /* 펼친 후보에서 바로 고르기 — 저장이 아니라 '예정' 이다([작성] 때 적용) */
  function ssXrefPick(code, prodSeq, prodCd, prodNm){
    var it=''; for(var i=0;i<ssXrefUnmap.length;i++) if(ssXrefUnmap[i].code===code) it=ssXrefUnmap[i].item||'';
    window._ssXrefCur={ code:code, item:it }; window._ssXrefNow=false;
    ssXrefLink(prodSeq, prodCd, prodNm);      // 안에서 ssXrefRefresh 까지 한다
  }
  /* 후보가 마땅치 않을 때만 팝업 */
  function ssXrefFindOpen(code){
    var it='', cur=null;
    for(var i=0;i<ssXrefUnmap.length;i++) if(ssXrefUnmap[i].code===code) it=ssXrefUnmap[i].item||'';
    if(ssXrefMap[code]) cur=ssXrefMap[code];
    if(ssXrefPend[code]) cur={ prodCd:ssXrefPend[code].prodCd, prodNm:ssXrefPend[code].prodNm };
    ssXrefOpenFor({ code:code, item:it, zone:'', cur:cur });
  }

  /* 연결·해제·되돌리기 뒤 다시 그리기.
     ★표시가 미리보기 표의 품목코드 칸으로 옮겨졌으므로(2026-08-01) 미리보기까지 같이 그려야 한다.
       화면이 튀지 않도록 ssPvRender 안에서 #ssPvWrap 의 스크롤 위치를 보존한다. */
  function ssXrefRefresh(){
    if(!(ssPvCur && ssPvCur.aoa && ssPvCur.map)) return;
    ssXrefSubRemove();          // 펼쳐 둔 후보 줄은 접고 다시 그린다
    ssPvRender();               // 안에서 ssXrefScan + ssXrefRender 까지 한다
  }
  function ssEscHtml(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

  /* 연결 팝업 — 후보(서버 추천) + 직접 검색.
     ★추천 근거는 단가·규격이 1순위고 품명은 보조다(서버 selectXrefCandidates). 자동 확정은 없다.
     ★공용 알림(_alertBox)이 아니라 전용 모달을 쓴다 — 340px 컴팩트라 품명이 세 줄로 접히고
       가로 스크롤이 생겨 고를 수가 없었다(2026-08-01 지적).
     ★바깥을 눌러도 닫히지 않는다 — 품목을 고르는 중에 실수로 닫히면 처음부터 다시 해야 한다.
       닫는 길은 헤더 ✕ 와 하단 [닫기] 뿐이다. */
  function _ssXrefPopEnsure(){
    var ov=document.getElementById('ssXrefPop');
    if(!ov){
      ov=document.createElement('div'); ov.className='ss-modal'; ov.id='ssXrefPop';
      ov.innerHTML=
        '<div class="box">'
        + '<div class="mh"><span>🔗 품목 연결</span>'
        +   '<span style="cursor:pointer;font-size:18px" onclick="ssXrefPopClose()" title="닫기">✕</span></div>'
        + '<div id="ssXrefBody" style="padding:16px 20px; overflow:auto; font-size:13px; text-align:left"></div>'
        + '<div style="padding:10px 20px 14px; border-top:1px solid var(--logi-border); text-align:right">'
        +   '<button class="ss-btn" onclick="ssXrefPopClose()">닫기</button></div>'
        + '</div>';
      /* 배경 클릭으로 닫지 않는다(핸들러를 아예 안 단다) — 상자 안 클릭이 배경으로 새는 것만 막는다 */
      document.body.appendChild(ov);
    } else if (ov.parentNode !== document.body) {
      document.body.appendChild(ov);      // 미리보기 모달이 body 로 옮겨질 때 같이 따라가게
    }
    return ov;
  }
  function ssXrefPopClose(){ var ov=document.getElementById('ssXrefPop'); if(ov) ov.classList.remove('on'); }

  /* ★비슷한 후보가 여럿일 때 고를 재료 (2026-08-01 지적).
       품명·규격이 같으면 근거만으로는 못 고른다 — 단가·재고·최근출고가 실제 판단 근거다.
       재고도 거래도 없는 쪽은 예전에 만든 가상코드일 가능성이 높다(흐리게 표시).
       ★추천 후보와 직접 찾기가 같이 쓰므로 바깥 범위에 둔다. */
  function _num(v){ return (v==null||v==='') ? '' : Number(v).toLocaleString(); }
  function _dt(v){ v=(''+(v||'')); return v.length===8 ? v.slice(4,6)+'-'+v.slice(6,8) : ''; }
  /* 품명에서 찾기 좋은 조각을 뽑는다 — 서버 추천(nk.core8)과 같은 규칙.
     맨 앞 괄호묶음(브랜드 표기)은 거래처마다 달라 빼고, 그 뒤 8자를 쓴다.
     예) (런던&레이&하이)줄무늬크라프트유산지,350*250MM → '줄무늬크라프트유' */
  function ssXrefFrag(nm){
    var n=String(nm||'').replace(/\s/g,'');
    var p=n.indexOf(')');
    if(p>=1 && p<=11) n=n.substring(p+1);
    n=n.replace(/^[,\-·]+/,'');
    return n.substring(0,8);
  }

  function ssXrefLinkOpen(i){ var u=ssXrefUnmap[i]; if(u) ssXrefOpenFor(u); }
  /* now=true 면 고르는 즉시 저장한다 — 점검 화면에는 [작성] 같은 확정 단계가 없다.
     업로드 미리보기(now 아님)는 예정으로만 담고 [작성] 때 적용한다. */
  function ssXrefOpenFor(u, now){
    window._ssXrefCur=u; window._ssXrefNow=!!now;
    var ctx=KONET_CTX+'';
    function row(o){
      var dead = (!o.curQty || Number(o.curQty)===0) && !o.lastOutDt;   // 재고·거래 둘 다 없음
      return '<div class="xr-row"'+(dead?' style="opacity:.62"':'')+'>'
        + '<span class="xr-cd">'+ssEscHtml(o.prodCd)+'</span>'
        + '<span class="xr-nm" title="'+ssEscHtml(o.prodNm)+'">'+ssEscHtml(o.prodNm)+'</span>'
        + '<span class="xr-sp" title="'+ssEscHtml(o.extSpec||'')+'">'+ssEscHtml(o.extSpec||'')+'</span>'
        + '<span class="xr-n" title="판매단가">'+_num(o.salePrice)+'</span>'
        + '<span class="xr-n" title="현재고">'+_num(o.curQty)+'</span>'
        + '<span class="xr-n" title="최근 출고">'+_dt(o.lastOutDt)+'</span>'
        + '<span class="xr-wy">'+ssEscHtml(o.matchWhy||'')+'</span>'
        + '<button class="ss-btn" style="height:24px;padding:0 10px;font-size:12px" '
        +   'onclick="ssXrefLink('+o.prodSeq+',\''+ssEscHtml(o.prodCd)+'\',\''+ssEscHtml(String(o.prodNm||'').replace(/'/g,'')) +'\')">연결</button>'
        + '</div>';
    }
    function paint(cands){
      var html=
          '<div style="padding:10px 12px;background:#f4f8f7;border:1px solid #d5e6e2;border-radius:7px;margin-bottom:12px;line-height:1.7">'
        +   '<span style="color:#6b7a89">거래처 코드</span> <b>'+ssEscHtml(u.code)+'</b>'
        +   '<span style="margin-left:16px;color:#6b7a89">거래처 품명</span> <b>'+ssEscHtml(u.item)+'</b>'
        +   (u.zone?'<span style="margin-left:16px;color:#6b7a89">출고장</span> '+ssEscHtml(u.zone):'')
        +   (u.cur?'<div style="margin-top:6px;padding-top:6px;border-top:1px solid #d5e6e2">'
                 + '<span style="color:#6b7a89">지금 연결</span> <b>'+ssEscHtml(u.cur.prodCd)+'</b> '
                 + ssEscHtml(u.cur.prodNm)+' <span style="color:#8a97a3">— 아래에서 다른 품목을 고르면 바뀝니다</span></div>':'')
        + '</div>'
        + '<div style="color:#c0392b;font-size:12px;margin-bottom:8px">'
        +   '⚠️ 거래처는 품명도 자기 식으로 보냅니다 — 이름이 아니라 <b>규격·단가</b>로 확인하세요.</div>';
      if(cands && cands.length){
        html += '<div style="font-weight:700;margin-bottom:2px">추천 후보</div>'
          + '<div class="xr-row" style="border:0;color:#8a97a3;font-size:11.5px;padding-bottom:0">'
          +   '<span class="xr-cd">품목코드</span><span class="xr-nm">품명</span><span class="xr-sp">규격</span>'
          +   '<span class="xr-n">판매단가</span><span class="xr-n">현재고</span><span class="xr-n">최근출고</span>'
          +   '<span class="xr-wy">근거</span><span style="flex:0 0 64px"></span></div>'
          + cands.map(row).join('');
      } else {
        html += '<div style="color:#8a97a3">추천할 후보가 없습니다 — 아래에 <b>품명 조각</b>을 넣어 뒀습니다. 지우고 다르게 쳐도 됩니다.</div>';
      }
      html += '<div style="margin-top:16px;font-weight:700">직접 찾기</div>'
        + '<input id="ssXrefQ" placeholder="품목코드 · 품명 · 규격" autocomplete="off"'
        +   ' style="width:100%;height:32px;border:1px solid #cfd8e3;border-radius:6px;padding:0 10px;margin:6px 0" oninput="ssXrefSearch()">'
        + '<div id="ssXrefRes"></div>';
      var ov=_ssXrefPopEnsure();
      document.getElementById('ssXrefBody').innerHTML = html;
      document.getElementById('ssXrefBody').style.maxHeight = '70vh';
      ov.classList.add('on');
      var q=document.getElementById('ssXrefQ');
      if(q){
        /* 추천이 비면 검색창을 비워 두지 않는다 — 사용자가 매번 품명에서 조각을 골라
           손으로 치고 있었다. 서버 추천과 같은 규칙(맨 앞 괄호묶음을 떼고 8자)으로 채워 준다. */
        if(!(cands && cands.length)){ q.value = ssXrefFrag(u.item); ssXrefSearch(); }
        q.focus(); q.select();
      }
    }
    /* ★코드도 보낸다 — 서버가 그 코드로 들어온 정산서에서 단가·규격을 찾아 1순위 근거로 쓴다.
         발주현황표에는 규격·단가가 없어서 품명만 보내면 못 믿는 근거로만 추천하게 된다. */
    fetch(ctx+'/prod/xrefCandidates.do', { method:'POST', credentials:'same-origin',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'extItemCd='+encodeURIComponent(u.code)+'&extItemNm='+encodeURIComponent(u.item) })
      .then(function(r){ return r.json(); })
      .then(function(j){ paint((j&&j.data)||[]); })
      .catch(function(){ paint([]); });
  }
  function ssXrefSearch(){
    var q=((document.getElementById('ssXrefQ')||{}).value||'').trim().toLowerCase();
    var res=document.getElementById('ssXrefRes'); if(!res) return;
    function draw(){
      var l=(ssXrefProds||[]).filter(function(p){
        if(!q) return false;
        return [p.prodCd,p.prodNm,p.spec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
      }).slice(0,30);
      /* 추천 후보와 같은 열 구성 — 여기서도 단가를 봐야 고를 수 있다(재고·최근출고는 목록에 없다) */
      res.innerHTML = l.length ? l.map(function(p){
        return '<div class="xr-row">'
          + '<span class="xr-cd">'+ssEscHtml(p.prodCd)+'</span>'
          + '<span class="xr-nm" title="'+ssEscHtml(p.prodNm)+'">'+ssEscHtml(p.prodNm)+'</span>'
          + '<span class="xr-sp" title="'+ssEscHtml(p.spec||'')+'">'+ssEscHtml(p.spec||'')+'</span>'
          + '<span class="xr-n" title="판매단가">'+_num(p.salePrice)+'</span>'
          + '<span class="xr-n"></span><span class="xr-n"></span>'
          + '<span class="xr-wy"></span>'
          + '<button class="ss-btn" style="height:24px;padding:0 10px;font-size:12px" onclick="ssXrefLink('+p.prodSeq+',\''+ssEscHtml(p.prodCd)+'\',\''+ssEscHtml(String(p.prodNm||'').replace(/'/g,''))+'\')">연결</button>'
          + '</div>';
      }).join('') : (q?'<div style="color:#8a97a3;padding:6px 0">결과가 없습니다.</div>':'');
    }
    if(ssXrefProds) { draw(); return; }
    fetch(KONET_CTX+'/prod/prodList.do', { method:'POST', credentials:'same-origin',
        headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'findData=' })
      .then(function(r){ return r.json(); })
      .then(function(j){ ssXrefProds=(j&&j.data)||[]; draw(); })
      .catch(function(){ res.innerHTML='<div style="color:#c0392b">품목 조회 오류</div>'; });
  }
  /* ★고른 것은 '예정' 으로만 담아 둔다 — 실제 저장은 [작성] 을 눌러야 한다 (2026-08-01 지적).
       이 모달은 '내용 확인 후 작성' 흐름인데 [연결]만 즉시 DB 에 쓰면 흐름이 어긋난다.
       [취소]로 나가면 아무것도 안 남아야 한다.
     거래처·출고장은 비워 공통 별칭으로 저장한다 — 품목코드는 출고장 7곳이 공유하므로
     출고장별로 나눠 걸면 같은 코드를 7번 등록하게 된다. 예외는 상품관리 탭에서 거래처를 지정해 추가. */
  var ssXrefPend={};   // 거래처코드 → {op:'link'|'relink'|'unlink', xrefSeq?, prodSeq, prodCd, prodNm}
  function ssXrefLink(prodSeq, prodCd, prodNm){
    var u=window._ssXrefCur; if(!u) return;
    /* 점검 화면에서 부른 경우 — 즉시 저장. 이미 연결이 있으면 지우고 새로 건다(UNIQUE 때문). */
    if(window._ssXrefNow){ ssXrefSaveNow(u, prodSeq, prodCd, prodNm); return; }
    var old = ssXrefMap[u.code];          // 이미 연결돼 있으면 '변경'이다 — 옛 연결을 지우고 새로 건다
    ssXrefPend[u.code] = { op: old ? 'relink' : 'link', xrefSeq: old ? old.xrefSeq : null,
                           prodSeq:prodSeq, prodCd:prodCd, prodNm:prodNm||'', extItemNm:u.item };
    ssXrefPopClose();
    if(window._toast) _toast((old?'변경':'연결')+' 예정 — '+u.code+' → '+prodCd+' · [작성] 할 때 적용됩니다','ok');
    ssXrefRefresh();
  }
  /* 이미 연결된 코드를 고친다 — 연결 팝업을 그대로 재사용하고, 고르면 위에서 relink 로 담긴다 */
  function ssXrefEditOpen(code){
    var L=null; for(var i=0;i<ssXrefLinked.length;i++) if(ssXrefLinked[i].code===code) L=ssXrefLinked[i];
    if(!L) return;
    ssXrefOpenFor({ code:L.code, item:L.item, zone:'', cur:L.info });
  }
  /* 연결 해제 — 즉시 지우지 않고 예정으로 담는다([작성] 때 적용, [취소]면 없던 일) */
  function ssXrefUnlink(code){
    var m=ssXrefMap[code]; if(!m) return;
    ssXrefPend[code] = { op:'unlink', xrefSeq:m.xrefSeq, prodCd:m.prodCd, prodNm:m.prodNm };
    if(window._toast) _toast('해제 예정 — '+code+' · [작성] 할 때 적용됩니다','warn');
    ssXrefRefresh();
  }
  function ssXrefUndo(code){ delete ssXrefPend[code]; ssXrefRefresh(); }
  function ssXrefPendClear(){ ssXrefPend={}; }
  function ssXrefLinkedToggle(){ window._ssXrefLinkOpen = !window._ssXrefLinkOpen; ssXrefRefresh(); }

  /* [작성] 직전에 예정분을 실제로 저장한다. 하나라도 실패하면 업로드를 진행하지 않는다
     — 매핑이 빠진 채로 저장되면 그 품목이 재고에서 조용히 빠지기 때문이다. */
  function ssXrefPendSave(){
    var keys=Object.keys(ssXrefPend);
    if(!keys.length) return Promise.resolve(true);
    var ctx=KONET_CTX+'';
    function post(url, body){
      return fetch(ctx+url, { method:'POST', credentials:'same-origin',
                 headers:{'Content-Type':'application/json'}, body: JSON.stringify(body) })
        .then(function(r){ return r.text().then(function(t){ return {ok:r.ok,t:t}; }); });
    }
    return keys.reduce(function(chain, cd){
      return chain.then(function(ok){
        if(!ok) return false;
        var p=ssXrefPend[cd];
        /* 해제·변경은 먼저 옛 연결을 지운다 — 서버가 그때 이미 반영된 출고·정산까지 되돌린다.
           변경은 '지우고 새로 걸기' 다(같은 코드에 두 연결이 생기면 UNIQUE 위반). */
        var first = (p.op==='unlink' || p.op==='relink')
          ? post('/prod/xrefDelete.do', { xrefSeq:p.xrefSeq })
          : Promise.resolve({ok:true, t:''});
        return first.then(function(x0){
          if(!x0.ok){ ssToast('⚠️ 연결 해제 실패 ('+cd+') — '+x0.t); return false; }
          if(p.op==='unlink') return true;
          return post('/prod/xrefSave.do', { prodSeq:p.prodSeq, prodCd:p.prodCd,
                       /* 연결 시점에는 규격·단가가 없어(발주현황표에 그 칸이 없다) 품명만 보고 고르게 된다.
                          그래서 '확인 필요' 상태로 저장하고, 정산서가 와서 대조가 되면 확정한다. */
                       extItemCd:cd, extItemNm:p.extItemNm, confirmYn:'N' })
            .then(function(x){
              if(!x.ok){ ssToast('⚠️ 품목 연결 저장 실패 ('+cd+') — '+x.t); return false; }
              return true;
            });
        });
      });
    }, Promise.resolve(true)).then(function(ok){
      if(ok){ ssXrefPendClear(); ssXrefLoad(function(){}); }   // 저장됐으니 예정 목록을 비우고 코드집합 갱신
      return ok;
    });
  }

  // 미리보기 렌더 (엑셀 내용 그대로 + 인식컬럼 하이라이트)
  function ssPvRender(){
    var aoa=ssPvAoa();
    var m=ssMapCols(aoa);
    ssPvCur={aoa:aoa, map:m};
    var info=document.getElementById('ssPvInfo');
    var errBox=document.getElementById('ssPvErr');
    var btn=document.getElementById('ssPvApplyBtn');
    var hlCols={}, dlvCol=-1, badRows={};
    if(errBox) errBox.innerHTML='';
    if(m){
      [m.cItem,m.cBiz,m.cBizCode,m.cZone,m.cQty,m.cCode,m.cInb,m.cCenter].forEach(function(c){ if(c>=0) hlCols[c]=1; });
      if(m.cDate>=0){ dlvCol=m.cDate; }   // 납기일자 컬럼(구분 표시)
      var _exRows=ssExtractRows(aoa,m);
      var cnt=_exRows.length;
      // 출고일자 기본값 = 엑셀에서 읽은 날짜(코네트 양식 = 납기일자) 그대로 — 사용자가 고치지 않았으면 채움
      //  ★출고장(김해·제주 포함) 구분 없이 같은 값. 여러 날짜가 섞여 있으면 가장 늦은 날짜.
      var shpEl=document.getElementById('ssPvShpoutDt');
      if(shpEl){
        if(shpEl.getAttribute('data-file')!==ssPvName){ shpEl.removeAttribute('data-touched'); shpEl.setAttribute('data-file', ssPvName||''); }
        if(shpEl.getAttribute('data-touched')!=='1'){
          var _ds=_exRows.map(function(r){ return r.date; }).filter(Boolean).sort();
          shpEl.value = _ds.length ? _ds[_ds.length-1] : SS_TODAY;
        }
      }
      info.className='ss-pvinfo';
      if(m.fmt==='konet'){
        info.innerHTML=SS_PV_RST+'✅ 인식 완료 (코네트 발주현황표·출고장) — '
          + '<span class="tag">물류센터명+입고장 → 출고장</span>'
          + '<span class="tag">품목명() → 사업장</span>'
          + (m.cCode>=0?'<span class="tag">품목코드</span>':'')
          + '<span class="tag">수량 → 출고량</span>'
          + ' · 데이터 <b>'+cnt+'</b>건 (노란 칸이 반영 대상)';
      } else {
        info.innerHTML=SS_PV_RST+'✅ 인식 완료 — <span class="tag">품목명</span><span class="tag">사업장명</span>'
          + (m.cBizCode>=0?'<span class="tag">사업장코드</span>':'')
          + '<span class="tag">존(출고장)</span><span class="tag">수량</span>'
          + (m.cCode>=0?'<span class="tag">품목코드</span>':'')
          + ' · 데이터 <b>'+cnt+'</b>건 (노란 칸이 반영 대상)';
      }
      // 우리 품목으로 해석 안 되는 품목코드 — 저장은 막지 않고 알리기만(재고 반영만 보류된다)
      ssXrefScan(_exRows); ssXrefRender();
      // 양식은 맞아도 값이 빠진 행이 있으면 오류내역을 함께 (저장은 막지 않음)
      var _rd=ssRowDiag(aoa,m); badRows=_rd.bad;
      var _rh=ssRowErrHtml(_rd);
      if(errBox) errBox.innerHTML=_rh;
      if(_rh && (_rd.zone.length||_rd.qty.length) && ssPvBadFile!==ssPvName){
        ssPvBadFile=ssPvName;
        ssToast('⚠️ 오류내역 있음 — 출고장/수량이 빠진 행 '+(_rd.zone.length+_rd.qty.length)+'행 (미리보기 위쪽 확인)');
      }
      btn.removeAttribute('disabled'); btn.style.opacity='1';
    } else {
      ssXrefUnmap=[]; ssXrefRender();   // 양식부터 안 맞으면 미매핑을 따질 단계가 아니다
      info.className='ss-pvinfo warn';
      info.innerHTML=SS_PV_RST+'⚠️ <b>형식이 맞지 않는 자료입니다</b> — 발주현황표(출고) 양식이 아닙니다.<br>'
        + '헤더에 <b>물류센터명·품목명·현 발주</b>(코네트) 또는 <b>품목명·사업장명·존·수량</b> 이 있어야 합니다. 시트를 바꿔 보세요.';
      if(errBox) errBox.innerHTML=ssFmtErrHtml(aoa);   // 무엇이 다른지 목록으로
      btn.setAttribute('disabled','disabled'); btn.style.opacity='.5';
      // 같은 파일엔 한 번만 팝업(시트 바꿀 때마다 반복 방지)
      if(ssPvBadFile!==ssPvName){ ssPvBadFile=ssPvName; ssToast('⚠️ 형식이 맞지 않는 자료입니다 — 오류내역을 확인하세요'); }
    }
    // ※ ssPvBadFile 은 '이 파일로 이미 알렸다' 표시 — 오류가 없을 때만 푼다(있으면 시트 바꿔도 재알림 안 함)
    if(m && !Object.keys(badRows).length) ssPvBadFile=null;
    // 미리보기 표 (전체 행 표시 — 모달 내 스크롤)
    var maxR=Math.min(aoa.length,2000), maxC=0;
    for(var i=0;i<maxR;i++) maxC=Math.max(maxC,(aoa[i]||[]).length);
    maxC=Math.min(maxC,40);
    ssPvMaxC=maxC;                                       // 펼침 줄 colspan
    var _wrap=document.getElementById('ssPvWrap'), _sc=_wrap?_wrap.scrollTop:0;
    var codeCol = m ? m.cCode : -1;                      // 품목코드 칸 — 여기를 누르면 연결한다
    var nHid=0, _firstRow={};                            // 코드별 첫 등장 행 — 후보를 그 아래 펼친다
    var html='';
    for(var r=0;r<maxR;r++){
      var isHdr = m && (r===m.h || r===m.h+1);
      /* ★'미연결 행만' — 손볼 거리가 있는 행만 남긴다. 208행 중 4행을 찾아 스크롤하지 않게.
           머리글 줄은 언제나 남긴다(칸이 뭔지 못 보면 표를 읽을 수 없다). */
      if(ssXrefOnlyNew && !isHdr && codeCol>=0){
        var _cv=String(ssCellDisp(aoa[r]&&aoa[r][codeCol])||'').trim();
        if(!(_cv && (ssXrefBadSet[_cv] || ssXrefPend[_cv]))){ nHid++; continue; }
      }
      /* ★값이 빠진 행(badrow)에도 id 를 준다 — 그 행의 품목코드를 눌렀을 때 펼칠 자리를 못 찾으면
           아무 반응이 없다(오류가 겹친 행일수록 손볼 일이 많다). */
      html+= isHdr ? '<tr class="hdr">' : '<tr id="sspv-r-'+r+'"'+(badRows[r]?' class="badrow"':'')+'>';
      html+='<td class="rn">'+(r+1)+'</td>';
      for(var c=0;c<maxC;c++){
        var v=ssCellDisp(aoa[r]&&aoa[r][c]);
        var cls = (c===dlvCol) ? 'dlv' : (hlCols[c] ? 'hl' : '');   // 납기일자=파란, 반영대상=노랑
        var extra='', pre='';
        if(!isHdr && c===codeCol && v){
          var cd=String(v).trim(), pn=ssXrefPend[cd], lk=ssXrefMap[cd];
          if(_firstRow[cd]==null) _firstRow[cd]=r;
          /* ★코드 앞에 상태를 글자로 붙인다 (2026-08-01 요청) — 색만으로는 '연결이 된 건지'를
               말해 주지 못한다. 딱지가 있으면 스크롤하며 훑어도 바로 읽힌다. */
          if(pn){
            cls='xrpend'; pre='<span class="xrchip">'+(pn.op==='unlink'?'해제':'연결')+'</span>';
            extra=' onclick="ssXrefCellClick('+r+',\''+_sxQ(cd)+'\')"'
              + ' title="'+(pn.op==='unlink'?'해제 예정':'연결 예정')+' → '+ssEscHtml(pn.prodCd||'')+' · [작성] 할 때 저장됩니다. 눌러서 되돌리기·다시 고르기"';
          } else if(ssXrefBadSet[cd]){
            cls='xrbad';  pre='<span class="xrchip">미연결</span>';
            extra=' onclick="ssXrefCellClick('+r+',\''+_sxQ(cd)+'\')"'
              + ' title="우리 품목을 찾지 못했습니다 — 연결 전까지 이 품목은 재고에서 빠집니다. 눌러서 연결하세요."';
          } else if(lk){
            cls='xrlnk';  pre='<span class="xrchip">연결</span>';
            extra=' onclick="ssXrefCellClick('+r+',\''+_sxQ(cd)+'\')"'
              + ' title="🔗 '+ssEscHtml(lk.prodCd||'')+' '+ssEscHtml(lk.prodNm||'')+' 로 연결돼 있습니다. 눌러서 수정·해제"';
          } else if(ssXrefExt[cd]){
            /* 상품코드등록 화면에 붙여 둔 거래처 매칭코드로 상품이 정해지는 코드 (2026-08-01).
               여기서는 누를 수 없다 — 고치려면 그 화면에서. 딱지로 '무엇으로 풀렸는지'만 알려 준다. */
            var ex=ssXrefExt[cd];
            cls='xrext';  pre='<span class="xrchip">매칭</span>';
            extra=' title="🔖 거래처 매칭코드 → '+ssEscHtml(ex.prodCd||'')+' '+ssEscHtml(ex.prodNm||'')
              + ' &#10;고치려면 기준정보 ▸ 상품코드등록 화면의 [거래처 매칭코드] 에서."';
          }
        }
        if(!extra) extra=' title="'+v.replace(/"/g,'&quot;')+'"';
        html+='<td'+(cls?' class="'+cls+'"':'')+extra+'>'+pre+v+'</td>';
      }
      html+='</tr>';
    }
    if(nHid) html+='<tr><td class="rn">…</td><td colspan="'+maxC+'" style="color:#9aa7b3">'
      + '연결이 끝난 '+nHid+'행은 감췄습니다 — 위 <b>미연결 행만</b> 체크를 끄면 전부 보입니다</td></tr>';
    if(aoa.length>2000) html+='<tr><td class="rn">…</td><td colspan="'+maxC+'" style="color:#9aa7b3">이하 '+(aoa.length-2000)+'행 생략 (작성 시 전체 반영)</td></tr>';
    document.getElementById('ssPvTbl').innerHTML=html;
    if(_wrap) _wrap.scrollTop=_sc;                       // 연결 뒤에도 보던 자리 유지
    ssXrefAutoExpand(_firstRow);                         // '미연결 행만' 일 때 후보를 미리 펼쳐 둔다
    ssBackMsgUpd();   // 마지막에 올린 자료보다 이전 출고일자면 하단에 알림(막지는 않음)
  }

  // 앱 스타일 확인 메시지 박스 (native confirm 대체)
  function ssConfirm(html, onYes, opts){
    opts=opts||{};
    var ov=document.getElementById('ssConfirmOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='ssConfirmOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(440px,90vw)">'
        +'<div class="mh"><h4 id="ssConfirmTitle">📋 반영 확인</h4><button class="x" onclick="ssConfirmClose()">&times;</button></div>'
        +'<div class="mbody" id="ssConfirmMsg" style="font-size:14px; line-height:1.6; color:#37475a"></div>'
        +'<div class="mfoot"><button class="btn-line" onclick="ssConfirmClose()">취소</button>'
        +'<button class="btn-teal" id="ssConfirmYes">반영</button></div></div>';
      document.body.appendChild(ov);
    }
    document.getElementById('ssConfirmTitle').textContent = opts.title || '📋 반영 확인';
    document.getElementById('ssConfirmMsg').innerHTML=html;
    var yes=document.getElementById('ssConfirmYes'); yes.textContent = opts.yes || '반영';
    yes.onclick=function(){ ssConfirmClose(); if(onYes) onYes(); };
    ov.classList.add('on');
  }
  function ssConfirmClose(){ var ov=document.getElementById('ssConfirmOv'); if(ov) ov.classList.remove('on'); }

  // 사업장·품목 직접 추가 (새 열 생성 → 칸에서 수량 입력)
  function ssAddItem(){
    var ov=document.getElementById('ssAddOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='ssAddOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(440px,92vw)">'
        +'<div class="mh"><h4>＋ 사업장·품목 추가</h4><button class="x" onclick="ssAddClose()">&times;</button></div>'
        +'<div class="mbody" style="font-size:13px">'
        +'<div style="margin-bottom:9px"><label style="display:block;color:#6b7a89;margin-bottom:3px">사업장(브랜드) — 기존 선택 또는 신규 입력</label><input id="ssAddBiz" list="ssAddBizDL" style="width:100%;height:34px;border:1px solid #dfe6e3;border-radius:6px;padding:0 10px;box-sizing:border-box" placeholder="기존 사업장 선택 또는 새 이름(비우면 기타·공통)"><datalist id="ssAddBizDL"></datalist></div>'
        +'<div style="margin-bottom:9px"><label style="display:block;color:#6b7a89;margin-bottom:3px">품목명 * — 기존 검색 또는 신규 입력</label><input id="ssAddName" list="ssAddNameDL" oninput="ssAddNamePick(this.value)" style="width:100%;height:34px;border:1px solid #dfe6e3;border-radius:6px;padding:0 10px;box-sizing:border-box" placeholder="품목명 검색 또는 새 품목명"><datalist id="ssAddNameDL"></datalist></div>'
        +'<div><label style="display:block;color:#6b7a89;margin-bottom:3px">품목코드(선택)</label><input id="ssAddCode" style="width:100%;height:34px;border:1px solid #dfe6e3;border-radius:6px;padding:0 10px;box-sizing:border-box" placeholder="없으면 품목명으로 매칭"></div>'
        +'<div style="margin-top:8px;color:#9aa7b3;font-size:12px">추가하면 새 열이 생기고, 당일 모드에서 칸에 수량을 입력하면 합계에 자동 합산됩니다.</div>'
        +'</div>'
        +'<div class="mfoot"><button class="btn-line" onclick="ssAddClose()">취소</button><button class="btn-teal" onclick="ssAddSave()">추가</button></div></div>';
      document.body.appendChild(ov);
    }
    document.getElementById('ssAddBiz').value=''; document.getElementById('ssAddName').value=''; document.getElementById('ssAddCode').value='';
    document.getElementById('ssAddBizDL').innerHTML=(window.ssBrandList||[]).map(function(b){ return '<option value="'+(''+b).replace(/"/g,'&quot;')+'">'; }).join('');
    document.getElementById('ssAddNameDL').innerHTML=(window.ssItemList||[]).map(function(it){ return '<option value="'+(''+it.name).replace(/"/g,'&quot;')+'">'+(it.brand||'')+(it.code?(' · '+it.code):'')+'</option>'; }).join('');
    ov.classList.add('on');
  }
  // 품목명 검색 선택 시 코드·사업장 자동 채움
  function ssAddNamePick(v){
    v=(v||'').trim(); if(!v) return;
    var hit=(window.ssItemList||[]).filter(function(it){ return it.name===v || it.full===v; })[0];
    if(hit){ document.getElementById('ssAddCode').value=hit.code||''; document.getElementById('ssAddBiz').value=hit.brand||''; }
  }
  function ssAddClose(){ var ov=document.getElementById('ssAddOv'); if(ov) ov.classList.remove('on'); }
  function ssAddSave(){
    var biz=(document.getElementById('ssAddBiz').value||'').trim();
    var name=(document.getElementById('ssAddName').value||'').trim();
    var code=(document.getElementById('ssAddCode').value||'').trim();
    if(!name){ ssToast('⚠️ 품목명을 입력하세요.'); return; }
    var fullName = (biz && !/^\(/.test(name)) ? ('('+biz+')'+name) : name;   // 브랜드 접두로 그룹 매칭
    var key = code ? code : ('NM:'+fullName);
    // 중복 체크 — 품목코드(있으면) / 없으면 품목명 기준
    var dup = (window.ssItemList||[]).some(function(it){ return code ? (it.code===code && code!=='') : (it.full===fullName); })
            || ssExtraItems.some(function(e){ return e.key===key; });
    if(dup){ ssToast('⚠️ 이미 등록된 품목입니다'+(code?(' (품목코드 '+code+')'):' (품목명 동일)')); return; }
    ssExtraItems.push({name:fullName, code:code, key:key});
    ssAddClose(); ssRender();
    ssToast('＋ 품목 추가: '+name+(biz?(' ['+biz+']'):'')+' — 칸에 수량을 입력하세요(당일 모드)');
  }

  // 존(출고장) 직접 추가
  function ssAddZone(){
    var ov=document.getElementById('ssZoneOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='ssZoneOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(400px,92vw)">'
        +'<div class="mh"><h4>＋ 출고장 추가</h4><button class="x" onclick="ssZoneClose()">&times;</button></div>'
        +'<div class="mbody" style="font-size:13px"><label style="display:block;color:#6b7a89;margin-bottom:3px">출고장 코드</label>'
        +'<input id="ssZoneCode" style="width:100%;height:34px;border:1px solid #dfe6e3;border-radius:6px;padding:0 10px;box-sizing:border-box" placeholder="예) A5, B1, F9 (앞 글자=입고장 그룹)">'
        +'<div style="margin-top:8px;color:#9aa7b3;font-size:12px">앞 글자(A·C·D·F)로 입고장 그룹에 들어갑니다. 당일 모드에서 칸에 수량 입력 → 합계 자동 합산.</div></div>'
        +'<div class="mfoot"><button class="btn-line" onclick="ssZoneClose()">취소</button><button class="btn-teal" onclick="ssZoneSave()">추가</button></div></div>';
      document.body.appendChild(ov);
    }
    document.getElementById('ssZoneCode').value='';
    ov.classList.add('on');
  }
  function ssZoneClose(){ var ov=document.getElementById('ssZoneOv'); if(ov) ov.classList.remove('on'); }
  // 추가 품목/존 삭제 (수량 없을 때만 ✕ 노출됨)
  function ssDelItem(e, el){ if(e){e.stopPropagation();e.preventDefault();} var k=el.getAttribute('data-dk'); ssExtraItems=(ssExtraItems||[]).filter(function(x){return x.key!==k;}); ssRender(); ssToast('🗑 추가 품목 삭제'); }
  function ssDelZone(e, el){ if(e){e.stopPropagation();e.preventDefault();} var z=el.getAttribute('data-dz'); ssExtraZones=(ssExtraZones||[]).filter(function(x){return x!==z;}); ssRender(); ssToast('🗑 추가 출고장 삭제: '+z); }
  // 출고장 그룹 삭제 — 그룹(앞글자 기준)에 속한 모든 출고장 데이터 제거
  function ssDelZoneGroup(e, el){
    if(e){e.stopPropagation();e.preventDefault();}
    var L=el.getAttribute('data-dgl'); if(!L) return;
    ssConfirm('<b>'+L+'출고장</b> 그룹 전체를 삭제하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 이 그룹에 속한 모든 출고장이 삭제됩니다. 다른 그룹은 유지됩니다.</span>',
      function(){
        SHIP_DATA=SHIP_DATA.filter(function(r){ return ((''+(r.zone||'')).charAt(0)||'').toUpperCase()!==L; });
        ssExtraZones=(ssExtraZones||[]).filter(function(x){ return ((''+x).charAt(0)||'').toUpperCase()!==L; });
        delete ssZoneCollapsed[L];
        ssRender();
        ssToast('🗑 출고장 그룹 삭제: '+L+'출고장');
      });
  }
  // 개별 출고장 삭제 — 해당 출고장의 데이터만 제거(다른 출고장은 유지)
  function ssDelZoneData(e, el){
    if(e){e.stopPropagation();e.preventDefault();}
    var z=el.getAttribute('data-dz'); if(!z) return;
    ssConfirm('출고장 <b>'+z+'</b> 을(를) 삭제하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 이 출고장 행만 삭제되고, 다른 출고장은 그대로 유지됩니다.</span>',
      function(){
        SHIP_DATA=SHIP_DATA.filter(function(r){ return (''+(r.zone||''))!==z; });
        ssExtraZones=(ssExtraZones||[]).filter(function(x){ return x!==z; });
        ssRender();
        ssToast('🗑 출고장 삭제: '+z);
      });
  }
  // 출고장 초기화 — 화면의 모든 데이터(샘플/업로드) 비우기
  function ssClearAll(){
    ssConfirm('출고장을 <b>초기화</b> 하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 화면의 모든 출고장·품목 데이터(샘플·업로드 포함)가 비워집니다. 이후 엑셀 업로드로 출고장을 새로 채울 수 있습니다.</span>',
      function(){
        SHIP_DATA=[];
        ssExtraItems=[]; ssExtraZones=[];
        ssZoneCollapsed={};
        window.ssSrcUp=false; window.ssSrcInfo='';
        ssRender();
        ssToast('🔄 출고장 초기화 — 데이터를 모두 비웠습니다.');
      });
  }
  function ssZoneSave(){
    var z=(document.getElementById('ssZoneCode').value||'').trim().toUpperCase();
    if(!z){ ssToast('⚠️ 출고장 코드를 입력하세요.'); return; }
    if((window.ssZoneList||[]).indexOf(z)>=0 || ssExtraZones.indexOf(z)>=0){ ssToast('⚠️ 이미 있는 출고장입니다: '+z); return; }
    ssExtraZones.push(z);
    ssZoneClose(); ssRender();
    ssToast('＋ 출고장 추가: '+z+' — 칸에 수량을 입력하세요(당일 모드)');
  }

  // 작성(반영): 확인 메시지 후 실행
  function ssPvApply(){
    // 파일을 아직 안 고른 채로 열릴 수 있다(버튼이 곧바로 모달을 연다) → '형식 오류'와 구분해서 안내
    if(!ssPvWb){ ssToast('⚠️ 먼저 왼쪽 목록에서 파일을 고르거나 <b>📄 파일 선택</b>으로 엑셀을 여세요.'); return; }
    if(!ssPvCur || !ssPvCur.map){ ssToast('⚠️ 형식이 맞지 않는 자료입니다 — 발주현황표(출고) 양식이 아니라 서버(TBL_SHIPOUT_MST)에 반영할 수 없습니다.'); return; }
    var rows=ssExtractRows(ssPvCur.aoa, ssPvCur.map);
    if(!rows.length){ ssToast('⚠️ 데이터 행이 없습니다.'); return; }
    var sheetNm=ssPvWb.SheetNames[+(document.getElementById('ssPvSheet').value||0)];
    var _upZ={}; rows.forEach(function(r){ if(r.zone) _upZ[r.zone]=1; }); var _zc=Object.keys(_upZ).length;
    // 출고일자 — 비어있으면 막는다(반영 확인창 하단에 이 값을 함께 표시)
    //  ★출고장 구분 없이 이 날짜 하나로 전 행이 저장된다(기본값 = 엑셀 납기일자, 여기서 수정 가능).
    var _shpEl=document.getElementById('ssPvShpoutDt'); var _shp=(_shpEl&&_shpEl.value)||'';
    if(!_shp){ ssToast('⚠️ 출고일자를 입력하세요.'); if(_shpEl) _shpEl.focus(); return; }
    // 김해·제주 출고장 포함 여부 — 조기출고(앞당겨 출고) 관행이 있어 확인창에서 출고일자 변경 여부를 물어본다(2026-07-31 요청).
    //  ★자동으로 날짜를 바꾸지는 않는다(2026-07-29 조기출고 예외 폐지 유지) — 알림만 하고 수정은 사용자가 확인창의 출고일자 칸에서.
    //  판정은 출고장 이름으로 — 업로드 행(ssExtractRows)에는 dcCd 가 없고 zone 이름(예: 김해물류센터1)뿐이다.
    var _kj = rows.some(function(r){ return /김해|제주/.test(''+(r.zone||'')); });
    // 반영 확인(단일) — 예전 1단계 '출고일자' 별도 창은 제거하고, 이 창 하단에 출고일자를 명시(2026-07-24 요청)
    //  ※ 종전의 "기존 화면 자료를 초기화한 뒤 … 이력으로 남고 새 버전이 활성화" 안내문은 사용자 요청으로 제거(2026-07-31)
    //     — 같은 내용이 도움말 「🔗 데이터 연계」 카드·업무설명서에 있다. 그 자리에 김해·제주 알림을 넣는다.
    ssConfirm('파일 <b>'+ssPvName+'</b> · 시트 "<b>'+sheetNm+'</b>"<br>발주 <b style="color:#137a6c">'+rows.length+'</b>건 · 출고장 <b style="color:#137a6c">'+_zc+'</b>곳을 반영하시겠습니까?'
      +(_kj ? '<div class="ss-blink" style="margin-top:12px;padding:9px 11px;border:1px solid #f0d9a8;background:#fff9ec;border-radius:6px;'
        +'font-size:12.5px;color:#8a6414;font-weight:700;line-height:1.55;text-align:left">⚠️ <b>김해·제주</b> 출고장이 포함되어 있습니다 — <b>출고일자 변경 여부</b>를 확인하세요.'
        +'<br><span style="font-weight:400">김해·제주는 앞당겨 출고하는 경우가 있습니다. 변경이 필요하면 아래 <b>출고일자</b>를 수정한 뒤 [반영]을 누르세요.</span></div>' : '')
      +'<div style="text-align:center;margin-top:14px;padding-top:12px;border-top:1px solid #e6ecf0">출고일자 '
      +'<input type="date" id="ssConfirmShpDt" value="'+_shp+'" oninput="ssConfirmBackUpd()" style="font-size:18px;font-weight:700;color:#137a6c;text-align:center;border:1px solid #cdd7dd;border-radius:6px;padding:4px 8px">'
      +'<div style="font-size:11.5px;color:#9aa7b3;margin-top:5px">이 날짜로 <b>전 출고장</b>이 저장됩니다(기본값 = 엑셀 납기일자) — 필요하면 여기서 바로 수정하세요</div>'
      +'<div id="ssConfirmBack"></div></div>',   // 마지막에 올린 자료보다 이전이면 여기 경고가 채워진다(ssConfirmBackUpd)
      function(){
        var _ce=document.getElementById('ssConfirmShpDt');
        var _nv=(_ce&&_ce.value)||_shp;                                   // 확인창에서 수정한 값 우선, 비었으면 원래 값
        var _pv=document.getElementById('ssPvShpoutDt'); if(_pv) _pv.value=_nv;   // ssDoApply 가 여기서 읽음
        /* ★품목 연결 '예정' 분을 먼저 저장한다 — 업로드 저장 직후 서버가 resolve 를 돌리므로
             그 전에 매핑이 들어가 있어야 이번 자료부터 바로 재고에 잡힌다.
             실패하면 업로드를 진행하지 않는다(매핑 빠진 채 저장되면 그 품목이 조용히 빠진다). */
        ssXrefPendSave().then(function(ok){ if(ok) ssDoApply(rows, sheetNm); });
      });
    ssConfirmBackUpd();   // 확인창을 그린 뒤 '이전 자료' 여부 판정(내용은 위 #ssConfirmBack 에 채워진다)
  }

  // 실제 반영 처리 — ★ 기존화면 자료 초기화 후 생성 (업로드 파일로 전체 교체) + 서버 저장
  function ssDoApply(rows, sheetNm){
    var upZones={}; rows.forEach(function(r){ if(r.zone) upZones[r.zone]=1; });
    var zoneList=Object.keys(upZones);
    // ★ 기존화면 자료 초기화 후 생성 (병합 아님)
    ssExtraItems=[]; ssExtraZones=[]; ssZoneCollapsed={};
    SHIP_DATA = rows.slice();
    var st=document.getElementById('ssBizSel'); if(st) st.value='__ALL__';
    // 출고일자(SHPOUT_DT): 프리뷰에서 확정한 값(엑셀기준·수정가능) 우선, 없으면 엑셀 계산값
    var upD=rows.map(function(r){ return r.date; }).filter(Boolean).sort();
    var _shpEl=document.getElementById('ssPvShpoutDt');
    var theDay = (_shpEl && _shpEl.value) ? _shpEl.value : (upD.length ? upD[upD.length-1] : SS_TODAY);
    // 화면 표시·날짜필터 기준을 출고일자로 통일 (엑셀엔 납기일자만 있어 r.date=납기일자로 채워지므로 덮어씀)
    //  ★출고장 구분 없이 전 행이 theDay(= 엑셀 납기일자, 프리뷰에서 수정 가능) 하나로 통일된다.
    SHIP_DATA.forEach(function(r){ r.date = theDay; });
    ssSetVal('ssDateFrom', theDay); ssSetVal('ssDateTo', theDay);
    window.ssSrcUp=true;
    window.ssSrcInfo='✅ 업로드(초기화 후 생성): '+ssPvName+' · 출고장 '+zoneList.length+'곳 · '+rows.length+'건';
    ssRender();
    ssFlash();
    ssPvOpen(false);
    // ★ 서버 저장(TBL_SHIPOUT_MST) — 원본 전체컬럼, 기존 활성배치 이력마감 후 신규배치 INSERT
    ssSaveShipoutToDB(ssPvCur.aoa, theDay);
    // ★ 품목명 앞 () 없는 행의 사업장(코드→명)을 TBL_BIZI_MST 에 자동등록(없을때만) 후 분류 갱신
    ssSaveBiziFromRows(rows);
    ssToast('✅ <b>'+ssPvName+'</b> — 초기화 후 <b>'+rows.length+'</b>건 생성 (출고장 '+zoneList.length+'곳)');
    /* ★반영이 끝났으니 미리보기를 비운다 — 다시 열면 '파일을 고르세요' 상태다 (2026-08-01 요청).
         ssPvName 을 쓰는 위 두 줄(저장·토스트) 뒤에 두어야 한다. */
    ssPvSkipAutoPick=true; ssPvReset();
  }

  // 업로드 행 중 "품목명 앞 () 없는" 사업장만 distinct 수집 → 서버 자동등록(insert if absent) → 분류 최신화
  function ssSaveBiziFromRows(rows){
    var seen={}, list=[];
    (rows||[]).forEach(function(r){
      var item=(''+(r.item||'')).trim(); if(!item) return;
      if(/^\(/.test(item)) return;                       // 괄호有 제외
      var bc=(''+(r.bizCode||'')).trim(); if(!bc || seen[bc]) return;
      seen[bc]=1; list.push({ bizCd:bc, bizNm:(''+(r.bizName||'')).trim() });
    });
    if(!list.length){ ssLoadBiziMst(function(){ ssRender(); }); return; }
    fetch(KONET_CTX+'/shipout/saveBiziAuto.do', {
      method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
      body: JSON.stringify(list)
    })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, t:t}; }); })
    .then(function(r){
      if(r.ok && (+r.t)>0) ssToast('🏢 신규 사업장 <b>'+r.t+'</b>곳 자동등록 (TBL_BIZI_MST)');
      ssLoadBiziMst(function(){ ssRender(); });        // 등록 반영해 재분류
    })
    .catch(function(){ ssLoadBiziMst(function(){ ssRender(); }); });
  }

  // ── 발주현황표(코네트 출고장) 원본 전체컬럼을 서버 TBL_SHIPOUT_MST 에 저장
  //    헤더 2행(1행=메인/2행=현발주 하위) → 컬럼 매핑 후 /shipout/saveShipoutMst.do POST
  //    복합키 = (DLV_DT 납품일자 + DC_CD 물류센터코드). 서버에서 조합별 그룹·버전관리
  //    ★출고일자(SHPOUT_DT)는 키에서 제외(2026-07-27) — 같은 납품일자·출고장을 다른 출고일자로 다시 올려도 기존 자료를 대체한다
  function ssBuildShipoutRows(aoa){
    function eq(arr,name){ for(var k=0;k<arr.length;k++){ if((''+arr[k]).trim()===name) return k; } return -1; }
    // 헤더행 탐색 (1행에 물류센터명+품목명)
    var h=-1, r1=[], r2=[];
    for(var i=0;i<Math.min(aoa.length,8);i++){
      var rr=(aoa[i]||[]).map(function(c){return (''+c).trim();});
      if(eq(rr,'물류센터명')>=0 && eq(rr,'품목명')>=0){ h=i; r1=rr; r2=(aoa[i+1]||[]).map(function(c){return (''+c).trim();}); break; }
    }
    if(h<0) return [];
    // 헤더명 → 컬럼인덱스 (1행 우선, 없으면 2행=현발주 하위)
    function idx(name){ var k=eq(r1,name); return k>=0?k:eq(r2,name); }
    var MAP={
      rowNo:'No', inrsvYn:'입고예약', labelPrtGb:'라벨발행구분', dcCd:'물류센터코드', dcNm:'물류센터명',
      vendorCd:'협력업체코드', vendorNm:'협력업체명', itemCd:'품목코드', itemNm:'품목명', fsfdGb:'FS/FD 구분',
      dlvDt:'납기일자', statYn:'상황여부', prodKind:'상품종류', tempGb:'온도구분', ordGb:'발주구분',
      bizCd:'사업장코드', bizNm:'사업장명', boxQty:'Box입수량', labelQty:'라벨수량', unpaidLabelQty:'미납라벨수량',
      inwh:'입고장', zone:'존', busNo:'버스번호', rtSeq:'RT순번', curQty:'수량', dlvGb:'배송구분', remark:'특기사항',
      unit:'단위', indivId:'개체식별번호', ordNo:'발주번호', ordItemNo:'발주ITEM번호', jumunNo:'주문번호',
      jumunItemNo:'주문ITEM번호', sorter:'소터'
    };
    var COL={}; for(var f in MAP){ COL[f]=idx(MAP[f]); }
    var NUM={rowNo:1,boxQty:1,labelQty:1,unpaidLabelQty:1,curQty:1}, DT={dlvDt:1};
    function num(v){ var s=(''+(v==null?'':v)).replace(/[^0-9.\-]/g,''); return s===''?null:(parseInt(s,10)||0); }
    var out=[];
    for(var r=h+2; r<aoa.length; r++){
      var row=aoa[r]||[];
      var nm=(''+(COL.itemNm>=0?row[COL.itemNm]:'')).trim(); if(!nm) continue;   // 품목명 없으면 데이터 끝
      var obj={};
      for(var fld in COL){
        var c=COL[fld]; var cell=(c>=0)?row[c]:'';
        if(NUM[fld]) obj[fld]=num(cell);
        else if(DT[fld]) obj[fld]=ssFmtDate(cell);            // yyyy-mm-dd (서버에서 '-' 제거 저장)
        else obj[fld]=(''+(cell==null?'':cell)).trim();
      }
      out.push(obj);
    }
    return out;
  }
  /* 발주현황표 서버저장 진행바 — 정산엑셀(slsProg)과 동일 원리: 업로드 실측(0~25%) → 서버추정(25~95%) → 완료(100%).
       이 저장은 프리뷰 모달이 닫힌 뒤 백그라운드로 도므로, 전용 중앙 오버레이로 표시한다(자체 <style> 포함·독립). */
  var SHP_PROG_UP=25, SHP_PROG_CEIL=95;
  var _shpProgTimer=null, _shpProgSrvStart=0, _shpProgTau=3000;
  function _shpProgEnsure(){
    var ov=document.getElementById('shpProgOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='shpProgOv';
      ov.style.cssText='display:none;position:fixed;inset:0;z-index:100001;background:rgba(15,23,32,.35);align-items:center;justify-content:center';
      ov.innerHTML='<style>@keyframes shpProgFlow{0%{background-position:0 0}100%{background-position:34px 0}}'
        +'.shp-prog-indet{background-image:repeating-linear-gradient(45deg,rgba(255,255,255,.28) 0 9px,rgba(255,255,255,0) 9px 17px),linear-gradient(90deg,#17a589,#137a6c)!important;background-size:34px 34px,100% 100%!important;animation:shpProgFlow .7s linear infinite}</style>'
        +'<div style="background:#fff;width:min(420px,92vw);border-radius:12px;box-shadow:0 12px 40px rgba(0,0,0,.3);overflow:hidden">'
        +'<div id="shpProgTit" style="background:linear-gradient(135deg,#1f9b8e,#137a6c);color:#fff;padding:12px 18px;font-size:15px;font-weight:600">💾 발주현황표 저장</div>'
        +'<div style="padding:18px 20px 20px">'
        +'<div style="display:flex;justify-content:space-between;font-size:12px;color:#5a6b7a;margin-bottom:6px"><span id="shpProgLab">저장 준비 중…</span><span id="shpProgPct" style="font-weight:700;color:#137a6c"></span></div>'
        +'<div style="height:11px;background:#e6ecf0;border-radius:6px;overflow:hidden"><div id="shpProgFill" style="height:100%;width:0%;background:linear-gradient(90deg,#17a589,#137a6c);border-radius:6px;transition:width .2s ease"></div></div>'
        +'</div></div>';
      document.body.appendChild(ov);
    }
    return ov;
  }
  function _shpProgWidth(pct, stripe){
    pct=Math.max(0,Math.min(100,pct));
    var f=document.getElementById('shpProgFill'), p=document.getElementById('shpProgPct');
    if(f){ f.style.width=pct+'%'; if(stripe) f.classList.add('shp-prog-indet'); else f.classList.remove('shp-prog-indet'); }
    if(p) p.textContent=Math.round(pct)+'%';
  }
  /* 총량을 모르는 단계(품목 해석 등) — 막대를 꽉 채우고 줄무늬만 흐르게 한다.
     ★_shpProgWidth(0,true) 로 두면 폭이 0% 라 줄무늬가 보일 자리가 없어 '멈춘 화면'처럼 보인다
       (2026-08-01 실제 지적). 퍼센트도 0% 대신 '진행 중' 으로 적는다 — 아직 셀 수 없는 단계다. */
  function _shpProgIndet(lab){
    _shpProgWidth(100, true);
    var p=document.getElementById('shpProgPct'); if(p) p.textContent='진행 중';
    _shpProgLab(lab);
  }
  function _shpProgLab(t){ var l=document.getElementById('shpProgLab'); if(l && t!=null) l.textContent=t; }
  /* 제목은 부르는 쪽이 정한다 — 이 진행바를 발주현황표 저장과 재고 재집계가 함께 쓴다(2026-08-01).
     인자를 안 주면 종전 그대로 '발주현황표 저장' 이라 기존 호출부는 손댈 것이 없다. */
  function shpProgShow(lab, title){
    _shpProgEnsure().style.display='flex'; _shpProgWidth(0,false); _shpProgLab(lab||'저장 준비 중…');
    var t=document.getElementById('shpProgTit'); if(t) t.textContent = title || '💾 발주현황표 저장';
  }
  function shpProgUpload(frac, lab){ _shpProgWidth((+frac||0)*SHP_PROG_UP, false); _shpProgLab(lab); }
  function shpProgServerStart(rows){
    _shpProgTau=Math.max(1500, (+rows||0)*7);
    _shpProgSrvStart=Date.now();
    _shpProgWidth(SHP_PROG_UP, true);
    _shpProgLab('서버 반영 중… (이력마감·배치 저장)');
    if(_shpProgTimer) clearInterval(_shpProgTimer);
    _shpProgTimer=setInterval(function(){
      var t=Date.now()-_shpProgSrvStart;
      _shpProgWidth(SHP_PROG_UP + (SHP_PROG_CEIL-SHP_PROG_UP)*(t/(t+_shpProgTau)), true);
    }, 150);
  }
  function _shpProgStop(){ if(_shpProgTimer){ clearInterval(_shpProgTimer); _shpProgTimer=null; } }
  function shpProgDone(){ _shpProgStop(); _shpProgWidth(100,false); _shpProgLab('완료'); }
  function shpProgHide(){ _shpProgStop(); var ov=document.getElementById('shpProgOv'); if(ov) ov.style.display='none'; var f=document.getElementById('shpProgFill'); if(f){ f.classList.remove('shp-prog-indet'); f.style.width='0%'; } }
  function ssSaveShipoutToDB(aoa, baseDt){
    var rows=ssBuildShipoutRows(aoa);
    if(!rows.length) return;
    var srcFile=ssPvName;
    // 복합키=(납품일자 DLV_DT 행별) + (물류센터 DC_CD 행별). 출고일자·사업장은 키 아님(출고일자는 값으로만 저장).
    //  ★출고일자 = baseDt(프리뷰 확정값 = 엑셀 납기일자) — 출고장 구분 없이 전 행 동일(2026-07-29 확정).
    rows.forEach(function(o){ if(!o.dlvDt) o.dlvDt=baseDt; o.shpoutDt=baseDt; o.srcFile=srcFile; });
    var body=JSON.stringify(rows), nRows=rows.length;
    shpProgShow('업로드 중… (0 / '+nRows.toLocaleString()+'건)');
    var xhr=new XMLHttpRequest();
    xhr.open('POST', KONET_CTX+'/shipout/saveShipoutMst.do', true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.withCredentials=true;
    // 1) 업로드 진행 — 실제 전송 바이트로 0~25% (건수는 근사표기)
    xhr.upload.onprogress=function(ev){
      if(!ev.lengthComputable) return;
      var frac=ev.loaded/ev.total;
      shpProgUpload(frac, '업로드 중… ('+Math.round(frac*nRows).toLocaleString()+' / '+nRows.toLocaleString()+'건)');
    };
    // 2) 업로드 완료 → 서버 반영 구간: 경과시간 추정 %로 25→95% 전진
    xhr.upload.onload=function(){ shpProgServerStart(nRows); };
    xhr.onload=function(){
      shpProgDone();                 // 실제 응답 → 100% 스냅
      setTimeout(shpProgHide, 500);
      var ok=(xhr.status>=200 && xhr.status<300), t=xhr.responseText;
      if(ok){
        ssToast('💾 서버 저장 완료 — 출고일자 '+baseDt+' · <b>'+t+'</b>건 (기존 자료 초기화 후 생성)');
        if(window.ssLoadShipoutFromDB) ssLoadShipoutFromDB();   // 저장 끝나면 출고일자로 DB 조회 1회 자동 실행
        if(window.ssUpHistLoad) ssUpHistLoad();                 // 방금 올린 배치가 좌측 '올린 이력' 맨 위로 올라오게
        if(window.ssArchiveApplied) ssArchiveApplied(srcFile);  // 반영 끝난 엑셀은 상단 목록에서 「_반영됨」으로 치운다
      }
      else ssToast('⚠️ 서버 저장 실패: '+(t||('HTTP '+xhr.status)));
    };
    xhr.onerror=function(){ shpProgHide(); ssToast('⚠️ 서버 저장 통신오류 — 네트워크를 확인하세요.'); };
    xhr.ontimeout=function(){ shpProgHide(); ssToast('⚠️ 저장 시간 초과 — 잠시 후 다시 시도하세요.'); };
    xhr.send(body);
  }

  // 일자별(단일 일자) 조건인지
  function ssIsSingleDay(){
    var f=(document.getElementById('ssDateFrom')||{}).value||'', t=(document.getElementById('ssDateTo')||{}).value||'';
    return !!(f && f===t) ? f : '';
  }

  // 해당일자 출고데이터 저장 (일자별 조건에서만)
  function ssSaveData(){
    var d=ssIsSingleDay();
    if(!d){ ssToast('⚠️ 출고데이타저장은 일자별(시작=종료) 조건에서만 가능합니다.'); return; }
    var ag=ssAggregate();
    if(!(ag.totQty>0)){ ssToast('⚠️ '+d+' 출고 데이터가 없습니다.'); return; }
    var items=Object.keys(ag.items).length;
    ssConfirm('<b>'+d+'</b> 출고데이터를 저장하시겠습니까?<br>품목 <b style="color:#137a6c">'+items+'</b>종 · 출고 <b style="color:#137a6c">'+ssNum(ag.totQty)+'</b> BOX'
      +'<br><br><span style="color:#9aa7b3">※ 데모: 브라우저에 저장됩니다. 실제 운영 시 서버 출고테이블에 저장됩니다.</span>',
      function(){
        try{ localStorage.setItem('ssSaved_'+d, JSON.stringify({date:d, qty:ag.totQty, items:items})); }catch(e){}
        ssToast('💾 <b>'+d+'</b> 출고데이터 저장 완료 (품목 '+items+'종 · '+ssNum(ag.totQty)+' BOX)');
      });
  }

  // 출고현황표 → 엑셀(.xlsx) : 데이터 모델에서 깔끔한 숫자표로 재구성(날짜 오인 방지) + 상단 출고일자
  function ssDownload(){
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
    var ag=ssAggregate();
    var keys=Object.keys(ag.items).sort(function(a,b){ var A=ag.items[a],B=ag.items[b]; return A.brand.localeCompare(B.brand,'ko')||A.name.localeCompare(B.name,'ko'); });
    if(!keys.length){ ssToast('⚠️ 출력할 데이터가 없습니다.'); return; }
    var zones=Object.keys(ag.zoneSet).sort();
    var f=(document.getElementById('ssDateFrom')||{}).value||'', t=(document.getElementById('ssDateTo')||{}).value||'';
    var dlab=(f&&f===t)?f:(f+' ~ '+t);
    var colTot={}; zones.forEach(function(z){ keys.forEach(function(k){ colTot[k]=(colTot[k]||0)+((ag.matrix[z]&&ag.matrix[z][k])||0); }); });
    function cv(v){ return v?v:''; }                 // 0은 공백(숫자형 유지)
    function row(label, getv){
      var cells=[], sum=0;
      keys.forEach(function(k){ var v=getv(k)||0; sum+=v; cells.push(cv(v)); });
      return ssSumFront ? [label, sum].concat(cells) : [label].concat(cells, [sum]);
    }
    var aoa=[];
    aoa.push(['출고현황표']);
    aoa.push(['출고일자', dlab]);
    aoa.push([]);
    // 헤더 2행 (사업장 / 품목(코드))
    var h1=ssSumFront?['출고장 \\ 품목','합계']:['출고장 \\ 품목'];
    var h2=ssSumFront?['','']:[''];
    for(var i=0;i<keys.length;){
      var br=ag.items[keys[i]].brand, j=i; while(j<keys.length && ag.items[keys[j]].brand===br) j++;
      h1.push(br); for(var x=i+1;x<j;x++) h1.push('');
      for(var p=i;p<j;p++){ var it=ag.items[keys[p]]; h2.push(ssShortName(it.name)+(it.code?(' ('+it.code+')'):'')); }
      i=j;
    }
    if(!ssSumFront){ h1.push('합계'); h2.push(''); }
    aoa.push(h1); aoa.push(h2);
    // 출고장 그룹별 (그룹순서 설정 반영 — 물류센터명 기준, 데시보드2와 공유)
    var byL={}, letters=[]; zones.forEach(function(z){ var L=(z.charAt(0)||'').toUpperCase(); if(!byL[L]){ byL[L]=[]; letters.push(L); } byL[L].push(z); });
    function _lblOf(L){ var _n=(''+(byL[L][0]||'')).replace(/\s*\d+\s*$/,'').trim(); return (_n.length>1)?_n:(L+'출고장'); }
    letters.sort(function(a,b){ var la=_lblOf(a), lb=_lblOf(b); var ia=ssGroupOrder.indexOf(la), ib=ssGroupOrder.indexOf(lb); if(ia>=0&&ib>=0) return ia-ib; if(ia>=0) return -1; if(ib>=0) return 1; return la.localeCompare(lb,'ko'); });
    letters.forEach(function(L){
      aoa.push([L+'출고장']);
      byL[L].forEach(function(z){ aoa.push(row(z+' 출고장', function(k){ return (ag.matrix[z]&&ag.matrix[z][k])||0; })); });
      aoa.push(row(L+'출고장 합계', function(k){ var s=0; byL[L].forEach(function(z){ s+=(ag.matrix[z]&&ag.matrix[z][k])||0; }); return s; }));
    });
    aoa.push(row('전체 출고장 합계', function(k){ return colTot[k]||0; }));
    if(ag.unassigned>0) aoa.push(row('미배정('+ag.unassigned+'건)', function(k){ return ag.unMatrix[k]||0; }));
    aoa.push([]);
    aoa.push(['■ 출고내역 · 재고량']);
    var base={}; keys.forEach(function(k){ var it=ag.items[k]; base[k]=30+(ssHash(it.code||it.name)%150); });
    aoa.push(row('재고량(기초)', function(k){ return base[k]; }));
    var selLbl=(f&&f===t)?(f===SS_TODAY?'당일 출고':'선택일 출고'):'기간 출고';
    aoa.push(row(selLbl, function(k){ return colTot[k]||0; }));
    var ym=SS_TODAY.slice(0,7), mTot={};
    SHIP_DATA.forEach(function(r){ if(!r.zone) return; if((''+(r.date||SS_TODAY)).slice(0,7)!==ym) return; var c=(''+(r.code||'')).trim(), kk=c?c:('NM:'+r.item); mTot[kk]=(mTot[kk]||0)+(+r.qty||0); });
    aoa.push(row('당월 출고('+ym+')', function(k){ return mTot[k]||0; }));
    aoa.push(row('현재고', function(k){ return base[k]-(colTot[k]||0); }));
    SS_MONTHS.forEach(function(mn){ aoa.push(row(mn+' 출고', function(k){ var it=ag.items[k]; return ssHash((it.code||it.name)+mn)%9; })); });

    var ws=XLSX.utils.aoa_to_sheet(aoa);
    ws['!cols']=[{wch:16}].concat(keys.map(function(){ return {wch:11}; })).concat([{wch:9}]);
    if(ssSumFront) ws['!cols'].splice(1,0,{wch:9});
    var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '출고현황표');
    XLSX.writeFile(wb, '출고현황표_'+(f||'')+((t&&t!==f)?'~'+t:'')+'.xlsx');
    ssToast('📥 출고현황표 엑셀 저장 완료 (출고일자 '+dlab+')');
  }

  // xlsx-js-style(무료·MIT, SheetJS 스타일 지원 포크) 지연 로드 — 색·테두리 엑셀 전용.
  //   · 로컬(폐쇄망 대비) 우선 → 실패 시 CDN 순으로 시도
  //   · 읽기용 원본 XLSX 는 건드리지 않도록, 로드 후 window.XLSX 를 즉시 원복하고 스타일본만 캐시
  var _XLSXStyle=null;
  var _XLSXStyleSrcs=[
    KONET_CTX+'/assets/vendor/xlsx-js-style/xlsx.bundle.js',
    'https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js'
  ];
  function ssLoadStyleXlsx(cb){
    if(_XLSXStyle){ cb(_XLSXStyle); return; }
    var prev=window.XLSX, i=0;
    (function tryNext(){
      if(i>=_XLSXStyleSrcs.length){ window.XLSX=prev; cb(null); return; }
      var s=document.createElement('script');
      s.src=_XLSXStyleSrcs[i++];
      s.onload=function(){ _XLSXStyle=window.XLSX; window.XLSX=prev; cb(_XLSXStyle); };
      s.onerror=function(){ window.XLSX=prev; tryNext(); };   // 다음 소스로 폴백
      document.head.appendChild(s);
    })();
  }

  // 출고장별 엑셀(.xlsx) : ★ 한 장(시트 1개)에 출고장을 위→아래로 구분해 쌓음 + 색/테두리(출고장 화면 스타일)
  //   · 각 출고장 블록에는 그 출고장에 '출고량이 있는 품목만' 나열(상품 없는 품목 제외)
  //   · 물건 없는 출고장은 블록 자체를 생략, 출고장 사이는 빈 줄로 구분
  function ssDownloadByZone(){
    ssLoadStyleXlsx(function(XLSXS){
      var LIB = XLSXS || window.XLSX;               // 스타일본 실패 시 원본(무색)으로라도 저장
      var styled = !!XLSXS;
      if(!LIB){ ssToast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
      var ag=ssAggregate();
      var f=(document.getElementById('ssDateFrom')||{}).value||'', t=(document.getElementById('ssDateTo')||{}).value||'';
      var dlab=(f&&f===t)?f:(f+' ~ '+t);
      // 매트릭스 key → 품목명/사업장/코드 (미배정 key 도 안전 처리)
      function kName(k){ return (ag.items[k]&&ag.items[k].name) || (String(k).indexOf('NM:')===0? String(k).slice(3): k); }
      function kBrand(k){ return (ag.items[k]&&ag.items[k].brand) || ''; }
      function kCode(k){ return (ag.items[k]&&ag.items[k].code) || (String(k).indexOf('NM:')===0? '': k); }
      function srt(a,b){ return kBrand(a).localeCompare(kBrand(b),'ko')||kName(a).localeCompare(kName(b),'ko'); }

      var COLS=5;                 // No | 사업장 | 품목명 | 품목코드 | 출고수량
      var aoa=[], merges=[], meta=[];   // meta[r] = 행 유형(스타일 적용용)
      function mergeRow(ri, e){ merges.push({s:{r:ri,c:0}, e:{r:ri,c:(e==null?COLS-1:e)}}); }
      function push(row, ty, mEnd){ aoa.push(row); meta.push(ty); if(mEnd!=null) mergeRow(aoa.length-1, mEnd); }
      // 상단 제목
      push(['출고장별 출고현황'], 'title', COLS-1);
      push(['출고일자  '+dlab], 'date', COLS-1);
      push([], 'blank');

      // 출고장별 납기일자 집계 — SHIP_DATA 행에서 zone → 납기일자 distinct
      var zoneDlv={};
      (SHIP_DATA||[]).forEach(function(r){ if(!r||!r.zone) return; var d=(''+(r.dlvDt||'')).trim(); if(!d) return; (zoneDlv[r.zone]=zoneDlv[r.zone]||{})[d]=1; });
      function dlvLabelOf(z){ var a=Object.keys(zoneDlv[z]||{}).sort(); return a.length?('납기일자 '+a.join(', ')):''; }

      // 출고장 1개 블록을 아래로 이어붙임
      function block(zoneLabel, keys, get, extra){
        var tot=0; keys.forEach(function(k){ tot+=(get(k)||0); });
        push(['▣ '+zoneLabel+'   (품목 '+keys.length+'종 · 출고 '+ssNum(tot)+(extra?(' · '+extra):'')+')'], 'zone', COLS-1);   // 출고장 제목줄
        push(['No','사업장','품목명','품목코드','출고수량'], 'head');                                    // 컬럼 헤더
        keys.forEach(function(k,ix){ push([ix+1, kBrand(k), kName(k), kCode(k), get(k)||0], 'item'); }); // 품목행(수량>0만, 출고장별 1번부터)
        push(['소계','','','',tot], 'sub', COLS-2);                                                     // 소계(라벨 병합)
        push([], 'blank');                                                                              // 출고장 구분 빈 줄
      }

      // 출고장 정렬 — 그룹(물류센터명) 순서설정 반영 후, 그룹 내 이름순 (데시보드2와 공유)
      function _gidx(z){ var lbl=(''+z).replace(/\s*\d+\s*$/,'').trim(); var i=ssGroupOrder.indexOf(lbl); return i>=0?i:9999; }
      var zones=Object.keys(ag.zoneSet).sort(function(a,b){ var d=_gidx(a)-_gidx(b); return d!==0?d:a.localeCompare(b,'ko'); });
      var made=0, skipped=0, grand=0;
      zones.forEach(function(z){
        var mz=ag.matrix[z]||{};
        var keys=Object.keys(mz).filter(function(k){ return (mz[k]||0)>0; }); // 상품 없는(0) 품목 제외
        if(!keys.length){ skipped++; return; }                                // 물건 없는 출고장은 생략
        keys.sort(srt);
        keys.forEach(function(k){ grand+=(mz[k]||0); });
        block(z+' 출고장', keys, function(k){ return mz[k]||0; }, dlvLabelOf(z));
        made++;
      });
      // 미배정(출고장 미지정) 품목도 블록으로 (있을 때만)
      if(ag.unassigned>0){
        var uk=Object.keys(ag.unMatrix).filter(function(k){ return (ag.unMatrix[k]||0)>0; });
        if(uk.length){ uk.sort(srt); uk.forEach(function(k){ grand+=(ag.unMatrix[k]||0); }); block('미배정 · 출고장 미지정', uk, function(k){ return ag.unMatrix[k]||0; }); }
      }
      if(!made){ ssToast('⚠️ 출고량이 있는 출고장이 없습니다.'); return; }
      push(['전체 합계','','','',grand], 'grand', COLS-2);

      var ws=LIB.utils.aoa_to_sheet(aoa);
      ws['!cols']=[{wch:5},{wch:18},{wch:44},{wch:18},{wch:11}];
      ws['!merges']=merges;

      if(styled){
        var enc=LIB.utils.encode_cell;
        var LINE={style:'thin', color:{rgb:'DFE6E3'}};
        var box={top:LINE,bottom:LINE,left:LINE,right:LINE};
        var S={
          title:{ fill:{fgColor:{rgb:'178074'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          date:{ font:{color:{rgb:'1F2A37'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          zone:{ fill:{fgColor:{rgb:'1F9B8E'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          head:{ fill:{fgColor:{rgb:'E3F4EF'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemL:{ font:{color:{rgb:'10161D'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          itemC:{ font:{color:{rgb:'6B7A89'}}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemCB:{ font:{color:{rgb:'000000'}}, alignment:{horizontal:'center',vertical:'center'}, border:box }, // No·품목코드(검정)
          itemN:{ font:{color:{rgb:'1F2A37'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box }, // 출고수량 조금 크게
          subL:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'37475A'},bold:true}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          subN:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'137A6C'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box }, // 소계 값 크게
          grandL:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          grandN:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:14}, alignment:{horizontal:'right',vertical:'center'} } // 전체합계 값 크게
        };
        function put(r,c,st){ var ref=enc({r:r,c:c}); if(!ws[ref]) ws[ref]={t:'s',v:''}; ws[ref].s=st; }
        var rows=[];
        meta.forEach(function(ty,r){
          var h=null;
          if(ty==='title'){ put(r,0,S.title); h=26; }
          else if(ty==='date'){ put(r,0,S.date); h=24; }
          else if(ty==='zone'){ put(r,0,S.zone); h=22; }
          else if(ty==='head'){ for(var c=0;c<COLS;c++) put(r,c,S.head); h=20; }
          else if(ty==='item'){ put(r,0,S.itemCB); put(r,1,S.itemL); put(r,2,S.itemL); put(r,3,S.itemCB); put(r,4,S.itemN); } // 0=No, 3=품목코드 → 검정 가운데
          else if(ty==='sub'){ for(var c2=0;c2<COLS-1;c2++) put(r,c2,S.subL); put(r,COLS-1,S.subN); h=19; }
          else if(ty==='grand'){ for(var c3=0;c3<COLS-1;c3++) put(r,c3,S.grandL); put(r,COLS-1,S.grandN); h=22; }
          rows.push(h!=null?{hpt:h}:{});
        });
        ws['!rows']=rows;
      }

      var wb=LIB.utils.book_new();
      LIB.utils.book_append_sheet(wb, ws, '출고장별');
      LIB.writeFile(wb, '출고장별_'+(f||'')+((t&&t!==f)?'~'+t:'')+'.xlsx');
      ssToast('📥 출고장별 엑셀(한 장'+(styled?', 색구분':'')+') 저장 완료 · 출고장 '+made+'개'+(skipped?(' (물건없는 '+skipped+'개 제외)'):'')+' · 출고일자 '+dlab);
    });
  }

  // 출고현황표 → PDF 파일 저장 (jsPDF + html2canvas, 한글 안전)
  function ssPdf(){
    var jsPDF = window.jspdf && window.jspdf.jsPDF;
    if(!jsPDF || !window.html2canvas){ ssToast('⚠️ PDF 라이브러리 로딩 중입니다(인터넷 필요). 잠시 후 다시 시도하세요.'); return; }
    var tbl=document.getElementById('ssWideTbl'); if(!tbl){ ssToast('⚠️ 표가 없습니다.'); return; }
    var f=(document.getElementById('ssDateFrom')||{}).value||'', t=(document.getElementById('ssDateTo')||{}).value||'';
    var dlab=(f&&f===t)?f:(f+' ~ '+t);
    var clone=tbl.cloneNode(true);
    [].slice.call(clone.querySelectorAll('tr')).forEach(function(tr){ if(tr.style && tr.style.display==='none' && tr.parentNode) tr.parentNode.removeChild(tr); });
    [].slice.call(clone.querySelectorAll('.bx,.caret,.zcaret,.delx')).forEach(function(e){ if(e.parentNode) e.parentNode.removeChild(e); });
    [].slice.call(clone.querySelectorAll('[contenteditable]')).forEach(function(e){ e.removeAttribute('contenteditable'); });
    [].slice.call(clone.querySelectorAll('td,th')).forEach(function(c){ c.style.position='static'; });   // sticky 해제(캡처 정확)
    clone.style.width='auto';
    var wrap=document.createElement('div');
    wrap.style.cssText='position:fixed;left:-100000px;top:0;background:#fff;padding:14px;font-family:\"Malgun Gothic\",sans-serif;';
    wrap.innerHTML='<div style="font-size:18px;font-weight:700;margin-bottom:4px">출고현황표</div>'
      +'<div style="font-size:12px;color:#555;margin-bottom:8px">출고일자 : '+dlab+'</div>';
    wrap.appendChild(clone);
    document.body.appendChild(wrap);
    ssToast('📄 PDF 생성 중…');
    window.html2canvas(wrap, {scale:2, backgroundColor:'#ffffff'}).then(function(canvas){
      if(wrap.parentNode) wrap.parentNode.removeChild(wrap);
      var pdf=new jsPDF('l','mm','a4');
      var mg=8, pw=pdf.internal.pageSize.getWidth()-mg*2, ph=pdf.internal.pageSize.getHeight()-mg*2;
      var iw=pw, ih=canvas.height*iw/canvas.width;
      if(ih<=ph){
        pdf.addImage(canvas.toDataURL('image/png'),'PNG',mg,mg,iw,ih);
      } else {
        // 세로로 페이지 분할
        var sliceHpx=Math.floor(canvas.width*ph/pw), y=0, page=0;
        while(y<canvas.height){
          var hpx=Math.min(sliceHpx, canvas.height-y);
          var c2=document.createElement('canvas'); c2.width=canvas.width; c2.height=hpx;
          c2.getContext('2d').drawImage(canvas,0,y,canvas.width,hpx,0,0,canvas.width,hpx);
          if(page>0) pdf.addPage();
          pdf.addImage(c2.toDataURL('image/png'),'PNG',mg,mg,iw,hpx*iw/canvas.width);
          y+=hpx; page++;
        }
      }
      pdf.save('출고현황표_'+(f||'')+((t&&t!==f)?'~'+t:'')+'.pdf');
      ssToast('📄 PDF 저장 완료 (출고일자 '+dlab+')');
    }).catch(function(e){ if(wrap.parentNode) wrap.parentNode.removeChild(wrap); ssToast('⚠️ PDF 생성 오류: '+e.message); });
  }

  // ── 날짜 유틸 / 당일 기준
  function ssPad(n){ return (n<10?'0':'')+n; }
  function ssFmtDate(v){
    if(v instanceof Date && !isNaN(v)) return v.getFullYear()+'-'+ssPad(v.getMonth()+1)+'-'+ssPad(v.getDate());
    var s=''+(v==null?'':v); var m=s.match(/(\d{4})[-.\/](\d{1,2})[-.\/](\d{1,2})/);
    return m ? (m[1]+'-'+ssPad(+m[2])+'-'+ssPad(+m[3])) : '';
  }
  var SS_TODAY=(function(){ var d=new Date(); return d.getFullYear()+'-'+ssPad(d.getMonth()+1)+'-'+ssPad(d.getDate()); })();
  function ssAllDates(){
    var f={}; SHIP_DATA.forEach(function(r){ var d=r.date||SS_TODAY; f[d]=(f[d]||0)+1; });
    return Object.keys(f).sort().map(function(d){ return {d:d, n:f[d]}; });
  }
  // 날짜 입력 클릭 시 달력 팝업 즉시 열기 (지원 브라우저)
  function ssOpenCal(el){ try{ if(el && el.showPicker) el.showPicker(); }catch(e){} }
  // 적용 시 KPI 깜빡임(갱신 알림)
  function ssFlash(){ var s=document.querySelector('#panel-shipstatus .tb-stats'); if(s){ s.classList.remove('ss-flash'); void s.offsetWidth; s.classList.add('ss-flash'); } }
  function ssSetVal(id,v){ var e=document.getElementById(id); if(e) e.value=v; }
  function ssToday(){ ssSetVal('ssDateFrom',SS_TODAY); ssSetVal('ssDateTo',SS_TODAY); ssLoadShipoutFromDB(); }
  function ssThisMonth(){
    var d=new Date(), y=d.getFullYear(), m=d.getMonth(), last=new Date(y,m+1,0).getDate();
    ssSetVal('ssDateFrom', y+'-'+ssPad(m+1)+'-01');
    ssSetVal('ssDateTo',   y+'-'+ssPad(m+1)+'-'+ssPad(last));
    ssLoadShipoutFromDB();   // 당월=기간 합산 조회
  }

  // ── 출고현황표 DB 조회: 선택한 출고일자(단일)의 활성배치를 읽어와 표시. 없으면 빈 화면 ──
  //    DB행 → 화면 SHIP_DATA 매핑은 ssExtractRows(konet 포맷)와 동일:
  //      · 출고장(zone) = 물류센터명(DC_NM) + 입고장(INWH)  예) "평택물류센터1"
  //      · 사업장(biz)  = 사업장명 [사업장코드]
  // ── 대시보드1↔2 출고일자 조건 동기화 (localStorage 'logiShipDate' 공유 + storage 이벤트) ──
  var _ssDateSyncing=false;
  function ssSaveSharedDate(){
    try{ localStorage.setItem('logiShipDate', JSON.stringify({
      from:(document.getElementById('ssDateFrom')||{}).value||'',
      to:(document.getElementById('ssDateTo')||{}).value||'' })); }catch(e){}
  }
  function ssApplySharedDate(){   // 저장된 공유 날짜 적용(있으면 true)
    try{ var d=JSON.parse(localStorage.getItem('logiShipDate')||'null'); if(!d) return false;
      if(d.from!=null) ssSetVal('ssDateFrom', d.from); if(d.to!=null) ssSetVal('ssDateTo', d.to); return true;
    }catch(e){ return false; }
  }
  window.addEventListener('storage', function(e){   // 대시보드2에서 날짜 바꾸면 따라가기
    if(e.key!=='logiShipDate') return;
    try{ var d=JSON.parse(e.newValue||'null'); if(!d) return;
      var f=document.getElementById('ssDateFrom'), t=document.getElementById('ssDateTo'); if(!f||!t) return;
      if(f.value===(d.from||'') && t.value===(d.to||'')) return;
      _ssDateSyncing=true; f.value=d.from||''; t.value=d.to||''; ssLoadShipoutFromDB(); _ssDateSyncing=false;
    }catch(_){}
  });
  // ★속도 개선(2026-07-31): 분류표(selectBiziMst)와 출고 조회를 병렬로 — 종전엔 순차라 최초 진입이 합산 지연.
  //   대개 분류표(≈0.5s)가 출고(≈0.7s~)보다 먼저 끝나 렌더 시점엔 분류가 준비돼 있고,
  //   드물게 분류표가 늦으면 도착 시 ssRender() 한 번만 더(추가 조회 없음 — 분류 라벨 갱신).
  var _ssLoadSeq=0, _ssShipDone=false;
  function ssLoadShipoutFromDB(){
    if(!_ssDateSyncing) ssSaveSharedDate();
    var seq=(++_ssLoadSeq); _ssShipDone=false;
    ssLoadBiziMst(function(){ if(seq===_ssLoadSeq && _ssShipDone) ssRender(); });
    _ssLoadShipoutInner();
  }
  function _ssLoadShipoutInner(){
    // 종착점 공용 렌더 — 분류표 병렬화의 재렌더 판정용 완료 표시를 함께 남긴다
    function _rend(){ _ssShipDone=true; ssRender(); }
    var f=(document.getElementById('ssDateFrom')||{}).value||'';
    var t=(document.getElementById('ssDateTo')||{}).value||'';
    // 단일일자=단일조회 / 기간(시작≠종료)=기간 전체 합산 조회 (둘 다 있어야 조회)
    if(!f || !t){ _rend(); if(typeof konetAsqSetDash1==='function') konetAsqSetDash1({hide:true}); return; }
    var _single=(f===t);
    fetch(KONET_CTX+'/shipout/selectShipoutMst.do', {
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
      credentials:'same-origin',
      body: _single ? ('shpoutDt='+encodeURIComponent(f))
                    : ('shpoutDtFrom='+encodeURIComponent(f)+'&shpoutDtTo='+encodeURIComponent(t))
    })
    .then(function(res){ return res.text().then(function(txt){ return {status:res.status, ok:res.ok, txt:txt}; }); })
    .then(function(r){
      // HTTP 오류(404=엔드포인트 미배포 / 500=서버오류 등) — 상태·본문을 그대로 노출
      if(!r.ok){
        window.ssSrcInfo='⚠️ DB 조회 HTTP '+r.status; SHIP_DATA=[]; _rend();
        if(window.ssToast) ssToast('⚠️ 출고 조회 실패 (HTTP '+r.status+')<br><span style="font-size:11px">'+(r.txt||'').replace(/[<>]/g,'').slice(0,300)+'</span>');
        return;
      }
      // 본문이 JSON 이 아니면(로그인 HTML 리다이렉트 등) 파싱 실패 — 본문 노출
      var j; try{ j=JSON.parse(r.txt); }catch(e){
        window.ssSrcInfo='⚠️ 응답형식 오류'; SHIP_DATA=[]; _rend();
        if(window.ssToast) ssToast('⚠️ 조회 응답이 JSON이 아닙니다<br><span style="font-size:11px">'+(r.txt||'').replace(/[<>]/g,'').slice(0,300)+'</span>');
        return;
      }
      var rows=(j&&j.data)||[];
      SHIP_DATA = rows.map(function(o){
        var dcNm=(''+(o.dcNm||'')).trim(), inwh=(''+(o.inwh||'')).trim();
        var zone = dcNm ? (dcNm+inwh) : (''+(o.zone||'')).trim();
        var bizNm=(''+(o.bizNm||'')).trim(), bizCd=(''+(o.bizCd||'')).trim();
        var bizLbl = bizCd ? (bizNm ? (bizNm+' ['+bizCd+']') : ('['+bizCd+']')) : bizNm;
        var _dlv=(''+(o.dlvDt||'')).trim(); if(/^\d{8}$/.test(_dlv)) _dlv=_dlv.slice(0,4)+'-'+_dlv.slice(4,6)+'-'+_dlv.slice(6,8);
        var _sd=(''+(o.shpoutDt||'')).trim(); if(/^\d{8}$/.test(_sd)) _sd=_sd.slice(0,4)+'-'+_sd.slice(4,6)+'-'+_sd.slice(6,8);
        return { code:(''+(o.itemCd||'')).trim(), item:(''+(o.itemNm||'')).trim(),
                 biz:bizLbl, bizCode:bizCd, inb:inwh, zone:zone, dcCd:(''+(o.dcCd||'')).trim(),
                 qty:(+o.curQty||0), dlvDt:_dlv, date:(_sd||f) };   // 실제 출고일자(기간 합산 시 범위 필터·집계용) / dcCd=오산센터 그룹 판정용
      });
      window.ssSrcUp   = rows.length>0;
      var _lab=_single?f:(f+'~'+t+' 합산');
      window.ssSrcInfo = rows.length>0 ? ('🗄️ DB 조회 '+_lab+' · '+rows.length+'건') : ('🗄️ DB '+_lab+' — 데이터 없음');
      _rend();
      if(_single) ssLoadAsqBar();   // 직전배치 대조 알림바는 단일일자만
      else if(typeof konetAsqSetDash1==='function') konetAsqSetDash1({hide:true});
    })
    .catch(function(e){ window.ssSrcInfo='⚠️ DB 통신오류'; SHIP_DATA=[]; _rend(); if(typeof konetAsqSetDash1==='function') konetAsqSetDash1({hide:true}); if(window.ssToast) ssToast('⚠️ 출고 조회 통신오류: '+e.message); });
  }

  // ── 하단 알림 바(대시보드1 자체) — 현재 SHIP_DATA vs 직전 배치 대조 요약 ──
  function _ssAsqEsc(s){ return (''+(s==null?'':s)).replace(/[&<>"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c];}); }
  function _ssAsqNormCur(r){   // 현재 화면 데이터(SHIP_DATA) 정규화
    return { zone:(''+(r.zone||'')).trim(), biz:(''+(r.bizCode||'')).trim(),
             key:((''+(r.code||'')).trim()||('NM:'+(''+(r.item||'')).trim())), qty:+r.qty||0 };
  }
  function _ssAsqNormPrev(o){   // 직전 배치 DB행 정규화(현재와 동일 키 규칙: 사업장코드+품목)
    var dc=(''+(o.dcNm||'')).trim(), iw=(''+(o.inwh||'')).trim(); var zn=dc?(dc+iw):(''+(o.zone||'')).trim();
    var c=(''+(o.itemCd||'')).trim();
    return { zone:zn, biz:(''+(o.bizCd||'')).trim(), key:(c||('NM:'+(''+(o.itemNm||'')).trim())), qty:+o.curQty||0 };
  }
  function _ssAsqGroup(list){   // zone → { (사업장|품목) : 수량합 }
    var z={};
    (list||[]).forEach(function(n){ if(n.qty<=0) return; var kk=n.biz+'|'+n.key; (z[n.zone]=z[n.zone]||{}); z[n.zone][kk]=(z[n.zone][kk]||0)+n.qty; });
    return z;
  }
  function ssBuildAsqSummary(curNorm, prevNorm){
    var cur=_ssAsqGroup(curNorm), prev=_ssAsqGroup(prevNorm);
    var zones=Object.keys(cur); Object.keys(prev).forEach(function(zn){ if(zones.indexOf(zn)<0) zones.push(zn); });
    zones.sort(function(a,b){ return (''+a).localeCompare(''+b,'ko'); });
    var items=[];
    zones.forEach(function(zn){
      var p=prev[zn];
      // ★ 직전 배치 없는 출고장(최초 업로드) = 신규/삭제 판정 보류 (대시보드1 line 1299와 동일).
      //   없으면 최초 배치 전량이 '신규'로 오탐됨 (예: 김해물류센터1 단일 배치 → 신규 37).
      if(!p) return;
      var c=cur[zn]||{}, nw=0,up=0,dn=0,dl=0;
      Object.keys(c).forEach(function(k){ if(!(k in p)) nw++; else if(c[k]!==p[k]){ (c[k]>p[k]?up++:dn++); } });
      Object.keys(p).forEach(function(k){ if(!(k in c)) dl++; });
      if(nw+up+dn+dl===0) return;
      var parts=[];
      if(nw) parts.push('<span class="tk-new">신규 '+nw+'</span>');
      if(up) parts.push('<span class="tk-up">▲증가 '+up+'</span>');
      if(dn) parts.push('<span class="tk-dn">▼감소 '+dn+'</span>');
      if(dl) parts.push('<span class="tk-del">삭제 '+dl+'</span>');
      items.push('<span class="tk-item" data-zone="'+_ssAsqEsc(zn)+'"><span class="z">'+_ssAsqEsc(zn)+'</span> '+parts.join(' · ')+'</span>');
    });
    if(!items.length) items.push('<span class="tk-item">✓ 직전 업로드 대비 변경 없음</span>');
    return { hide:false, html:'<span class="tk-spacer"></span>'+items.join('<span class="tk-sep">|</span>') };
  }
  // 현재+직전 배치를 모두 새로 조회해 요약 생성 → 셸 바로 전달 (그리드 SHIP_DATA는 건드리지 않음 → 리프레시에도 안전)
  function ssLoadAsqBar(){
    if(typeof konetAsqSetDash1!=='function') return;   // 셸 바 없으면(단독 접근) 스킵
    var f=(document.getElementById('ssDateFrom')||{}).value||'';
    var t=(document.getElementById('ssDateTo')||{}).value||'';
    if(!(f && f===t)){ konetAsqSetDash1({hide:true}); return; }   // 기간모드 제외
    var CTX=KONET_CTX+'';
    var opt={ method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin', body:'shpoutDt='+encodeURIComponent(f) };
    Promise.all([
      fetch(CTX+'/shipout/selectShipoutMst.do', opt).then(function(r){ return r.ok?r.text():''; }),
      fetch(CTX+'/shipout/selectShipoutPrev.do', opt).then(function(r){ return r.ok?r.text():''; })
    ]).then(function(txts){
      function pj(x){ try{ var j=JSON.parse(x); return (j&&j.data)||[]; }catch(e){ return []; } }
      // 현재·직전 모두 DB 원본행 → 동일 정규화(_ssAsqNormPrev) 적용
      konetAsqSetDash1(ssBuildAsqSummary(pj(txts[0]).map(_ssAsqNormPrev), pj(txts[1]).map(_ssAsqNormPrev)));
    }).catch(function(){ konetAsqSetDash1({hide:true}); });
  }

  // 초기 렌더 (AJAX 주입/직접 접근 모두 대응) — 내장 데이터는 금일자로 간주
  function ssInit(){
    if(!document.getElementById('ssWideTbl')) return;
    if(!window.ssSrcInfo){ window.ssSrcInfo='내장 샘플 데이터 (당일 기준)'; window.ssSrcUp=false; }
    SHIP_DATA.forEach(function(r){ if(!r.date) r.date=SS_TODAY; });
    var f=document.getElementById('ssDateFrom'), t=document.getElementById('ssDateTo');
    // 진입(로그인) 시엔 항상 당일로 시작 — 이전 날짜 기억 안 함. (두 대시보드 동시 사용 중엔 아래 storage 이벤트로 실시간 동기화)
    if(f) f.value=SS_TODAY;
    if(t) t.value=SS_TODAY;
    ssLoadShipoutFromDB();   // 진입 시 = 당일 → DB에서 조회
    // 기본 화면 = 대시보드2 → iframe 자동 로드(한 번만). 직접/AJAX 로드 모두 커버
    var _if2=document.getElementById('if-shipstatus2');
    if(_if2){ var _c2=_if2.getAttribute('src')||''; if(!_c2 || _c2==='about:blank'){ _if2.src=KONET_CTX+'/admin/logistics_demo1.do'; } _if2.setAttribute('data-loaded','1'); }
  }
  /* ══════════════════════════════════════════════════════════════════════════
     매출(판매) 확정내역 업로드 — 출고장 제공 엑셀 → TBL_SALES_MST
      ★엑셀은 '출고장 기준'으로 쓰여 있어 우리 기준으로 뒤집어 담는다
          엑셀 '입고량'=우리 출고량 / '단가'=우리 판매단가 / '매입금액'=우리 매출액 / '입고일자'=우리 출고일자
      · 출고장(평택 등)은 엑셀 안에 없고 파일명에만 있다 → 파일명에서 뽑아 화면에서 확인·수정
      · 납품일자는 엑셀 안에 있으므로 엑셀 값을 쓴다(파일명 날짜는 참고용)
      · 파일 1개 = 1배치(납품일자+출고장). 재업로드 시 서버가 기존 배치 이력마감 후 신규 적재
     ══════════════════════════════════════════════════════════════════════════ */
  var _slsFiles=[];   // [{name, dcNm, rows:[...], err}]
  var _slsDone={};    // 이미 반영된 파일명 → {uploadDttm, dcNm}

  /* ══════════════════════════════════════════════════════════════════════════
     출고장(물류센터) 코드 ↔ 지역명 — 이 화면들의 단일 원천 (2026-07-22 통합)
       근거 = TBL_SHIPOUT_MST 실데이터의 DC_CD ↔ DC_NM
       거래처(TBL_VENDOR_MST) 대응 = E100:00273 E200:00275 E300:00274 E400:00276
                                     E500:00272 E600:00277 E700:00278

     ★센터가 추가·변경되면 아래 KONET_DC 한 곳만 고치면 된다.
       (종전에는 이름→코드 / 코드→이름 두 표와 정규화 로직이 따로 있어,
        한쪽만 고치면 조용히 어긋났다)
     ※ 대시보드·매출마감의 '오산센터 묶음'(CLOSE_DCGROUP / SS_DCGROUP)은
       성격이 다른 표(물류 동선용 그룹)이므로 여기와 합치지 않는다.
     ══════════════════════════════════════════════════════════════════════════ */
  var KONET_DC = { E100:'용인', E200:'왜관', E300:'김해', E400:'광주', E500:'평택', E600:'제주', E700:'오산' };
  var KONET_DC_R = (function(){ var r={}; for(var c in KONET_DC){ r[KONET_DC[c]]=c; } return r; })();   // 지역명→코드 (자동 생성)

  // 표기 통일 : '평택물류센터'·'평택 1'·'평택출고장' → '평택'
  //   두 표가 서로 다르게 적는다 — 정산서는 파일명 유래 '평택', 발주현황표는 '평택물류센터'
  function konetDcShort(s){
    var v=(''+(s==null?'':s)).replace(/\s+/g,'');
    return v.replace(/\d+$/,'').replace(/(물류)?센터$/,'').replace(/출고장$/,'').replace(/\d+$/,'');
  }
  // 이름 → 코드. ①정규화 후 정확 매칭 우선 → ②실패 시 LIKE(지역명 포함) 매칭
  //   파일명이 규칙에서 벗어나(예: 날짜 누락 '2026.07._광주.xlsx') 출고장 칸에 통째로 들어와도
  //   그 안에 지역명(광주 등)이 있으면 해당 센터코드로 잡는다.
  function konetDcCd(nm){
    var hit=KONET_DC_R[konetDcShort(nm)];
    if(hit) return hit;                                              // ① 정확 매칭
    var v=(''+(nm==null?'':nm)).replace(/\s+/g,'');
    for(var region in KONET_DC_R){ if(region && v.indexOf(region)>=0) return KONET_DC_R[region]; }  // ② LIKE
    return '';
  }
  function konetDcNmOf(r){                                                     // 행 → 지역명 (DC_CD 우선)
    var cd=(''+((r&&r.dcCd)||'')).trim().toUpperCase();
    return KONET_DC[cd] || konetDcShort(r&&r.dcNm);
  }

  // 아래 3개는 기존 호출부 유지를 위한 얇은 별칭 — 실제 규칙은 위 4개 함수에만 있다
  function slsDcCd(nm){ return konetDcCd(nm); }     // 정산 엑셀 저장 시 DC_CD 채우기
  function _ohDc(s){ return konetDcShort(s); }      // 이름만 정규화
  function _ohDcOf(r){ return konetDcNmOf(r); }     // 대사 출고장키
  // 지역명 → 대시보드 물류센터 묶음 라벨 (매출마감 CLOSE_DCGROUP 재사용). 매출내역 4탭 공통(2026-07-22)
  function _ohDcGrp(dc){ return CLOSE_DCGROUP[KONET_DC_R[dc]||''] || dc; }

  /* 출고장 다중선택 드롭다운 — 데시보드1(D2_DCSEL/.dc-pop)과 같은 방식(2026-07-22).
     자유 입력이면 '평택물류센터'처럼 잘못 적어 0건이 나와도 이유를 모른다.
     1단 = 대표출고장(묶음) / 2단 = 개별 출고장. 둘 다 체크 가능하고, 아무것도 안 고르면 전체.
     ★목록은 KONET_DC 가 아니라 '조회된 자료에 실제로 있는 출고장'으로 만든다 —
       없는 곳을 고르면 0건이 나와 혼란스럽기 때문(대시보드도 dcAll 로 같은 방식). */
  var _ohDcSel={};   // { '오산센터':1, '평택':1 } — 비어 있으면 전체
  function ohDcOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('ohDcPop'); if(p) p.classList.toggle('open'); }
  function ohDcToggle(k){ if(_ohDcSel[k]) delete _ohDcSel[k]; else _ohDcSel[k]=1; ohDcApply(); }
  function ohDcAll(){ _ohDcSel={}; ohDcApply(); }
  /* 선택을 화면에 반영 — 서버 재조회 없이 즉시. 원본(_ohSalesAll/_ohShipAll)은 그대로 두고
     걸러낸 결과만 _ohSales/_ohShip 에 담는다(집계 함수들이 이 둘을 본다). */
  function ohDcApply(){
    _ohSales=(_ohSalesAll||[]).filter(function(r){ return _ohDcHit(_ohDcOf(r)); });
    _ohShip =(_ohShipAll ||[]).filter(function(r){ return _ohDcHit(_ohDcOf(r)); });
    ohDcSync(); ohRender();
  }
  document.addEventListener('click', function(e){
    var w=document.getElementById('ohDcWrap'), p=document.getElementById('ohDcPop');
    if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
  });
  // 조회 자료에서 (묶음 → 개별) 목록을 뽑아 드롭다운·라벨을 다시 그린다
  function ohDcSync(){
    var pop=document.getElementById('ohDcPop'), lbl=document.getElementById('ohDcLbl');
    if(!pop) return;
    var grp={}, ord=[];
    // ★목록은 '선택 전 원본'으로 만든다 — 걸러진 결과로 만들면 한 곳을 고른 순간 나머지가 사라져 되돌릴 수 없다
    (_ohSalesAll||[]).concat(_ohShipAll||[]).forEach(function(r){
      var dc=_ohDcOf(r); if(!dc) return;
      var g=_ohDcGrp(dc);
      if(!grp[g]){ grp[g]={}; ord.push(g); }
      grp[g][dc]=1;
    });
    ord.sort(function(a,b){ return a.localeCompare(b,'ko'); });
    // 사라진 선택은 정리 (기간을 바꿔 그 출고장이 없어졌을 때)
    var live={}; ord.forEach(function(g){ live[g]=1; Object.keys(grp[g]).forEach(function(k){ live[k]=1; }); });
    Object.keys(_ohDcSel).forEach(function(k){ if(!live[k]) delete _ohDcSel[k]; });
    var n=Object.keys(_ohDcSel).length;
    if(lbl) lbl.textContent = n===0 ? '전체' : (n===1 ? Object.keys(_ohDcSel)[0] : n+'곳 선택');
    var h='<label class="all'+(n===0?' on':'')+'"><input type="checkbox"'+(n===0?' checked':'')
        + ' onchange="ohDcAll()"><span>전체 ('+ord.length+'개 물류센터)</span></label>';
    ord.forEach(function(g){
      var kids=Object.keys(grp[g]).sort(function(a,b){ return a.localeCompare(b,'ko'); });
      var on=!!_ohDcSel[g];
      h+='<label class="'+(on?'on':'')+'"><input type="checkbox"'+(on?' checked':'')
       + ' data-k="'+_cesc(g)+'" onchange="ohDcToggle(this.getAttribute(\'data-k\'))">'
       + '<span>🗂️ '+_cesc(g)+(kids.length>1?' <span style="color:#9aa7b3">('+kids.length+'곳)</span>':'')+'</span></label>';
      if(kids.length<2) return;                       // 혼자면 하위를 또 보여줄 필요 없다
      kids.forEach(function(k){
        var kon=!!_ohDcSel[k];
        h+='<label class="kid'+(kon?' on':'')+'"><input type="checkbox"'+(kon?' checked':'')
         + ' data-k="'+_cesc(k)+'" onchange="ohDcToggle(this.getAttribute(\'data-k\'))"><span>'+_cesc(k)+'</span></label>';
      });
    });
    pop.innerHTML=h;
  }
  /* ══ 출고장 표시이름 + 정정 (2026-07-27) ═══════════════════════════════════════════
       표시이름 : 7곳으로 인식되는 이름은 통일키(용인·평택…), 인식 안 되는 이름은 <원표기 그대로>.
         konetDcShort 가 끝 숫자를 떼기 때문에('평택물류센터1'→'평택') 잘못 저장된 이름은
         DB 값이 '15.24.51' 인데도 화면엔 '15.24.' 로 잘려 보였다(사용자 지적). 정정하려면 원표기가 보여야 한다.
       정정 : 저장된 DC_NM 을 7곳 중 하나로 바꾼다 → /sales/renameSalesDc.do
         ★UPDATE 대상은 정규화된 라벨이 아니라 <원표기(raw)> 다 — 라벨로 찾으면 한 건도 못 고친다.
         원표기가 여러 개 섞인 줄은 무엇을 고칠지 모호해 버튼을 내지 않는다(각 원표기가 각자 줄로 나올 때만).
         이미 7곳으로 인식되는 줄에도 내지 않는다(오조작 방지).                                */
  function _ohDcLabel(g){
    if(KONET_DC_R[g.dc]) return g.dc;                     // 용인·왜관·김해·광주·평택·제주·오산
    var raws=Object.keys(g.raw||{});
    return raws.length ? raws.join(' / ') : g.label;
  }
  function ohDcFixBtn(g){
    if(KONET_DC_R[g.dc]) return '';                       // 정상 인식되는 출고장은 버튼 없음
    /* ★직접판매(전표)는 정정 대상이 아니다 (2026-08-03 지적) — 판매등록 전표에는 출고장이 아예 없고
         '직접판매(전표)' 는 화면에서 붙인 고정 라벨이다. 7곳으로 인식되지 않으니 위 가드를 통과해
         '잘못 저장된 이름'처럼 버튼이 났지만, 고칠 DC_NM 이 TBL_SALES_MST 에 없어 눌러도 0행이다
         (renameSalesDc 는 정산서 전용). 라벨까지 함께 보는 이유 = 전표만 있는 묶음이면 g.trx 로 잡히지만
         라벨이 원표기로 들어오는 경로가 생겨도 안전하게. */
    if(g.trx || /직접판매/.test(''+(g.dc||''))) return '';
    var raws=Object.keys(g.raw||{});
    if(raws.length!==1) return '';                        // 원표기가 여러 개면 대상이 모호
    return ' <span onclick="event.stopPropagation();ohDcFix(\''+encodeURIComponent(raws[0])+'\')"'
      +' title="저장된 출고장 이름이 잘못됐습니다 — 눌러서 바로잡기"'
      +' style="cursor:pointer;color:#c0392b;font-weight:700;font-size:11.5px;border:1px solid #f0c9c2;border-radius:4px;padding:1px 6px;background:#fff;margin-left:6px">✏️ 출고장 고치기</span>';
  }
  function ohDcFix(rawEnc){
    var raw=decodeURIComponent(rawEnc);
    var f=(document.getElementById('slsFrom')||{}).value||'', t=(document.getElementById('slsTo')||{}).value||'';
    var names=[]; for(var cd in KONET_DC){ if(KONET_DC.hasOwnProperty(cd)) names.push(KONET_DC[cd]); }
    var sel='<select id="ohDcFixSel" style="height:34px;font-size:15px;font-weight:700;color:#137a6c;border:1px solid #cdd7dd;border-radius:6px;padding:0 10px">'
      +'<option value="">선택하세요</option>'
      +names.map(function(n){ return '<option value="'+_cesc(n)+'">'+_cesc(n)+'</option>'; }).join('')+'</select>';
    ssConfirm('저장된 <b>출고장 이름</b>을 바로잡습니다.<br><br>'
      +'현재 <b style="color:#c0392b;word-break:break-all">'+_cesc(raw)+'</b> &nbsp;→&nbsp; 바꿀 출고장 '+sel
      +'<div style="margin-top:12px;font-size:12px;color:#6b7a89;line-height:1.7">'
      +'대상 = 조회 기간 <b>'+_cesc(f||'전체')+' ~ '+_cesc(t||'전체')+'</b> 의 이 출고장 자료 전부(활성분 + 이력분)<br>'
      +'행수·수량·금액은 그대로이고 <b>출고장 이름·센터코드만</b> 바뀝니다.<br>'
      +'<span style="color:#a85700">같은 납품일자에 그 출고장 자료가 이미 있으면 정정하지 않습니다</span>(매출이 두 번 잡히므로).</div>',
      function(){
        var v=((document.getElementById('ohDcFixSel')||{}).value||'').trim();
        if(!v){ ssToast('⚠️ 바꿀 출고장을 고르세요.'); return; }
        fetch(KONET_CTX+'/sales/renameSalesDc.do', {
          method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin',
          body:'dcNm='+encodeURIComponent(raw)+'&newDcNm='+encodeURIComponent(v)+'&newDcCd='+encodeURIComponent(konetDcCd(v)||'')
              +'&dlvDtFrom='+encodeURIComponent(f)+'&dlvDtTo='+encodeURIComponent(t)
        })
        .then(function(r){ return r.json(); })
        .then(function(j){
          if(j && j.ok){ ssToast('✏️ 출고장 정정 — <b>'+_cesc(raw)+'</b> → <b>'+_cesc(v)+'</b> ('+(+j.rows||0).toLocaleString()+'행)'); ohQuery(); return; }
          if(j && j.conflict){ ssToast('⚠️ 정정하지 않았습니다 — 같은 납품일자에 <b>'+_cesc(v)+'</b> 자료가 이미 있습니다.<br><span style="font-size:11px">이 경우는 이름 정정이 아니라 잘못 올린 자료를 지워야 합니다.</span>'); return; }
          ssToast('⚠️ 정정 실패: '+_cesc((j&&j.msg)||'알 수 없는 오류'));
        })
        .catch(function(){ ssToast('⚠️ 정정 통신오류 — 잠시 후 다시 시도하세요.'); });
      }, {title:'✏️ 출고장 정정', yes:'정정'});
  }

  // 이 행이 현재 선택에 걸리는가 — 묶음명·개별명 어느 쪽으로 체크했든 통한다
  function _ohDcHit(dc){
    if(!Object.keys(_ohDcSel).length) return true;    // 선택 없음 = 전체
    return !!(_ohDcSel[dc] || _ohDcSel[_ohDcGrp(dc)]);
  }

  // '2026.07.11_평택.xlsx' / '2026.07.11 오산.xlsx' → 출고장명
  function slsParseName(fname){
    var base=(''+fname).replace(/\.[^.]+$/,'');
    var m=base.match(/(\d{4})[.\-\/](\d{1,2})[.\-\/](\d{1,2})[\s_\-]*(.*)$/);
    if(m) return { dt:m[1]+'-'+ssPad(+m[2])+'-'+ssPad(+m[3]), dc:(m[4]||'').trim() };
    // 날짜가 불완전한 파일명(일 누락 등)도 앞 날짜류 접두어를 걷어내고 지역명만 취한다.
    //   예: '2026.07._광주' → 날짜 인식 실패 → dc='광주' (통째로 남지 않게)
    var d=base.replace(/^\s*\d{4}[.\-\/]\d{1,2}(?:[.\-\/]\d{0,2})?[\s._\-]*/,'').trim();
    return { dt:'', dc:(d||base.trim()) };
  }
  function slsStr(v){ return (''+(v==null?'':v)).trim(); }
  function slsNum(v){
    if(v==null||v==='') return null;
    var s=(''+v).replace(/,/g,'').trim(); if(s==='') return null;
    var n=Number(s); return isNaN(n)?null:n;
  }
  // 엑셀 시트(2차원) → 우리 관점 행 목록
  function slsBuildRows(aoa){
    function eq(arr,name){ for(var k=0;k<arr.length;k++){ if(slsStr(arr[k])===name) return k; } return -1; }
    var h=-1, hr=[];
    for(var i=0;i<Math.min(aoa.length,10);i++){
      var rr=(aoa[i]||[]).map(slsStr);
      if(eq(rr,'발주번호')>=0 && eq(rr,'품목코드')>=0){ h=i; hr=rr; break; }
    }
    if(h<0) return { rows:[], err:'헤더(발주번호·품목코드)를 찾지 못했습니다.' };
    var C={ rowNo:eq(hr,'No'), ordNo:eq(hr,'발주번호'), ordItemNo:eq(hr,'발주항번'),
            itemCd:eq(hr,'품목코드'), itemNm:eq(hr,'품목명'), spec:eq(hr,'규격'), unit:eq(hr,'단위'),
            ordQty:eq(hr,'발주량'), settleQty:eq(hr,'정산수량'), settleAmt:eq(hr,'정산금액'),
            dlvDt:eq(hr,'납품일자'), outDt:eq(hr,'입고일자'), outQty:eq(hr,'입고량'),
            salePrice:eq(hr,'단가'), saleAmt:eq(hr,'매입금액'), dlvType:eq(hr,'납품유형'),
            taxGb:eq(hr,'면과세 구분') };
    if(C.taxGb<0) C.taxGb=eq(hr,'면과세구분');
    /* ★헤더 이름 변형 대응 (2026-08-02) — eq() 는 완전일치라 '정산 수량'처럼 띄어쓰기 하나만 달라도 못 읽고,
         그러면 정산수량·정산금액이 통째로 0 으로 저장된다(화면에서는 '정산이 안 온 것'처럼 보인다).
         면과세구분이 이미 같은 이유로 대체 이름을 두고 있어 같은 방식으로 넓힌다.
       ★찾은 이름이 있을 때만 덮으므로, 원래 이름이 있는 파일에는 아무 영향이 없다. */
    if(C.settleQty<0) C.settleQty=eq(hr,'정산 수량');
    if(C.settleQty<0) C.settleQty=eq(hr,'확정수량');
    if(C.settleAmt<0) C.settleAmt=eq(hr,'정산 금액');
    if(C.settleAmt<0) C.settleAmt=eq(hr,'확정금액');
    if(C.outQty<0)    C.outQty   =eq(hr,'입고 수량');
    if(C.outQty<0)    C.outQty   =eq(hr,'입고수량');
    /* ★못 찾은 칸을 조용히 넘기지 않는다 (2026-08-02).
         종전에는 머리글 이름이 조금만 달라도 그 칸이 통째로 0 으로 저장되고 아무 말이 없어서,
         화면에서 "정산금액이 왜 0이냐"를 한참 뒤에야 알게 됐다.
         여기서 '엑셀에 실제로 있던 머리글'을 같이 넘겨 업로드 화면에 그대로 보여 준다. */
    var _miss=[];
    if(C.settleQty<0) _miss.push('정산수량');
    if(C.settleAmt<0) _miss.push('정산금액');
    if(C.outQty<0)    _miss.push('입고량');
    if(C.salePrice<0) _miss.push('단가');
    if(C.saleAmt<0)   _miss.push('매입금액');
    var g=function(row,i){ return i>=0 ? row[i] : ''; };
    var out=[], lastOrd='';
    /* ★오류 행은 아예 담지 않는다(2026-07-26 사용자 확정) — 담아서 경고만 하던 것을 '저장 안 함'으로 바꿨다.
         사유는 화면에 길게 늘어놓지 않고 확인창에 '오류 N행 제외 (사유 개수)' 한 줄로만 알린다.
         · 담기지 않으므로 파일 목록의 행수·출고량·매출액 = 실제로 저장될 값이 된다(어긋날 여지 없음). */
    var nBad=0, badWhy={};
    var _mark=function(w){ nBad++; badWhy[w]=(badWhy[w]||0)+1; };
    for(var r=h+1;r<aoa.length;r++){
      var row=aoa[r]||[];
      var cd=slsStr(g(row,C.itemCd));
      if(!cd) continue;                       // 품목코드 없는 행 = 합계행/빈행 → 제외(오류 아님)
      var ono=slsStr(g(row,C.ordNo));
      if(ono) lastOrd=ono; else ono=lastOrd;  // 발주번호 병합셀(B3:B63) → 위 값 승계
      var _dlv=ssFmtDate(g(row,C.dlvDt));
      var _rq=slsStr(g(row,C.outQty)), _ra=slsStr(g(row,C.saleAmt));
      var _q=slsNum(g(row,C.outQty)), _p=slsNum(g(row,C.salePrice)), _a=slsNum(g(row,C.saleAmt));
      if(!_dlv){                    _mark('납품일자'); continue; }   // 배치키(납품일자+출고장)가 안 섬
      if(!ono){                     _mark('발주번호'); continue; }   // 위에도 값이 없어 승계 실패
      if(_rq==='' || _q===null){    _mark('입고량');   continue; }
      if(_ra==='' || _a===null){    _mark('매입금액'); continue; }
      if(_p!==null && Math.abs(_a - _q*_p) > 1){ _mark('매입금액≠입고량×단가'); continue; }   // 원본 검산
      out.push({
        rowNo:slsNum(g(row,C.rowNo)), ordNo:ono, ordItemNo:slsStr(g(row,C.ordItemNo)),
        itemCd:cd, itemNm:slsStr(g(row,C.itemNm)), spec:slsStr(g(row,C.spec)), unit:slsStr(g(row,C.unit)),
        ordQty:slsNum(g(row,C.ordQty)), settleQty:slsNum(g(row,C.settleQty)), settleAmt:slsNum(g(row,C.settleAmt)),
        dlvDt:ssFmtDate(g(row,C.dlvDt)), outDt:ssFmtDate(g(row,C.outDt)),
        outQty:slsNum(g(row,C.outQty)), salePrice:slsNum(g(row,C.salePrice)), saleAmt:slsNum(g(row,C.saleAmt)),
        dlvType:slsStr(g(row,C.dlvType)), taxGb:slsStr(g(row,C.taxGb))
      });
    }
    // 한 행도 못 담았으면 이유를 err 로 — 목록 상태칸에 그대로 뜬다(문구는 종전처럼 한 줄)
    var e0 = out.length ? ''
           : (nBad ? ('모든 행에 오류가 있어 저장할 수 없습니다 ('+nBad.toLocaleString()+'행)')
                   : '품목코드가 있는 데이터행이 없습니다.');
    return { rows:out, err:e0, nBad:nBad, badWhy:badWhy,
             miss:_miss, hdr:hr.filter(function(x){ return x; }) };
  }
  // 오류 행 사유 요약 한 줄 — "매입금액 12 · 납품일자 3" (확인창·상태칸용, 목록으로 늘어놓지 않는다)
  function slsBadWhy(f){
    var w=(f&&f.badWhy)||{}, a=[];
    for(var k in w){ if(w.hasOwnProperty(k)) a.push({k:k, n:w[k]}); }
    a.sort(function(x,y){ return y.n-x.n; });
    return a.map(function(x){ return x.k+' '+x.n.toLocaleString(); }).join(' · ');
  }
  /* ★이 파일이 저장에서 빠지는 이유 — 없으면 ''. 목록 상태칸(slsRender)과 저장(slsSave)이 같은 판정을 쓰도록 한 곳에 둔다.
       여기 걸린 파일만 제외되고 나머지는 저장된다(2026-07-26 'A안' — 종전에는 하나만 걸려도 전체가 막혔다). */
  function slsSkipWhy(f){
    if(!f) return '';
    if(!f.rows.length)        return f.err || '저장할 행 없음';   // 오류 행은 이미 rows 에서 빠져 있다
    var _dc=(f.dcNm||'').trim();
    if(!_dc)                  return '출고장이 비어 있음';
    /* ★출고장을 물류센터로 알아보지 못한 파일도 저장하지 않는다 (2026-07-27 사용자 지시).
         종전에는 '미확인'이어도 DC_CD 를 빈값으로 두고 저장했다 → 그 자료는 출고장으로 묶이지 않아
         대사·출고장별 집계에서 통째로 빠지고, 파일명에서 잘못 딴 값(예: '09.49.30')이 그대로 남았다.
         형식오류와 같은 급으로 막고, 출고장 칸을 고치면 곧바로 저장 가능해진다(입력값으로 재판정). */
    if(!slsDcCd(_dc))         return '출고장 미확인 — 용인·왜관·김해·광주·평택·제주·오산 중 선택';
    return '';
  }
  // 이미 반영된 파일명 목록 (재업로드=기존배치 대체 임을 화면에 알림)
  function slsLoadDone(){
    fetch(KONET_CTX+'/sales/selectSalesSrcFiles.do', { method:'POST', credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(j){ _slsDone={}; ((j&&j.data)||[]).forEach(function(o){ _slsDone[o.srcFile]={uploadDttm:o.uploadDttm, dcNm:o.dcNm}; }); slsRender(); })
      .catch(function(){});
  }
  /* 정산 엑셀 고르기 진입점 (2026-08-01) — 버튼을 판매등록 화면(salesReg.jsp, iframe)으로 옮기면서 만든 것.
     iframe 쪽에서 parent.konetSlsExcelPick() 로 부른다. 파일 input·확인 저장 팝업은 여기(부모)에 그대로 두었다 —
     팝업은 화면 전체를 덮는 오버레이라 어느 화면을 보고 있든 그 위에 뜬다. */
  function konetSlsExcelPick(){
    var f=document.getElementById('slsFile');
    if(!f){ if(typeof ssToast==='function') ssToast('⚠️ 정산 엑셀 입력을 찾지 못했습니다.'); return false; }
    f.click(); return true;
  }
  window.konetSlsExcelPick = konetSlsExcelPick;   // iframe(판매등록)에서 부르므로 window 에 명시 등록
  function slsUpload(input){
    var fs=input.files; if(!fs||!fs.length) return;
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); input.value=''; return; }
    var list=Array.prototype.slice.call(fs), done=0;
    var fin=function(){ if(++done===list.length){ slsRender(); slsSyncDates(); slsLoadDone(); slsUpOpen(); } };   // 고르면 확인·저장 팝업을 연다
    list.forEach(function(f){
      var rd=new FileReader();
      rd.onload=function(e){
        ssReadXlsx(e.target.result, function(wb){
          try{
            var ws=wb.Sheets[wb.SheetNames[0]];
            var aoa=ws?XLSX.utils.sheet_to_json(ws,{header:1,defval:''}):[];
            var b=slsBuildRows(aoa);
            _slsFiles=_slsFiles.filter(function(x){ return x.name!==f.name; });   // 같은 파일 다시 고르면 교체
            _slsFiles.push({ name:f.name, dcNm:slsParseName(f.name).dc, rows:b.rows, err:b.err, nBad:b.nBad, badWhy:b.badWhy,
                             miss:b.miss, hdr:b.hdr });
          }catch(err){ _slsFiles.push({ name:f.name, dcNm:'', rows:[], err:err.message }); }
          fin();
        }, function(err){ _slsFiles.push({ name:f.name, dcNm:'', rows:[], err:err.message }); fin(); });
      };
      rd.readAsArrayBuffer(f);
    });
    input.value='';
  }
  function slsSetDc(i, v){ if(_slsFiles[i]) _slsFiles[i].dcNm=(''+v).trim(); }
  function slsDrop(i){ _slsFiles.splice(i,1); slsRender(); }
  function slsClear(){ _slsFiles=[]; slsRender(); slsUpClose(); }
  function slsDates(f){   // 파일 안 납품일자 distinct
    var s={}, o=[]; f.rows.forEach(function(r){ if(r.dlvDt && !s[r.dlvDt]){ s[r.dlvDt]=1; o.push(r.dlvDt); } }); return o.sort();
  }
  /* 파일 목록·미리보기·저장은 전부 팝업(ss-modal)으로 — 본 화면에는 안 깔린다(2026-07-22 요청).
     미리보기는 <details> 로 접어두어 필요할 때만 펼친다. */
  function _slsUpEnsure(){
    var ov=document.getElementById('slsUpOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='slsUpOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(1150px,90vw)">'
        +'<style>@keyframes slsProgFlow{0%{background-position:0 0}100%{background-position:34px 0}}'
        +'.sls-prog-indet{background-image:repeating-linear-gradient(45deg,rgba(255,255,255,.28) 0 9px,rgba(255,255,255,0) 9px 17px),linear-gradient(90deg,#17a589,#137a6c)!important;background-size:34px 34px,100% 100%!important;animation:slsProgFlow .7s linear infinite}</style>'
        +'<div class="mh"><h4>📥 정산 엑셀 저장</h4><button class="x" onclick="slsUpClose()">&times;</button></div>'
        +'<div class="mbar"><span id="slsUpSum"></span></div>'
        +'<div class="mbody" id="slsUpWrap"></div>'
        +'<div id="slsProg" style="display:none;padding:8px 16px 2px">'
        +'  <div style="display:flex;justify-content:space-between;font-size:12px;color:#5a6b7a;margin-bottom:5px">'
        +'    <span id="slsProgLab">저장 중…</span><span id="slsProgPct" style="font-weight:700;color:#137a6c"></span></div>'
        +'  <div style="height:11px;background:#e6ecf0;border-radius:6px;overflow:hidden">'
        +'    <div id="slsProgFill" style="height:100%;width:0%;background:linear-gradient(90deg,#17a589,#137a6c);border-radius:6px;transition:width .2s ease"></div>'
        +'  </div></div>'
        +'<div class="mfoot">'
        +'<button class="btn-line" style="margin-right:auto" onclick="document.getElementById(\'slsFile\').click()">📁 파일 추가</button>'
        +'<button class="btn-line" onclick="slsClear()">🧹 비우기</button>'
        +'<button class="btn-line" onclick="slsUpClose()">닫기</button>'
        +'<button class="btn-teal" id="slsSaveBtn" onclick="slsSave()">💾 저장</button>'
        +'</div></div>';
      document.body.appendChild(ov);
      // ※ 바깥 클릭으로는 안 닫는다(요청 2026-07-22) — 고른 파일이 실수로 날아가는 걸 막기 위함.
      //    닫으려면 ✕ / [닫기] 를 눌러야 한다.
    }
    return ov;
  }
  function slsUpOpen(){ _slsUpEnsure().classList.add('on'); slsRender(); }
  function slsUpClose(){ var ov=document.getElementById('slsUpOv'); if(ov) ov.classList.remove('on'); }
  // 본 화면 버튼: 대기 파일이 있을 때만 보인다 (닫아도 다시 열 수 있게)
  function _slsUpChip(){
    var c=document.getElementById('slsUpChip'); if(!c) return;
    if(!_slsFiles.length){ c.style.display='none'; return; }
    c.style.display=''; c.innerHTML='📄 대기 <b>'+_slsFiles.length+'</b>개 — 저장하기';
  }
  function slsRender(){
    _slsUpEnsure();
    var wrap=document.getElementById('slsUpWrap'), sum=document.getElementById('slsUpSum');
    _slsUpChip();
    if(!wrap) return;
    if(!_slsFiles.length){ sum.textContent=''; wrap.innerHTML='<div style="padding:24px;text-align:center;color:#9aa7b3">고른 파일이 없습니다. <b>📁 파일 추가</b> 로 정산 엑셀을 선택하세요.</div>'; return; }
    var tQ=0, tA=0, tR=0;
    _slsFiles.forEach(function(f){ f.rows.forEach(function(r){ tR++; tQ+=(+r.outQty||0); tA+=(+r.saleAmt||0); }); });
    var tB=_slsFiles.reduce(function(s,f){ return s+(+f.nBad||0); }, 0);       // 오류로 빠진 행(rows 에 이미 없음)
    sum.innerHTML='파일 <b>'+_slsFiles.length+'</b>개 · 행 <b>'+tR.toLocaleString()+'</b> · 출고량 <b>'+_cnum(tQ)+'</b> · 매출액 <b style="color:#137a6c">'+_cnum(tA)+'</b>'
      + (tB?(' · <span style="color:#c0392b">오류 <b>'+tB.toLocaleString()+'</b>행 제외</span>'):'');
    var h='<table class="logi-tb sls-ftb"><thead><tr><th>파일명</th><th>출고장</th><th>센터코드</th><th>납품일자</th>'
        + '<th style="text-align:right">행</th><th style="text-align:right">출고량</th><th style="text-align:right">매출액</th><th>상태</th><th></th></tr></thead><tbody>';
    _slsFiles.forEach(function(f,i){
      var q=0,a=0; f.rows.forEach(function(r){ q+=(+r.outQty||0); a+=(+r.saleAmt||0); });
      var ds=slsDates(f), dlab=ds.length?(ds[0]+(ds.length>1?(' 외 '+(ds.length-1)+'일'):'')):'<span style="color:#c0392b">없음</span>';
      // 저장에서 빠지는 파일은 이유를 한 줄로 — 나머지 파일은 그대로 저장된다(전체가 막히지 않음)
      var _sw=slsSkipWhy(f), st;
      if(_sw) st='<span style="color:#c0392b">⚠ '+_cesc(_sw)+'</span>';
      else {
        st = _slsDone[f.name] ? '<span style="color:#a85700">↻ 이미 반영됨 ('+_cesc(_slsDone[f.name].uploadDttm||'')+') — 저장 시 대체</span>'
                              : '<span style="color:#137a6c">신규</span>';
        if(+f.nBad) st+=' <span style="color:#c0392b">· 오류 '+(+f.nBad).toLocaleString()+'행 제외</span>';
      }
      /* ★못 찾은 머리글을 여기서 알린다 (2026-08-02).
           이 경고가 없어서, 엑셀에 '정산금액' 칸이 있는데도 이름이 조금 달라 못 읽고
           DB 에 0 으로 저장된 것을 한참 뒤에야 알았다.
           엑셀에 **실제로 있던 머리글**을 hover 로 그대로 보여 주므로, 어떤 이름을 추가하면 되는지 바로 알 수 있다. */
      if(f.miss && f.miss.length){
        st += '<br><span style="color:#c0392b;font-weight:700;cursor:help" title="'
            + _cesc('엑셀에서 이 머리글을 찾지 못했습니다: ' + f.miss.join(', ')
                   + '&#10;→ 해당 칸은 0 으로 저장됩니다.'
                   + '&#10;&#10;[이 파일의 실제 머리글]&#10;' + (f.hdr||[]).join(' | '))
            + '">⚠ 머리글 못 찾음: ' + _cesc(f.miss.join(', ')) + ' <u>(실제 머리글 보기)</u></span>';
      }
      h+='<tr><td class="txt-l">'+_cesc(f.name)+'</td>'
        // 출고장을 고치면 칸을 벗어날 때(onchange) 다시 그려 센터코드·상태를 즉시 재판정한다.
        //   oninput 마다 재그리면 입력 중 포커스가 날아가므로 값 갱신만 한다.
        +'<td><input class="cq" style="width:120px;height:26px'+(slsDcCd(f.dcNm)?'':';border-color:#c0392b')+'" value="'+_cesc(f.dcNm)+'" oninput="slsSetDc('+i+',this.value)" onchange="slsSetDc('+i+',this.value);slsRender()" placeholder="예: 평택"></td>'
        +'<td>'+(slsDcCd(f.dcNm)
                 ? '<b style="color:#137a6c">'+slsDcCd(f.dcNm)+'</b>'
                 : '<span style="color:#c0392b" title="출고장명으로 물류센터코드를 찾지 못했습니다. 용인·왜관·김해·광주·평택·제주·오산 중 하나로 적어주세요.&#10;★이 파일은 저장되지 않습니다 — 출고장 칸을 고치면 곧바로 저장 대상이 됩니다.">미확인</span>')+'</td>'
        +'<td>'+dlab+'</td>'
        +'<td style="text-align:right">'+f.rows.length.toLocaleString()+'</td>'
        +'<td style="text-align:right">'+_cnum(q)+'</td>'
        +'<td style="text-align:right;font-weight:700;color:#137a6c">'+_cnum(a)+'</td>'
        +'<td>'+st+'</td>'
        +'<td><button class="btn-line" style="height:26px;padding:0 8px" onclick="slsDrop('+i+')">제거</button></td></tr>';
    });
    h+='</tbody></table>';
    // 미리보기(첫 파일 최대 15행) — 기본 접힘. 확인이 필요할 때만 펼친다
    var f0=_slsFiles[0];
    if(f0 && f0.rows.length){
      h+='<details style="margin-top:12px"><summary style="cursor:pointer;font-size:12.5px;font-weight:700;color:#5a6b7a;padding:6px 0">'
        +'🔎 미리보기 — '+_cesc(f0.name)+' <span style="font-weight:400;color:#9aa7b3">(앞 15행 / 총 '+f0.rows.length.toLocaleString()+'행)</span></summary>'
        +'<table class="logi-tb"><thead><tr><th>No</th><th>발주번호</th><th>항번</th><th>품목코드</th><th>품목명</th>'
        +'<th style="text-align:right">발주량</th><th style="text-align:right">출고량</th>'
        +'<th style="text-align:right">판매단가</th><th style="text-align:right">매출액</th><th>납품일자</th><th>출고일자</th></tr></thead><tbody>';
      f0.rows.slice(0,15).forEach(function(r){
        h+='<tr><td>'+(r.rowNo==null?'':r.rowNo)+'</td><td>'+_cesc(r.ordNo)+'</td><td>'+_cesc(r.ordItemNo)+'</td>'
          +'<td>'+_cesc(r.itemCd)+'</td><td class="txt-l">'+_cesc(r.itemNm)+'</td>'
          +'<td style="text-align:right">'+(r.ordQty==null?'':r.ordQty)+'</td>'
          +'<td style="text-align:right;'+((+r.outQty||0)<0?'color:#c0392b':'')+'">'+(r.outQty==null?'':r.outQty)+'</td>'
          +'<td style="text-align:right">'+_cnum(r.salePrice)+'</td>'
          +'<td style="text-align:right;font-weight:700;color:#137a6c">'+_cnum(r.saleAmt)+'</td>'
          +'<td>'+_cesc(r.dlvDt)+'</td><td>'+_cesc(r.outDt)+'</td></tr>';
      });
      h+='</tbody></table></details>';
    }
    wrap.innerHTML=h;
  }
  /* 저장 진행바 — 업로드(실측 바이트 0~25%) → 서버 반영(경과시간 추정 25~95%) → 완료(100%)
       서버가 진행률을 안 알려주므로 서버 구간은 경과시간으로 %를 계산한다.
         p = UP + (CEIL-UP) * t/(t+tau)   (tau=행수 기반 예상시간)
       추정이 빗나가도 상한(CEIL)에 점근할 뿐 넘지 않고, 실제 응답이 오면 100%로 스냅 → 거짓 완료 없음. */
  var SLS_PROG_UP=25, SLS_PROG_CEIL=95;
  var _slsProgTimer=null, _slsProgSrvStart=0, _slsProgTau=3000;
  function _slsProgWidth(pct, stripe){
    pct=Math.max(0,Math.min(100,pct));
    var f=document.getElementById('slsProgFill'), p=document.getElementById('slsProgPct');
    if(f){ f.style.width=pct+'%'; if(stripe) f.classList.add('sls-prog-indet'); else f.classList.remove('sls-prog-indet'); }
    if(p) p.textContent=Math.round(pct)+'%';
  }
  function _slsProgLab(t){ var l=document.getElementById('slsProgLab'); if(l && t!=null) l.textContent=t; }
  function slsProgShow(lab){ var b=document.getElementById('slsProg'); if(b) b.style.display=''; _slsProgWidth(0,false); _slsProgLab(lab||'저장 준비 중…'); }
  // 업로드 실측 — bytes 비율(0~1) → 0~UP%
  function slsProgUpload(frac, lab){ _slsProgWidth((+frac||0)*SLS_PROG_UP, false); _slsProgLab(lab); }
  // 서버 반영 — 경과시간 추정 %로 계속 전진(줄무늬 애니메이션 병행)
  function slsProgServerStart(rows){
    _slsProgTau=Math.max(1500, (+rows||0)*7);          // 대략 행당 7ms 가정(느린 편 — 빗나가도 자기보정)
    _slsProgSrvStart=Date.now();
    _slsProgWidth(SLS_PROG_UP, true);
    _slsProgLab('서버 반영 중… (이력마감·단가이력 처리)');
    if(_slsProgTimer) clearInterval(_slsProgTimer);
    _slsProgTimer=setInterval(function(){
      var t=Date.now()-_slsProgSrvStart;
      _slsProgWidth(SLS_PROG_UP + (SLS_PROG_CEIL-SLS_PROG_UP)*(t/(t+_slsProgTau)), true);
    }, 150);
  }
  function _slsProgStop(){ if(_slsProgTimer){ clearInterval(_slsProgTimer); _slsProgTimer=null; } }
  function slsProgDone(){ _slsProgStop(); _slsProgWidth(100, false); _slsProgLab('완료'); }
  function slsProgHide(){ _slsProgStop(); var b=document.getElementById('slsProg'), f=document.getElementById('slsProgFill'); if(b) b.style.display='none'; if(f){ f.classList.remove('sls-prog-indet'); f.style.width='0%'; } }
  function slsSaveBtnBusy(on){ var b=document.getElementById('slsSaveBtn'); if(b){ b.disabled=!!on; b.style.opacity=on?'0.55':''; b.style.pointerEvents=on?'none':''; } }
  /* 저장 뒤 정리 — 저장에 들어간 파일만 목록에서 빼고, 제외된 파일은 남겨 고쳐서 다시 저장할 수 있게 한다.
       남은 게 없으면 종전대로 팝업을 닫는다. 반환 = 목록에 남은(제외된) 파일 수. */
  function _slsAfterSave(savedNames){
    _slsFiles=_slsFiles.filter(function(f){ return !savedNames[f.name]; });
    var left=_slsFiles.length;
    slsLoadDone();                       // 반영 파일 목록 갱신(내부에서 slsRender)
    slsQuery();
    if(left) slsRender(); else slsUpClose();
    return left;
  }
  function slsSave(){
    if(!_slsFiles.length){ ssToast('⚠️ 업로드된 파일이 없습니다.'); return; }
    /* ★저장 가능한 파일만 저장한다(2026-07-26 요청) — 종전에는 한 파일이라도 문제가 있으면 전체가 막혔다.
         문제 파일은 payload 에서 빼고 `bad` 에 사유를 남겨 확인창에 보여준 뒤, 저장 후에도 목록에 남긴다. */
    var payload=[], bad=[], okFiles=[];
    _slsFiles.forEach(function(f){
      var why=slsSkipWhy(f);
      if(why){ bad.push(f.name+' — '+why); return; }
      var dc=(f.dcNm||'').trim(), dcc=slsDcCd(dc);   // 물류센터코드 — 여기 온 파일은 slsSkipWhy 를 통과했으므로 항상 값이 있다
      f.rows.forEach(function(o){          // rows 에는 오류 행이 이미 없다(slsBuildRows 에서 제외)
        payload.push({ srcFile:f.name, dcNm:dc, dcCd:dcc,
          rowNo:o.rowNo, ordNo:o.ordNo, ordItemNo:o.ordItemNo, itemCd:o.itemCd, itemNm:o.itemNm,
          spec:o.spec, unit:o.unit, ordQty:o.ordQty, settleQty:o.settleQty, settleAmt:o.settleAmt,
          dlvDt:o.dlvDt, outDt:o.outDt, outQty:o.outQty, salePrice:o.salePrice, saleAmt:o.saleAmt,
          dlvType:o.dlvType, taxGb:o.taxGb });
      });
      okFiles.push(f);
    });
    if(!payload.length){ ssToast('⚠️ 저장할 수 있는 파일이 없습니다.'+(bad.length?('<br>'+bad.map(_cesc).join('<br>')):'')); return; }
    var q=0,a=0; payload.forEach(function(r){ q+=(+r.outQty||0); a+=(+r.saleAmt||0); });
    var dup=okFiles.filter(function(f){ return _slsDone[f.name]; }).length;
    var savedNames={}; okFiles.forEach(function(f){ savedNames[f.name]=1; });   // 저장 뒤 목록에서 뺄 파일
    // 오류 행은 파싱 단계에서 이미 빠져 있다 → 몇 행이 왜 빠졌는지만 한 줄로 알린다
    var nBad=okFiles.reduce(function(s,f){ return s+(+f.nBad||0); }, 0);
    var whys={}; okFiles.forEach(function(f){ for(var k in (f.badWhy||{})) whys[k]=(whys[k]||0)+f.badWhy[k]; });
    var whyTxt=slsBadWhy({badWhy:whys});
    ssConfirm('매출 확정내역 <b>'+payload.length.toLocaleString()+'</b>행을 저장하시겠습니까?<br>'
      +'파일 <b>'+okFiles.length+'</b>개 · 출고장 <b>'+_cesc(okFiles.map(function(f){return f.dcNm;}).join(', '))+'</b>'
      +' · 출고량 <b style="color:#137a6c">'+_cnum(q)+'</b> · 매출액 <b style="color:#137a6c">'+_cnum(a)+'</b>'
      +(nBad?('<br><span style="color:#c0392b">※ 오류 '+nBad.toLocaleString()+'행은 저장하지 않습니다'+(whyTxt?(' ('+_cesc(whyTxt)+')'):'')+'.</span>'):'')
      +(dup?('<br><span style="color:#a85700">※ 이미 반영된 파일 '+dup+'개 — 같은 (납품일자+출고장) 기존 자료는 이력마감 후 새로 적재됩니다.</span>'):'')
      +(bad.length?('<br><span style="color:#c0392b">※ '+bad.length+'개 파일은 저장 제외 — '+bad.map(_cesc).join(' / ')+'</span>'):''),
      function(){
        var body=JSON.stringify(payload);
        var nRows=payload.length;
        slsSaveBtnBusy(true);
        slsProgShow('업로드 중… (0 / '+nRows.toLocaleString()+'행)');
        var xhr=new XMLHttpRequest();
        xhr.open('POST', KONET_CTX+'/sales/saveSalesMst.do', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.withCredentials=true;
        // 1) 업로드 진행 — 실제 전송 바이트로 0~25% (행수는 근사표기)
        xhr.upload.onprogress=function(ev){
          if(!ev.lengthComputable) return;
          var frac=ev.loaded/ev.total;
          slsProgUpload(frac, '업로드 중… ('+Math.round(frac*nRows).toLocaleString()+' / '+nRows.toLocaleString()+'행)');
        };
        // 2) 업로드 완료 → 서버 반영 구간: 경과시간 추정 %로 25→95% 전진
        xhr.upload.onload=function(){ slsProgServerStart(nRows); };
        xhr.onload=function(){
          slsProgDone();                 // 실제 응답 → 100% 스냅
          setTimeout(slsProgHide, 500);
          slsSaveBtnBusy(false);
          var ok=(xhr.status>=200 && xhr.status<300), t=xhr.responseText;
          if(!ok){ ssToast('⚠️ 저장 실패: '+(t||('HTTP '+xhr.status))); return; }
          // 응답 = {saved:행수, price:판매단가 이력 반영 품목수, none:변화없음, skip:단가 충돌로 제외}
          //  · 문자열로 한 번 더 감싸져 오면(서버가 String 으로 반환하면) 풀어준다 — 안 그러면 전부 0으로 보임
          var j=null; try{ j=JSON.parse(t); }catch(e){}
          if(typeof j==='string'){ try{ j=JSON.parse(j); }catch(e){ j=null; } }
          // 저장된 파일만 목록에서 빠지고, 제외된 파일은 남는다 → 남은 수를 알림에 덧붙인다
          var _leftMsg=function(n){ return n?(' · <span style="color:#c0392b">제외 '+n+'개 파일은 목록에 남김</span>'):''; };
          if(!j || typeof j!=='object'){ var l0=_slsAfterSave(savedNames); ssToast('💾 저장 완료 — <b>'+_cesc(t)+'</b>'+_leftMsg(l0)); return; }
          var msg='💾 저장 완료 — <b>'+(+j.saved||0).toLocaleString()+'</b>행 · 판매단가 이력 <b>'+(+j.price||0)+'</b>종 반영';
          if(+j.none)  msg+=' · <span style="color:#9aa7b3">변화없음 '+j.none+'종</span>';
          if(+j.skip)  msg+=' · <span style="color:#a85700">단가충돌 '+j.skip+'종 제외</span>';
          msg+=_leftMsg(_slsAfterSave(savedNames));
          ssToast(msg);
        };
        xhr.onerror=function(){ slsProgHide(); slsSaveBtnBusy(false); ssToast('⚠️ 통신오류 — 네트워크를 확인하세요.'); };
        xhr.ontimeout=function(){ slsProgHide(); slsSaveBtnBusy(false); ssToast('⚠️ 저장 시간 초과 — 잠시 후 다시 시도하세요.'); };
        xhr.send(body);
      });
  }
  /* ══════════════════════════════════════════════════════════════════════════
     출고내역 (매입·재고관리 ▸ 출고내역) — 정산서 × 출고내역 대사
       · 정산서   = TBL_SALES_MST   (출고장이 준 엑셀. 출고장에 들어간 물품값 = 우리가 받을 금액)
       · 출고내역 = TBL_SHIPOUT_MST (발주현황표 업로드분. 실제 나간 수량)
       · 짝 맞추기 = 발주번호(ORD_NO) + 발주항번(ORD_ITEM_NO)  ← 두 표가 같은 값을 쓴다
       · 기간 기준 = 납품일자(=납기일자 DLV_DT). 출고내역은 SHPOUT_DT 로만 조회되는데
         먼 지역은 발주분을 하루 당겨 출고하므로 ±7일 넉넉히 읽어 DLV_DT 로 다시 거른다.
     ══════════════════════════════════════════════════════════════════════════ */
  /* 매출내역 4탭 표시 방식 — 한 번에 18행(KONET_GRID_ROWS)씩, 나머지는 스크롤로 자동 이어붙임 — 2026-07-25 요청.
       "한 화면 18행으로 하되 페이지 버튼으로 넘기지 말고 자동 스크롤"
       · 2026-07-24 의 'OH_ROWS 를 크게 잡아 전체 행 표시'를 대체한다. 전체 렌더는 4천행에서 표가 무거웠고,
         그 전의 페이저는 페이지를 넘겨가며 봐야 했다. 둘 다 없애는 방식이 이것이다.
       · 화면 아래로 넘치지 않게 표 높이는 18행으로 맞추되, 창이 낮으면 뷰포트에서 자른다(_ohFit).
       · 입고내역 INB_PAGE·재고현황 STK_PAGE 등 다른 화면의 페이징에는 영향 없음. */
  var _ohSales=[], _ohShip=[], _ohTab='dc', _ohCol={}, _ohAllCol=false, OH_ROWS=KONET_GRID_ROWS;
  var _ohSalesAll=[], _ohShipAll=[];   // 출고장 선택 전 원본 — 선택은 화면에서만 거르므로 재조회 없이 되돌릴 수 있다

  /* 수량차이 칸 — 값의 부호로 색을 정한다 (2026-08-02 요청).
       음수(정산<출고) = 보냈는데 청구가 덜 됨 → **빨강** (돈을 못 받는 쪽이라 제일 급하다)
       양수(정산>출고) = 청구가 더 됨(과청구·출고기록 누락) → 남색
       0                = 일치 → 초록
     ★왜 class 가 아니라 inline + !important 인가
       합계줄 `tr.close-total td { color:#fff !important }`, 그룹줄 `tr.close-grp td { color:#137a6c }`
       가 특이성으로 .oh-gap(0,1,0) 을 눌러 버려서, 마이너스인데 흰색·초록으로 보였다.
       inline !important 만이 그 둘을 다 이긴다. 클래스로 되돌리지 말 것.
     blankZero=true 면 0 을 빈칸으로 둔다(품목 줄은 0 을 안 찍던 종전 동작 유지). */
  function _ohGapCell(v, blankZero){
    var n=Number(v)||0, z=Math.abs(n)<1e-6;
    var c = z ? '#137a6c' : (n<0 ? '#c0392b' : '#274b8f');
    return '<td style="text-align:right;font-weight:800;color:'+c+' !important">'
         + ((z && blankZero) ? '' : _ohQ(n)) + '</td>';
  }
  function _ohQ(v){   // 수량 — 소수·음수 보존(반품행 0.49/-0.49)
    var n=Number(v); if(!isFinite(n)) return '';
    return (Math.abs(n%1)<1e-9) ? n.toLocaleString() : n.toLocaleString(undefined,{maximumFractionDigits:3});
  }
  function _ohYmd(s){ return (''+(s==null?'':s)).replace(/-/g,'').trim(); }         // '2026-07-11'|'20260711' → '20260711'
  /* 출고장 통일키(_ohDc / _ohDcOf)는 위쪽 KONET_DC 블록에 있다 — 여기 있던 중복 정의 제거(2026-07-22).
     ※ DC_CD 는 정산서에 2026-07-22부터 저장되므로 그 전 자료는 이름으로 잡힌다 — 둘 다 '평택'으로 수렴한다. */
  /* ★대사키 = 납기일자 + 출고장 + 품목코드 (2026-07-22 사용자 확정)
       발주번호+항번을 쓰다가 바꿨다. 이유:
         · 발주현황표의 ORD_NO 가 절반(1145행 중 573행) 비어 있어 그만큼 영영 대사 불가였다
           (병합셀 아님 — ORD_NO·ORD_ITEM_NO 가 함께 비고 JUMUN_NO 만 100% 차 있다. 원본이 그렇다)
         · 정산서에는 주문번호 칸이 없어(엑셀 17컬럼 실측) 주문번호로도 못 잇는다
         · 이 세 칸은 양쪽 다 100% 채워져 있다 → 빠지는 행이 없다
       성격: 행 대 행이 아니라 **합계 대 합계**.
         정산서 105행 → 103키 / 출고 1145행 → 888키 (출고는 사업장이 자동 합산된다) */
  function _ohKey(o){
    /* 판매전표(직접판매)는 대사 대상이 아니다 — 출고장 발주현황표에 짝이 있을 수 없다.
       키를 안 만들어야 '출고미상'(정산엔 있는데 출고가 없음)으로 오분류되지 않는다(2026-07-25). */
    if(o && o.trxYn==='Y') return '';
    var d=_ohYmd(o&&o.dlvDt), dc=_ohDcOf(o), it=(''+((o&&o.itemCd)||'')).trim();
    return (d&&dc&&it) ? (d+'|'+dc+'|'+it) : '';   // 셋 중 하나라도 비면 키가 안 선다(실측 0건)
  }
  function _ohShift(d, days){   // 'yyyy-mm-dd' ± n일
    if(!d) return '';
    var p=d.split('-'); if(p.length<3) return '';
    var t=new Date(+p[0], +p[1]-1, +p[2]+days);
    return t.getFullYear()+'-'+ssPad(t.getMonth()+1)+'-'+ssPad(t.getDate());
  }

  function ohEnter(){   // 메뉴 진입 — 기간 기본값 → 첫 진입이면 자동 조회
    slsInit();
    if(!_ohSales.length && !_ohShip.length){ slsLoadDone(); ohQuery(); }
  }
  function ohTab(t){
    _ohTab=t;
    document.querySelectorAll('#ohTabs .ctab').forEach(function(b){ b.classList.toggle('on', b.getAttribute('data-t')===t); });
    ohRender();
  }
  // ①탭 출고장 줄 클릭 → ②(품목)탭으로 드릴다운. 그 출고장만 펼치고 나머지는 접는다
  //   — '차이'가 어느 품목 때문인지 한 클릭에 보이게(2026-07-22 요청).
  //   출고장이 7곳뿐이라 접힌 머리행이 전부 1페이지에 들어와 대상이 항상 바로 보인다.
  function ohDrill(k){
    k=decodeURIComponent(k);
    _ohAllCol=true; _ohCol={}; _ohCol['i:'+k]=false;
    ohTab('item');
  }
  function ohToggleAll(){
    _ohAllCol=!_ohAllCol; _ohCol={}; _ohUpdAllBtn(); ohRender();   // 표시행이 통째로 바뀌므로 처음 18행부터 다시
  }
  function _ohUpdAllBtn(){ var b=document.getElementById('ohAllBtn'); if(b) b.innerHTML=_ohAllCol?'⊞ 전체 펼치기':'⊟ 전체 접기'; }
  // 접기/펼치기 — 키에 탭 접두사를 붙여 ②(i:)와 ④(s:/b:)가 서로 간섭하지 않게 한다
  function _ohIsCol2(k, def){ return (k in _ohCol) ? _ohCol[k] : def; }
  function ohGrp(k){
    k=decodeURIComponent(k);
    var def = (k==='dtsec')         ? true            // ①탭 일자별 구획 = 기본 접힘
            : (k.indexOf('gq:')===0)? true            // ⑤탭 품목 하위(출고 원본행) = 기본 접힘
            : (k.indexOf('b:')===0) ? true            // 사업장 하위(원본행) = 기본 접힘
            : (/^d\d*:/.test(k))    ? false           // 물류센터 묶음(d:①/d2:②/d3:③/d4:④) = 기본 펼침 (_ohAllCol 영향 안 받음)
            : _ohAllCol;
    _ohCol[k] = !_ohIsCol2(k, def);
    _ohKeepScroll(ohRender);   // ★접기/펼치기 후 화면이 맨 위로 튀지 않게 (2026-07-27 지적)
  }
  /* 접기/펼치기는 표를 innerHTML 로 통째로 다시 그린다(lzMount) → #ohWrap 의 scrollTop 이 0으로 초기화되면서
     보고 있던 줄이 화면 밖으로 사라진다. 그래서 위치를 저장했다가 되돌린다.
      · 다시 그리면 앞 N행만 붙고 나머지는 스크롤할 때 채워지므로(lzFill), 저장한 위치가 보일 만큼 먼저 채운다.
      · 페이지 자체 스크롤(window)도 함께 되돌린다 — 표 높이가 바뀌면 페이지가 밀릴 수 있다. */
  function _ohKeepScroll(fn){
    var w=document.getElementById('ohWrap');
    var top=w?w.scrollTop:0, winY=(window.pageYOffset||document.documentElement.scrollTop||0);
    fn();
    w=document.getElementById('ohWrap');
    if(w){
      for(var g=0; w._lz && w._lz.from<w._lz.list.length && w.scrollHeight < top+w.clientHeight && g<400; g++) lzFill(w);
      w.scrollTop=top;
    }
    if(winY) window.scrollTo(0, winY);
  }
  function _ohIsCol(k){ return _ohIsCol2('i:'+k, _ohAllCol); }

  // 정산(TBL_SALES_MST) + 출고내역(TBL_SHIPOUT_MST) 동시 조회
  function ohQuery(){
    var f=(document.getElementById('slsFrom')||{}).value||'', t=(document.getElementById('slsTo')||{}).value||'';
    var ic=((document.getElementById('slsItemCd')||{}).value||'').trim();
    var sum=document.getElementById('ohSum'); if(sum) sum.textContent='조회 중…';
    qBusy('ohWrap','ohPager','정산서와 출고내역을 맞춰 보는 중입니다…');
    var post=function(url, body){
      return fetch(KONET_CTX+''+url, { method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:body })
        .then(function(r){ return r.json(); }).then(function(j){ return (j&&j.data)||[]; });
    };
    /* 출고장은 서버에 넘기지 않고 화면에서 거른다 —
       ①묶음('G:오산센터')은 서버가 모르는 개념이고
       ②DC_NM 표기가 두 표에서 다르다('평택' vs '평택물류센터'). 양쪽을 같은 규칙(_ohDcHit)으로 걸러야 어긋나지 않는다. */
    var pSales=post('/sales/selectSalesMst.do',
      'dlvDtFrom='+encodeURIComponent(f)+'&dlvDtTo='+encodeURIComponent(t)+'&itemCd='+encodeURIComponent(ic));
    /* 출고내역은 SHPOUT_DT 로만 조회되므로 넉넉히 읽어 아래에서 DLV_DT 로 재필터한다.
       ★창 밖으로 벗어난 행은 '경고 없이' 빠지고 화면은 그대로 '일치'로 보인다 —
         이 화면에서 가장 나쁜 실패 방식이라, 감지 로직을 붙이는 대신 창을 한 달로 넓혔다(2026-07-22).
         실측 편차는 0일(1,312행)·-1일(41행)뿐이지만 여유를 크게 두는 쪽이 안전하다.
       (자료가 몇 년치 쌓여 응답이 무거워지면 서버에서 DLV_DT 로 거르도록 바꿔야 한다 — WAR 재빌드) */
    var OH_WIN=31;
    var pShip = (f && t)
      ? post('/shipout/selectShipoutMst.do', 'shpoutDtFrom='+encodeURIComponent(_ohShift(f,-OH_WIN))+'&shpoutDtTo='+encodeURIComponent(_ohShift(t,OH_WIN)))
      : post('/shipout/selectShipoutMst.do', '');
    /* 판매전표(직접판매) — 정산서 밖에서 직접 판 건. 서버가 정산서 행과 같은 모양으로 준다(2026-07-25 요청).
       출고장이 아니라 '직접판매(전표)' 라는 별도 묶음으로 서고, trxYn='Y' 표시가 붙어 온다.
       그 표시가 있으면 _ohKey 가 대사키를 만들지 않는다 — 출고 자료에 짝이 있을 수 없어서
       그냥 넣으면 전부 '출고미상'(빨간 경고)으로 잡히기 때문. */
    var pTrx=post('/mangr/salesTrxHist.do',
      'fromDt='+encodeURIComponent(f)+'&toDt='+encodeURIComponent(t)+'&findData='+encodeURIComponent(ic))
      .catch(function(){ return []; });
    Promise.all([pSales, pShip, pTrx]).then(function(a){
      var fY=_ohYmd(f), tY=_ohYmd(t), icQ=ic.toLowerCase();
      _ohSalesAll=(a[0]||[]).concat(a[2]||[]);
      _ohShipAll=(a[1]||[]).filter(function(r){
        var d=_ohYmd(r.dlvDt)||_ohYmd(r.shpoutDt);
        if(fY && tY && (d<fY || d>tY)) return false;
        if(icQ && (''+(r.itemCd||'')).toLowerCase().indexOf(icQ)<0
               && (''+(r.itemNm||'')).toLowerCase().indexOf(icQ)<0) return false;
        return true;
      });
      ohDcApply();   // 출고장 선택 반영 + 드롭다운 목록 갱신 + 렌더
    }).catch(function(e){ qFail('ohWrap','조회 오류 — '+_cesc(e.message)); ssToast('⚠️ 조회 오류: '+e.message); });
  }
  function slsQuery(){ ohQuery(); }   // 저장 직후 재조회 (기존 호출부 유지)

  // 출고장 → {정산 합계, 출고 합계} 로 접어 담기 (탭 공통 소스)
  function _ohRoll(){
    var m={}, ord=[];
    var pick=function(r0, nm){
      var k=_ohDcOf(r0)||'(출고장 미지정)';
      // 라벨은 통일키(평택), 원래 표기(평택/평택물류센터)는 hover 로 남긴다
      // sKeys/oKeys = 대사키 집합. 수량 합계만 보면 '정산에만 5개 + 출고에만 5개'가 상쇄돼
      //               차이 0 = 일치 로 오진하므로, 짝 없는 키를 따로 센다.
      if(!m[k]){ m[k]={ dc:k, label:k, raw:{}, sRows:0, sQty:0, sAmt:0, oRows:0, oQty:0, eQty:0, eAmt:0,
                        items:{}, itemOrd:[], sKeys:{}, oKeys:{}, sOnly:0, oOnly:0 }; ord.push(k); }
      if(nm) m[k].raw[nm]=1;
      return m[k];
    };
    var item=function(g, cd, nm){
      var k=cd||'(품목코드 없음)';
      /* dts = 납품일자별 낟알 { '20260722':{oQty,sQty,price} } — ②탭에서 '어느 날짜 자료인지'를 보이려고 담는다.
         (2026-08-02 요청: 기간을 며칠로 잡으면 합산돼 어디까지가 22일인지 알 수 없었다) */
      if(!g.items[k]){ g.items[k]={ itemCd:k, itemNm:nm||'', sQty:0, sAmt:0, oQty:0, eQty:0, eAmt:0, price:null, dts:{} }; g.itemOrd.push(k); }
      var it=g.items[k]; if(!it.itemNm && nm) it.itemNm=nm; return it;
    };
    _ohSales.forEach(function(r){
      var g=pick(r, r.dcNm); g.sRows++; g.sQty+=(+r.outQty||0); g.sAmt+=(+r.saleAmt||0);
      if(r.trxYn==="Y") g.trx=true;   // 직접판매 묶음 표시 — 대사 대상이 아니라는 뜻
      var kk=_ohKey(r); if(kk) g.sKeys[kk]=1;
      var it=item(g, r.itemCd, r.itemNm); it.sQty+=(+r.outQty||0); it.sAmt+=(+r.saleAmt||0);
      (function(){ var d=_ohYmd(r.dlvDt)||'', e=it.dts[d]||(it.dts[d]={oQty:0,sQty:0,price:null});
                   e.sQty+=(+r.outQty||0); if(e.price==null && r.salePrice!=null) e.price=+r.salePrice; })();
      it.sRows=(it.sRows||0)+1;   // [⑤차이탭] '정산서가 온 품목'인지 판정용 — 수량이 0인 정산행도 온 것으로 본다
      if(it.price==null && r.salePrice!=null) it.price=+r.salePrice;
    });
    /* ★정산서가 아직 안 온 출고의 매출금액 — 마감관리와 같은 방식으로 채운다(2026-07-25 요청).
         · 대상 = 대사키가 정산서에 없는 출고행(= 미정산). 키가 아예 안 서는 행(일자·출고장·품목 중 빈칸)도 포함.
         · 금액 = 출고수량 × saleUnit. saleUnit 은 서버가 selectClosing 과 똑같은 규칙으로 붙여 준다
           (판매단가 이력 APPLY_DT ≤ 납품일자 공통가 최신 → 없으면 상품마스터 SALE_PRICE).
         · 정산서가 온 건은 손대지 않는다 — 그건 실제 '받을 금액'이고 이건 추정이다. 구분은 상태 칸(미정산 뱃지).
       ※ 위 _ohSales 루프가 먼저 돌아 g.sKeys 가 이미 다 차 있으므로 여기서 바로 판정할 수 있다. */
    _ohShip.forEach(function(r){
      var g=pick(r, r.dcNm); g.oRows++; g.oQty+=(+r.curQty||0);
      var kk=_ohKey(r); if(kk) g.oKeys[kk]=1;
      var it=item(g, r.itemCd, r.itemNm), q=(+r.curQty||0);
      it.oQty+=q;
      (function(){ var d=_ohYmd(r.dlvDt)||'', e=it.dts[d]||(it.dts[d]={oQty:0,sQty:0,price:null});
                   e.oQty+=q; if(e.price==null && r.saleUnit) e.price=+r.saleUnit; })();
      if(!kk || !g.sKeys[kk]){
        var u=(+r.saleUnit||0), amt=q*u;
        g.eQty+=q; g.eAmt+=amt; it.eQty+=q; it.eAmt+=amt;
        if(it.price==null && u) it.price=u;   // 정산단가가 없으면 추정단가라도 보여준다
      }
    });
    // 짝 없는 대사키 집계 — oOnly=보냈는데 청구 안 됨(미정산) / sOnly=보낸 적 없는데 청구됨(출고미상)
    ord.forEach(function(k){
      var g=m[k];
      Object.keys(g.sKeys).forEach(function(x){ if(!g.oKeys[x]) g.sOnly++; });
      Object.keys(g.oKeys).forEach(function(x){ if(!g.sKeys[x]) g.oOnly++; });
    });
    return ord.sort(function(a,b){ return a.localeCompare(b,'ko'); }).map(function(k){ return m[k]; });
  }
  function _ohDateFmt(d){ d=''+(d==null?'':d); return d.length===8 ? d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8) : d; }
  /* 일자(납품일자 DLV_DT) → 출고장 로 접어 담기 — ①탭 '일자별' 구획 소스.
       _ohRoll 과 같은 규칙(대사키 date|dc|item 이 이미 날짜 포함)이라 날짜로 한 겹 더 나눠도 미정산/출고미상이 일관.
       ※ 납품일자 없는 행(키없음)은 날짜 배치가 안 되므로 이 구획에서 빠진다 → 일자합 총합 ≤ 총합계(정상). */
  function _ohRollByDate(){
    var dm={};
    var pick=function(r0, nm){
      var d=_ohYmd(r0 && r0.dlvDt) || '';
      var k=_ohDcOf(r0)||'(출고장 미지정)';
      if(!dm[d]) dm[d]={ date:d, m:{}, ord:[] };
      var D=dm[d];
      if(!D.m[k]){ D.m[k]={ dc:k, label:k, raw:{}, sRows:0,sQty:0,sAmt:0, oRows:0,oQty:0, eQty:0,eAmt:0, sKeys:{}, oKeys:{}, sOnly:0, oOnly:0 }; D.ord.push(k); }
      if(nm) D.m[k].raw[nm]=1;
      return D.m[k];
    };
    _ohSales.forEach(function(r){ var g=pick(r, r.dcNm); g.sRows++; g.sQty+=(+r.outQty||0); g.sAmt+=(+r.saleAmt||0);
      if(r.trxYn==='Y') g.trx=true; var kk=_ohKey(r); if(kk) g.sKeys[kk]=1; });
    _ohShip.forEach(function(r){ var g=pick(r, r.dcNm); g.oRows++; g.oQty+=(+r.curQty||0); var kk=_ohKey(r); if(kk) g.oKeys[kk]=1;
      if(!kk || !g.sKeys[kk]){ var q=(+r.curQty||0); g.eQty+=q; g.eAmt+=q*(+r.saleUnit||0); }   // 미정산 = 추정매출(위 _ohRoll 과 같은 규칙)
    });
    var dates=Object.keys(dm).filter(function(d){ return d; }).sort().reverse();   // YYYYMMDD 최근순
    return dates.map(function(d){
      var D=dm[d];
      var kids=D.ord.sort(function(a,b){ return a.localeCompare(b,'ko'); }).map(function(k){
        var g=D.m[k];
        Object.keys(g.sKeys).forEach(function(x){ if(!g.oKeys[x]) g.sOnly++; });
        Object.keys(g.oKeys).forEach(function(x){ if(!g.sKeys[x]) g.oOnly++; });
        return g;
      });
      var tot={ oRows:0,oQty:0,sRows:0,sQty:0,sAmt:0,eQty:0,eAmt:0,sOnly:0,oOnly:0 };
      kids.forEach(function(g){ tot.oRows+=g.oRows; tot.oQty+=g.oQty; tot.sRows+=g.sRows; tot.sQty+=g.sQty; tot.sAmt+=g.sAmt; tot.eQty+=g.eQty; tot.eAmt+=g.eAmt; tot.sOnly+=g.sOnly; tot.oOnly+=g.oOnly; });
      return { date:d, kids:kids, tot:tot };
    });
  }
  // 발주번호+항번 → 상대편 행 (상세 2탭의 대사 열). a=정산금액(정산서 인덱스일 때만 값이 있다)
  function _ohIndex(rows, qtyField){
    var m={}; rows.forEach(function(r){
      var k=_ohKey(r); if(!k) return;
      var e=m[k] || (m[k]={n:0,q:0,a:0,r:r});
      e.n++; e.q+=(+r[qtyField]||0); e.a+=(+r.saleAmt||0);
    });
    return m;
  }
  /* 출고장 ▸ 사업장 ▸ 출고원본행 3단 — ③탭 전용. 출고수량만 다루고 금액은 얹지 않는다.
       ★사업장별 정산금액은 만들지 않는다(2026-07-22 사용자 확정).
         정산서는 '발주' 단위, 출고는 '발주 × 사업장' 단위라 1:N —
         실측 572행이 발주번호+항번 352개(정산서는 105행=105키 1:1).
         정산서에 사업장 칸이 없으니 사업장으로 쪼개면 어떤 방식이든 추정이 된다.
         → 금액은 ①②(출고장·품목 단위)에서만 보고, 여기서는 '대사 상태'만 사실로 표시. */
  function _ohRollBiz(){
    var idx=_ohIndex(_ohSales,'outQty'), m={}, ord=[];
    _ohShip.forEach(function(r){
      var dk=_ohDcOf(r)||'(출고장 미지정)';
      var g=m[dk]; if(!g){ g=m[dk]={ dc:dk, label:dk, oRows:0, oQty:0, hit:0, noKey:0, unpaid:0, bizOrd:[], biz:{} }; ord.push(dk); }
      var bnm=(''+(r.bizNm||'')).trim()||'(사업장 미지정)', bk=(''+(r.bizCd||''))+'|'+bnm;
      var b=g.biz[bk]; if(!b){ b=g.biz[bk]={ key:bk, bizCd:r.bizCd||'', bizNm:bnm, rows:[], oQty:0, hit:0, noKey:0, unpaid:0 }; g.bizOrd.push(bk); }
      var k=_ohKey(r), hit=k?!!idx[k]:false, oq=(+r.curQty||0);
      b.rows.push({ r:r, hit:hit, k:k });
      b.oQty+=oq; g.oQty+=oq; g.oRows++;
      if(hit){ b.hit++; g.hit++; } else if(!k){ b.noKey++; g.noKey++; } else { b.unpaid++; g.unpaid++; }
    });
    ord.sort(function(a,b){ return a.localeCompare(b,'ko'); });
    ord.forEach(function(k){ m[k].bizOrd.sort(function(a,b){ return m[k].biz[a].bizNm.localeCompare(m[k].biz[b].bizNm,'ko'); }); });
    return ord.map(function(k){ return m[k]; });
  }
  
  // 대사 상태 요약 — 건수만(금액 아님). noKey 는 세 칸 중 하나가 빈 이상행(실측 0건)
  function _ohStat(o){
    return (o.hit  ? ' <span style="font-weight:700;color:#137a6c">대사 '+o.hit+'</span>' : '')
         + (o.unpaid ? ' <span style="font-weight:700;color:#c0392b">· 미정산 '+o.unpaid+'</span>' : '')
         + (o.noKey  ? ' <span style="font-weight:600;color:#9aa7b3">· 키없음 '+o.noKey+'</span>' : '');
  }

  /* 탭별 원천 — 요약줄 맨 앞에 칩으로 붙인다(전용 줄을 두면 상단이 무거워짐. 자세한 건 탭 버튼 hover).
     ①②는 정산서 기준이 아니라 양쪽 합집합이다(한쪽만 있어도 줄이 생겨야 '정산 미도착'을 잡는다). */
  var OH_DESC={ dc:'정산서 ∪ 출고내역', item:'정산서 ∪ 출고내역 · 품목축', gap:'정산서 온 품목 · 수량 불일치만', ship:'출고내역 · 사업장축', settle:'정산서 단독' };
  function _ohSrcChip(){
    return '<span style="display:inline-block;padding:1px 8px;margin-right:6px;border-radius:999px;background:#eaf3f1;color:#137a6c;font-size:11.5px;font-weight:700"'
      + ' title="이 탭이 어느 표에서 줄을 가져오는지. 자세한 설명은 탭 이름에 마우스를 올려 보세요.">'+(OH_DESC[_ohTab]||'')+'</span>';
  }
  /* 같은 대사키에 '단가가 다른 정산서 행'이 섞였는지 감지 (2026-07-25 요청).
       대사키는 납품일자+출고장+품목이라 그 안에 발주가 여러 건 들어올 수 있다. 발주별 단가가 같으면
       마감의 사업장별 안분(출고수량 비율)이 발주 단위로 나눈 것과 똑같아서 문제가 없다.
       단가가 다른 순간부터 안분이 틀어지므로, 그 조건이 생기면 알려만 준다.
       ※ 2026-07 실측 = 0건. 발주키로 대사를 바꾸는 대신 이 감지를 두기로 확정
         (발주번호는 출고 자료의 10%가 비어 있어 대사키로 쓰면 매칭률이 88%→82%로 떨어진다). */
  function _ohPriceMix(){
    var m={}, hit=[], amt=0;
    _ohSales.forEach(function(r){
      var k=_ohKey(r); if(!k) return;
      var e=m[k] || (m[k]={ p:{}, amt:0, r:r });
      e.p[''+(+r.salePrice||0)]=1; e.amt+=(+r.saleAmt||0);
    });
    Object.keys(m).forEach(function(k){
      var e=m[k]; if(Object.keys(e.p).length<2) return;
      hit.push({ k:k, r:e.r, amt:e.amt, prices:Object.keys(e.p) }); amt+=e.amt;
    });
    hit.sort(function(a,b){ return b.amt-a.amt; });
    return { n:hit.length, amt:amt, list:hit };
  }
  function _ohMixNote(){
    var x=_ohPriceMix(); if(!x.n) return '';
    var tip='같은 대사키(납품일자+출고장+품목)에 단가가 서로 다른 정산서 행이 섞였습니다.\n'
      +'이 경우 매출마감의 사업장별 안분(출고수량 비율)이 발주 단위로 나눈 값과 달라집니다.\n'
      +'총액·출고장별 금액은 영향이 없고, 사업장별 배분만 어긋납니다.\n\n금액 큰 순:\n';
    x.list.slice(0,5).forEach(function(o){
      var p=o.k.split('|');
      tip += '· '+_ohDateFmt(p[0])+' '+p[1]+' '+(o.r.itemNm||p[2])+' — 단가 '+o.prices.join(' / ')+' · '+_cnum(o.amt)+'원\n';
    });
    if(x.n>5) tip += '… 외 '+(x.n-5)+'건';
    return ' · <span style="color:#c47f17;font-weight:700" title="'+_cesc(tip)+'">⚠ 키당 단가 혼재 '+x.n+'건 · '+_cnum(x.amt)+'원</span>';
  }
  function ohRender(){
    var wrap=document.getElementById('ohWrap'), sum=document.getElementById('ohSum'), pg=document.getElementById('ohPager');
    if(!wrap) return;
    // ⊟ 전체 접기 — 그룹이 있는 탭에서만. ④(settle)도 출고장별 묶음이 생겼으므로 포함(2026-07-22)
    //   빠뜨리면 그룹은 접힌 채인데 펼칠 수단이 없어진다
    // 접기 버튼은 트리가 있는 탭에서만 — ①(1단만)·⑤(평면 목록)에는 접을 것이 없다
    var btn=document.getElementById('ohAllBtn'); if(btn) btn.style.display=(_ohTab==='dc'||_ohTab==='gap')?'none':'';
    _ohUpdAllBtn();   // 라벨(접기/펼치기)이 현재 상태와 어긋나지 않게 매 렌더마다 맞춘다
    if(!_ohSales.length && !_ohShip.length){
      sum.innerHTML=_ohSrcChip()+'조회된 자료가 없습니다. (정산 엑셀 저장분·발주현황표 출고 모두 없음)';
      wrap.innerHTML=''; wrap._lz=null; if(pg) pg.innerHTML=''; return;   // 남아있던 '더 붙일 행'도 함께 버린다
    }
    /* sQ/sA = 정산수량·정산금액(직접판매 포함).
       tQ/tA = 그중 직접판매(전표)분. 수량차이는 대사 대상만 봐야 하므로 sQ 에서 tQ 를 뺀 값으로 잰다
       — 안 그러면 전표를 넣는 순간 없던 '수량차이'가 생긴 것처럼 보인다(2026-07-25). */
    var sQ=0,sA=0,oQ=0,noKey=0,tQ=0,tA=0,tRows=0;
    _ohSales.forEach(function(r){
      sQ+=(+r.outQty||0); sA+=(+r.saleAmt||0);
      if(r.trxYn==='Y'){ tQ+=(+r.outQty||0); tA+=(+r.saleAmt||0); tRows++; }
    });
    _ohShip.forEach(function(r){ oQ+=(+r.curQty||0); if(!_ohKey(r)) noKey++; });
    var gapQ = (sQ - tQ) - oQ;   // 대사용 수량차이 = 정산 − 출고 (2026-08-02 확정). 직접판매는 빼고 잰다
    var G=_ohRoll();
    var eA=0; G.forEach(function(g){ eA+=(+g.eAmt||0); });   // 정산서 안 온 출고의 추정매출 합
    sum.innerHTML=_ohSrcChip()+'출고장 <b>'+G.length+'</b>곳 · 출고내역 <b>'+_ohShip.length.toLocaleString()+'</b>행/<b>'+_ohQ(oQ)+'</b>'
      +' · 정산 <b>'+_ohSales.length.toLocaleString()+'</b>행/<b>'+_ohQ(sQ)+'</b>'
      +' · <span style="color:#137a6c">정산금액 <b>'+_cnum(sA+eA)+'</b></span>'
      +(eA?' <span style="color:#a85700" title="정산서가 아직 안 온 출고를 판매단가(마감관리와 같은 규칙)로 채운 금액입니다.">(정산 '+_cnum(sA)+' + 추정 '+_cnum(eA)+')</span>':'')
      +(tRows ? ' · <span style="color:#1a73c7;font-weight:700" title="판매등록으로 직접 입력한 매출. 출고장 대사 대상이 아니라 수량차이 계산에서 빠집니다.">직접판매 '+tRows.toLocaleString()+'행/'+_cnum(tA)+'</span>' : '')
      +(Math.abs(gapQ)>1e-6 ? ' · <span class="oh-gap">수량차이 '+_ohQ(gapQ)+'</span>' : ' · <span class="oh-ok">수량 일치</span>')
      // 짝 없는 대사키 — 수량이 상쇄돼 '일치'로 보일 수 있으므로 건수를 따로 띄운다
      +(function(){ var so=0,oo=0; G.forEach(function(g){ so+=g.sOnly; oo+=g.oOnly; });
          return (oo?' · <span style="color:#c0392b;font-weight:700" title="보냈는데 정산서에 없는 품목(청구 누락 후보)">미정산 '+oo+'품목</span>':'')
               + (so?' · <span style="color:#a85700;font-weight:700" title="정산서에는 있는데 출고내역에 없는 품목">출고미상 '+so+'품목</span>':'')
               + ((!oo&&!so&&_ohSales.length&&_ohShip.length)?' · <span class="oh-ok">품목 전건 대사</span>':''); })()
      +(noKey ? ' · <span style="color:#c47f17;font-weight:700" title="납기일자·출고장·품목코드 중 빈 칸이 있어 대사키가 서지 않는 출고행입니다.">키 없는 출고 '+noKey.toLocaleString()+'행</span>' : '')
      +(!_ohShip.length && _ohSales.length ? ' · <span style="color:#c47f17;font-weight:700">이 기간 출고내역(발주현황표) 자료가 없습니다</span>' : '')
      +_ohMixNote();
    if(_ohTab==='dc')          _ohRenderDc(G, wrap, oQ, sQ, sA);
    else if(_ohTab==='item')   _ohRenderItem(G, wrap, oQ, sQ, sA);
    else if(_ohTab==='gap')    _ohRenderGap(G, wrap);
    else if(_ohTab==='settle') _ohRenderSettle(wrap, sQ, sA);
    else                       _ohRenderShip(wrap, oQ);
  }

  /* ⑤ 수량차이 품목 (2026-07-27 요청) — "정산서 온 것 기준으로, 출고수량과 정산수량이 다른 품목".
       ①②의 트리에 필터를 걸면 소계가 필터 전/후로 갈려 읽기 나빠지므로, 별도 탭에 평면 목록으로 뽑는다.
       ★대상 기준 = <정산서에 온 품목>(it.sRows>0). "정산서 온 것만 대사" (2026-07-27 사용자 확정).
         · 정산서에 아예 없는 품목은 대사 대상이 아니다 → 목록에 넣지 않는다.
           (그건 '차이'가 아니라 청구가 안 된 것 = 미정산. ①탭 상태 칸에서 본다.)
         · 다만 몇 건이 그렇게 빠졌는지는 총합계 줄에 숫자로만 알려 준다 — 조용히 빠지면 다 본 줄 알기 때문.
       정렬 = 차이 절대값 큰 순. 부호로 방향을 구분한다.
         · +  출고 > 정산 = 보냈는데 청구가 덜 됐다(청구 누락 후보)
         · −  정산 > 출고 = 청구가 더 됐다(과청구·출고기록 누락 후보)                          */
  /* ★[미정산 같이 보기] (2026-07-28 요청) — 기본은 끔.
       켜면 <정산서에 없는 품목>(=미정산)까지 같은 표에 회색·호박색으로 섞어 보여 준다.
       · 이때는 **정산서가 통째로 안 온 출고장**까지 훑는다 — 미정산은 거기 몰려 있기 때문이다.
       · 미정산 줄은 '차이'가 아니므로 (정산 많음 · 출고 많음) 건수에는 넣지 않는다. 따로 센다.
       · 제외 건수(skipNB)는 켜고 끄고에 상관없이 **항상 전체 기준**으로 센다 — 안 그러면 같은 화면에서
         숫자가 오락가락한다(종전엔 정산서 온 출고장 안에서만 세어 실제보다 적게 나왔다). */
  var _ohGapNB=false;
  function ohGapNB(){ _ohGapNB=!_ohGapNB; ohRender(); }
  /* ②탭 [일자별로 나누기] (2026-08-02 요청) — 기본 끔(종전 화면 = 품목 단위 집계 유지) */
  var _ohItemByDate=false;
  function ohItemByDate(){ _ohItemByDate=!_ohItemByDate; ohRender(); }

  function _ohRenderGap(G, wrap){
    /* ★수량차이 = <정산수량 − 출고수량> (2026-07-27 사용자 확정). 정산서 기준 탭이라 정산서를 앞에 둔다.
         ①②③탭은 반대(출고−정산)라 부호가 뒤집혀 보인다 — 이 탭은 정산서 기준이라는 뜻이므로 헷갈리지 않게
         컬럼도 '정산수량 → 출고수량' 순으로 놓고, 머리글·툴팁에 계산식을 적어 둔다.
           +  정산 > 출고 = 청구가 더 됐다(과청구·출고기록 누락 후보)
           −  출고 > 정산 = 보냈는데 청구가 덜 됐다(청구 누락 후보) */
    var rows=[], tO=0, tS=0, sMore=0, oMore=0, skipNB=0, dcN=0, nbN=0;
    G.forEach(function(g){
      var hasS=(g.sRows>0);                                        // 이 출고장에 정산서가 왔는가
      if(hasS) dcN++;
      g.itemOrd.forEach(function(k){
        var it=g.items[k];
        var d=(+it.sQty||0)-(+it.oQty||0);                         // 정산수량 − 출고수량
        if(Math.abs(d)<=0.0001) return;                            // 수량이 맞는 품목 제외
        if(!(it.sRows>0)){                                         // 정산서에 없는 품목 = 미정산(대사 대상 아님)
          skipNB++;                                                //   전체 기준으로 항상 센다
          if(!_ohGapNB) return;                                    //   [미정산 같이 보기] 꺼져 있으면 여기까지
          nbN++;
          rows.push({ dc:g.label, it:it, d:d, nb:true });
          tO+=(+it.oQty||0); tS+=(+it.sQty||0);
          return;
        }
        if(!hasS) return;                                          // 방어 — 정산행이 있으면 hasS 가 참이어야 한다
        rows.push({ dc:g.label, it:it, d:d });
        tO+=(+it.oQty||0); tS+=(+it.sQty||0);
        if(d>0) sMore++; else oMore++;
      });
    });
    /* [통합해서 본 것도 표시] 총합계(전체) → 출고장별 소계 → 그 출고장의 차이 품목.
         차이가 큰 출고장부터, 그 안에서도 차이가 큰 품목부터 나온다. */
    var gm={}, gs=[];
    rows.forEach(function(r){
      var e=gm[r.dc];
      if(!e){ e=gm[r.dc]={ dc:r.dc, its:[], oQty:0, sQty:0, d:0, nb:0 }; gs.push(e); }
      e.its.push(r); e.oQty+=(+r.it.oQty||0); e.sQty+=(+r.it.sQty||0); e.d+=r.d;
      if(r.nb) e.nb++;
    });
    gs.forEach(function(e){ e.its.sort(function(a,b){ return Math.abs(b.d)-Math.abs(a.d); }); });
    gs.sort(function(a,b){ return Math.abs(b.d)-Math.abs(a.d) || String(a.dc).localeCompare(String(b.dc),'ko'); });
    /* 품목 줄을 누르면 그 아래에 <출고 원본행>을 펼친다(다시 누르면 접힘) — 눈으로 대사하기 위한 것.
         같은 주문번호(JUMUN_NO)가 출고일자 두 곳에 걸쳐 있으면 재저장 후보라 배지로 표시한다.
         출고 조회가 이미 ordNo·jumunNo·zone·inwh·bizCd·srcFile 을 주므로 서버 변경 없이 만들 수 있다. */
    var list=[];
    gs.forEach(function(e){
      list.push({ t:'g', e:e });
      e.its.forEach(function(r){
        var key='gq:'+r.dc+'|'+r.it.itemCd;
        var col=_ohIsCol2(key, true);
        list.push({ t:'it', r:r, key:key, col:col });
        if(col) return;
        // 정산서 원본행 먼저 — 납기일자(DLV_DT)·출고일자(OUT_DT)를 보여 출고 쪽 날짜와 나란히 대사한다(2026-07-27 요청)
        var sraw=_ohSales.filter(function(x){ return (_ohDcOf(x)||'(출고장 미지정)')===r.dc && (''+(x.itemCd||''))===r.it.itemCd; });
        sraw.sort(function(a,b){ return String(a.dlvDt||'').localeCompare(String(b.dlvDt||'')) || String(a.ordNo||'').localeCompare(String(b.ordNo||'')); });
        sraw.forEach(function(x){ list.push({ t:'sraw', x:x }); });
        var raw=_ohShip.filter(function(x){ return (_ohDcOf(x)||'(출고장 미지정)')===r.dc && (''+(x.itemCd||''))===r.it.itemCd; });
        raw.sort(function(a,b){ return String(a.shpoutDt||'').localeCompare(String(b.shpoutDt||'')) || String(a.zone||'').localeCompare(String(b.zone||'')); });
        var jm={};   // 주문번호별 출고일자 집합 — 2개 이상이면 재저장 후보
        raw.forEach(function(x){ var j=(''+(x.jumunNo||'')).trim(); if(!j) return; (jm[j]=jm[j]||{})[(''+(x.shpoutDt||''))]=1; });
        raw.forEach(function(x){
          var j=(''+(x.jumunNo||'')).trim();
          list.push({ t:'raw', x:x, dup:!!(j && Object.keys(jm[j]||{}).length>1) });
        });
        if(!raw.length) list.push({ t:'none' });
      });
    });

    var RED='color:#c0392b;font-weight:800';
    var h='<table class="logi-tb"><thead><tr><th>출고장</th><th>품목코드</th><th>품목명</th>'
        +'<th style="text-align:right">정산수량</th><th style="text-align:right">출고수량</th>'
        +'<th style="text-align:right" title="정산수량 − 출고수량&#10;+ 정산이 많음 = 청구가 더 됨(과청구·출고기록 누락 후보)&#10;− 출고가 많음 = 보냈는데 청구가 덜 됨(청구 누락 후보)">수량차이<br><span style="font-weight:400;font-size:10.5px">정산−출고</span></th>'
        +'<th style="text-align:right">판매단가</th>'
        +'<th style="text-align:right" title="정산서 금액 + 정산서가 안 온 출고의 추정매출(판매단가).">정산금액</th></tr></thead><tbody>';
    /* [미정산 같이 보기] 스위치 — 합계줄 안에 둔다(표 밖에 두면 페이저가 다시 그릴 때 사라진다) */
    var nbBtn = '<span onclick="ohGapNB()" title="'
      + (_ohGapNB ? '미정산 품목을 숨기고 수량차이만 봅니다'
                  : '정산서에 없는 품목(미정산)까지 같은 표에 섞어 봅니다 — 정산서가 아예 안 온 출고장도 포함')
      + '" style="cursor:pointer;user-select:none;font-weight:700;font-size:11.5px;'
      + 'border:1px solid rgba(255,255,255,.55);border-radius:6px;padding:1px 8px;margin-left:8px;'
      + (_ohGapNB ? 'background:#ffe9c9;color:#7a4b0a' : 'color:#ffe9c9') + '">'
      + (_ohGapNB ? '☑' : '☐') + ' 미정산 같이 보기'+(skipNB?(' '+skipNB+'건'):'')+'</span>';
    h+='<tr class="close-total"><td colspan="3">■ 차이 품목 '+(rows.length-nbN).toLocaleString()+'건'
      +((rows.length-nbN)?(' <span style="font-weight:600">(정산 많음 '+sMore+' · 출고 많음 '+oMore+' · 출고장 '+gs.length+'곳)</span>'):'')
      +(nbN?(' <span style="font-weight:700;font-size:11.5px;color:#ffe9c9">+ 미정산 '+nbN+'건</span>'):'')
      +' <span style="font-weight:600;font-size:11.5px">— 정산서 온 출고장 '+dcN+'곳'+(_ohGapNB?'':' · 정산서에 있는 품목만 대사')+'</span>'
      + nbBtn
      +(skipNB && !_ohGapNB ?('<br><span style="font-weight:600;font-size:11.5px;color:#ffe9c9">※ 정산서에 없는 품목 '+skipNB+'건은 대사 대상이 아니라 제외 — 위 [미정산 같이 보기] 또는 ①탭 상태 칸의 <b>미정산</b>에서 확인</span>'):'')
      +'</td>'
      +'<td style="text-align:right">'+_ohQ(tS)+'</td><td style="text-align:right">'+_ohQ(tO)+'</td>'
      +'<td style="text-align:right">'+_ohQ(tS-tO)+'</td><td></td><td></td></tr>';
    if(!rows.length){
      _ohMount(wrap, h+_ohEmptyRow(8, (dcN ? '수량이 어긋난 품목이 없습니다' : '이 기간 정산서 자료가 없습니다'),
        (dcN
          ? '정산서가 온 출고장 <b>'+dcN+'곳</b>에서 정산서에 있는 품목은 <b>출고수량과 정산수량이 모두 일치</b>합니다.'
            +(skipNB?('<br>정산서에 없는 품목 <b>'+skipNB+'건</b>은 대사 대상이 아니라 제외했습니다 — 위 <b>[미정산 같이 보기]</b>를 누르면 여기 같이 나옵니다(①탭 <b>미정산</b>과 같은 것).'):'')
          : '비교할 정산서가 없어 차이를 낼 수 없습니다.<br>정산 엑셀을 올린 뒤 다시 조회하거나, 정산서가 안 온 건은 ①탭 상태 칸에서 <b>미정산</b>으로 확인하세요.')), [], _ohIdent);
      return;
    }
    // 출고장 소계(통합) 줄 — 빨간색은 품목 줄에만 쓴다(2026-07-27 요청). 소계는 기본 색.
    var gRow=function(e){
      var up=e.d>0;
      return '<tr class="close-grp" style="cursor:default"><td colspan="3">🏭 '+_cesc(e.dc)
        +' <span style="font-weight:600;color:#5a6b7a">(차이 '+(e.its.length-e.nb)+'품목'
        +(e.nb?(' · <span style="color:#c47f17">미정산 '+e.nb+'품목</span>'):'')+')</span></td>'
        +'<td style="text-align:right">'+_ohQ(e.sQty)+'</td><td style="text-align:right">'+_ohQ(e.oQty)+'</td>'
        +'<td style="text-align:right">'+(up?'+':'')+_ohQ(e.d)+'</td><td></td><td></td></tr>';
    };
    // 품목 줄 — 여기만 빨간색. 누르면 아래에 출고 원본행이 펼쳐진다.
    var itRow=function(r, key, col){
      var it=r.it, up=r.d>0;
      /* ★미정산 줄은 **빨강이 아니라 호박색**으로 — '수량이 어긋난 것'과 '아직 청구가 안 된 것'은
           성격이 달라 같은 빨강으로 두면 대사할 것이 뒤섞여 보인다(2026-07-28). */
      var nb=!!r.nb, CLR=nb?'color:#c47f17;font-weight:700':RED;
      // ★펼치기/접기는 <화살표를 눌렀을 때만> 동작한다(2026-07-27 요청) — 줄 전체 클릭은 쓰지 않는다.
      //   품목명·수치를 마우스로 긁어 복사할 때 표가 접히거나 펼쳐지는 것을 막기 위한 것.
      return '<tr'+(nb?' style="background:#fffaf1"':'')+' title="'
        + (nb?'정산서에 이 품목이 없습니다 — 아직 청구가 안 된 것(미정산). 수량차이가 아닙니다'
            : up?'정산이 출고보다 많음 — 과청구·출고기록 누락 여부 확인':'출고가 정산보다 많음 — 청구 누락 여부 확인')+'">'
        + '<td class="txt-l" style="color:#8a95a1">'+_cesc(r.dc)+'</td>'
        + '<td style="'+CLR+'">'
        +   '<span onclick="event.stopPropagation();ohGrp(\''+encodeURIComponent(key)+'\')"'
        +   ' title="'+(col?'출고 원본행 펼치기':'출고 원본행 접기')+'"'
        +   ' style="'+(nb?'color:#c47f17':'color:#c0392b')+';cursor:pointer;display:inline-block;width:20px;text-align:center;'
        +   'user-select:none;-webkit-user-select:none">'+(col?'▶':'▼')+'</span> '
        +   _cesc(it.itemCd)+'</td>'
        // '펼치기/접기' 글자 배지는 제거(2026-07-27 요청) — 줄을 클릭하면 되고, 상태는 왼쪽 캐럿(▶/▼)으로 보인다
        + '<td class="txt-l" style="'+CLR+'">'
        +   (nb?'<span style="font-size:10.5px;border:1px solid #e3c08a;background:#fdf5e6;color:#7a4b0a;'
        +       'border-radius:9px;padding:1px 6px;margin-right:5px;font-weight:700">미정산</span> ':'')
        +   _cesc(it.itemNm)+'</td>'
        + '<td style="text-align:right">'+_ohQ(it.sQty)+'</td>'
        + '<td style="text-align:right">'+_ohQ(it.oQty)+'</td>'
        + '<td style="text-align:right;'+CLR+'">'+(up?'+':'')+_ohQ(r.d)+'</td>'
        + '<td style="text-align:right">'+(it.price==null?'':_cnum(it.price))+'</td>'
        + _ohAmtCell(it)+'</tr>';
    };
    /* 정산서 원본행.
         ★대사는 <납품일자>만 비교한다(2026-07-27 사용자 확정). 출고일자는 정산서(출고장이 적어 준 값)와
           우리 출고자료가 서로 다를 수 있다 — 특히 2026-07-28 이전 업로드분은 김해·제주에 '납기 2일 전'
           규칙이 적용돼 있었다(2026-07-29 폐지). 그래서 출고일자는 참고로만 회색·괄호로 두고,
           '날짜 다름' 같은 경고 표시는 붙이지 않는다(정상을 오류로 보이게 하므로).
         수량은 <정산수량 칸>에 놓아(출고행은 출고수량 칸) 어느 쪽 자료인지 위치로 구분된다.
         ※ 정산서에는 사업장·주문번호 칸이 없다(출고 자료에만 있음). */
    var srawRow=function(x){
      var ord=(''+(x.ordNo||'')).trim();
      return '<tr style="background:#f4fbf8">'
        + '<td></td>'
        + '<td colspan="2" class="txt-l" style="padding-left:26px;color:#137a6c;font-size:12.5px">'
        //   출고일자도 읽히게 진하게 둔다(2026-07-27) — 대사 기준은 아니지만 날짜 확인에 자주 본다.
        +   '↳ <b>정산서</b> · 납품일자 <b>'+_cesc(_ohDateFmt(x.dlvDt))+'</b>'
        +   ' <span style="color:#5a6b7a">(출고일자 <b>'+_cesc(_ohDateFmt(x.outDt))+'</b>)</span>'
        + '</td>'
        + '<td style="text-align:right;color:#137a6c;font-weight:700">'+_ohQ(x.outQty)+'</td>'
        + '<td></td>'
        + '<td colspan="3" class="txt-l" style="color:#9aa7b3;font-size:11.5px">'
        +   '발주 '+(ord?_cesc(ord):'<span style="color:#c47f17">없음</span>')
        +   (x.ordItemNo?('-'+_cesc(x.ordItemNo)):'')
        +   (x.ordQty!=null?(' · 발주량 '+_ohQ(x.ordQty)):'')
        +   (x.srcFile?(' · '+_cesc(x.srcFile)):'')
        + '</td></tr>';
    };
    /* 출고 원본행 — 무엇 때문에 차이가 났는지 눈으로 대사하는 줄.
         출고일자·차수 / 입고장·존·사업장 / 수량 / 발주번호·주문번호·원본파일.
         같은 주문번호가 출고일자 두 곳에 있으면 '중복 합산' 배지 — 이게 이중계상의 정체다.
         (날짜를 비교해서 붙이는 게 아니다 — 대사 기준은 납품일자뿐이라 출고일자 차이는 오류가 아니다.) */
    var rawRow=function(x, dup){
      var inwh=(''+(x.inwh||'')).trim(), zone=(''+(x.zone||'')).trim();
      var biz=(''+(x.bizNm||x.bizCd||'')).trim();
      var ord=(''+(x.ordNo||'')).trim(), jum=(''+(x.jumunNo||'')).trim();
      return '<tr style="background:#fcfdfe">'
        + '<td></td>'
        + '<td colspan="2" class="txt-l" style="padding-left:26px;color:#5a6b7a;font-size:12.5px">'
        //   ★대사 기준은 납품일자뿐이다. 출고일자는 참고 — 정산서의 출고일자와 다를 수 있고
        //     (2026-07-28 이전 김해·제주 조기출고 저장분 포함) 그것 자체는 오류가 아니다(회색 괄호로 둔다).
        +   '↳ <b>출고내역</b> · 납품일자 <b>'+_cesc(_ohDateFmt(x.dlvDt))+'</b>'
        +   ' <span style="color:#5a6b7a">(출고일자 <b>'+_cesc(_ohDateFmt(x.shpoutDt))+'</b>'+(x.jobSeq?(' '+x.jobSeq+'차'):'')+')</span>'
        +   (inwh?(' · 입고장 '+_cesc(inwh)):'')+(zone?(' · 존 '+_cesc(zone)):'')+(biz?(' · '+_cesc(biz)):'')
        /* ★배지 문구 주의(2026-07-27) — '재저장 의심'이라고 쓰니 "출고일자가 달라서 오류"로 읽혔다.
             출고일자 차이 자체는 오류가 아니다(대사 기준은 납품일자). 이 배지가 뜻하는 것은
             <같은 주문번호가 서로 다른 배치에 활성으로 남아 출고수량이 두 번 더해졌다>는 것뿐이다.
             그래서 날짜를 가리키지 않는 말('중복 합산')로 바꾸고, 툴팁에 이유를 적는다. */
        +   (dup?' <span title="같은 주문번호가 서로 다른 배치에 활성으로 남아 있어 출고수량이 두 번 더해졌습니다.&#10;'
                 +'※ 출고일자가 다른 것 자체는 오류가 아닙니다(대사 기준은 납품일자). 문제는 같은 주문이 두 번 저장된 것입니다."'
                 +' style="font-size:11px;font-weight:700;color:#c0392b;border:1px solid #f0c9c2;background:#fff7f6;border-radius:4px;padding:0 5px;cursor:help">중복 합산</span>':'')
        + '</td>'
        + '<td></td>'
        + '<td style="text-align:right;color:#37475a">'+_ohQ(x.curQty)+'</td>'
        + '<td colspan="3" class="txt-l" style="color:#9aa7b3;font-size:11.5px">'
        +   '발주 '+(ord?_cesc(ord):'<span style="color:#c47f17">없음</span>')
        +   (x.ordItemNo?('-'+_cesc(x.ordItemNo)):'')
        +   ' · 주문 '+(jum?_cesc(jum):'-')
        +   (x.srcFile?(' · '+_cesc(x.srcFile)):'')
        + '</td></tr>';
    };
    _ohMount(wrap, h, list, function(x){
      return x.t==='g'    ? gRow(x.e)
           : x.t==='it'   ? itRow(x.r, x.key, x.col)
           : x.t==='sraw' ? srawRow(x.x)
           : x.t==='raw'  ? rawRow(x.x, x.dup)
           : '<tr style="background:#fcfdfe"><td></td><td colspan="7" class="txt-l" style="padding-left:26px;color:#9aa7b3;font-size:12px">↳ 이 기간 출고 원본행이 없습니다(정산서만 온 건).</td></tr>';
    });
  }

  // 개별 출고장 상태 뱃지 — ①탭 1·2단 공용
  function _ohStBadge(g){
    /* 직접판매(판매등록 전표)는 출고장 발주현황표와 맞출 대상이 아니다.
       출고내역이 없는 게 정상이라 '출고내역 없음'·'출고미상' 을 띄우면 오해를 부른다(2026-07-25). */
    if(g.trx) return '<span class="badge b-done" title="판매등록으로 직접 입력한 매출입니다.&#10;출고장 발주현황표와 대사하는 대상이 아니라 수량차이·출고미상이 잡히지 않습니다.">전표</span>';
    var gap=g.oQty-g.sQty, ok=Math.abs(gap)<1e-6;
    // ★수량 합계만 보면 안 된다 — '정산에만 5개 + 출고에만 5개' 가 상쇄돼 차이 0 이 될 수 있다.
    //   짝 없는 대사키가 하나라도 있으면 '일치'로 부르지 않는다.
    var clean = ok && !g.sOnly && !g.oOnly;
    var st = (!g.sRows) ? '<span class="badge b-wait">정산 미도착</span>'
           : (!g.oRows) ? '<span class="badge b-wait">출고내역 없음</span>'
           : (clean ? '<span class="badge b-done">일치</span>' : '<span class="badge b-ship">차이</span>');
    if(g.oOnly) st+=' <span style="color:#c0392b;font-weight:700;font-size:11.5px" title="보냈는데 정산서에 없는 품목 수(납기일자+출고장+품목코드 기준).&#10;청구 누락 후보입니다. ②탭에서 정산수량이 0인 품목을 보세요.">미정산 '+g.oOnly+'</span>';
    if(g.sOnly) st+=' <span style="color:#a85700;font-weight:700;font-size:11.5px" title="정산서에는 있는데 출고내역에 없는 품목 수.&#10;보낸 적 없는데 청구된 건일 수 있으니 확인이 필요합니다. ②탭에서 출고수량이 0인 품목을 보세요.">출고미상 '+g.sOnly+'</span>';
    return st;
  }
  /* 상태 칸(td) — 여기만 클릭하면 ②탭 드릴다운. 줄 전체를 클릭 대상으로 두면
     숫자를 드래그해 확인하려다 실수로 탭이 바뀌어서, 클릭 영역을 이 칸으로 좁혔다(2026-07-22 요청). */
  function _ohStCell(g){
    return '<td class="oh-st" onclick="ohDrill(\''+encodeURIComponent(g.dc)+'\')"'
      + ' title="클릭 → ② 출고장 ▸ 품목 탭에서 '+_cesc(g.label)+'만 펼쳐 어느 품목이 어긋났는지 봅니다">'
      + _ohStBadge(g)+'</td>';
  }
  // 묶음/일자 머리행의 상태칸 — 표시 전용. 클릭 미적용(접기·드릴 모두 없음).
  //   줄 전체가 접기 토글이라, 이 칸 클릭이 접기로 이어지지 않게 stopPropagation 만 건다.
  function _ohStCellGrp(gg){
    return '<td onclick="event.stopPropagation()" style="cursor:default"'
      + ' title="묶음 합계 상태 (이 칸은 클릭·접기 없음)">'
      + _ohStBadge(gg)+'</td>';
  }
  /* 매출금액 = 정산금액(정산서) + 추정매출(정산서가 안 온 출고 × 판매단가).
     둘을 한 칸에 합쳐 보여준다 — 구분은 상태 칸 뱃지(정산 미도착·미정산 N)로 이미 되고 있다(2026-07-25 요청).
     hover 하면 얼마가 확정이고 얼마가 추정인지 나온다. */
  function _ohAmt(o){ return (+o.sAmt||0) + (+o.eAmt||0); }
  function _ohAmtQ(o){ return (+o.sQty||0) + (+o.eQty||0); }   // 평균단가 분모 — 금액이 잡힌 수량만
  function _ohAmtCell(o, bold){
    var s=(+o.sAmt||0), e=(+o.eAmt||0);
    var tip = e ? ('정산서 '+_cnum(s)+' + 추정 '+_cnum(e)+'&#10;추정 = 정산서가 안 온 출고 × 판매단가(마감관리와 같은 단가)')
                : ('정산서 기준 실제 받을 금액');
    return '<td style="text-align:right;'+(bold?'font-weight:800;':'font-weight:700;')+'color:#137a6c" title="'+tip+'">'
      +_cnum(s+e)+(e?' <span style="color:#a85700;font-weight:600;font-size:11px">추정</span>':'')+'</td>';
  }
  // 숫자 칸 8개(출고건수~정산금액) — ①탭 1·2단 공용
  function _ohDcCells(o){
    var gap=o.sQty-o.oQty, ok=Math.abs(gap)<1e-6, aq=_ohAmtQ(o);
    // 직접판매는 출고 짝이 없는 게 정상 — 수량차이를 숫자로 띄우면 어긋난 것처럼 보인다
    var gapCell = o.trx
      ? '<td style="text-align:right;color:#9aa7b3" title="직접판매 전표라 대사 대상이 아닙니다">—</td>'
      : _ohGapCell(gap);
    return '<td style="text-align:right">'+o.oRows.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(o.oQty)+'</td>'
      +'<td style="text-align:right">'+o.sRows.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(o.sQty)+'</td>'
      +gapCell
      +'<td style="text-align:right">'+(aq?_cnum(_ohAmt(o)/aq):'')+'</td>'
      +_ohAmtCell(o,true);
  }
  /* ① 출고장별 합계 — 대시보드처럼 2단 (2026-07-22 사용자 요청)
       1단 = 물류센터 묶음(CLOSE_DCGROUP: 왜관·김해·광주·제주·오산 → 오산센터. 매출마감과 동일 규칙)
       2단 = 개별 출고장 (정산서·거래처가 출고장별이므로 돈은 여기가 기준 — 클릭하면 ②품목 드릴다운)
       묶음이 실제로 생기는 그룹(2곳 이상)만 머리행을 만들고, 용인·평택처럼 혼자인 곳은 그냥 한 줄.
       접기키 'd:' + 그룹라벨, 기본 = 펼침(개별 출고장·상태가 바로 보이는 게 이 표의 목적이라). */
  function _ohRenderDc(G, wrap, oQ, sQ, sA){
    // 출고장 칸 넓히기(2026-07-27) — 머리글(th)은 그대로 두고 자료칸(tbody td)에만 최소폭을 준다.
    //   테이블 클래스 oh-dc 로 이 표만 겨냥한다(.logi-tb 는 다른 표와 공용이라 전역으로 주면 안 된다).
    var h='<table class="logi-tb oh-dc"><thead><tr><th>출고장</th>'
        +'<th style="text-align:right">출고건수</th><th style="text-align:right">출고수량</th>'
        +'<th style="text-align:right">정산행수</th><th style="text-align:right">정산수량</th>'
        +'<th style="text-align:right" title="정산수량 − 출고수량&#10;+ 정산이 많음 = 청구가 더 됨(과청구·출고기록 누락 후보)&#10;− 출고가 많음 = 보냈는데 청구가 덜 됨(청구 누락 후보)">수량차이<br><span style="font-weight:400;font-size:10.5px">정산−출고</span></th><th style="text-align:right">평균단가</th>'
        +'<th style="text-align:right" title="정산서 금액 + 정산서가 안 온 출고의 추정매출(판매단가). 추정이 섞인 줄에는 &quot;추정&quot; 표시가 붙습니다.">정산금액(받을 금액)</th><th>상태</th></tr></thead><tbody>';
    var T={ sAmt:0, eAmt:0, sQty:sQ, eQty:0 };   // 총합계 줄도 개별 줄과 같은 셀 함수를 쓴다
    var tQ2=0;                                    // 직접판매 정산수량 — 총합계 수량차이에서 뺀다
    G.forEach(function(g){ T.sAmt+=(+g.sAmt||0); T.eAmt+=(+g.eAmt||0); T.eQty+=(+g.eQty||0); if(g.trx) tQ2+=(+g.sQty||0); });
    h+='<tr class="close-total"><td>■ 총합계</td>'
      +'<td style="text-align:right">'+_ohShip.length.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(oQ)+'</td>'
      +'<td style="text-align:right">'+_ohSales.length.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(sQ)+'</td>'
      +'<td style="text-align:right">'+_ohQ(oQ-(sQ-tQ2))+'</td>'
      +'<td style="text-align:right">'+(_ohAmtQ(T)?_cnum(_ohAmt(T)/_ohAmtQ(T)):'')+'</td>'
      +_ohAmtCell(T,true)+'<td></td></tr>';
    // 지역명 → 대시보드 그룹 (KONET_DC_R 로 코드 환원 후 CLOSE_DCGROUP 조회 — 매핑 원천 재사용)
    //   ②③④와 같이 표시행을 배열(R)에 모은다 — 18행씩 자동 스크롤로 붙이려면 행이 낱개로 있어야 한다
    var R=[], GM={}, GL=[];
    G.forEach(function(g){
      var lbl = _ohDcGrp(g.dc);
      // eQty/eAmt(추정분)도 반드시 같이 더한다 — 빠뜨리면 묶음 머리행만 정산분으로 표시돼 하위 합과 안 맞는다
      var gg=GM[lbl]; if(!gg){ gg=GM[lbl]={ label:lbl, kids:[], oRows:0, oQty:0, sRows:0, sQty:0, sAmt:0, eQty:0, eAmt:0, sOnly:0, oOnly:0 }; GL.push(gg); }
      gg.kids.push(g); gg.oRows+=g.oRows; gg.oQty+=g.oQty; gg.sRows+=g.sRows; gg.sQty+=g.sQty; gg.sAmt+=g.sAmt;
      gg.eQty+=(+g.eQty||0); gg.eAmt+=(+g.eAmt||0); gg.sOnly+=g.sOnly; gg.oOnly+=g.oOnly;
      if(g.trx) gg.trx=true;   // 묶음 머리행도 '전표' 로 — 하위가 직접판매면 대사 대상이 아니다
    });
    GL.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    // 줄 전체가 아니라 '상태' 칸을 눌렀을 때만 ②탭으로 이동한다(2026-07-22 요청) — 실수 이동 방지
    var kidRow=function(g, indent){
      return '<tr title="원표기: '+_cesc(Object.keys(g.raw).join(' / '))+'">'
        +'<td class="txt-l"'+(indent?' style="padding-left:26px"':'')+'><b>'+_cesc(_ohDcLabel(g))+'</b>'+ohDcFixBtn(g)+'</td>'
        +_ohDcCells(g)+_ohStCell(g)+'</tr>';
    };
    GL.forEach(function(gg){
      if(gg.kids.length<2){ R.push(kidRow(gg.kids[0], false)); return; }   // 혼자인 곳은 묶음 머리 없이 한 줄
      var col=_ohIsCol2('d:'+gg.label, false);   // 기본 펼침
      // 묶음 머리행은 클릭=접기/펼치기. 상태 칸은 그 자체가 클릭 대상이 아니므로 뱃지만 표시
      R.push('<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('d:'+gg.label)+'\')" title="클릭 → 소속 출고장 '+gg.kids.length+'곳 접기/펼치기">'
        +'<td><span class="ccar">'+(col?'▶':'▼')+'</span> 🗂️ '+_cesc(gg.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+gg.kids.length+'곳)</span></td>'
        +_ohDcCells(gg)+_ohStCellGrp(gg)+'</tr>');
      if(!col) gg.kids.forEach(function(g){ R.push(kidRow(g, true)); });
    });
    // ── 일자별 (최근순) 구획 — 원래 기간합(위) 다음에 배치. 기본 접힘, 캐럿으로 펼치기(2026-07-24 요청)
    //     날짜 머리행 = 접기/펼치기(캐럿). 상태 칸은 클릭 미적용(_ohStCellGrp). 개별 출고장은 드릴 가능(_ohStCell).
    var DBYD=_ohRollByDate();
    if(DBYD.length){
      var dsecCol=_ohIsCol2('dtsec', true);   // 구획 전체 = 기본 접힘
      R.push('<tr class="close-grp" onclick="ohGrp(\'dtsec\')" title="클릭 → 일자별 구획 접기/펼치기">'
        +'<td colspan="9"><span class="ccar">'+(dsecCol?'▶':'▼')+'</span> 📅 <b>일자별 합계</b>'
        +' <span style="font-weight:600;color:#5a6b7a">(최근순 · '+DBYD.length+'일 · 납품일자 기준'+(dsecCol?' · 접힘, 클릭해 펼치기':'')+')</span></td></tr>');
      if(!dsecCol) DBYD.forEach(function(D){
        var dk='dt:'+D.date, dCol=_ohIsCol2(dk, false), dgap=D.tot.oQty-D.tot.sQty;
        R.push('<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent(dk)+'\')" title="클릭 → '+_ohDateFmt(D.date)+' 소속 출고장 접기/펼치기">'
          +'<td style="padding-left:22px"><span class="ccar">'+(dCol?'▶':'▼')+'</span> 🗓️ '+_ohDateFmt(D.date)
          +' <span style="font-weight:600;color:#5a6b7a">('+D.kids.length+'곳)</span></td>'
          +'<td style="text-align:right">'+D.tot.oRows.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(D.tot.oQty)+'</td>'
          +'<td style="text-align:right">'+D.tot.sRows.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(D.tot.sQty)+'</td>'
          +_ohGapCell(dgap)
          +'<td style="text-align:right">'+(_ohAmtQ(D.tot)?_cnum(_ohAmt(D.tot)/_ohAmtQ(D.tot)):'')+'</td>'
          +_ohAmtCell(D.tot,true)
          +_ohStCellGrp(D.tot)+'</tr>');
        if(!dCol) D.kids.forEach(function(g){
          R.push('<tr title="원표기: '+_cesc(Object.keys(g.raw).join(' / '))+'">'
            +'<td class="txt-l" style="padding-left:40px"><b>'+_cesc(_ohDcLabel(g))+'</b></td>'
            +_ohDcCells(g)+_ohStCell(g)+'</tr>');
        });
      });
    }
    _ohMount(wrap, h, R, _ohIdent);
  }

  /* ② 출고장 ▸ 품목 (그룹 접기/펼치기 + 소계)
     표시행을 평평하게(list) 늘어놓고 _ohMount 에 넘긴다 — 18행씩 이어붙이는 일은 거기서.
     ※ 예전 페이저 때 있던 '페이지가 그룹 중간에서 시작하면 소속 헤더를 문맥으로 먼저 찍기'는 뺐다.
       이어붙이기는 끊김 없이 연속이라 머리행이 이미 위에 있다(중복으로 두 번 찍히는 문제만 생긴다). */
  function _ohRenderItem(G, wrap, oQ, sQ, sA){
    /* ★칸 수 주의 — 머리글 8칸 = 자료줄 8칸.
         납품일자 th 를 빠뜨렸다가 자료가 한 칸씩 밀려 **날짜가 출고수량 자리**에 찍혔다(2026-08-02).
         이 표의 칸: 품목코드 · 품목명 · 납품일자 · 출고수량 · 정산수량 · 수량차이 · 판매단가 · 정산금액
         그룹/소계 줄은 앞 3칸을 colspan="3" 으로 묶는다 — 여기 칸을 늘리면 그쪽도 같이 고칠 것. */
    var h='<table class="logi-tb"><thead><tr><th>품목코드</th><th>품목명</th>'
        +'<th style="width:96px" title="이 줄이 어느 날짜 자료인지.&#10;여러 날이 섞이면 [N일] 로 묶어 보여 주고, 마우스를 올리면 날짜별 수량이 나옵니다.&#10;날짜마다 한 줄로 펴려면 총합계 줄의 [일자별로 나누기] 를 켜세요.">납품일자</th>'
        +'<th style="text-align:right">출고수량</th><th style="text-align:right">정산수량</th>'
        +'<th style="text-align:right" title="정산수량 − 출고수량&#10;+ 정산이 많음 = 청구가 더 됨(과청구·출고기록 누락 후보)&#10;− 출고가 많음 = 보냈는데 청구가 덜 됨(청구 누락 후보)">수량차이<br><span style="font-weight:400;font-size:10.5px">정산−출고</span></th><th style="text-align:right">판매단가</th>'
        +'<th style="text-align:right" title="정산수량 × 판매단가&#10;정산서가 안 온 출고의 추정매출은 넣지 않습니다 — 여기는 실제로 청구된 금액만 봅니다.&#10;(추정까지 포함한 금액은 [출고장별 합계] 탭과 위 요약줄에 있습니다)">정산금액<br><span style="font-weight:400;font-size:10.5px">정산수량×단가</span></th></tr></thead><tbody>';
    /* ★이 탭의 정산금액 = 정산수량 × 판매단가 (2026-08-02 확정).
         종전에는 `정산서금액 + 추정매출` 이라, 출고 6·정산 1 인 품목이 6×단가 로 찍혀
         "정산수량 1 인데 금액은 6개분" 으로 보였다(사용자 지적).
       ★소계·총합계도 같은 식(품목별 정산수량×단가의 합)으로 내야 한다 —
         g.sAmt 를 그대로 쓰면 합이 품목 줄들과 안 맞는다. */
    /* ★정산금액 = 정산서 원본 금액(SALE_AMT) 을 그대로 쓴다 (2026-08-02, 정산실적 화면과 기준 일치).
         종전에는 정산수량×판매단가로 다시 계산했는데, 할인·반올림이 섞이면 원본과 어긋난다.
         it.sAmt 는 _ohRoll 이 r.saleAmt 를 그대로 누적한 값이다(= 정산실적의 '정산금액/매입금액' 과 같은 원천). */
    var _setAmt = function(it){ return (+it.sAmt||0); };
    var _setAmtG = function(g){ var s=0; g.itemOrd.forEach(function(k){ s+=_setAmt(g.items[k]); }); return s; };
    var _amtCell = function(v, bold){
      return '<td style="text-align:right;'+(bold?'font-weight:800;':'font-weight:700;')+'color:#137a6c"'
           + ' title="정산서 원본 금액(SALE_AMT) 합계">'+_cnum(v)+'</td>';
    };
    /* ── 납품일자 (2026-08-02 요청) ──────────────────────────────────────────
       기간을 며칠로 잡으면 이 표가 기간 전체를 합산해서, 한 줄이 22일 것인지 27일 것인지 알 수 없었다.
         · 기본(끔) : 날짜 칸에 그 품목의 날짜를 적고, 여러 날이면 [N일] + 마우스오버로 날짜별 수량
         · 켜면     : 품목을 **날짜마다 한 줄로** 펴고 수량·금액도 그 날짜 것만 보여 준다
       ★기본을 '끔' 으로 두는 이유 = 종전 화면(품목 단위 집계)을 그대로 쓰던 흐름을 깨지 않기 위해서다. */
    var _dts = function(it){ return Object.keys(it.dts||{}).filter(function(d){ return d; }).sort(); };
    var _dtLbl = function(d){ return d && d.length===8 ? d.slice(4,6)+'-'+d.slice(6,8) : (d||''); };
    var _dtCell = function(it){
      var ds=_dts(it);
      if(!ds.length) return '<td style="color:#c8ced4">-</td>';
      if(ds.length===1) return '<td style="white-space:nowrap;color:#37475a">'+_dtLbl(ds[0])+'</td>';
      var tip=ds.map(function(d){ var e=it.dts[d];
        return _ohDateFmt(d)+'  출고 '+_ohQ(e.oQty)+' · 정산 '+_ohQ(e.sQty); }).join('&#10;');
      return '<td style="white-space:nowrap" title="'+tip+'">'
           + '<span style="font-weight:800;color:#274b8f;cursor:help">'+ds.length+'일</span></td>';
    };
    /* [일자별로 나누기] 스위치 — ⑤탭 [미정산 같이 보기] 와 같은 방식으로 총합계 줄 안에 둔다
       (표 밖에 두면 목록을 다시 그릴 때 사라진다) */
    var dBtn = '<span onclick="ohItemByDate()" title="'
      + (_ohItemByDate ? '날짜를 합쳐 품목 한 줄로 봅니다'
                       : '품목을 납품일자마다 한 줄로 펴서 봅니다 — 어느 날 자료인지 바로 구분됩니다')
      + '" style="cursor:pointer;user-select:none;font-weight:700;font-size:11.5px;'
      + 'border:1px solid rgba(255,255,255,.55);border-radius:6px;padding:1px 8px;margin-left:8px;'
      + (_ohItemByDate ? 'background:#ffe9c9;color:#7a4b0a' : 'color:#ffe9c9') + '">'
      + (_ohItemByDate ? '☑' : '☐') + ' 일자별로 나누기</span>';
    /* [일자별] 품목 한 줄 — 그 날짜의 수량만 쓴다.
       단가는 그 날짜에 잡힌 단가가 있으면 그것을, 없으면 품목 대표단가(정산이 없는 날은 추정단가).
       ★날짜 그룹 렌더보다 **먼저** 정의해야 한다 — 아래 일자별 분기에서 바로 쓰기 때문. */
    var _itRowD=function(gi,k,dt){
      var it=G[gi].items[k], e=it.dts[dt]||{oQty:0,sQty:0,price:null};
      var oq=+e.oQty||0, sq=+e.sQty||0, pr=(e.price!=null?e.price:it.price);
      var d=sq-oq, dok=Math.abs(d)<1e-6;
      return '<tr><td>'+_cesc(it.itemCd)+'</td><td class="txt-l">'+_cesc(it.itemNm)+'</td>'
        +'<td style="white-space:nowrap;color:#37475a" title="'+_ohDateFmt(dt)+'">'+_dtLbl(dt)+'</td>'
        +'<td style="text-align:right">'+_ohQ(oq)+'</td>'
        +'<td style="text-align:right;'+(sq<0?'color:#c0392b':'')+'">'+_ohQ(sq)+'</td>'
        +_ohGapCell(d, true)
        +'<td style="text-align:right">'+(pr==null?'':_cnum(pr))+'</td>'
        +_amtCell(sq*(+pr||0))+'</tr>';
    };
    var TA=0; G.forEach(function(g){ TA+=_setAmtG(g); });
    h+='<tr class="close-total"><td colspan="3">■ 총합계'+dBtn+'</td>'
      +'<td style="text-align:right">'+_ohQ(oQ)+'</td><td style="text-align:right">'+_ohQ(sQ)+'</td>'
      +'<td style="text-align:right">'+_ohQ(sQ-oQ)+'</td><td></td>'
      +_amtCell(TA,true)+'</tr>';
    /* ══ [일자별로 나누기] 켜짐 = 날짜를 맨 위 그룹으로 (2026-08-02 사용자 확정) ══
         납품일자 ▸ 출고장 ▸ 품목. 물류센터 묶음(🗂️) 단계는 이 모드에서 뺀다 —
         날짜까지 넣어 4단이 되면 접었다 펴는 것만으로 지쳐서 못 쓴다.
       ★날짜별 소계도 그 날짜 것만으로 다시 낸다(품목 줄과 단위를 맞춘다).
       ★납품일자가 없는 자료는 맨 아래 '(납품일자 없음)' 으로 모은다 — 없는 날짜를 지어낼 수는 없다. */
    if(_ohItemByDate){
      var DM={}, dOrd=[];
      G.forEach(function(g,gi){
        g.itemOrd.forEach(function(k){
          var it=g.items[k], dd=it.dts||{};
          Object.keys(dd).forEach(function(d){
            var e=dd[d], pr=(e.price!=null?e.price:it.price)||0, amt=(+e.sQty||0)*pr;
            var D=DM[d]; if(!D){ D=DM[d]={ date:d, gs:{}, gOrd:[], oQty:0, sQty:0, amt:0, items:0 }; dOrd.push(d); }
            var GG=D.gs[gi]; if(!GG){ GG=D.gs[gi]={ gi:gi, keys:[], oQty:0, sQty:0, amt:0 }; D.gOrd.push(gi); }
            GG.keys.push(k); GG.oQty+=(+e.oQty||0); GG.sQty+=(+e.sQty||0); GG.amt+=amt;
            D.oQty+=(+e.oQty||0); D.sQty+=(+e.sQty||0); D.amt+=amt; D.items++;
          });
        });
      });
      /* 최근 날짜부터 위로 (2026-08-02 요청) — 빈 날짜는 그대로 맨 뒤
         (내림차순이라 빈 날짜는 '00000000' 으로 낮춰 잡아야 아래로 간다) */
      dOrd.sort(function(a,b){ return (b?b:'00000000').localeCompare(a?a:'00000000'); });
      var dlist=[];
      dOrd.forEach(function(d){
        var D=DM[d];
        dlist.push({t:'D', d:d});
        if(_ohIsCol2('dt:'+d, _ohAllCol)) return;                       // 날짜 접힘
        D.gOrd.sort(function(a,b){ return G[a].label.localeCompare(G[b].label,'ko'); });
        D.gOrd.forEach(function(gi){
          dlist.push({t:'Dg', d:d, gi:gi});
          if(_ohIsCol2('dtg:'+d+'|'+gi, _ohAllCol)) return;             // 그 날짜의 출고장 접힘
          DM[d].gs[gi].keys.slice().sort(function(a,b){ return a.localeCompare(b,'ko'); })
            .forEach(function(k){ dlist.push({t:'itd', gi:gi, k:k, d:d}); });
        });
      });
      var _dRow=function(d){
        var D=DM[d], col=_ohIsCol2('dt:'+d,_ohAllCol), gap=D.sQty-D.oQty;
        return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('dt:'+d)+'\')"><td colspan="3">'
          +'<span class="ccar">'+(col?'▶':'▼')+'</span> 📅 <b>'+(d?_ohDateFmt(d):'(납품일자 없음)')+'</b>'
          +' <span style="font-weight:600;color:#5a6b7a">('+D.gOrd.length+'곳 · '+D.items+'품목)</span></td>'
          +'<td style="text-align:right">'+_ohQ(D.oQty)+'</td><td style="text-align:right">'+_ohQ(D.sQty)+'</td>'
          +_ohGapCell(gap)+'<td></td>'
          +_amtCell(D.amt)+'</tr>';
      };
      var _dGrpRow=function(d, gi){
        var GG=DM[d].gs[gi], col=_ohIsCol2('dtg:'+d+'|'+gi,_ohAllCol), gap=GG.sQty-GG.oQty;
        return '<tr class="close-sub" style="cursor:pointer" onclick="ohGrp(\''+encodeURIComponent('dtg:'+d+'|'+gi)+'\')">'
          +'<td colspan="3" style="padding-left:24px">'
          +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🏭 '+_cesc(G[gi].label)
          +' <span style="font-weight:600;color:#5a6b7a">('+GG.keys.length+'품목)</span></td>'
          +'<td style="text-align:right">'+_ohQ(GG.oQty)+'</td><td style="text-align:right">'+_ohQ(GG.sQty)+'</td>'
          +_ohGapCell(gap)+'<td></td>'
          +_amtCell(GG.amt)+'</tr>';
      };
      _ohMount(wrap, h, dlist, function(r){
        return (r.t==='D')  ? _dRow(r.d)
             : (r.t==='Dg') ? _dGrpRow(r.d, r.gi)
             :                _itRowD(r.gi, r.k, r.d);
      });
      return;
    }

    // 표시행 평면화 (접힘 반영) — 1단 물류센터 묶음(d2:) → 2단 출고장(i:) → 품목. 묶음이 2곳 이상일 때만 머리행
    var L0s=[], lm={};
    G.forEach(function(g,gi){
      var lbl=_ohDcGrp(g.dc);
      var e=lm[lbl]; if(!e){ e=lm[lbl]={ label:lbl, gis:[], oQty:0, sQty:0, sAmt:0, eQty:0, eAmt:0, items:0 }; L0s.push(e); }
      e.gis.push(gi); e.oQty+=g.oQty; e.sQty+=g.sQty; e.sAmt+=g.sAmt; e.eQty+=g.eQty; e.eAmt+=g.eAmt; e.items+=g.itemOrd.length;
    });
    L0s.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    var sorted=[], list=[];
    L0s.forEach(function(e){
      var multi=e.gis.length>1;
      if(multi){ list.push({t:'G',e:e}); if(_ohIsCol2('d2:'+e.label,false)) return; }
      e.gis.forEach(function(gi){
        var g=G[gi];
        sorted[gi]=g.itemOrd.slice().sort(function(a,b){ return a.localeCompare(b,'ko'); });
        list.push({t:'g',gi:gi,e:multi?e:null});
        if(_ohIsCol(g.dc)) return;
        sorted[gi].forEach(function(k){
          if(!_ohItemByDate){ list.push({t:'it',gi:gi,k:k,e:multi?e:null}); return; }
          // 켜짐 — 그 품목의 납품일자마다 한 줄. 날짜가 아예 없는 자료는 종전처럼 한 줄로 둔다.
          var ds=_dts(g.items[k]);
          if(!ds.length){ list.push({t:'it',gi:gi,k:k,e:multi?e:null}); return; }
          ds.forEach(function(d){ list.push({t:'itd',gi:gi,k:k,d:d,e:multi?e:null}); });
        });
      });
    });
    var L0Row=function(e){
      var col=_ohIsCol2('d2:'+e.label,false), gap=e.sQty-e.oQty;
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('d2:'+e.label)+'\')"><td colspan="3">'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🗂️ '+_cesc(e.label)+' <span style="font-weight:600;color:#5a6b7a">('+e.gis.length+'곳 · '+e.items+'품목)</span></td>'
        +'<td style="text-align:right">'+_ohQ(e.oQty)+'</td><td style="text-align:right">'+_ohQ(e.sQty)+'</td>'
        +_ohGapCell(gap)+'<td></td>'
        +_amtCell(e.gis.reduce(function(s,gi){ return s+_setAmtG(G[gi]); },0))+'</tr>';
    };
    var grpRow=function(gi, ind){
      var g=G[gi], col=_ohIsCol(g.dc), gap=g.sQty-g.oQty;
      return '<tr class="close-sub" style="cursor:pointer" onclick="ohGrp(\''+encodeURIComponent('i:'+g.dc)+'\')"><td colspan="3"'+(ind?' style="padding-left:24px"':'')+'>'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🏭 '+_cesc(g.label)+' <span style="font-weight:600;color:#5a6b7a">('+g.itemOrd.length+'품목)</span></td>'
        +'<td style="text-align:right">'+_ohQ(g.oQty)+'</td><td style="text-align:right">'+_ohQ(g.sQty)+'</td>'
        +_ohGapCell(gap)+'<td></td>'
        +_amtCell(_setAmtG(g))+'</tr>';
    };
    var itRow=function(gi,k){
      var it=G[gi].items[k], d=it.sQty-it.oQty, dok=Math.abs(d)<1e-6;
      return '<tr><td>'+_cesc(it.itemCd)+'</td><td class="txt-l">'+_cesc(it.itemNm)+'</td>'
        +_dtCell(it)
        +'<td style="text-align:right">'+_ohQ(it.oQty)+'</td>'
        +'<td style="text-align:right;'+(it.sQty<0?'color:#c0392b':'')+'">'+_ohQ(it.sQty)+'</td>'
        +_ohGapCell(d, true)
        +'<td style="text-align:right">'+(it.price==null?'':_cnum(it.price))+'</td>'
        +_amtCell(_setAmt(it))+'</tr>';
    };
    _ohMount(wrap, h, list, function(r){
      return (r.t==='G')  ? L0Row(r.e)
           : (r.t==='g')  ? grpRow(r.gi, !!r.e)
           : (r.t==='itd')? _itRowD(r.gi, r.k, r.d)
           :                itRow(r.gi, r.k);
    });
  }

  // 한쪽 원천이 통째로 없을 때 — 빈 표 대신 왜 비었는지 알려준다
  function _ohEmptyRow(cols, title, desc){
    return '<tr><td colspan="'+cols+'" style="padding:34px 16px;text-align:center;color:#5a6b7a;background:#fbfcfc">'
      +'<div style="font-size:13.5px;font-weight:800;color:#c47f17;margin-bottom:6px">'+title+'</div>'
      +'<div style="font-size:12.5px;line-height:1.7">'+desc+'</div></td></tr>';
  }
  /* ④ 정산서 원본(엑셀) — 출고장별로 묶고 접기/펼치기 + 소계 (②③과 동일한 방식)
       ★출고수량 소계는 '행별 값의 합'이 아니라 '대사키 distinct 합'이다.
         정산서 2행이 같은 (납기일자·출고장·품목)이면 두 행 모두 같은 출고합계를 표시하므로
         그대로 더하면 이중계상된다. used 로 키당 1회만 더한다. */
  function _ohRenderSettle(wrap, sQ, sA){
    var idx=_ohIndex(_ohShip,'curQty');
    var h='<table class="logi-tb"><thead><tr><th>납품일자</th><th>출고장</th><th>발주번호</th><th>항번</th><th>품목코드</th><th>품목명</th>'
        +'<th style="text-align:right">발주량</th><th style="text-align:right">정산수량</th>'
        +'<th style="text-align:right">출고수량</th>'
        +'<th style="text-align:right">판매단가</th><th style="text-align:right">정산금액</th><th>원본파일</th></tr></thead><tbody>';
    if(!_ohSales.length){
      h+='<tr class="close-total"><td colspan="6">■ 총합계</td><td></td>'
        +'<td style="text-align:right">'+_ohQ(sQ)+'</td><td></td><td></td>'
        +'<td style="text-align:right">'+_cnum(sA)+'</td><td></td></tr>';
      _ohMount(wrap, h+_ohEmptyRow(12, '이 기간 정산서(엑셀) 자료가 없습니다',
        '이 탭은 <b>출고장이 보내준 정산 엑셀의 원본 행</b>을 그대로 보여줍니다.<br>'
        +'조회기간에 저장된 정산서가 없어 띄울 행이 없습니다'
        +(_ohShip.length ? ' — 출고는 <b>'+_ohShip.length.toLocaleString()+'행</b> 있으니 <b>정산서가 아직 안 온 날</b>입니다.' : '.')
        +'<br><b>매출 관리 ▸ 판매 등록</b> 화면의 <b>📥 정산서 가져오기</b> 로 해당 날짜 파일을 올리면 여기에 채워집니다.'), [], _ohIdent);
      return;
    }
    // 출고장별로 묶기
    var S=[], sm={}, tO=0, tUsed={};
    _ohSales.forEach(function(r){
      var k=_ohDcOf(r)||'(출고장 미지정)';
      var g=sm[k]; if(!g){ g=sm[k]={ dc:k, label:k, rows:[], sQty:0, sAmt:0, oQty:0, miss:0, used:{} }; S.push(g); }
      g.rows.push(r); g.sQty+=(+r.outQty||0); g.sAmt+=(+r.saleAmt||0);
      var kk=_ohKey(r), hit=kk?idx[kk]:null;
      if(hit){
        if(!g.used[kk]){ g.used[kk]=1; g.oQty+=hit.q; }
        if(!tUsed[kk]){ tUsed[kk]=1; tO+=hit.q; }
      } else g.miss++;
    });
    S.sort(function(a,b){ return a.dc.localeCompare(b.dc,'ko'); });
    h+='<tr class="close-total"><td colspan="6">■ 총합계</td><td></td>'
      +'<td style="text-align:right">'+_ohQ(sQ)+'</td>'
      +'<td style="text-align:right">'+_ohQ(tO)+'</td><td></td>'
      +'<td style="text-align:right">'+_cnum(sA)+'</td><td></td></tr>';
    // 표시행 평면화 (3단: 물류센터 묶음(d4:) → 출고장(t:) → 정산행. 접힘 반영. 묶음이 2곳 이상일 때만 머리행)
    var L0s=[], lm={};
    S.forEach(function(g,gi){
      var lbl=_ohDcGrp(g.dc);
      var e=lm[lbl]; if(!e){ e=lm[lbl]={ label:lbl, gis:[], rowsN:0, sQty:0, sAmt:0, oQty:0, miss:0 }; L0s.push(e); }
      e.gis.push(gi); e.rowsN+=g.rows.length; e.sQty+=g.sQty; e.sAmt+=g.sAmt; e.oQty+=g.oQty; e.miss+=g.miss;
    });
    L0s.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    var list=[];
    L0s.forEach(function(e){
      var multi=e.gis.length>1;
      if(multi){ list.push({t:'G',e:e}); if(_ohIsCol2('d4:'+e.label,false)) return; }
      e.gis.forEach(function(gi){
        var g=S[gi];
        list.push({t:'g',gi:gi,e:multi?e:null});
        if(_ohIsCol2('t:'+g.dc, _ohAllCol)) return;
        g.rows.forEach(function(r,ri){ list.push({t:'r',gi:gi,ri:ri,e:multi?e:null}); });
      });
    });
    var L0Row=function(e){
      var col=_ohIsCol2('d4:'+e.label,false);
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('d4:'+e.label)+'\')"><td colspan="6">'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🗂️ '+_cesc(e.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+e.gis.length+'곳 · '+e.rowsN.toLocaleString()+'행)</span>'
        +(e.miss?' <span style="font-weight:700;color:#c0392b">· 출고미상 '+e.miss+'</span>':'')+'</td>'
        +'<td></td><td style="text-align:right">'+_ohQ(e.sQty)+'</td>'
        +'<td style="text-align:right">'+_ohQ(e.oQty)+'</td><td></td>'
        +'<td style="text-align:right">'+_cnum(e.sAmt)+'</td><td></td></tr>';
    };
    var grpRow=function(gi, ind){
      var g=S[gi], col=_ohIsCol2('t:'+g.dc, _ohAllCol);
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('t:'+g.dc)+'\')"><td colspan="6"'+(ind?' style="padding-left:24px"':'')+'>'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🏭 '+_cesc(g.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+g.rows.length.toLocaleString()+'행)</span>'
        +(g.miss?' <span style="font-weight:700;color:#c0392b" title="출고내역에 짝이 없는 정산행(보낸 적 없는데 청구된 건일 수 있음)">· 출고미상 '+g.miss+'</span>':'')+'</td>'
        +'<td></td><td style="text-align:right">'+_ohQ(g.sQty)+'</td>'
        +'<td style="text-align:right">'+_ohQ(g.oQty)+'</td><td></td>'
        +'<td style="text-align:right">'+_cnum(g.sAmt)+'</td><td></td></tr>';
    };
    var detRow=function(gi,ri){
      var r=S[gi].rows[ri], k=_ohKey(r), m=k?idx[k]:null, oq=m?m.q:null;
      return '<tr><td>'+_cesc(r.dlvDt)+'</td><td>'+_cesc(r.dcNm)+'</td><td>'+_cesc(r.ordNo)+'</td><td>'+_cesc(r.ordItemNo)+'</td>'
        +'<td>'+_cesc(r.itemCd)+'</td><td class="txt-l">'+_cesc(r.itemNm)+'</td>'
        +'<td style="text-align:right">'+(r.ordQty==null?'':_ohQ(r.ordQty))+'</td>'
        +'<td style="text-align:right;'+((+r.outQty||0)<0?'color:#c0392b':'')+'">'+(r.outQty==null?'':_ohQ(r.outQty))+'</td>'
        +'<td style="text-align:right" title="같은 납기일자·출고장·품목코드의 출고 합계입니다(사업장 여러 곳이면 합쳐진 값).">'
        +(oq==null?'<span style="color:#c0392b">출고미상</span>':_ohQ(oq))+'</td>'
        +'<td style="text-align:right">'+_cnum(r.salePrice)+'</td>'
        +'<td style="text-align:right;font-weight:700;color:#137a6c">'+_cnum(r.saleAmt)+'</td>'
        +'<td class="txt-l" style="color:#9aa7b3">'+_cesc(r.srcFile)+'</td></tr>';
    };
    _ohMount(wrap, h, list, function(x){
      return (x.t==='G') ? L0Row(x.e) : (x.t==='g') ? grpRow(x.gi, !!x.e) : detRow(x.gi,x.ri);
    });
  }


  /* ④ 출고장 ▸ 사업장 — ②(품목축)와 겹치지 않는 유일한 축.
     정산서에 없는 '어느 점포로 나갔나'를 세우고, 사업장을 펼치면 출고 원본행이 나온다. */
  function _ohRenderShip(wrap, oQ){
    var h='<table class="logi-tb"><thead><tr><th>사업장 / 품목</th><th>품목코드</th><th>발주번호</th><th>항번</th><th>출고일자</th>'
        +'<th style="text-align:right">출고수량</th><th>정산 대사</th></tr></thead><tbody>';
    if(!_ohShip.length){
      _ohMount(wrap, h+_ohEmptyRow(7, '이 기간 출고내역(발주현황표) 자료가 없습니다',
        '이 탭은 출고를 <b>출고장 ▸ 사업장(점포)</b> 으로 묶어, 어느 점포로 얼마나 나갔는지 보여줍니다.<br>'
        +'조회기간에 저장된 출고가 없어 띄울 행이 없습니다'
        +(_ohSales.length ? ' — 정산서는 <b>'+_ohSales.length.toLocaleString()+'행</b> 있으니 <b>발주현황표가 아직 안 올라온 날</b>입니다.' : '.')
        +'<br>기간은 <b>납품일자(=납기일자)</b> 기준입니다.'), [], _ohIdent);
      return;
    }
    var B=_ohRollBiz(), tT={hit:0,unpaid:0,noKey:0};
    B.forEach(function(g){ tT.hit+=g.hit; tT.unpaid+=g.unpaid; tT.noKey+=g.noKey; });
    h+='<tr class="close-total"><td colspan="5">■ 총합계 <span style="font-weight:600" title="사업장별 정산금액은 만들지 않습니다. 정산서는 발주 단위, 출고는 발주×사업장 단위라 쪼개면 추정이 됩니다. 금액은 ①②탭에서 보세요.">(출고수량 전용 · 금액은 ①②탭)</span></td>'
      +'<td style="text-align:right">'+_ohQ(oQ)+'</td><td>'+_ohStat(tT)+'</td></tr>';
    // 표시행 평면화 (4단: 물류센터 묶음(d3:) → 출고장(s:) → 사업장(b:) → 출고 원본행. 접힘 반영. 묶음이 2곳 이상일 때만 머리행)
    var L0s=[], lm={};
    B.forEach(function(g,gi){
      var lbl=_ohDcGrp(g.dc);
      var e=lm[lbl]; if(!e){ e=lm[lbl]={ label:lbl, gis:[], oRows:0, oQty:0, hit:0, unpaid:0, noKey:0, bizN:0 }; L0s.push(e); }
      e.gis.push(gi); e.oRows+=g.oRows; e.oQty+=g.oQty; e.hit+=g.hit; e.unpaid+=g.unpaid; e.noKey+=g.noKey; e.bizN+=g.bizOrd.length;
    });
    L0s.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    var list=[];
    L0s.forEach(function(e){
      var multi=e.gis.length>1;
      if(multi){ list.push({t:'G',e:e}); if(_ohIsCol2('d3:'+e.label,false)) return; }
      e.gis.forEach(function(gi){
        var g=B[gi];
        list.push({t:'g',gi:gi,e:multi?e:null});
        if(_ohIsCol2('s:'+g.dc, _ohAllCol)) return;
        g.bizOrd.forEach(function(bk,bi){
          list.push({t:'b',gi:gi,bi:bi,e:multi?e:null});
          if(_ohIsCol2('b:'+g.dc+'|'+bk, true)) return;          // 사업장 하위(원본행)는 기본 접힘
          g.biz[bk].rows.forEach(function(x,xi){ list.push({t:'r',gi:gi,bi:bi,xi:xi,e:multi?e:null}); });
        });
      });
    });
    var L0Row=function(e){
      var col=_ohIsCol2('d3:'+e.label,false);
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('d3:'+e.label)+'\')"><td colspan="5">'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🗂️ '+_cesc(e.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+e.gis.length+'곳 · '+e.bizN+'개 사업장 · '+e.oRows.toLocaleString()+'행)</span></td>'
        +'<td style="text-align:right">'+_ohQ(e.oQty)+'</td><td>'+_ohStat(e)+'</td></tr>';
    };
    var grpRow=function(gi, ind){
      var g=B[gi], gk='s:'+g.dc, gcol=_ohIsCol2(gk, _ohAllCol);
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent(gk)+'\')"><td colspan="5"'+(ind?' style="padding-left:24px"':'')+'>'
        +'<span class="ccar">'+(gcol?'▶':'▼')+'</span> 🏭 '+_cesc(g.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+g.bizOrd.length+'개 사업장 · '+g.oRows.toLocaleString()+'행)</span></td>'
        +'<td style="text-align:right">'+_ohQ(g.oQty)+'</td><td>'+_ohStat(g)+'</td></tr>';
    };
    var bizRow=function(gi,bi,ind){
      var g=B[gi], bk=g.bizOrd[bi], b=g.biz[bk], bcol=_ohIsCol2('b:'+g.dc+'|'+bk, true);
      return '<tr class="close-sub" style="cursor:pointer" onclick="ohGrp(\''+encodeURIComponent('b:'+g.dc+'|'+bk)+'\')">'
        +'<td class="txt-l" style="padding-left:'+(ind?44:24)+'px"><span class="ccar">'+(bcol?'▶':'▼')+'</span> 🏢 '+_cesc(b.bizNm)
        +' <span style="font-weight:600;color:#5a6b7a">('+b.rows.length+'행)</span></td>'
        +'<td colspan="4" style="color:#9aa7b3">'+_cesc(b.bizCd)+'</td>'
        +'<td style="text-align:right">'+_ohQ(b.oQty)+'</td><td>'+_ohStat(b)+'</td></tr>';
    };
    var detRow=function(gi,bi,xi,ind){
      var g=B[gi], x=g.biz[g.bizOrd[bi]].rows[xi], r=x.r;
      // 이 행의 (납기일자·출고장·품목코드)가 정산서에 있느냐 — 사실만 표시(사업장별 금액 배분은 하지 않는다)
      var st = x.hit ? '<span style="color:#137a6c;font-weight:700" title="이 행의 납기일자·출고장·품목코드가 정산서에 있습니다.&#10;금액은 품목 합계 단위라 ①②탭에서 보세요.">대사됨</span>'
                     : (x.k ? '<span style="color:#c0392b;font-weight:700" title="보냈는데 정산서에 이 납기일자·출고장·품목이 없습니다 — 청구 누락 후보.">미정산</span>'
                            : '<span style="color:#9aa7b3" title="납기일자·출고장·품목코드 중 빈 칸이 있어 키가 서지 않습니다(정상 자료에는 없습니다).">키없음</span>');
      return '<tr><td class="txt-l" style="padding-left:'+(ind?66:46)+'px">'+_cesc(r.itemNm)+'</td>'
        +'<td>'+_cesc(r.itemCd)+'</td>'
        +'<td>'+(_cesc(r.ordNo)||'<span style="color:#c9d2d0">—</span>')+'</td><td>'+_cesc(r.ordItemNo)+'</td>'
        +'<td>'+_cesc(r.shpoutDt)+(_ohYmd(r.shpoutDt)!==_ohYmd(r.dlvDt)?' <span style="color:#c47f17" title="납기일자 '+_cesc(r.dlvDt)+' — 먼 지역은 하루 당겨 출고합니다">*</span>':'')+'</td>'
        +'<td style="text-align:right">'+_ohQ(r.curQty)+'</td>'
        +'<td>'+st+'</td></tr>';
    };
    _ohMount(wrap, h, list, function(r2){
      return (r2.t==='G') ? L0Row(r2.e)
           : (r2.t==='g') ? grpRow(r2.gi, !!r2.e)
           : (r2.t==='b') ? bizRow(r2.gi,r2.bi, !!r2.e)
           : detRow(r2.gi,r2.bi,r2.xi, !!r2.e);
    });
  }

  /* ══ 표 공통 — N행씩 보여주고 나머지는 스크롤로 자동 이어붙이기(무한 스크롤) ══════════
       쓰는 곳 : 매출내역 4탭(18행) · 재고현황 ①품목별 현재고(10행)
       화면 쪽에서는 '표시행 목록(list)'과 '행 하나를 HTML 로 만드는 함수(rowFn)'만 넘긴다.
       행을 만드는 규칙(그룹 머리행·소계·접기 등)은 화면마다 그대로 두고, 자르고 이어붙이는 일만 여기서 한다.
         lzMount : 머리 N행을 찍고 스크롤 감시를 건다
         lzFill  : 다음 N행을 tbody 에 이어붙인다 (바닥 가까이 오면 자동 호출)
         lzFit   : 표 높이를 N행에 맞춘다 (창이 낮으면 뷰포트에서 자름 — 페이지 스크롤이 생기면 안 된다)
       ※ 페이지 버튼은 없앴다. 대신 하단에 '몇 행까지 나왔는지'와 [모두 표시]를 둔다
         (Ctrl+F 검색·전체 드래그 복사에는 전부 펼쳐야 하므로 수단은 남겨 둔다).
       ※ 상태(_lz)는 표 컨테이너에 붙여 둔다 — 화면마다 표가 따로 살아 있어야 하므로 전역 하나로는 안 된다. */
  function lzIdent(s){ return s; }   // list 가 이미 행 HTML 문자열인 표(①탭·재고현황)용
  function lzMount(o){               // {wrap, pager, head, list, rowFn, rows, capTop, fill}
    var wrap=(typeof o.wrap==='string')?document.getElementById(o.wrap):o.wrap; if(!wrap) return;
    var rows=o.rows||KONET_GRID_ROWS, list=o.list||[], rowFn=o.rowFn||lzIdent;
    var n=Math.min(rows, list.length), body='';
    for(var i=0;i<n;i++) body+=rowFn(list[i]);
    wrap.innerHTML=o.head+body+'</tbody></table>';
    wrap._lz={ list:list, from:n, rowFn:rowFn, rows:rows, pager:o.pager||'', capTop:o.capTop||214, fill:!!o.fill };
    lzFit(wrap); lzBind(wrap);
    // N행이 표 높이보다 짧으면(행이 얇거나 창이 큰 경우) 스크롤이 안 생겨 영영 안 채워지고,
    // fill 표는 화면을 채울 만큼 행이 필요하다 — 어느 쪽이든 찰 때까지 미리 붙인다
    for(var g=0; wrap._lz.from<list.length && wrap.scrollHeight<=wrap.clientHeight+2 && g<200; g++) lzFill(wrap);
    lzInfo(wrap);
  }
  function lzFit(wrap){
    var z=wrap._lz; if(!z) return;
    var cap=Math.max(240, window.innerHeight-z.capTop);   // 창을 벗어나면 안 됨
    /* ★fill 표(매출내역 탭들)는 <화면 바닥까지> 쓴다 (2026-08-04 "빈공간").
         N행 높이로 상한을 걸면 큰 화면에서 표 아래가 텅 비었다. 표 시작 위치를 실측해
         (창높이 − 시작위치 − 하단안내줄) 로 상한을 잡는다 — 행이 모자라면 표는 짧게 끝나고,
         남으면 lzMount 의 미리 붙이기가 바닥까지 채운다.
       재고현황처럼 표 두 개를 한 화면에 두는 곳은 fill 없이 종전(N행 상한) 그대로다. */
    if (z.fill && wrap.offsetParent){
      var top=wrap.getBoundingClientRect().top + (window.scrollY||window.pageYOffset||0);
      cap=Math.max(240, window.innerHeight - top - 46);
      wrap.style.maxHeight=cap+'px';
      return;
    }
    var tb=wrap.querySelector('table');
    if(!tb){ wrap.style.maxHeight=cap+'px'; return; }
    // 행 높이가 종류마다 달라(그룹 머리행·설명행) 계산하지 않고 실측한다. +1 = 맨 위 '■ 총합계' 줄
    var px=(tb.tHead?tb.tHead.offsetHeight:0), rs=(tb.tBodies[0]?tb.tBodies[0].rows:[]);
    for(var i=0;i<rs.length && i<=z.rows;i++) px+=rs[i].offsetHeight;
    wrap.style.maxHeight=Math.min(px+2, cap)+'px';
  }
  function lzFill(wrap){
    var z=wrap&&wrap._lz; if(!z || z.from>=z.list.length) return;
    var tb=wrap.querySelector('tbody'); if(!tb){ wrap._lz=null; return; }
    var to=Math.min(z.from+z.rows, z.list.length), s='';
    for(var i=z.from;i<to;i++) s+=z.rowFn(z.list[i]);
    tb.insertAdjacentHTML('beforeend', s);
    z.from=to; lzInfo(wrap);
  }
  function lzShowAll(id){   // [모두 표시] — 남은 행을 한 번에 (검색·복사용)
    var wrap=document.getElementById(id), z=wrap&&wrap._lz; if(!z || z.from>=z.list.length) return;
    var tb=wrap.querySelector('tbody'); if(!tb) return;
    var s=''; for(var i=z.from;i<z.list.length;i++) s+=z.rowFn(z.list[i]);
    tb.insertAdjacentHTML('beforeend', s); z.from=z.list.length; lzInfo(wrap);
  }
  function lzBind(wrap){
    if(wrap._lzBound) return; wrap._lzBound=1;   // 컨테이너는 그대로 있고 안쪽만 갈리므로 한 번만 건다
    wrap.addEventListener('scroll', function(){
      var z=wrap._lz; if(!z || z.from>=z.list.length) return;
      if(wrap.scrollTop+wrap.clientHeight >= wrap.scrollHeight-60) lzFill(wrap);   // 바닥 60px 전에 미리 채운다
    });
    window.addEventListener('resize', function(){ if(wrap._lz && wrap.querySelector('table')) lzFit(wrap); });
  }
  function lzInfo(wrap){
    var z=wrap._lz; if(!z || !z.pager) return;
    var pg=document.getElementById(z.pager); if(!pg) return;
    var tot=z.list.length, shown=Math.min(z.from, tot);
    if(z.from>=tot){ pg.innerHTML = tot>z.rows
        ? '<span style="color:#9aa7b3;font-size:12px">총 '+tot.toLocaleString()+'행 — 모두 표시됨</span>' : '';
      return; }
    pg.innerHTML='<span style="color:#5a6b7a;font-size:12px">'+shown.toLocaleString()+' / <b>'+tot.toLocaleString()+'</b>행'
      +' <span style="color:#9aa7b3">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
      +' <button type="button" onclick="lzShowAll(\''+wrap.id+'\')" style="margin-left:8px" title="남은 행을 한 번에 펼칩니다(검색·복사용)">모두 표시</button>';
  }
  // 매출내역 4탭 — 위 공통 표에 얹기 (호출부는 list/rowFn 만 넘긴다)
  function _ohIdent(s){ return s; }
  function _ohMount(wrap, head, list, rowFn){
    lzMount({ wrap:wrap, pager:'ohPager', head:head, list:list, rowFn:rowFn, rows:OH_ROWS, capTop:214, fill:true });
  }
  /* ══ 매출내역 기간 빠른 선택 (2026-07-27 요청) ═══════════════════════════════
     당일 / 1주일(오늘 포함 최근 7일) / 해당월(1일~오늘, 말일 아님) / 직접 입력.
     · 프리셋 3개는 누르는 즉시 조회, '직접 입력'은 날짜만 열어 두고 [조회]를 기다린다.
     · 모드는 `_ohRg` 에 담되 **날짜칸 값과 어긋나면 자동으로 '직접 입력'으로 내려간다**
       (`ohRangeSync`) — 손으로 날짜를 고치거나 업로드가 기간을 바꿔도(slsSyncDates)
       버튼 표시가 실제 조회기간과 거짓말하지 않게. ★버튼 색만 바꾸고 조회는 안 한다. */
  var _ohRg='d';                                   // 진입 기본 = 당일 (2026-07-27 사용자 요청, 종전 '해당월')
  function _ohDayShift(n){ var d=new Date(); d.setDate(d.getDate()+n); return d.getFullYear()+'-'+ssPad(d.getMonth()+1)+'-'+ssPad(d.getDate()); }
  function _ohRgRange(m){
    if(m==='d') return [SS_TODAY, SS_TODAY];
    if(m==='w') return [_ohDayShift(-6), SS_TODAY];            // 오늘 포함 7일
    if(m==='m') return [SS_TODAY.slice(0,7)+'-01', SS_TODAY];  // 이번 달 1일 ~ 오늘
    return null;                                               // 'c' = 직접 입력
  }
  function ohRangeSync(){
    var fe=document.getElementById('slsFrom'), te=document.getElementById('slsTo');
    if(!fe || !te) return;   // ★head 로드 시점엔 패널이 아직 없다 — 빈 값으로 비교하면 기본(당일)이 '직접 입력'으로 내려간다
    var f=fe.value||'', t=te.value||'';
    var r=_ohRgRange(_ohRg);
    if(r && (f!==r[0] || t!==r[1])) _ohRg='c';                 // 칸을 손대면 직접 입력으로
    [['d','ohRgD'],['w','ohRgW'],['m','ohRgM'],['c','ohRgC']].forEach(function(p){
      var b=document.getElementById(p[1]); if(b) b.className=(p[0]===_ohRg)?'btn-teal':'btn-line';
    });
  }
  function ohRange(m){
    _ohRg=m;
    var r=_ohRgRange(m);
    if(!r){ ohRangeSync(); var e=document.getElementById('slsFrom');   // 직접 입력 — 시작일 칸으로 넘긴다
            if(e){ e.focus(); if(e.showPicker){ try{ e.showPicker(); }catch(x){} } } return; }
    var a=document.getElementById('slsFrom'), b=document.getElementById('slsTo');
    if(a) a.value=r[0];
    if(b) b.value=r[1];
    ohRangeSync();
    ohQuery();                                                 // 프리셋은 누르는 즉시 조회
  }
  // 진입 기본값 = 당일(오늘 하루) — 기본 모드 `_ohRg='d'` 와 반드시 같아야 한다
  //  (어긋나면 ohRangeSync 가 곧바로 '직접 입력'으로 내려버린다)
  function slsInit(){
    var f=document.getElementById('slsFrom'), t=document.getElementById('slsTo');
    if(f && !f.value) f.value=SS_TODAY;
    if(t && !t.value) t.value=SS_TODAY;
    ohRangeSync();
  }
  // 업로드 후 = 엑셀 납품일자가 속한 '달 전체'(1일~말일)로 조회기간 셋팅
  //  · 여러 달이 섞이면 가장 이른 달 1일 ~ 가장 늦은 달 말일
  function slsSyncDates(){
    var all=[];
    _slsFiles.forEach(function(f){ f.rows.forEach(function(r){ if(r.dlvDt) all.push(r.dlvDt); }); });
    if(!all.length) return;
    all.sort();
    var a=all[0], z=all[all.length-1];
    var y1=+a.slice(0,4), m1=+a.slice(5,7);
    var y2=+z.slice(0,4), m2=+z.slice(5,7);
    var last=new Date(y2, m2, 0).getDate();
    var f=document.getElementById('slsFrom'), t=document.getElementById('slsTo');
    if(f) f.value=y1+'-'+ssPad(m1)+'-01';
    if(t) t.value=y2+'-'+ssPad(m2)+'-'+ssPad(last);
    ohRangeSync();   // 업로드가 기간을 바꿨으니 기간 버튼 표시도 맞춘다(대개 '직접 입력'으로 내려감)
  }
  document.addEventListener('DOMContentLoaded', function(){ ssInit(); slsInit(); });
  (function(){ ssInit(); slsInit(); })();

  /* ══════════════════════════════════════════════════════════════════════════
     정산실적 (2026-08-02 요청) — 좌측 메뉴 [매출 관리 ▸ 정산실적]
     출고장이 준 **정산서 원본(TBL_SALES_MST)** 을 일자별·품목별로 그대로 펴서 본다.
     거래처(웰스토리) 쪽 '일자별/품목별납품실적조회' 화면과 같은 칸 구성.

     ★새 수집이 없다 — selectSalesMst 가 이미 전부 내려준다
       (발주량 ORD_QTY · 입고량 OUT_QTY · 정산수량 SETTLE_QTY · 납품유형 DLV_TYPE · 규격 · 단위 · 입고일자 OUT_DT).
     ★'매입금액' 칸은 만들지 않았다 — 우리 DB에 없는 값이다. 그 화면의 매입금액은
       거래처가 우리에게 줄 돈이라 우리 입장에서는 정산금액이 곧 받을 돈이다.
       매입가 이력으로 추정치를 넣을 수는 있지만 실제 청구액이 아니라 오해를 부른다.
     ★입고량이 음수(반품)면 금액도 음수로 온다 — 원본 그대로 보여 주고 색만 붉게 준다.
     ══════════════════════════════════════════════════════════════════════════ */
  var _spRows=[];
  /* 정산실적 전용 접기 상태 — ★ohGrp/_ohCol 을 쓰면 안 된다. 그건 매출내역(ohRender)을 다시 그려서
     이 화면이 통째로 사라진다. 키는 g1:묶음 / g2:묶음|출고장. 기본은 둘 다 펼침. */
  var _spCol={}, _spAllCol=false;                 // _spAllCol = 전체 접힘 여부(기본 펼침)
  /* 개별 지정(_spCol)이 있으면 그것을, 없으면 전체 상태(_spAllCol)를 따른다 —
     매출내역의 _ohIsCol2 와 같은 방식이라 조작감이 같다. */
  function _spIsCol(k){ return (k in _spCol) ? _spCol[k] : _spAllCol; }
  function spGrp(k){
    k=decodeURIComponent(k);
    _spCol[k]=!_spIsCol(k);
    _ohKeepScroll(spRender);        // 접었다 펴도 화면이 맨 위로 튀지 않게
  }
  /* 전체 접기/펼치기 — 개별 지정을 지우고 전체 상태만 남긴다(안 지우면 한두 개가 반대로 남는다) */
  function spAllToggle(){
    _spAllCol=!_spAllCol; _spCol={};
    _ohKeepScroll(spRender);
  }
  function _spUpdAllBtn(){
    var b=document.getElementById('spAllBtn');
    if(b) b.innerHTML = _spAllCol ? '⊞ 전체 펼치기' : '⊟ 전체 접기';
  }
  function spEnter(){
    var f=document.getElementById('spFrom');
    if(f && !f.value){ spRange('m'); return; }     // 첫 진입 = 이번 달
    if(!_spRows.length) spLoad();
  }
  function spRange(k){
    var r=_ohRgRange(k==='d'?'d':(k==='w'?'w':'m'));
    var f=document.getElementById('spFrom'), t=document.getElementById('spTo');
    if(f) f.value=r[0]; if(t) t.value=r[1];
    spLoad();
  }
  /* 매입단가 맵 — 매입금액 칸의 원천 (2026-08-02 요청).
       ★값은 TBL_PROD_MST.IN_PRICE 를 쓴다. 매입가 이력(TBL_PROD_INPRICE_HST)에 새로 입력하면
         서버가 syncProdInPrice 로 이 칸을 같이 갱신하므로 = **가장 최근 입력한 매입가** 다.
       ★한계 : 이력 조회(selectInpriceList)는 PROD_SEQ 1건씩만 되어 그리드에서 쓸 수 없다.
         그래서 '납품일자 시점의 단가'가 아니라 '최신 단가'다. 과거 기간을 볼 때 단가가 바뀌었으면
         그만큼 어긋난다 — 일자 기준으로 맞추려면 서버 조회를 새로 만들어야 한다(WAR 재빌드).
       ★정산서의 품목코드는 거래처 코드일 수 있어, 매칭코드·연결코드에도 같은 단가를 걸어 둔다. */
  var _spInPrice=null;
  function _spLoadInPrice(cb){
    if(_spInPrice){ cb(); return; }
    var m={}, left=3, seq={};
    var done=function(){ if(--left===0){ _spInPrice=m; cb(); } };
    var post=function(u){ return fetch(KONET_CTX+u, { method:'POST', credentials:'same-origin',
        headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
        .then(function(r){ return r.json(); }).then(function(j){ return (j&&j.data)||[]; }); };
    post('/prod/prodList.do').then(function(a){
      a.forEach(function(o){ var c=String(o.prodCd||'').trim(); if(!c) return;
        var v=(o.inPrice==null?null:+o.inPrice); m[c]=v; if(o.prodSeq!=null) seq[o.prodSeq]=v; }); done();
    }).catch(done);
    post('/prod/extItemList.do').then(function(a){
      a.forEach(function(o){ var e=String(o.extItemCd||'').trim(), p=String(o.prodCd||'').trim();
        if(e && p && !(e in m)) m[e]=(p in m)?m[p]:null; }); done();
    }).catch(done);
    post('/prod/xrefList.do').then(function(a){
      a.forEach(function(o){ var e=String(o.extItemCd||'').trim(), p=String(o.prodCd||'').trim();
        if(e && p && !(e in m)) m[e]=(p in m)?m[p]:null; }); done();
    }).catch(done);
  }
  function _spPrice(r){
    if(!_spInPrice) return null;
    var c=String(r.itemCd||'').trim();
    var v=_spInPrice[c];
    return (v==null || isNaN(v)) ? null : +v;
  }
  function spLoad(){
    var f=(document.getElementById('spFrom')||{}).value||'';
    var t=(document.getElementById('spTo')||{}).value||'';
    var ic=(document.getElementById('spItem')||{}).value||'';
    var sum=document.getElementById('spSum'); if(sum) sum.textContent='조회 중…';
    fetch(KONET_CTX+'/sales/selectSalesMst.do', { method:'POST', credentials:'same-origin',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'dlvDtFrom='+encodeURIComponent(f)+'&dlvDtTo='+encodeURIComponent(t)+'&itemCd='+encodeURIComponent(ic) })
      .then(function(r){ return r.json(); })
      .then(function(j){ _spRows=(j&&j.data)||[];
        /* 매입단가는 늦게 와도 화면을 막지 않는다 — 먼저 그리고, 도착하면 표만 다시 그린다 */
        spRender(); _spLoadInPrice(function(){ spRender(); }); })
      .catch(function(e){ if(sum) sum.textContent='통신오류: '+e.message; });
  }
  /* 납품유형 — **입고량 부호로만** 판정한다 (2026-08-02 사용자 확정: "마이너스만 반품").
       ★정산서 원본의 DLV_TYPE 은 판정에 쓰지 않는다 — 비어 오거나 실제 부호와 어긋나는 자료가 있어,
         그대로 믿으면 반품 건수·필터가 수량과 안 맞는다. 원본 값은 칸의 hover 로만 남긴다. */
  function _spType(r){ return ((+r.outQty||0) < 0) ? '반품' : '납품'; }
  function _spTypeTip(r){
    var v=(''+(r.dlvType||'')).trim(), t=_spType(r);
    if(!v)     return '정산서 원본에 납품유형이 비어 있어 입고량 부호로 판정했습니다';
    if(v!==t)  return '정산서 원본 표기: ' + v + ' (입고량 부호로는 ' + t + ')';
    return '정산서 원본 표기와 같습니다';
  }
  /* ══ 정산실적 전용 출고장 다중선택 (2026-08-02 요청) ══════════════════════
       대시보드·매출내역과 같은 방식(1단 묶음 / 2단 개별, 아무것도 안 고르면 전체).
       ★상태(_spDcSel)와 DOM id 를 매출내역(_ohDcSel/ohDc*)과 따로 둔다 —
         같이 쓰면 한 화면에서 고른 출고장이 다른 화면 조회까지 바꿔 버린다.
       ★목록은 '조회된 자료에 실제로 있는 출고장'으로 만든다(없는 곳을 고르면 0건이라 혼란).
       ★거르기는 서버 재조회 없이 화면에서만 한다 — 원본 _spRows 는 그대로 두고 그릴 때 거른다. */
  var _spDcSel={};
  function spDcOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('spDcPop'); if(p) p.classList.toggle('open'); }
  function spDcToggle(k){ if(_spDcSel[k]) delete _spDcSel[k]; else _spDcSel[k]=1; spRender(); }
  function spDcAll(){ _spDcSel={}; spRender(); }
  function _spDcHit(dc){
    if(!Object.keys(_spDcSel).length) return true;
    return !!(_spDcSel[dc] || _spDcSel[_ohDcGrp(dc)]);
  }
  document.addEventListener('click', function(e){
    var w=document.getElementById('spDcWrap'), p=document.getElementById('spDcPop');
    if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
  });
  function spDcSync(){
    var pop=document.getElementById('spDcPop'), lbl=document.getElementById('spDcLbl');
    if(!pop) return;
    var grp={}, ord=[];
    (_spRows||[]).forEach(function(r){
      var dc=_ohDcOf(r); if(!dc) return;
      var g=_ohDcGrp(dc);
      if(!grp[g]){ grp[g]={}; ord.push(g); }
      grp[g][dc]=1;
    });
    ord.sort(function(a,b){ return a.localeCompare(b,'ko'); });
    var live={}; ord.forEach(function(g){ live[g]=1; Object.keys(grp[g]).forEach(function(k){ live[k]=1; }); });
    Object.keys(_spDcSel).forEach(function(k){ if(!live[k]) delete _spDcSel[k]; });   // 기간을 바꿔 사라진 선택 정리
    var n=Object.keys(_spDcSel).length;
    if(lbl) lbl.textContent = n===0 ? '전체' : (n===1 ? Object.keys(_spDcSel)[0] : n+'곳 선택');
    var h='<label class="all'+(n===0?' on':'')+'"><input type="checkbox"'+(n===0?' checked':'')
        + ' onchange="spDcAll()"><span>전체 ('+ord.length+'개 물류센터)</span></label>';
    ord.forEach(function(g){
      var kids=Object.keys(grp[g]).sort(function(a,b){ return a.localeCompare(b,'ko'); });
      var on=!!_spDcSel[g];
      h+='<label class="'+(on?'on':'')+'"><input type="checkbox"'+(on?' checked':'')
       + ' data-k="'+_cesc(g)+'" onchange="spDcToggle(this.getAttribute(&#39;data-k&#39;))">'
       + '<span>🗂️ '+_cesc(g)+(kids.length>1?' <span style="color:#9aa7b3">('+kids.length+'곳)</span>':'')+'</span></label>';
      if(kids.length<2) return;
      kids.forEach(function(k){
        var kon=!!_spDcSel[k];
        h+='<label class="kid'+(kon?' on':'')+'"><input type="checkbox"'+(kon?' checked':'')
         + ' data-k="'+_cesc(k)+'" onchange="spDcToggle(this.getAttribute(&#39;data-k&#39;))"><span>'+_cesc(k)+'</span></label>';
      });
    });
    pop.innerHTML=h;
  }
  function spRender(){
    var wrap=document.getElementById('spWrap'), sum=document.getElementById('spSum');
    if(!wrap) return;
    spDcSync();                                   // 고를 수 있는 출고장 목록·라벨 갱신
    var ty=(document.getElementById('spType')||{}).value||'';
    var rows=_spRows.filter(function(r){
      if(ty && _spType(r)!==ty) return false;
      return _spDcHit(_ohDcOf(r));                // 출고장 선택 (없으면 전체)
    });
    /* ★금액 두 가지를 섞지 말 것 (2026-08-02 확정)
         입고금액 = saleAmt  ← 정산서 엑셀의 '매입금액' 칸 (입고량 × 단가). 거래처가 우리에게 줄 돈.
         정산금액 = settleAmt ← 정산서 엑셀의 '정산금액' 칸 (정산수량 × 단가).
       처음에 정산금액 자리에 saleAmt 를 넣어 두 값이 뒤바뀌어 있었다. */
    /* ★정산서는 '정산 전'과 '정산 후' 두 시점에 올 수 있다 (2026-08-02 확정).
         · 정산 후(확정본) : SETTLE_QTY/SETTLE_AMT 에 값이 있다  → 그 값을 쓴다
         · 정산 전         : 두 칸이 0 이고 OUT_QTY/SALE_AMT 만 있다 → 그것으로 대체해 보여 준다
       ★컬럼(정산수량·정산금액)은 **항상 고정**이다 — 파일에 따라 칸이 생겼다 사라지면 못 쓴다.
         대체로 채운 값은 회색으로 표시하고 hover 로 근거를 남긴다(확정값과 눈으로 구분되게). */
    var _setQ=function(r){ var v=+r.settleQty||0;
      return Math.abs(v)>1e-9 ? {v:v, est:false} : {v:(+r.outQty||0), est:true}; };
    var _setA=function(r){ var v=+r.settleAmt||0;
      return Math.abs(v)>1e-9 ? {v:v, est:false} : {v:(+r.saleAmt||0), est:true}; };
    var tOrd=0,tIn=0,tInAmt=0,tSet=0,tAmt=0,tCost=0, nRet=0, noCost=0, nEst=0;
    rows.forEach(function(r){
      tOrd+=(+r.ordQty||0); tIn+=(+r.outQty||0); tInAmt+=(+r.saleAmt||0);
      var eq=_setQ(r), ea=_setA(r);
      tSet+=eq.v; tAmt+=ea.v; if(ea.est) nEst++;
      /* ★매입원가 기준수량 = **입고량**(2026-08-02 확정) — 매입금액(=입고량×단가)과 같은 기준이라야
           둘을 나란히 놓고 마진을 볼 수 있다. 정산수량 기준이면 미정산 구간에서 원가가 0 이 되어 비교가 안 된다. */
      var pc=_spPrice(r);
      if(pc==null){ if(_spInPrice) noCost++; } else tCost+=(+r.outQty||0)*pc;
      if(_spType(r)==='반품') nRet++;
    });
    if(sum) sum.innerHTML='총 <b>'+rows.length.toLocaleString()+'</b>행'
      +(nRet?(' · <span style="color:#c0392b;font-weight:800">반품 '+nRet.toLocaleString()+'행</span>'):'')
      +' · 발주량 <b>'+_ohQ(tOrd)+'</b> · 입고량 <b>'+_ohQ(tIn)+'</b> · 정산수량 <b>'+_ohQ(tSet)+'</b>'
      +' · <span style="color:#137a6c">정산금액 <b>'+_cnum(tAmt)+'</b></span>'
      +(nEst?(' <span style="color:#9aa7b3;font-size:11.5px" title="정산서에 정산금액이 아직 없어 입고금액(매입금액)으로 대신 잡은 행입니다.">(정산 전 '+nEst.toLocaleString()+'행 포함)</span>'):'')
      +' · 매입금액 <b>'+_cnum(tInAmt)+'</b>'
      +' · <span style="color:#a85700">매입원가 <b>'+_cnum(tCost)+'</b></span>'
      +(noCost?(' <span style="color:#c0392b;font-size:11.5px">※ 매입가 없는 품목 '+noCost+'행 제외</span>'):'')

    /* 칸 14개 — 머리글과 자료줄 수가 어긋나면 값이 통째로 밀린다(2026-08-02에 실제로 겪음). 늘릴 때 같이 고칠 것. */
    /* 칸 순서는 거래처(웰스토리) 화면과 같게 맞춘다 (2026-08-02 요청) —
         … 발주량 · 입고량 · 정산수량 · 단가 · 정산금액 · 매입금액 · 매입원가 · 납품유형
       ★'매입금액' 은 정산서 엑셀의 그 칸(saleAmt) 이름 그대로다 = 입고량 × 단가 (우리가 받을 돈).
         '매입원가' 는 코네트가 사 온 값(매입가 이력) × 정산수량 (우리가 쓴 돈). 이름이 비슷하니 섞지 말 것.
       ★칸 16개(항번 제외, 2026-08-02) — 머리글/총합계/그룹줄/자료줄 수가 어긋나면 값이 통째로 밀린다. 늘릴 때 네 곳 다 고칠 것. */
    var head='<table class="logi-tb"><thead><tr>'
      +'<th>납품일자</th><th>입고일자</th><th>출고장</th><th>발주번호</th>'
      +'<th>품목코드</th><th>품목명</th><th>규격</th><th>단위</th>'
      +'<th style="text-align:right">발주량</th>'
      +'<th style="text-align:right" title="정산서 원본의 &quot;입고량&quot; — 거래처가 받은 수량입니다. 반품이면 음수로 옵니다.">입고량</th>'
      +'<th style="text-align:right" title="정산 확정본(SETTLE_QTY)이 오면 그 값, 아직이면 입고량(OUT_QTY)으로 대체해 보여 줍니다.&#10;대체된 값은 회색으로 표시됩니다.">정산수량</th>'
      +'<th style="text-align:right">단가</th>'
      +'<th style="text-align:right" title="정산 확정본(SETTLE_AMT)이 오면 그 값, 아직이면 매입금액(SALE_AMT=입고량×단가)으로 대체해 보여 줍니다.&#10;대체된 값은 회색으로 표시됩니다.">정산금액</th>'
      +'<th style="text-align:right" title="정산서 원본의 &quot;매입금액&quot; 칸 = 입고량 × 단가.&#10;거래처가 우리에게 줄 돈입니다(우리 매출).">매입금액</th>'
      +'<th style="text-align:right" title="입고량 × 매입단가 (매입금액과 같은 수량 기준)&#10;매입단가는 상품코드등록의 매입가 이력에 마지막으로 입력한 값(TBL_PROD_MST.IN_PRICE)입니다 = 코네트가 사 온 값.&#10;※ 납품일자 시점의 단가가 아니라 최신 단가라, 기간 중 단가가 바뀌었다면 그만큼 차이가 납니다.&#10;※ 매입가를 안 넣은 품목은 - 로 둡니다.">매입원가<br><span style="font-weight:400;font-size:10.5px">입고량×매입가</span></th>'
      +'<th>납품유형</th></tr></thead><tbody>';
    /* ★[전체 접기/펼치기] 버튼은 표 안이 아니라 요약줄 오른쪽 끝(#spAllBtn)에 있다 —
         매출내역(#ohAllBtn)과 같은 자리로 맞춘 것(2026-08-02). 여기서는 글자만 갱신한다. */
    _spUpdAllBtn();
    var totRow='<tr class="close-total"><td colspan="8">■ 총합계</td>'
      +'<td style="text-align:right">'+_ohQ(tOrd)+'</td>'
      +'<td style="text-align:right">'+_ohQ(tIn)+'</td>'
      +'<td style="text-align:right">'+_ohQ(tSet)+'</td>'
      +'<td></td>'
      +'<td style="text-align:right">'+_cnum(tAmt)+'</td>'
      +'<td style="text-align:right">'+_cnum(tInAmt)+'</td>'
      +'<td style="text-align:right">'+_cnum(tCost)+'</td><td></td></tr>';
    /* ── 출고장 그룹 (2026-08-02 요청) ────────────────────────────────────
         1단 = 물류센터 묶음(_ohDcGrp) — ★오산센터(왜관·김해·광주·제주·오산)처럼
               여러 출고장을 하나로 묶는 규칙을 다른 화면과 **같은 함수**로 쓴다.
               여기서 따로 만들면 화면마다 묶음이 달라져 숫자가 안 맞아 보인다.
         2단 = 개별 출고장.  묶음에 출고장이 1곳뿐이면 1단 머리행은 만들지 않는다(줄만 늘어난다).
       ★접기/펼치기는 ohGrp 를 쓰면 안 된다 — 그건 매출내역(ohRender)을 다시 그린다. 전용 spGrp 사용. */
    var L=[], lm={};
    rows.forEach(function(r){
      var dc=_ohDcOf(r)||'(출고장 미지정)', lbl=_ohDcGrp(dc);
      var e=lm[lbl]; if(!e){ e=lm[lbl]={ label:lbl, gs:{}, gOrd:[], ord:0, inq:0, inamt:0, set:0, amt:0, cost:0, n:0 }; L.push(e); }
      var g=e.gs[dc]; if(!g){ g=e.gs[dc]={ dc:dc, rows:[], ord:0, inq:0, inamt:0, set:0, amt:0, cost:0 }; e.gOrd.push(dc); }
      var pc=_spPrice(r), c=(pc==null?0:(+r.outQty||0)*pc);      // 매입원가 = 입고량 × 매입가
      var q2=_setQ(r).v, a2=_setA(r).v;                            // 정산 확정값, 없으면 입고량/매입금액으로 대체
      g.rows.push(r);
      g.ord+=(+r.ordQty||0); g.inq+=(+r.outQty||0); g.inamt+=(+r.saleAmt||0); g.set+=q2; g.amt+=a2; g.cost+=c;
      e.ord+=(+r.ordQty||0); e.inq+=(+r.outQty||0); e.inamt+=(+r.saleAmt||0); e.set+=q2; e.amt+=a2; e.cost+=c; e.n++;
    });
    L.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    L.forEach(function(e){ e.gOrd.sort(function(a,b){ return a.localeCompare(b,'ko'); }); });

    var list=[];
    L.forEach(function(e){
      var multi=e.gOrd.length>1;
      if(multi){ list.push({t:'G',e:e}); if(_spIsCol('g1:'+e.label)) return; }
      e.gOrd.forEach(function(dc){
        list.push({t:'g',e:e,dc:dc,ind:multi});
        if(_spIsCol('g2:'+e.label+'|'+dc)) return;
        e.gs[dc].rows.forEach(function(r){ list.push({t:'r',r:r}); });
      });
    });

    if(!rows.length){
      wrap.innerHTML=head+totRow+'<tr><td colspan="16" style="text-align:center;color:#9aa7b3;padding:22px">'
        +'조회된 정산서 자료가 없습니다. (기간·품목·납품유형을 확인하세요)</td></tr></tbody></table>';
      var pg0=document.getElementById('spPager'); if(pg0) pg0.innerHTML='';
      return;
    }
    var _num=function(v,red){ return '<td style="text-align:right'+((red&&(+v||0)<0)?';color:#c0392b !important;font-weight:800':'')+'">'+_ohQ(v)+'</td>'; };
    var _amt=function(v){ return '<td style="text-align:right'+((+v||0)<0?';color:#c0392b !important;font-weight:800':'')+'">'+_cnum(v)+'</td>'; };
    var gRow=function(o, kind, label, ind, cnt){
      var col=_spIsCol(kind), car=col?'▶':'▼';
      var q=String.fromCharCode(39);   // 작은따옴표 — 문자열 안에서 이스케이프하지 않으려고 코드로 만든다
      return '<tr class="'+(ind===null?'close-grp':'close-sub')+'" style="cursor:pointer" onclick="spGrp('+q+encodeURIComponent(kind)+q+')">'
        +'<td colspan="8"'+(ind?' style="padding-left:24px"':'')+'>'
        +'<span class="ccar">'+car+'</span> '+(ind===null?'🗂️':'🏭')+' '+_cesc(label)
        +' <span style="font-weight:600;color:#5a6b7a">('+cnt+')</span></td>'
        +_num(o.ord)+_num(o.inq,true)+_num(o.set,true)+'<td></td>'
        +_amt(o.amt)+_amt(o.inamt)+_amt(o.cost)+'<td></td></tr>';
    };
    var rowFn=function(x){
      if(x.t==='G') return gRow(x.e, 'g1:'+x.e.label, x.e.label, null, x.e.gOrd.length+'곳 · '+x.e.n+'행');
      if(x.t==='g'){ var g=x.e.gs[x.dc]; return gRow(g, 'g2:'+x.e.label+'|'+x.dc, x.dc, x.ind, g.rows.length+'행'); }
      var r=x.r;
      var ret=(_spType(r)==='반품'), neg=function(v){ return (+v||0)<0 ? ';color:#c0392b !important;font-weight:800' : ''; };
      /* 납품일자 칸에 '어느 정산서 파일에서 온 행인지'를 hover 로 붙인다 (2026-08-02 요청).
         이 화면은 정산서 테이블만 읽으므로 모든 행이 정산서에서 온 것이지만,
         미정산 행을 보면 "정산서가 온 게 맞나?" 를 반복해서 묻게 된다 — 근거를 바로 볼 수 있게 둔다.
         칸을 새로 만들지 않는 이유 = 이미 16칸이라 가로가 빠듯하다. */
      var srcTip = '정산서 파일: ' + (r.srcFile || '(파일명 없음)')
                 + (r.uploadDttm ? ('&#10;업로드: ' + r.uploadDttm) : '')
                 + '&#10;이 화면의 모든 행은 정산서에서 온 것입니다.';
      return '<tr><td title="'+_cesc(srcTip)+'" style="cursor:help">'+_cesc(_ohDateFmt(r.dlvDt))+'</td><td>'+_cesc(_ohDateFmt(r.outDt))+'</td>'
        +'<td>'+_cesc(r.dcNm||'')+'</td><td>'+_cesc(r.ordNo||'')+'</td>'
        +'<td>'+_cesc(r.itemCd||'')+'</td>'
        +'<td class="txt-l sp-nm" title="'+_cesc(r.itemNm||'')+'">'+_cesc(r.itemNm||'')+'</td>'
        +'<td class="txt-l sp-spec" title="'+_cesc(r.spec||'')+'">'+_cesc(r.spec||'')+'</td>'
        +'<td>'+_cesc(r.unit||'')+'</td>'
        +'<td style="text-align:right">'+_ohQ(r.ordQty)+'</td>'
        +'<td style="text-align:right'+neg(r.outQty)+'">'+_ohQ(r.outQty)+'</td>'
        +(function(){ var q=_setQ(r);
            return '<td style="text-align:right;'+(q.est?'color:#8a95a1':'')+neg(q.v)
              +'" title="'+(q.est?'정산 확정 전 — 입고량으로 대체':'정산 확정값(SETTLE_QTY)')+'">'+_ohQ(q.v)+'</td>'; })()
        +'<td style="text-align:right">'+_cnum(r.salePrice)+'</td>'
        +(function(){ var a=_setA(r);
            return '<td style="text-align:right;'+(a.est?'color:#8a95a1':'')+neg(a.v)
              +'" title="'+(a.est?'정산 확정 전 — 매입금액(입고량×단가)으로 대체':'정산 확정값(SETTLE_AMT)')+'">'+_cnum(a.v)+'</td>'; })()
        +'<td style="text-align:right'+neg(r.saleAmt)+'">'+_cnum(r.saleAmt)+'</td>'
        +(function(){
            var pc=_spPrice(r);
            if(pc==null) return '<td style="text-align:right;color:#c8ced4" title="이 품목은 매입가가 등록돼 있지 않습니다">-</td>';
            var v=(+r.outQty||0)*pc;      // 매입금액과 같은 기준(입고량) — 미정산이어도 원가가 나온다
            return '<td style="text-align:right'+neg(v)+'" title="입고량 '+_ohQ(r.outQty)+' × 매입가 '+_cnum(pc)+'&#10;매입금액(입고량×단가)과 같은 수량 기준이라 두 금액을 그대로 비교할 수 있습니다.">'+_cnum(v)+'</td>'; })()
        +'<td title="'+_cesc(_spTypeTip(r))+'">'+(ret?'<span style="color:#c0392b;font-weight:800">반품</span>':_cesc(_spType(r)))+'</td></tr>';
    };
    lzMount({ wrap:wrap, pager:'spPager', head:head+totRow, list:list, rowFn:rowFn,
              rows:KONET_GRID_ROWS, capTop:214, fill:true });

  }

  /* ══════════════════════════════════════════════════════════════════════════
     매출 그래프 탭 (2026-08-02) — 종전 화면 2개(salesChartDay/salesChart)를 iframe 그대로 탭으로.
     ★화면 자체는 안 건드렸다 — 셸에서 갈아끼우기만 한다. 각 탭은 처음 열 때 한 번만 로드(상태 유지).
     ══════════════════════════════════════════════════════════════════════════ */
  function scTabGo(v){
    var fd=document.getElementById('if-saleschartday'), fm=document.getElementById('if-saleschart');
    var bd=document.getElementById('scTabD'), bm=document.getElementById('scTabM');
    if(!fd||!fm) return;
    var on='background:var(--logi-teal);color:#fff;border-color:var(--logi-teal)';
    if(bd) bd.style.cssText='height:32px;padding:0 16px;'+(v==='d'?on:'');
    if(bm) bm.style.cssText='height:32px;padding:0 16px;'+(v==='m'?on:'');
    var f=(v==='d')?fd:fm, url=KONET_CTX+((v==='d')?'/shipout/salesChartDay.do':'/shipout/salesChart.do');
    fd.style.display=(v==='d')?'block':'none';
    fm.style.display=(v==='d')?'none':'block';
    if(!f.getAttribute('src')) f.src=url;          // 처음 열 때만 로드 — 탭을 오가도 조회 상태가 유지된다
  }
  function scTabEnter(){ scTabGo('d'); }           // 진입 기본 = 일자별 (사용자 나열 순서)

  /* ══════════════════════════════════════════════════════════════════════════
     정산 그래프 (2026-08-02) — 정산서(TBL_SALES_MST)의 SALE_AMT 를 일자별/월별로.
       매출  = SALE_AMT 합 (정산실적 화면의 정산금액/매입금액 과 같은 원천 — 화면끼리 숫자가 같아야 한다)
       원가  = 입고량 × 코네트 매입가 (정산실적 매입원가 와 같은 규칙, _spPrice 재사용)
       마진  = 매출 − 원가.  매입가 없는 품목은 원가 0 으로 잡히므로 마진이 부풀 수 있다 — 요약줄에 알린다.
     ★Chart.js 는 셸에 없어서 처음 열 때 /js/Chart.min.js 를 심는다(매출 그래프 화면과 같은 2.7.2).
     ══════════════════════════════════════════════════════════════════════════ */
  var _sgTab='d', _sgChart=null, _sgDcChart=null, _sgRows=[];
  function _sgChartJs(cb){
    if(window.Chart){ cb(); return; }
    var sc=document.createElement('script');
    sc.src=KONET_CTX+'/js/Chart.min.js';
    sc.onload=function(){ if(window.Chart){ Chart.defaults.global.defaultFontColor='#1f2a37'; Chart.defaults.global.defaultFontSize=12; } cb(); };
    sc.onerror=function(){ var el=document.getElementById('sgSum'); if(el) el.textContent='Chart.min.js 를 불러오지 못했습니다.'; };
    document.head.appendChild(sc);
  }
  function sgEnter(){
    var f=document.getElementById('sgFrom');
    if(f && !f.value){
      var r=_ohRgRange('w'); f.value=r[0];   // 일자별 기본 = 최근 1주 (2026-08-02 요청, 매출 그래프(일자별)와 동일)
      var t=document.getElementById('sgTo'); if(t) t.value=r[1];
      sgTab('d'); return;
    }
    if(!_sgRows.length) sgLoad();
  }
  /* 기간 빠른 선택 — 매출 그래프(일자별) sdQuick/sdMonth 와 같은 계산.
     차이 하나: 거기는 날짜만 바꾸고 [조회]를 기다리지만, 여기는 누르는 즉시 조회한다(정산실적과 같은 조작감). */
  function sgQuick(days){
    var f=document.getElementById('sgFrom'), t=document.getElementById('sgTo');
    if(f) f.value=_ohDayShift(-(days-1));
    if(t) t.value=SS_TODAY;
    sgLoad();
  }
  function sgMonth(){
    var f=document.getElementById('sgFrom'), t=document.getElementById('sgTo');
    if(f) f.value=SS_TODAY.slice(0,7)+'-01';
    if(t) t.value=SS_TODAY;
    sgLoad();
  }
  /* 월별 탭 빠른선택 — 매출 그래프(월별) scQuick/scYear 와 같은 계산.
       올해 = 1월~이번 달 · 최근 N개월 = 이번 달 포함 N개월 · 전체 = 기간 비움(서버가 전 기간 반환).
       여기는 누르는 즉시 조회한다(일자별 빠른선택과 같은 조작감). */
  function _sgThisM(){ return SS_TODAY.slice(0,7); }
  function _sgShiftM(n){                       // 이번 달에서 n개월 전 'YYYY-MM'
    var y=+SS_TODAY.slice(0,4), mo=+SS_TODAY.slice(5,7)-1+n;
    var d=new Date(y, mo, 1);
    return d.getFullYear()+'-'+ssPad(d.getMonth()+1);
  }
  function sgMQuick(n){
    var f=document.getElementById('sgMFrom'), t=document.getElementById('sgMTo');
    if(f) f.value = n ? _sgShiftM(-(n-1)) : '';
    if(t) t.value = n ? _sgThisM() : '';
    sgLoad();
  }
  function sgMYear(){
    var f=document.getElementById('sgMFrom'), t=document.getElementById('sgMTo');
    if(f) f.value=SS_TODAY.slice(0,4)+'-01';
    if(t) t.value=_sgThisM();
    sgLoad();
  }
  function sgTab(v){
    _sgTab=v;
    var on='background:var(--logi-teal);color:#fff;border-color:var(--logi-teal)';
    var bd=document.getElementById('sgTabD'), bm=document.getElementById('sgTabM');
    if(bd) bd.style.cssText='height:36px;padding:0 14px;'+(v==='d'?on:'');
    if(bm) bm.style.cssText='height:36px;padding:0 14px;'+(v==='m'?on:'');
    var D=(v==='d');
    ['sgFromWrap','sgToWrap','sgBtnDWrap','sgQuickWrap'].forEach(function(id){ var e=document.getElementById(id); if(e) e.style.display=D?'':'none'; });
    ['sgMFromWrap','sgMToWrap','sgBtnMWrap','sgMQuickWrap'].forEach(function(id){ var e=document.getElementById(id); if(e) e.style.display=D?'none':''; });
    var dcCard=document.getElementById('sgDcCard'); if(dcCard) dcCard.style.display=D?'none':'';
    var tit=document.getElementById('sgMainTit');
    if(tit) tit.innerHTML=(D?'🗓️ 일자별':'🗓️ 월별')+' 매입원가·마진 <span style="font-weight:400; color:#9aa7b3">(합=매출)'+(D?'':' · 최근 달부터')+'</span>';
    if(!D){   // 월별 첫 진입 기본 = 올해 1월~이번 달 (매출 그래프(월별)와 같은 기본값 — 최근 12개월은 빈 달이 많다)
      var f=document.getElementById('sgMFrom');
      if(f && !f.value){ f.value=SS_TODAY.slice(0,4)+'-01'; var t=document.getElementById('sgMTo'); if(t) t.value=_sgThisM(); }
    }
    sgLoad();
  }
  function sgLoad(){
    var sum=document.getElementById('sgSum'); if(sum) sum.textContent='조회 중…';
    var f,t;
    if(_sgTab==='d'){ f=(document.getElementById('sgFrom')||{}).value||''; t=(document.getElementById('sgTo')||{}).value||''; }
    else {
      var mf=(document.getElementById('sgMFrom')||{}).value||'', mt=(document.getElementById('sgMTo')||{}).value||'';
      f = mf ? (mf+'-01') : '';
      t = mt ? (mt+'-31') : '';    // 문자열 비교(YYYYMMDD)라 짧은 달도 '31'이 상한으로 안전하다
    }
    /* 직접판매(판매전표) 포함 (2026-08-02 요청) — 매출내역과 같은 API.
         서버가 정산서 행과 같은 모양으로 주고 trxYn='Y'·출고장='직접판매(전표)' 로 온다.
         ★추정(정산서 미도착 출고)은 여기 안 넣는다 — 출고내역 대사까지 필요해 화면이 무거워지고,
           그 용도는 매출 그래프가 이미 담당한다. */
    var _post=function(url, body){
      return fetch(KONET_CTX+url, { method:'POST', credentials:'same-origin',
          headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:body })
        .then(function(r){ return r.json(); }).then(function(j){ return (j&&j.data)||[]; });
    };
    Promise.all([
      _post('/sales/selectSalesMst.do', 'dlvDtFrom='+encodeURIComponent(f)+'&dlvDtTo='+encodeURIComponent(t)+'&itemCd='),
      _post('/mangr/salesTrxHist.do',   'fromDt='+encodeURIComponent(f)+'&toDt='+encodeURIComponent(t)+'&findData=').catch(function(){ return []; })
    ]).then(function(a){
      _sgRows=(a[0]||[]).concat(a[1]||[]);
      _sgChartJs(function(){ _spLoadInPrice(function(){ sgRender(); }); });
    }).catch(function(e){ if(sum) sum.textContent='통신오류: '+e.message; });
  }
  function sgRender(){
    var rows=_sgRows;
    /* 일자별 = YYYYMMDD 그대로, 월별 = YYYYMM 으로 접는다 */
    var m={}, ord=[], noCost=0;
    rows.forEach(function(r){
      var d=_ohYmd(r.dlvDt)||''; if(!d) return;
      var k=(_sgTab==='d')?d:d.slice(0,6);
      var e=m[k]; if(!e){ e=m[k]={ amt:0, cost:0, n:0 }; ord.push(k); }
      e.amt+=(+r.saleAmt||0); e.n++;
      var pc=_spPrice(r);
      if(pc==null){ if(_spInPrice) noCost++; } else e.cost+=(+r.outQty||0)*pc;
    });
    ord.sort().reverse();   // ★최근 것부터(왼쪽이 최신) — 매출 그래프와 같은 방향(2026-08-02 요청)
    /* 축 라벨 = 07-27(월) · 표 라벨 = 2026-07-27 (월) — 매출 그래프(일자별)와 같은 표기(2026-08-02 요청) */
    var _WD=['일','월','화','수','목','금','토'];
    var _wd=function(k){ return _WD[new Date(+k.slice(0,4), +k.slice(4,6)-1, +k.slice(6,8)).getDay()]; };
    var labels=ord.map(function(k){ return (_sgTab==='d') ? (k.slice(4,6)+'-'+k.slice(6,8)+'('+_wd(k)+')') : (k.slice(0,4)+'-'+k.slice(4,6)); });
    var labelsFull=ord.map(function(k){ return (_sgTab==='d') ? (k.slice(0,4)+'-'+k.slice(4,6)+'-'+k.slice(6,8)+' ('+_wd(k)+')') : (k.slice(0,4)+'-'+k.slice(4,6)); });
    var amt=ord.map(function(k){ return Math.round(m[k].amt); });
    var cost=ord.map(function(k){ return Math.round(m[k].cost); });
    var tA=0,tC=0; ord.forEach(function(k){ tA+=m[k].amt; tC+=m[k].cost; });
    /* ── KPI 카드 (2026-08-02 요청) — 매출 그래프(일자별)의 카드 줄을 정산 용어로.
         · 반품 = 입고량 음수 행(정산실적의 반품 판정과 같은 규칙). 금액도 그 행의 SALE_AMT 합(음수).
         · 일평균/월평균 = 정산이 있는 구간만으로 나눈다(빈 날을 끼우면 평균이 실제보다 작아 보인다).
         · 최고 = 금액이 가장 큰 구간(일자별=하루, 월별=한 달). */
    (function(){
      var kp=document.getElementById('sgKpi'); if(!kp) return;
      var nRet=0, retAmt=0, tTrx=0, nTrx=0;
      rows.forEach(function(r){
        if((+r.outQty||0)<0){ nRet++; retAmt+=(+r.saleAmt||0); }
        if(r.trxYn==='Y'){ nTrx++; tTrx+=(+r.saleAmt||0); }
      });
      var bestK='', bestV=-1;
      ord.forEach(function(k,i){ if(m[k].amt>bestV){ bestV=m[k].amt; bestK=labels[i]; } });
      var unit=(_sgTab==='d')?'일':'월';
      var card=function(nm,val,cls){ return '<div class="k"><span>'+nm+'</span><b'+(cls?(' class="'+cls+'"'):'')+'>'+val+'</b></div>'; };
      kp.innerHTML =
          card('매출 합계', _cnum(tA))
        + card('정산서', _cnum(tA-tTrx))
        + card('직접판매(전표)', nTrx?(_cnum(tTrx)):'0')
        + card('매입원가', _cnum(tC), 'amber')
        + card('마진', _cnum(tA-tC), (tA-tC)<0?'warn':'')
        + card('마진율', tA?(((tA-tC)/tA*100).toFixed(1)+'%'):'-')
        + card('반품', nRet?(nRet.toLocaleString()+'행 · '+_cnum(retAmt)):'없음', nRet?'warn':'')
        + card(_sgTab==='d'?'정산 있는 일':'자료 있는 달', ord.length?(ord.length.toLocaleString()+(_sgTab==='d'?'일':'개월')):'-')
        + card(unit+'평균 (정산 있는 '+unit+')', ord.length?_cnum(Math.round(tA/ord.length)):'-')
        + card('최고 '+(_sgTab==='d'?'하루':'달'), bestV>=0?(_cnum(Math.round(bestV))+' <span style="display:inline;font-size:11px;color:#9aa7b3">('+bestK+')</span>'):'-');
    })();
    var sum=document.getElementById('sgSum');
    var _tTrx2=0; rows.forEach(function(r){ if(r.trxYn==='Y') _tTrx2+=(+r.saleAmt||0); });
    if(sum) sum.innerHTML=(_sgTab==='d'?'일자별':'월별')+' <b>'+ord.length+'</b>구간 · 행 <b>'+rows.length.toLocaleString()+'</b>'
      +' · <span style="color:#137a6c">매출 <b>'+_cnum(tA)+'</b></span>'
      +(_tTrx2?(' <span style="color:#1a73c7">(정산서 '+_cnum(tA-_tTrx2)+' + 직접판매 '+_cnum(_tTrx2)+')</span>'):'')
      +' · <span style="color:#a85700">매입원가 <b>'+_cnum(tC)+'</b></span>'
      +' · 마진 <b>'+_cnum(tA-tC)+'</b>'+(tA?(' ('+((tA-tC)/tA*100).toFixed(1)+'%)'):'')
      +(noCost?(' <span style="color:#c0392b;font-size:11.5px">※ 매입가 없는 품목 '+noCost.toLocaleString()+'행은 원가 미포함 — 마진이 실제보다 커 보일 수 있음</span>'):'');
    var box=document.getElementById('sgCanvas'); if(!box || !window.Chart) return;
    if(_sgChart){ _sgChart.destroy(); _sgChart=null; }   // 안 지우면 겹쳐 그려지고 툴팁이 두 번 뜬다(매출 그래프와 동일)
    /* 막대 값 라벨 (2026-08-02 요청: 항상 표시) — 막대가 좁으면 **세로로 돌려** 막대 위에 쓴다.
         종전에는 폭<30px 이면 생략했는데, 일자별은 한 달만 잡아도 좁아져 라벨이 하나도 안 보였다.
       ★shortAmt 는 salesChart.jsp 안의 함수라 여기(외부 JS)엔 없다 — 그대로 부르면 ReferenceError 로
         차트가 통째로 죽는다(폭 가드 덕에 조용했던 지뢰). 자체 축약(_sgAmtS)을 쓴다. */
    var _sgAmtS=function(v){
      v=Math.round(+v||0);
      var a=Math.abs(v), sg=v<0?'-':'';
      if(a>=100000000) return sg+(a/100000000).toFixed(1).replace(/\.0$/,'')+'억';
      if(a>=10000)     return sg+Math.round(a/10000).toLocaleString()+'만';
      return v.toLocaleString();
    };
    var lbl={ afterDatasetsDraw:function(ch){
      var ctx=ch.ctx; ctx.save();
      ctx.font='700 12.5px Malgun Gothic,sans-serif';   /* 매출 그래프와 같은 크기 (2026-08-02) */
      /* 조각 안 = 그 조각 값(들어갈 때만) · 막대 꼭대기 = 매출 합계(좁으면 세로) — 매출 그래프와 같은 읽기 방식 */
      var m0=ch.getDatasetMeta(0), m1=ch.getDatasetMeta(1);
      ch.data.labels.forEach(function(_, i){
        var e0=m0.data[i], e1=m1.data[i]; if(!e0) return;
        var c=+ch.data.datasets[0].data[i]||0, mg=+ch.data.datasets[1].data[i]||0, tot=c+mg;
        if(!tot && !c) return;
        [ [e0,c,'#7a4b0a'], [e1,mg,'#0d5c30'] ].forEach(function(seg){
          var el=seg[0], v=seg[1]; if(!el || !v) return;
          var md=el._model, h=Math.abs(md.base-md.y);
          if(h>=16 && md.width>=34){
            ctx.fillStyle=seg[2]; ctx.textAlign='center'; ctx.textBaseline='middle';
            ctx.fillText(_sgAmtS(v), md.x, (md.base+md.y)/2);
          }
        });
        var top=(e1&&e1._model)?e1._model:e0._model;   // 마진 조각이 숨김이면 원가 꼭대기
        ctx.fillStyle='#1f2a37';
        if(top.width>=46){
          ctx.textAlign='center'; ctx.textBaseline='bottom';
          ctx.fillText(_sgAmtS(tot), top.x, top.y-3);
        } else {
          ctx.save();
          ctx.translate(top.x, top.y-4); ctx.rotate(-Math.PI/2);
          ctx.textAlign='left'; ctx.textBaseline='middle';
          ctx.fillText(_sgAmtS(tot), 0, 0);
          ctx.restore();
        }
      });
      ctx.restore();
    }};
    _sgChart=new Chart(box.getContext('2d'), {
      type:'bar', plugins:[lbl],
      /* 한 막대 쌓기 (2026-08-02 요청) — 매출 그래프의 [매입·마진] 보기와 같은 구성.
           매입원가(주황) 아래 + 마진(초록) 위 → 막대 전체 높이 = 매출(정산서). */
      data:{ labels:labels, datasets:[
        { label:'매입원가', backgroundColor:'#F5A623', data:cost },
        { label:'마진',     backgroundColor:'#2E9E4F', data:amt.map(function(v,i){ return v-cost[i]; }) }
      ]},
      options:{
        responsive:true, maintainAspectRatio:false,
        layout:{ padding:{ top:52 } },   /* 세로 라벨(최대 '9,999만')이 막대 위로 서므로 그만큼 띄운다 */
        legend:{ position:'bottom', labels:{ usePointStyle:true, boxWidth:8, padding:14, fontSize:12, fontColor:'#1f2a37', fontStyle:'700' } },
        tooltips:{ mode:'index', intersect:false, callbacks:{
          label:function(ti,d){ return d.datasets[ti.datasetIndex].label+' : '+_cnum(ti.yLabel)+'원'; },
          footer:function(tis){ var c=+tis[0].yLabel||0, mg=(tis[1]?+tis[1].yLabel:0)||0, a=c+mg;
            return '매출(정산서) : '+_cnum(a)+'원'+(a?(' · 마진율 '+(mg/a*100).toFixed(1)+'%'):''); }
        }},
        scales:{
          xAxes:[{ stacked:true, gridLines:{ display:false, drawBorder:true, color:'#1f2a37' },
                   ticks:{ fontSize:12, fontColor:'#2b3a48', fontStyle:'700', autoSkip:_sgTab==='d', maxRotation:60 } }],
          yAxes:[{ stacked:true, display:false, gridLines:{ display:false }, ticks:{ beginAtZero:true } }]
        }
      }
    });
    /* ── 아래 표 — 매출 그래프(일자별)와 같은 모양 (2026-08-02 요청) ─────────────
         · 요일 칸 분리, 주말 줄 배경색(일=빨강 글씨·토=파랑 글씨)
         · **조회기간의 모든 날짜를 나열**하고 정산 없는 날은 0 으로 — 빠진 날이 안 보이면 "왜 없지"를 못 잡는다
           (그래프는 매출 그래프처럼 자료 있는 날만 그린다 — 빈 막대로 채우면 옆으로만 길어진다)
         · 스크롤은 CSS(#sgTbl sticky) — 표가 길어도 머리글이 남는다 */
    var tb=document.getElementById('sgTbl');
    if(tb){
      var isD=(_sgTab==='d');
      /* 기간 전체 날짜 나열(일자별) — 기간칸이 비면(전체 등) 자료 있는 날만 */
      var tOrd=ord;
      if(isD){
        var f0=_ohYmd((document.getElementById('sgFrom')||{}).value||''), t0=_ohYmd((document.getElementById('sgTo')||{}).value||'');
        if(f0 && t0 && f0<=t0){
          tOrd=[]; var cur=new Date(+f0.slice(0,4), +f0.slice(4,6)-1, +f0.slice(6,8));
          var end=new Date(+t0.slice(0,4), +t0.slice(4,6)-1, +t0.slice(6,8));
          for(var g=0; cur<=end && g<400; g++){
            tOrd.push(''+cur.getFullYear()+ssPad(cur.getMonth()+1)+ssPad(cur.getDate()));
            cur.setDate(cur.getDate()+1);
          }
        }
      }
      var h='<table class="logi-tb"><thead><tr><th>'+(isD?'일자':'월')+'</th>'
          +(isD?'<th style="width:52px">요일</th>':'')
          +'<th style="text-align:right">행수</th>'
          +'<th style="text-align:right">매출(정산서)</th><th style="text-align:right">매입원가</th>'
          +'<th style="text-align:right">마진</th><th style="text-align:right">마진율</th>'
          +'<th style="text-align:right">비중</th></tr></thead><tbody>';
      h+='<tr class="close-total"><td'+(isD?' colspan="2"':'')+'>■ 합계</td><td style="text-align:right">'+rows.length.toLocaleString()+'</td>'
        +'<td style="text-align:right">'+_cnum(tA)+'</td><td style="text-align:right">'+_cnum(tC)+'</td>'
        +'<td style="text-align:right">'+_cnum(tA-tC)+'</td><td style="text-align:right">'+(tA?((tA-tC)/tA*100).toFixed(1)+'%':'')+'</td>'
        +'<td style="text-align:right">100%</td></tr>';
      /* 일자별 달력 나열(tOrd)은 오름차순으로 만들어져 뒤집고, 월별(tOrd=ord)은 이미 최신순이라 그대로 */
      (isD ? tOrd.slice().reverse() : tOrd.slice()).forEach(function(k){
        var e=m[k]||{amt:0,cost:0,n:0};
        var wd=isD?_wd(k):'', we=(wd==='토'||wd==='일');
        var wdc = wd==='일' ? 'color:#c0392b !important;font-weight:800' : (wd==='토' ? 'color:#1a6fb3 !important;font-weight:800' : '');
        var la = isD ? (k.slice(0,4)+'-'+k.slice(4,6)+'-'+k.slice(6,8)) : (k.slice(0,4)+'-'+k.slice(4,6));
        h+='<tr'+(we?' class="sg-we"':'')+'><td>'+la+'</td>'
          +(isD?('<td style="text-align:center;'+wdc+'">'+wd+'</td>'):'')
          +'<td style="text-align:right">'+(e.n?e.n.toLocaleString():'0')+'</td>'
          +'<td style="text-align:right">'+_cnum(e.amt)+'</td><td style="text-align:right">'+_cnum(e.cost)+'</td>'
          +'<td style="text-align:right'+((e.amt-e.cost)<0?';color:#c0392b !important;font-weight:800':'')+'">'+_cnum(e.amt-e.cost)+'</td>'
          +'<td style="text-align:right">'+(e.amt?((e.amt-e.cost)/e.amt*100).toFixed(1)+'%':'—')+'</td>'
          +'<td style="text-align:right">'+(tA?(e.amt/tA*100).toFixed(1)+'%':'0.0%')+'</td></tr>';
      });
      tb.innerHTML=h+'</tbody></table>';
    }
    /* ── 출고장별 블록 (월별 탭 전용, 2026-08-02) — 매출 그래프(월별)의 왼쪽 블록과 같은 구성.
         묶음 규칙은 다른 화면과 같은 _ohDcGrp(오산센터 = 왜관·김해·광주·제주·오산). */
    if(_sgDcChart){ _sgDcChart.destroy(); _sgDcChart=null; }
    if(_sgTab==='m'){
      var dm={}, dOrd=[];
      rows.forEach(function(r){
        var g=_ohDcGrp(_ohDcOf(r)||'(출고장 미지정)');
        var e=dm[g]; if(!e){ e=dm[g]={ amt:0, cost:0, n:0 }; dOrd.push(g); }
        e.amt+=(+r.saleAmt||0); e.n++;
        var pc=_spPrice(r); if(pc!=null) e.cost+=(+r.outQty||0)*pc;
      });
      dOrd.sort(function(x,y){ return dm[y].amt-dm[x].amt; });   // 매출 큰 곳부터 — 매출 그래프와 같은 정렬
      var dBox=document.getElementById('sgDcCanvas');
      if(dBox && window.Chart){
        _sgDcChart=new Chart(dBox.getContext('2d'), {
          type:'bar', plugins:[lbl],
          data:{ labels:dOrd, datasets:[
            { label:'매입원가', backgroundColor:'#F5A623', data:dOrd.map(function(g){ return Math.round(dm[g].cost); }) },
            { label:'마진',     backgroundColor:'#2E9E4F', data:dOrd.map(function(g){ return Math.round(dm[g].amt-dm[g].cost); }) }
          ]},
          options:{
            responsive:true, maintainAspectRatio:false,
            layout:{ padding:{ top:52 } },
            legend:{ position:'bottom', labels:{ usePointStyle:true, boxWidth:8, padding:14, fontSize:12, fontColor:'#1f2a37', fontStyle:'700' } },
            tooltips:{ mode:'index', intersect:false, callbacks:{
              label:function(ti,d){ return d.datasets[ti.datasetIndex].label+' : '+_cnum(ti.yLabel)+'원'; },
              footer:function(tis){ var c=+tis[0].yLabel||0, mg=(tis[1]?+tis[1].yLabel:0)||0, a2=c+mg;
                return '매출(정산서) : '+_cnum(a2)+'원'+(a2?(' · 마진율 '+(mg/a2*100).toFixed(1)+'%'):''); }
            }},
            scales:{
              xAxes:[{ stacked:true, gridLines:{ display:false, drawBorder:true, color:'#1f2a37' },
                       ticks:{ fontSize:12, fontColor:'#2b3a48', fontStyle:'700', autoSkip:false, maxRotation:40 } }],
              yAxes:[{ stacked:true, display:false, gridLines:{ display:false }, ticks:{ beginAtZero:true } }]
            }
          }
        });
      }
      var dtb=document.getElementById('sgDcTbl');
      if(dtb){
        var dh='<table class="logi-tb"><thead><tr><th>출고장</th><th style="text-align:right">행수</th>'
            +'<th style="text-align:right">매출(정산서)</th><th style="text-align:right">매입원가</th>'
            +'<th style="text-align:right">마진</th><th style="text-align:right">마진율</th>'
            +'<th style="text-align:right">비중</th></tr></thead><tbody>';
        dh+='<tr class="close-total"><td>■ 합계</td><td style="text-align:right">'+rows.length.toLocaleString()+'</td>'
          +'<td style="text-align:right">'+_cnum(tA)+'</td><td style="text-align:right">'+_cnum(tC)+'</td>'
          +'<td style="text-align:right">'+_cnum(tA-tC)+'</td><td style="text-align:right">'+(tA?((tA-tC)/tA*100).toFixed(1)+'%':'')+'</td>'
          +'<td style="text-align:right">100%</td></tr>';
        dOrd.forEach(function(g){
          var e=dm[g];
          dh+='<tr><td class="txt-l">'+_cesc(g)+'</td><td style="text-align:right">'+e.n.toLocaleString()+'</td>'
            +'<td style="text-align:right">'+_cnum(e.amt)+'</td><td style="text-align:right">'+_cnum(e.cost)+'</td>'
            +'<td style="text-align:right'+((e.amt-e.cost)<0?';color:#c0392b !important;font-weight:800':'')+'">'+_cnum(e.amt-e.cost)+'</td>'
            +'<td style="text-align:right">'+(e.amt?((e.amt-e.cost)/e.amt*100).toFixed(1)+'%':'—')+'</td>'
            +'<td style="text-align:right">'+(tA?(e.amt/tA*100).toFixed(1)+'%':'0.0%')+'</td></tr>';
        });
        dtb.innerHTML=dh+'</tbody></table>';
      }
    } else {
      var dtb0=document.getElementById('sgDcTbl'); if(dtb0) dtb0.innerHTML='';
    }
  }
