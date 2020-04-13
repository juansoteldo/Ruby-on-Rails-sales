window.openSidebar = function (collapse) {
  $(".sidebar").collapse((collapse && "hide") || "show");
  return $("div.group").collapse("hide");
};

window.closeSidebar = function (collapse) {
  return $(".sidebar").collapse((collapse && "hide") || "show");
};
