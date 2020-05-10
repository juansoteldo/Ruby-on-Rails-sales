window.mouseOverTable = false;

(($) => {
  window.cartButtons = (value, row) => `
        <div class="row">
          <div class="col-md-5">
            <button class="btn btn-xs btn-show-options btn-block"
              data-email="${row.user.email}" data-id="${row.id}"
              data-class="deposit">Deposit</button>
          </div>
          <div class="col-md-2"></div>
          <div class="col-md-5">
            <button class="btn btn-xs btn-show-options btn-primary btn-block"
              data-email="${row.user.email} data-id="${row.id}
              data-class="final">Final</button>
          </div>
        </div>
    `;

  window.isNullFormatter = (value) => (value === null && "") || "X";

  window.imagesFormatter = (images, row) => {
    let i;
    let result = "";
    i = 1;
    $(images).each(() => {
      result += `<a href='${this.url}' data-lightbox='request-${row.id}' >${i}</a>`;
      i += 1;
      return i;
    });
    return result;
  };

  window.depositedFormatter = (value, row) => {
    if (value) {
      return `<a href='${row.crm_url}' target='_blank'>
            <span class='glyphicon glyphicon-usd'></span>
         </a>&nbsp;
         <a href='${row.send_confirmation_path}'>
             <span class='glyphicon glyphicon-refresh'></span>
         </a>`;
    } else {
      return "&nbsp;";
    }
  };

  window.dateFormatter = (value) => moment(value).format("D MMM h:mm a");

  window.currencyFormatter = (value) => {
    const newValue = parseFloat(value)
      .toFixed(2)
      .replace(/./g, (c, i, a) => {
        if (i && c !== "." && (a.length - i) % 3 === 0) {
          return `,${c}`;
        }
        return c;
      });
    return `$${newValue}`;
  };

  window.userFormatter = (value, row) => {
    let button;
    let email;
    if (row.user.opted_out) {
      button = `<a class=" btn-xs btn-simple btn-danger btn"
            href="${Routes.edit_email_preference_path(value.id)}"
            target="_blank"><i class="material-icons">do_not_disturb_on</i></a>`;
      email = `<strike>${value.email}</strike>`;
    } else {
      button = `<a class="small btn-xs btn-success btn-simple btn"
            href="${Routes.opt_out_admin_request_path(row.id)}"
            data-confirm="Are you sure you want to opt out ${value.email}?">
            <i class="material-icons">email</i></a>`;
      email = value.email;
    }
    return `<span title='row.client_id'>
        ${email}
        <span class="pull-right">${button}</span>
        </span>`;
  };

  window.hideButton = (value, row) =>
    `<button class='btn btn-sm btn-default btn-hide-request'
               data-id="${value}">hide</button>`;

  window.firstFormatter = (value, row) => {
    if (value) {
      return "1st";
    }
    return "";
  };

  window.visitedFormatter = (value, row) => {
    if (value) {
      return '<span class="glyphicon glyphicon-eye-open"></span>';
    }
    return "";
  };

  window.colorFormatter = (value, row) => {
    if (value) {
      return `<img src='${image_path("color-wheel.png")}'
            width='16' height='16' style='width: 16px;'/>`;
    }
    return "";
  };

  window.coverFormatter = (value, row) => {
    if (value) {
      return `<div style="border: 1px solid #222;padding: 2px;color: #444;"
                    class="">CU</div>`;
    }
    return "";
  };

  const filterSidebar = (filter) => {
    $("#variants .deposit, #variants .final").hide();
    return $(`#variants .${filter}`).show();
  };

  const appendSidebarUids = (el) => {
    const requestId = $(el).data("id");
    return $(".btn-url").each(() => {
      let url = $(this).data("url");
      if (typeof requestId !== "undefined") {
        url = url.replace(/requestId=/, `requestId=${requestId}`);
      }
      return $(this).data("clipboardText", url);
    });
  };

  const ready = () => {
    const requestTable = $("#request-table");
    requestTable.on("click", ".btn-hide-request", (e) =>
      $(e.target).data("id")
    );

    $(document).on("mouseenter", "#request-table", () => {
      window.mouseOverTable = true;
    });

    $(document).on("mouseleave", "#request-table", () => {
      window.mouseOverTable = false;
    });

    requestTable.on("click", ".btn-show-options", (e) => {
      e.preventDefault();
      appendSidebarUids(e.target);
      $("#request-table tr.active").removeClass("active");
      const row = $(e.target).closest("tr");
      row.addClass("active");
      const email = $(e.target).data("email");
      const variantsUser = $("#variants-user");
      variantsUser.text(email);
      window.openSidebar(variantsUser.text() !== email);
      const filterClass = $(e.target).data("class");
      return filterSidebar(filterClass);
    });
    return setInterval(() => {
      if (window.mouseOverTable) return;
      requestTable.bootstrapTable("refresh");
    }, 30000);
  };

  $(document).ready(ready);
  $(document).on("turbolinks:load", ready);
})(jQuery);
