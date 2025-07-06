// Todo2 リザルト画面で「URLをコピー」ボタンでコピーできるようにする
document.addEventListener("DOMContentLoaded", function () {
  const copyBtn = document.getElementById("copy_url");
  const shareUrlInput = document.getElementById("shareUrl");

  copyBtn.addEventListener("click", function () {
    const url = shareUrlInput.value;

    if (navigator.clipboard) {
      navigator.clipboard
        .writeText(url)
        .then(() => {
          alert("URLをコピーしました！");
        })
        .catch((err) => {
          alert("コピーに失敗しました。手動でコピーしてください。");
          console.error("Clipboard copy failed:", err);
        });
    } else {
      alert("このブラウザではコピー機能がサポートされていません。");
    }
  });
});

// Todo3 新しいトリセツを作るでセッションの削除
