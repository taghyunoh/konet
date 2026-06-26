/**
 * 관리자 목록 공통 클라이언트 페이징 엔진.
 * 서버에서 전체 목록을 받은 뒤 클라이언트에서 페이지 단위로 렌더링한다.
 *
 * 사용 예)
 *   var pager = new AdminPager({
 *     dataArea : '#dataArea',          // tbody 셀렉터
 *     paging   : '#pagingArea',        // 페이징 바 셀렉터
 *     pageSize : 15,
 *     colspan  : 6,                    // '검색된 정보가 없습니다' 행 colspan
 *     rowHtml  : function(item, idx){ return '<tr>...</tr>'; },  // idx: 0부터 전체연속
 *     onRender : function(){ ... }     // (선택) 페이지 렌더 후 콜백 (행 바인딩 등)
 *   });
 *   pager.setData(list);   // 검색 결과 배열 주입 → 1페이지부터 렌더
 */
function AdminPager(opts){
  this.dataSel  = opts.dataArea;
  this.pagingSel= opts.paging;
  this.rowHtml  = opts.rowHtml;
  this.size     = opts.pageSize || 15;
  this.colspan  = opts.colspan  || 12;
  this.emptyMsg = opts.emptyMsg || '검색된 정보가 없습니다.';
  this.onRender = opts.onRender || null;
  this.list = [];
  this.page = 1;
}
AdminPager.prototype.setData = function(list){
  this.list = list || [];
  this.page = 1;
  this.render();
};
AdminPager.prototype.goPage = function(p){
  if(p < 1) return;
  this.page = p;
  this.render();
};
AdminPager.prototype.render = function(){
  var $a = $(this.dataSel);
  $a.empty();
  var total = this.list.length;
  if(total === 0){
    $a.append("<tr><td colspan='" + this.colspan + "'>" + this.emptyMsg + "</td></tr>");
    this._paging(0);
    return;
  }
  var totalPages = Math.ceil(total / this.size);
  if(this.page > totalPages) this.page = totalPages;
  if(this.page < 1) this.page = 1;
  var start = (this.page - 1) * this.size;
  var end   = Math.min(start + this.size, total);
  var html = "";
  for(var i = start; i < end; i++){
    html += this.rowHtml(this.list[i], i);
  }
  $a.append(html);
  if(this.onRender) this.onRender();
  this._paging(totalPages);
};
AdminPager.prototype._paging = function(totalPages){
  var $p = $(this.pagingSel);
  $p.empty();
  if(totalPages < 1) return;   // 데이터가 있으면 1페이지여도 표시
  var self = this, block = 10;
  var startPage = Math.floor((this.page - 1) / block) * block + 1;
  var endPage   = Math.min(startPage + block - 1, totalPages);
  function btn(label, page, disabled, active){
    return '<button class="pg-btn' + (active ? ' active' : '') + '" '
         + (disabled ? 'disabled' : '') + ' data-page="' + page + '">' + label + '</button>';
  }
  var html = "";
  html += btn('&laquo;', 1, this.page === 1, false);
  html += btn('&lsaquo;', this.page - 1, this.page === 1, false);
  for(var p = startPage; p <= endPage; p++){
    html += btn(p, p, false, p === this.page);
  }
  html += btn('&rsaquo;', this.page + 1, this.page === totalPages, false);
  html += btn('&raquo;', totalPages, this.page === totalPages, false);
  $p.html(html);
  $p.find('.pg-btn').off('click').on('click', function(){
    var pg = parseInt($(this).attr('data-page'), 10);
    if(!isNaN(pg)) self.goPage(pg);
  });
};
