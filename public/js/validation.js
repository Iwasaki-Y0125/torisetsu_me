// Todo1 バリデーションの追加
document.addEventListener("DOMContentLoaded", function () {
  //* カテゴリーの自由記述の入力規制
  const categorySelect = document.getElementById("category");
  const categoryCustom = document.getElementById("category_custom");
  function toggleCategoryCustom() {
    if (categorySelect.value === "other") {
      categoryCustom.disabled = false;
      categoryCustom.style.backgroundColor = "";
      categoryCustom.style.opacity = "1";
    } else {
      categoryCustom.disabled = true;
      categoryCustom.style.backgroundColor = "#bbb";
      categoryCustom.style.opacity = "0.6";
    }
  }
  toggleCategoryCustom();
  categorySelect.addEventListener("change", toggleCategoryCustom);

  //* 一人称の自由記述の入力規制
  const categoryMeSelect = document.getElementById("category_me");
  const categoryMeCustom = document.getElementById("category_me_custom");
  function toggleCategoryMeCustom() {
    if (categoryMeSelect.value === "other") {
      categoryMeCustom.disabled = false;
      categoryMeCustom.style.backgroundColor = "";
      categoryMeCustom.style.opacity = "1";
    } else {
      categoryMeCustom.disabled = true;
      categoryMeCustom.style.backgroundColor = "#bbb";
      categoryMeCustom.style.opacity = "0.6";
    }
  }
  toggleCategoryMeCustom();
  categoryMeSelect.addEventListener("change", toggleCategoryMeCustom);

  //* 質問の自由記述の入力規制
  const questionSelects = document.querySelectorAll(".question-select");
  const questionCustoms = [];
  const answer_array = [];

  questionSelects.forEach((questionSelect) => {
    const index = questionSelect.id.split("_")[1];

    const questionCustom = document.getElementById(`question_custom_${index}`);
    questionCustoms.push(questionCustom);

    const answer = document.getElementById(`answer_${index}`);
    answer_array.push(answer);

    function toggleQuestionCustom() {
      if (questionSelect.value === "other") {
        questionCustom.readOnly = false;
        questionCustom.style.backgroundColor = "";
        questionCustom.style.opacity = "1";
      } else {
        questionCustom.readOnly = true;
        questionCustom.style.backgroundColor = "#bbb";
        questionCustom.style.opacity = "0.6";
      }
    }
    toggleQuestionCustom();
    questionSelect.addEventListener("change", toggleQuestionCustom);
  });

  //*未入力のアラート
  const nameInput = document.getElementById("name");
  const nameFuriganaInput = document.getElementById("name_furigana");
  const avatarRadios = document.querySelectorAll("input[name='avatar']");
  const messageTextarea = document.getElementById("message");

  const form = document.getElementById("post_result");
  form.addEventListener("submit", function (e) {
    const errors = [];

    if (!categorySelect.value) {
      errors.push("カテゴリを選択してください");
    }
    if (categorySelect.value === "other" && !categoryCustom.value.trim()) {
      errors.push("カテゴリの自由入力欄を入力してください");
    }
    if (!categoryMeSelect.value) {
      errors.push("一人称を選択してください");
    }
    if (categoryMeSelect.value === "other" && !categoryMeCustom.value.trim()) {
      errors.push("一人称の自由入力欄を入力してください");
    }
    if (!nameInput.value.trim()) {
      errors.push("名前を入力してください");
    }
    const avatarChecked = Array.from(avatarRadios).some((r) => r.checked);
    if (!avatarChecked) {
      errors.push("アバターを選択してください");
    }
    if (!messageTextarea.value.trim()) {
      errors.push("みんなにひとことを入力してください");
    }

    questionSelects.forEach((select, i) => {
      const isFirst = i === 0;
      if (isFirst) {
        if (!select.value) {errors.push(`トリセツ1の質問を選択してください`);
      }
        if (select.value === "other" && !questionCustoms[i].value.trim()) {
      errors.push(`トリセツ1の「その他（自由入力）」を入力してください`);
      }
      if (!answer_array[i].value.trim()) {
      errors.push(`トリセツ1の回答を入力してください`);
      }
      } else {
      const hasAnyInput =
      select.value || questionCustoms[i].value.trim() || answer_array[i].value.trim();

      if (hasAnyInput) {
        if (!select.value) {
        errors.push(`トリセツ${i + 1}の質問を選択してください`);
        }
        if (select.value === "other" && !questionCustoms[i].value.trim()) {
        errors.push(`トリセツ${i + 1}の「その他（自由入力）」を入力してください`);
        }
        if (!answer_array[i].value.trim()) {
        errors.push(`トリセツ${i + 1}の回答を入力してください`);
        }}}
    });

    if (errors.length > 0) {
      e.preventDefault();
      alert(errors.join("\n"));
    }
  });
});
