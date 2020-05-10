import { urlFor, pathFor } from "webpacker-routes";
const default_url_options = {};
const admin_cart_spec = [
  "/admin/test/cart(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_cart_url = (...args) => urlFor(admin_cart_spec, ...args);
export const admin_cart_path = (...args) => pathFor(admin_cart_spec, ...args);
const admin_email_statistics_spec = [
  "/admin/email_statistics(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_email_statistics_url = (...args) =>
  urlFor(admin_email_statistics_spec, ...args);
export const admin_email_statistics_path = (...args) =>
  pathFor(admin_email_statistics_spec, ...args);
const admin_events_spec = [
  "/admin/events(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_events_url = (...args) => urlFor(admin_events_spec, ...args);
export const admin_events_path = (...args) =>
  pathFor(admin_events_spec, ...args);
const admin_password_spec = [
  "/admins/password(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_password_url = (...args) =>
  urlFor(admin_password_spec, ...args);
export const admin_password_path = (...args) =>
  pathFor(admin_password_spec, ...args);
const admin_post_form_spec = [
  "/admin/test/post_form(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_post_form_url = (...args) =>
  urlFor(admin_post_form_spec, ...args);
export const admin_post_form_path = (...args) =>
  pathFor(admin_post_form_spec, ...args);
const admin_product_spec = [
  "/admin/products/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const admin_product_url = (...args) =>
  urlFor(admin_product_spec, ...args);
export const admin_product_path = (...args) =>
  pathFor(admin_product_spec, ...args);
const admin_products_spec = [
  "/admin/products(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_products_url = (...args) =>
  urlFor(admin_products_spec, ...args);
export const admin_products_path = (...args) =>
  pathFor(admin_products_spec, ...args);
const admin_quote_form_spec = [
  "/admin/test/quote_form(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_quote_form_url = (...args) =>
  urlFor(admin_quote_form_spec, ...args);
export const admin_quote_form_path = (...args) =>
  pathFor(admin_quote_form_spec, ...args);
const admin_request_spec = [
  "/admin/requests/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const admin_request_url = (...args) =>
  urlFor(admin_request_spec, ...args);
export const admin_request_path = (...args) =>
  pathFor(admin_request_spec, ...args);
const admin_requests_spec = [
  "/admin/requests(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_requests_url = (...args) =>
  urlFor(admin_requests_spec, ...args);
export const admin_requests_path = (...args) =>
  pathFor(admin_requests_spec, ...args);
const admin_root_spec = [
  "/admin(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_root_url = (...args) => urlFor(admin_root_spec, ...args);
export const admin_root_path = (...args) => pathFor(admin_root_spec, ...args);
const admin_salespeople_spec = [
  "/admin/salespeople(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_salespeople_url = (...args) =>
  urlFor(admin_salespeople_spec, ...args);
export const admin_salespeople_path = (...args) =>
  pathFor(admin_salespeople_spec, ...args);
const admin_salesperson_spec = [
  "/admin/salespeople/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const admin_salesperson_url = (...args) =>
  urlFor(admin_salesperson_spec, ...args);
export const admin_salesperson_path = (...args) =>
  pathFor(admin_salesperson_spec, ...args);
const admin_session_spec = [
  "/admins/sign_in(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_session_url = (...args) =>
  urlFor(admin_session_spec, ...args);
export const admin_session_path = (...args) =>
  pathFor(admin_session_spec, ...args);
const admin_shopify_customer_spec = [
  "/admin/shopify/customer/:customer_id(.:format)",
  ["customer_id", "format"],
  { ...default_url_options, ...{} },
];
export const admin_shopify_customer_url = (...args) =>
  urlFor(admin_shopify_customer_spec, ...args);
export const admin_shopify_customer_path = (...args) =>
  pathFor(admin_shopify_customer_spec, ...args);
const admin_shopify_customer_orders_spec = [
  "/admin/shopify/customer/:customer_id/orders(.:format)",
  ["customer_id", "format"],
  { ...default_url_options, ...{} },
];
export const admin_shopify_customer_orders_url = (...args) =>
  urlFor(admin_shopify_customer_orders_spec, ...args);
export const admin_shopify_customer_orders_path = (...args) =>
  pathFor(admin_shopify_customer_orders_spec, ...args);
const admin_shopify_customers_spec = [
  "/admin/shopify/customers(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_shopify_customers_url = (...args) =>
  urlFor(admin_shopify_customers_spec, ...args);
export const admin_shopify_customers_path = (...args) =>
  pathFor(admin_shopify_customers_spec, ...args);
const admin_shopify_orders_spec = [
  "/admin/shopify/orders(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_shopify_orders_url = (...args) =>
  urlFor(admin_shopify_orders_spec, ...args);
export const admin_shopify_orders_path = (...args) =>
  pathFor(admin_shopify_orders_spec, ...args);
const admin_shopify_products_spec = [
  "/admin/shopify/products(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_shopify_products_url = (...args) =>
  urlFor(admin_shopify_products_spec, ...args);
export const admin_shopify_products_path = (...args) =>
  pathFor(admin_shopify_products_spec, ...args);
const admin_shopify_variants_spec = [
  "/admin/shopify/variants(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_shopify_variants_url = (...args) =>
  urlFor(admin_shopify_variants_spec, ...args);
export const admin_shopify_variants_path = (...args) =>
  pathFor(admin_shopify_variants_spec, ...args);
const admin_sidekiq_web_spec = [
  "/admin/sidekiq",
  [],
  { ...default_url_options, ...{} },
];
export const admin_sidekiq_web_url = (...args) =>
  urlFor(admin_sidekiq_web_spec, ...args);
export const admin_sidekiq_web_path = (...args) =>
  pathFor(admin_sidekiq_web_spec, ...args);
const admin_users_spec = [
  "/admin/users(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_users_url = (...args) => urlFor(admin_users_spec, ...args);
export const admin_users_path = (...args) => pathFor(admin_users_spec, ...args);
const admin_webhook_spec = [
  "/admin/webhooks/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const admin_webhook_url = (...args) =>
  urlFor(admin_webhook_spec, ...args);
export const admin_webhook_path = (...args) =>
  pathFor(admin_webhook_spec, ...args);
const admin_webhooks_spec = [
  "/admin/webhooks(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const admin_webhooks_url = (...args) =>
  urlFor(admin_webhooks_spec, ...args);
export const admin_webhooks_path = (...args) =>
  pathFor(admin_webhooks_spec, ...args);
const ahoy_email_engine_spec = ["/ahoy", [], { ...default_url_options, ...{} }];
export const ahoy_email_engine_url = (...args) =>
  urlFor(ahoy_email_engine_spec, ...args);
export const ahoy_email_engine_path = (...args) =>
  pathFor(ahoy_email_engine_spec, ...args);
const api_request_spec = [
  "/api/requests/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const api_request_url = (...args) => urlFor(api_request_spec, ...args);
export const api_request_path = (...args) => pathFor(api_request_spec, ...args);
const api_request_image_spec = [
  "/api/request_images/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const api_request_image_url = (...args) =>
  urlFor(api_request_image_spec, ...args);
export const api_request_image_path = (...args) =>
  pathFor(api_request_image_spec, ...args);
const api_requests_spec = [
  "/api/requests(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const api_requests_url = (...args) => urlFor(api_requests_spec, ...args);
export const api_requests_path = (...args) =>
  pathFor(api_requests_spec, ...args);
const api_user_spec = [
  "/api/users/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const api_user_url = (...args) => urlFor(api_user_spec, ...args);
export const api_user_path = (...args) => pathFor(api_user_spec, ...args);
const api_users_spec = [
  "/api/users(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const api_users_url = (...args) => urlFor(api_users_spec, ...args);
export const api_users_path = (...args) => pathFor(api_users_spec, ...args);
const cancel_salesperson_registration_spec = [
  "/salespeople/cancel(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const cancel_salesperson_registration_url = (...args) =>
  urlFor(cancel_salesperson_registration_spec, ...args);
export const cancel_salesperson_registration_path = (...args) =>
  pathFor(cancel_salesperson_registration_spec, ...args);
const cancel_user_registration_spec = [
  "/users/cancel(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const cancel_user_registration_url = (...args) =>
  urlFor(cancel_user_registration_spec, ...args);
export const cancel_user_registration_path = (...args) =>
  pathFor(cancel_user_registration_spec, ...args);
const cart_redirect_spec = [
  "/public/redirect/:handle/:variant(.:format)",
  ["handle", "variant", "format"],
  { ...default_url_options, ...{ format: "html" } },
];
export const cart_redirect_url = (...args) =>
  urlFor(cart_redirect_spec, ...args);
export const cart_redirect_path = (...args) =>
  pathFor(cart_redirect_spec, ...args);
const deposit_redirect_spec = [
  "/public/thanks(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const deposit_redirect_url = (...args) =>
  urlFor(deposit_redirect_spec, ...args);
export const deposit_redirect_path = (...args) =>
  pathFor(deposit_redirect_spec, ...args);
const destroy_admin_session_spec = [
  "/admins/sign_out(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const destroy_admin_session_url = (...args) =>
  urlFor(destroy_admin_session_spec, ...args);
export const destroy_admin_session_path = (...args) =>
  pathFor(destroy_admin_session_spec, ...args);
const destroy_salesperson_session_spec = [
  "/salespeople/sign_out(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const destroy_salesperson_session_url = (...args) =>
  urlFor(destroy_salesperson_session_spec, ...args);
export const destroy_salesperson_session_path = (...args) =>
  pathFor(destroy_salesperson_session_spec, ...args);
const destroy_user_session_spec = [
  "/users/sign_out(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const destroy_user_session_url = (...args) =>
  urlFor(destroy_user_session_spec, ...args);
export const destroy_user_session_path = (...args) =>
  pathFor(destroy_user_session_spec, ...args);
const edit_admin_password_spec = [
  "/admins/password/edit(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const edit_admin_password_url = (...args) =>
  urlFor(edit_admin_password_spec, ...args);
export const edit_admin_password_path = (...args) =>
  pathFor(edit_admin_password_spec, ...args);
const edit_admin_product_spec = [
  "/admin/products/:id/edit(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const edit_admin_product_url = (...args) =>
  urlFor(edit_admin_product_spec, ...args);
export const edit_admin_product_path = (...args) =>
  pathFor(edit_admin_product_spec, ...args);
const edit_admin_request_spec = [
  "/admin/requests/:id/edit(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const edit_admin_request_url = (...args) =>
  urlFor(edit_admin_request_spec, ...args);
export const edit_admin_request_path = (...args) =>
  pathFor(edit_admin_request_spec, ...args);
const edit_admin_salesperson_spec = [
  "/admin/salespeople/:id/edit(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const edit_admin_salesperson_url = (...args) =>
  urlFor(edit_admin_salesperson_spec, ...args);
export const edit_admin_salesperson_path = (...args) =>
  pathFor(edit_admin_salesperson_spec, ...args);
const edit_email_preference_spec = [
  "/email_preferences/:id/edit(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const edit_email_preference_url = (...args) =>
  urlFor(edit_email_preference_spec, ...args);
export const edit_email_preference_path = (...args) =>
  pathFor(edit_email_preference_spec, ...args);
const edit_salesperson_password_spec = [
  "/salespeople/password/edit(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const edit_salesperson_password_url = (...args) =>
  urlFor(edit_salesperson_password_spec, ...args);
export const edit_salesperson_password_path = (...args) =>
  pathFor(edit_salesperson_password_spec, ...args);
const edit_salesperson_registration_spec = [
  "/salespeople/edit(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const edit_salesperson_registration_url = (...args) =>
  urlFor(edit_salesperson_registration_spec, ...args);
export const edit_salesperson_registration_path = (...args) =>
  pathFor(edit_salesperson_registration_spec, ...args);
const edit_user_password_spec = [
  "/users/password/edit(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const edit_user_password_url = (...args) =>
  urlFor(edit_user_password_spec, ...args);
export const edit_user_password_path = (...args) =>
  pathFor(edit_user_password_spec, ...args);
const edit_user_registration_spec = [
  "/users/edit(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const edit_user_registration_url = (...args) =>
  urlFor(edit_user_registration_spec, ...args);
export const edit_user_registration_path = (...args) =>
  pathFor(edit_user_registration_spec, ...args);
const email_preference_spec = [
  "/email_preferences/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const email_preference_url = (...args) =>
  urlFor(email_preference_spec, ...args);
export const email_preference_path = (...args) =>
  pathFor(email_preference_spec, ...args);
const email_preferences_spec = [
  "/email_preferences(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const email_preferences_url = (...args) =>
  urlFor(email_preferences_spec, ...args);
export const email_preferences_path = (...args) =>
  pathFor(email_preferences_spec, ...args);
const event_spec = [
  "/events/:id(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const event_url = (...args) => urlFor(event_spec, ...args);
export const event_path = (...args) => pathFor(event_spec, ...args);
const events_create_spec = [
  "/events/create(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const events_create_url = (...args) =>
  urlFor(events_create_spec, ...args);
export const events_create_path = (...args) =>
  pathFor(events_create_spec, ...args);
const get_links_spec = [
  "/public/get_links(.:format)",
  ["format"],
  { ...default_url_options, ...{ format: "json" } },
];
export const get_links_url = (...args) => urlFor(get_links_spec, ...args);
export const get_links_path = (...args) => pathFor(get_links_spec, ...args);
const get_uid_spec = [
  "/public/get_uid(.:format)",
  ["format"],
  { ...default_url_options, ...{ format: "json" } },
];
export const get_uid_url = (...args) => urlFor(get_uid_spec, ...args);
export const get_uid_path = (...args) => pathFor(get_uid_spec, ...args);
const how_to_admin_salespeople_spec = [
  "/admin/salespeople/how_to(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const how_to_admin_salespeople_url = (...args) =>
  urlFor(how_to_admin_salespeople_spec, ...args);
export const how_to_admin_salespeople_path = (...args) =>
  pathFor(how_to_admin_salespeople_spec, ...args);
const marketing_opt_in_spec = [
  "/marketing/opt_in(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const marketing_opt_in_url = (...args) =>
  urlFor(marketing_opt_in_spec, ...args);
export const marketing_opt_in_path = (...args) =>
  pathFor(marketing_opt_in_spec, ...args);
const marketing_opt_out_spec = [
  "/marketing/opt_out(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const marketing_opt_out_url = (...args) =>
  urlFor(marketing_opt_out_spec, ...args);
export const marketing_opt_out_path = (...args) =>
  pathFor(marketing_opt_out_spec, ...args);
const new_admin_password_spec = [
  "/admins/password/new(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_admin_password_url = (...args) =>
  urlFor(new_admin_password_spec, ...args);
export const new_admin_password_path = (...args) =>
  pathFor(new_admin_password_spec, ...args);
const new_admin_product_spec = [
  "/admin/products/new(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_admin_product_url = (...args) =>
  urlFor(new_admin_product_spec, ...args);
export const new_admin_product_path = (...args) =>
  pathFor(new_admin_product_spec, ...args);
const new_admin_request_spec = [
  "/admin/requests/new(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_admin_request_url = (...args) =>
  urlFor(new_admin_request_spec, ...args);
export const new_admin_request_path = (...args) =>
  pathFor(new_admin_request_spec, ...args);
const new_admin_salesperson_spec = [
  "/admin/salespeople/new(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_admin_salesperson_url = (...args) =>
  urlFor(new_admin_salesperson_spec, ...args);
export const new_admin_salesperson_path = (...args) =>
  pathFor(new_admin_salesperson_spec, ...args);
const new_admin_session_spec = [
  "/admins/sign_in(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_admin_session_url = (...args) =>
  urlFor(new_admin_session_spec, ...args);
export const new_admin_session_path = (...args) =>
  pathFor(new_admin_session_spec, ...args);
const new_request_spec = [
  "/public/new_request(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_request_url = (...args) => urlFor(new_request_spec, ...args);
export const new_request_path = (...args) => pathFor(new_request_spec, ...args);
const new_salesperson_password_spec = [
  "/salespeople/password/new(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_salesperson_password_url = (...args) =>
  urlFor(new_salesperson_password_spec, ...args);
export const new_salesperson_password_path = (...args) =>
  pathFor(new_salesperson_password_spec, ...args);
const new_salesperson_registration_spec = [
  "/salespeople/sign_up(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_salesperson_registration_url = (...args) =>
  urlFor(new_salesperson_registration_spec, ...args);
export const new_salesperson_registration_path = (...args) =>
  pathFor(new_salesperson_registration_spec, ...args);
const new_salesperson_session_spec = [
  "/salespeople/sign_in(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_salesperson_session_url = (...args) =>
  urlFor(new_salesperson_session_spec, ...args);
export const new_salesperson_session_path = (...args) =>
  pathFor(new_salesperson_session_spec, ...args);
const new_user_password_spec = [
  "/users/password/new(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_user_password_url = (...args) =>
  urlFor(new_user_password_spec, ...args);
export const new_user_password_path = (...args) =>
  pathFor(new_user_password_spec, ...args);
const new_user_registration_spec = [
  "/users/sign_up(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_user_registration_url = (...args) =>
  urlFor(new_user_registration_spec, ...args);
export const new_user_registration_path = (...args) =>
  pathFor(new_user_registration_spec, ...args);
const new_user_session_spec = [
  "/users/sign_in(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const new_user_session_url = (...args) =>
  urlFor(new_user_session_spec, ...args);
export const new_user_session_path = (...args) =>
  pathFor(new_user_session_spec, ...args);
const opt_in_admin_request_spec = [
  "/admin/requests/:id/opt_in(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const opt_in_admin_request_url = (...args) =>
  urlFor(opt_in_admin_request_spec, ...args);
export const opt_in_admin_request_path = (...args) =>
  pathFor(opt_in_admin_request_spec, ...args);
const opt_out_admin_request_spec = [
  "/admin/requests/:id/opt_out(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const opt_out_admin_request_url = (...args) =>
  urlFor(opt_out_admin_request_spec, ...args);
export const opt_out_admin_request_path = (...args) =>
  pathFor(opt_out_admin_request_spec, ...args);
const perform_admin_webhook_spec = [
  "/admin/webhooks/:id/perform(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const perform_admin_webhook_url = (...args) =>
  urlFor(perform_admin_webhook_spec, ...args);
export const perform_admin_webhook_path = (...args) =>
  pathFor(perform_admin_webhook_spec, ...args);
const public_get_ids_spec = [
  "/public/get_ids(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const public_get_ids_url = (...args) =>
  urlFor(public_get_ids_spec, ...args);
export const public_get_ids_path = (...args) =>
  pathFor(public_get_ids_spec, ...args);
const rails_blob_representation_spec = [
  "/rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)",
  ["signed_blob_id", "variation_key", "filename", "format"],
  { ...default_url_options, ...{} },
];
export const rails_blob_representation_url = (...args) =>
  urlFor(rails_blob_representation_spec, ...args);
export const rails_blob_representation_path = (...args) =>
  pathFor(rails_blob_representation_spec, ...args);
const rails_direct_uploads_spec = [
  "/rails/active_storage/direct_uploads(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const rails_direct_uploads_url = (...args) =>
  urlFor(rails_direct_uploads_spec, ...args);
export const rails_direct_uploads_path = (...args) =>
  pathFor(rails_direct_uploads_spec, ...args);
const rails_disk_service_spec = [
  "/rails/active_storage/disk/:encoded_key/*filename(.:format)",
  ["encoded_key", "filename", "format"],
  { ...default_url_options, ...{} },
];
export const rails_disk_service_url = (...args) =>
  urlFor(rails_disk_service_spec, ...args);
export const rails_disk_service_path = (...args) =>
  pathFor(rails_disk_service_spec, ...args);
const rails_service_blob_spec = [
  "/rails/active_storage/blobs/:signed_id/*filename(.:format)",
  ["signed_id", "filename", "format"],
  { ...default_url_options, ...{} },
];
export const rails_service_blob_url = (...args) =>
  urlFor(rails_service_blob_spec, ...args);
export const rails_service_blob_path = (...args) =>
  pathFor(rails_service_blob_spec, ...args);
const root_spec = ["/", [], { ...default_url_options, ...{} }];
export const root_url = (...args) => urlFor(root_spec, ...args);
export const root_path = (...args) => pathFor(root_spec, ...args);
const salesperson_password_spec = [
  "/salespeople/password(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const salesperson_password_url = (...args) =>
  urlFor(salesperson_password_spec, ...args);
export const salesperson_password_path = (...args) =>
  pathFor(salesperson_password_spec, ...args);
const salesperson_registration_spec = [
  "/salespeople(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const salesperson_registration_url = (...args) =>
  urlFor(salesperson_registration_spec, ...args);
export const salesperson_registration_path = (...args) =>
  pathFor(salesperson_registration_spec, ...args);
const salesperson_session_spec = [
  "/salespeople/sign_in(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const salesperson_session_url = (...args) =>
  urlFor(salesperson_session_spec, ...args);
export const salesperson_session_path = (...args) =>
  pathFor(salesperson_session_spec, ...args);
const save_email_spec = [
  "/public/save_email(.:format)",
  ["format"],
  { ...default_url_options, ...{ format: "json" } },
];
export const save_email_url = (...args) => urlFor(save_email_spec, ...args);
export const save_email_path = (...args) => pathFor(save_email_spec, ...args);
const send_confirmation_admin_request_spec = [
  "/admin/requests/:id/send_confirmation(.:format)",
  ["id", "format"],
  { ...default_url_options, ...{} },
];
export const send_confirmation_admin_request_url = (...args) =>
  urlFor(send_confirmation_admin_request_spec, ...args);
export const send_confirmation_admin_request_path = (...args) =>
  pathFor(send_confirmation_admin_request_spec, ...args);
const set_link_spec = [
  "/public/set_link(.:format)",
  ["format"],
  { ...default_url_options, ...{ format: "json" } },
];
export const set_link_url = (...args) => urlFor(set_link_spec, ...args);
export const set_link_path = (...args) => pathFor(set_link_spec, ...args);
const update_rails_disk_service_spec = [
  "/rails/active_storage/disk/:encoded_token(.:format)",
  ["encoded_token", "format"],
  { ...default_url_options, ...{} },
];
export const update_rails_disk_service_url = (...args) =>
  urlFor(update_rails_disk_service_spec, ...args);
export const update_rails_disk_service_path = (...args) =>
  pathFor(update_rails_disk_service_spec, ...args);
const user_password_spec = [
  "/users/password(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const user_password_url = (...args) =>
  urlFor(user_password_spec, ...args);
export const user_password_path = (...args) =>
  pathFor(user_password_spec, ...args);
const user_registration_spec = [
  "/users(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const user_registration_url = (...args) =>
  urlFor(user_registration_spec, ...args);
export const user_registration_path = (...args) =>
  pathFor(user_registration_spec, ...args);
const user_session_spec = [
  "/users/sign_in(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const user_session_url = (...args) => urlFor(user_session_spec, ...args);
export const user_session_path = (...args) =>
  pathFor(user_session_spec, ...args);
const webhooks_calendly_spec = [
  "/webhooks/calendly(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const webhooks_calendly_url = (...args) =>
  urlFor(webhooks_calendly_spec, ...args);
export const webhooks_calendly_path = (...args) =>
  pathFor(webhooks_calendly_spec, ...args);
const webhooks_orders_create_spec = [
  "/webhooks/orders_create(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const webhooks_orders_create_url = (...args) =>
  urlFor(webhooks_orders_create_spec, ...args);
export const webhooks_orders_create_path = (...args) =>
  pathFor(webhooks_orders_create_spec, ...args);
const webhooks_requests_create_spec = [
  "/webhooks/requests_create(.:format)",
  ["format"],
  { ...default_url_options, ...{} },
];
export const webhooks_requests_create_url = (...args) =>
  urlFor(webhooks_requests_create_spec, ...args);
export const webhooks_requests_create_path = (...args) =>
  pathFor(webhooks_requests_create_spec, ...args);
const widget_spec = [
  "/public/widget(.:format)",
  ["format"],
  { ...default_url_options, ...{ format: "js" } },
];
export const widget_url = (...args) => urlFor(widget_spec, ...args);
export const widget_path = (...args) => pathFor(widget_spec, ...args);
