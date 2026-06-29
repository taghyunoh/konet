$(function () {
    $("form").on("submit", function (event) {
        event.preventDefault(); // 기본 폼 제출 차단
        const isValid = validateForm(); // 유효성 검사 함수
        if (isValid) {
            
        } else {
            
        }
    });

    function validateForm() {
        let isValid = true;
        $("input, textarea").each(function () {
            if (!$(this).val()) {
                isValid = false;
                $(this).addClass("is-invalid");
            } else {
                $(this).removeClass("is-invalid");
            }
        });
        return isValid;
    }
});