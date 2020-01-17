class Admin::WebhooksController < Admin::BaseController
  before_action :require_admin!

  def index
    @webhooks = policy_scope(Webhook).order("aasm_state desc, id desc")
    @webhooks = @webhooks.paginate(page: params[:page])
  end

  def perform
    @webhook = Webhook.find(params[:id])
    authorize @webhook
    redirect_to(admin_webhooks_path) && return if @webhook.committed?
    respond_to do |format|
      if @webhook.perform!
        format.html { redirect_to admin_webhooks_path, notice: 'Committed this webhook.' }
        format.json { render :index, status: :committed, location: admin_webhooks_path }
      else
        format.html { redirect_to admin_webhooks_path, notice: 'Cannot commit this webhook.' }
        format.json { render json: @webhook.errors, status: :unprocessable_entity }
      end
    end
  end
end