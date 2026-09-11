$(document).ready(function () {
  // 페이지네이션 이벤트
  $(".pagination li").click(function () {
    $(".pagination li").removeClass("active");
    $(this).addClass("active");
  });
});
