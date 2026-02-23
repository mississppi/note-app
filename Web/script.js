// お問い合わせフォームの送信をダミーで処理
const form = document.querySelector("form");
if (form) {
  form.addEventListener("submit", function (e) {
    e.preventDefault();
    alert(
      "お問い合わせありがとうございます！\n（デモのため送信は行われません）",
    );
    form.reset();
  });
}
