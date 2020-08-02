class Admin::WebhooksController < Admin::BaseController
  before_action :require_admin!
  before_action :set_webhook, only: [:perform, :destroy]

  def index
    @webhooks = policy_scope(Webhook).order("aasm_state desc, id desc")
    @webhooks = @webhooks.paginate(page: params[:page])
  end

  def perform
    authorize @webhook
    redirect_to(admin_webhooks_path) && return if @webhook.committed?

    respond_to do |format|
      if @webhook.perform!
        format.html { redirect_to admin_webhooks_path, notice: "Committed this webhook." }
        format.json { render :index, status: :committed, location: admin_webhooks_path }
      else
        format.html { redirect_to admin_webhooks_path, notice: "Cannot commit this webhook." }
        format.json { render json: @webhook.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @webhook
    redirect_to(admin_webhooks_path) && return if @webhook.committed?

    respond_to do |format|
      if @webhook.destroy!
        format.html { redirect_to admin_webhooks_path, notice: "Deleted this webhook." }
        format.json { render :index, status: :committed, location: admin_webhooks_path }
      else
        format.html { redirect_to admin_webhooks_path, notice: "Cannot delete this webhook." }
        format.json { render json: @webhook.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_webhook
    @webhook = Webhook.find(params[:id])
  end
end
