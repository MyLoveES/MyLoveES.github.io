// 在文档加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 加载自定义CSS
    loadCustomCSS();
});

// 加载自定义CSS
function loadCustomCSS() {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.type = 'text/css';
    link.href = '/css/custom.css';
    document.head.appendChild(link);
}
