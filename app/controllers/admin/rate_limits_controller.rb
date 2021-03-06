class Admin::RateLimitsController < Admin::AdminController
  before_action :require_sysadmin
  before_action :find_rate_limit

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    if @rate_limit.update(rate_limit_params)
      redirect_to edit_admin_rate_limits_url, notice: :rate_limits_updated
    else
      respond_to do |format|
        format.html { render :edit }
      end
    end
  end

  private

  def rate_limit_params
    params.require(:rate_limit).permit(*rate_limit_attributes)
  end

  def rate_limit_attributes
    %i[
      burst_rate burst_period sustained_rate sustained_period
      allowed_domains allowed_ips blocked_domains blocked_ips
      geoblocking_enabled countries
    ]
  end

  def find_rate_limit
    @rate_limit = RateLimit.first_or_create!
  end
end
