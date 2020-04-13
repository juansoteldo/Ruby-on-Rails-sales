(function ($) {
  const ready = () => {
    return $(".btn-url").each(() => {
      const clip = new ZeroClipboard(this);
      clip.on("copy", (event) => {
        const url = $(event.target).data("clipboardText");
        const title = $(event.target).data("title");
        const clipboard = event.clipboardData;
        clipboard.setData("text/plain", url);
        return clipboard.setData(
          "text/html",
          `<a style='font-family: sans-serif;' href='${url}'>${title}</a>`
        );
      });

      return clip.on("aftercopy", () => {
        return window.closeSidebar(true);
      });
    });
  };

  $(document).ready(ready);

  $(document).on("page:load", ready);
})(jQuery);
