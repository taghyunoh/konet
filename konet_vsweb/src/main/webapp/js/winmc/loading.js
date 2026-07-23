// 로딩 UI 모듈
const LoadingUI = (function () {
    let loadingDiv = null;

    // 로딩 요소 생성
    const createLoadingElement = () => {
        loadingDiv = document.createElement('div');
        loadingDiv.id = 'loading';
        loadingDiv.style.position = 'absolute';
        loadingDiv.style.width = '60px';
        loadingDiv.style.height = '60px';
        loadingDiv.style.border = '6px solid #f3f3f3';
        loadingDiv.style.borderTop = '6px solid #3498db';
        loadingDiv.style.borderRadius = '50%';
        loadingDiv.style.animation = 'spin 1s linear infinite';
        loadingDiv.style.display = 'none'; // 기본적으로 숨김
        loadingDiv.style.zIndex = '9999';
        document.body.appendChild(loadingDiv);

        // @keyframes 추가
        const style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = `
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
        `;
        document.head.appendChild(style);
    };

    // 로딩 UI 표시
    const show = (options = {}) => {
        const { event, position = 'center' } = options; // 옵션에서 위치 설정 (기본값: center)

        if (loadingDiv) {
            if (position === 'cursor' && event) {
                // 마우스 커서 위치에 표시
                loadingDiv.style.left = `${event.pageX - 30}px`; // 커서 위치에 맞게 조정
                loadingDiv.style.top  = `${event.pageY - 30}px`;
            } else {
                // 화면 중앙에 표시
                loadingDiv.style.left = `50%`;
                loadingDiv.style.top  = `50%`;
                loadingDiv.style.transform = `translate(-50%, -50%)`;
            }
            loadingDiv.style.display = 'block';
        }
    };

    // 로딩 UI 숨기기
    const hide = () => {
        if (loadingDiv) {
            loadingDiv.style.display = 'none';
        }
    };

    // 로딩 요소가 없으면 생성
    if (!document.getElementById('loading')) {
        createLoadingElement();
    }

    return {
        show,
        hide,
    };
})();