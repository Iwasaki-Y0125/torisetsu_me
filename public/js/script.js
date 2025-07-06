// Todo1 その他を選んだら、自由入力欄のグレーアウトが消えて入力できるようになる
// 1-1自由入力欄をグレーアウトかつ入力できないようにする
// 1-2選択肢でその他を選ぶイベントの追加
// 1-3イベント時にグレーアウトの解除と入力可能の状態にする
document.addEventListener("DOMContentLoaded", function () {
  const categorySelect = document.getElementById("category");
  const categoryCustom = document.getElementById("category_custom");

  function isCategoryCustom() {
    if (categorySelect.value === "other"){
      categoryCustom.disabled = false;
      categoryCustom.style.backgroundColor = ""
      categoryCustom.style.opacity = "1";
    }else{
      categoryCustom.disabled = true;
      categoryCustom.style.backgroundColor = "#eee";
      categoryCustom.style.opacity = "0.6";
    }
  }

  isCategoryCustom();
  categorySelect.addEventListener("change",isCategoryCustom);
});


document.addEventListener("DOMContentLoaded", function () {
  const questionSelects = document.querySelectorAll(".question-select");

  questionSelects.forEach((questionSelect) => {
    const index = questionSelect.id.split("_")[1];
    const questionCustom = document.getElementById(`question_custom_${index}`);

    function isQuestionCustom() {
      if (questionSelect.value === "other") {
        questionCustom.readOnly = false;
        questionCustom.style.backgroundColor = "";
        questionCustom.style.opacity = "1";
      } else {
        questionCustom.readOnly = true;
        questionCustom.style.backgroundColor = "#eee";
        questionCustom.style.opacity = "0.6";
      }
    }

    isQuestionCustom();
    questionSelect.addEventListener("change", isQuestionCustom);
  });
});


// Todo2 バリデーションチェックの追加

// Todo3 リザルト画面で「URLをコピー」ボタンでコピーできるようにする

// Todo4 新しいトリセツを作るでセッションの削除
