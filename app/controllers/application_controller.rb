# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  helper_method :signed_in_as_admin?

  def signed_in_as_admin?
    signed_in? && current_user.admin?
  end

  def authenticate_admin
    deny_access("Please Login as an administrator to Access that Feature.") unless signed_in_as_admin?
  end

  protected

  def parse_date_hour(new_params, prefix)
    time = nil
    unless new_params["#{prefix}_date"].blank?
      time = Time.zone.parse(new_params["#{prefix}_date"] + ' ' + new_params["#{prefix}_hour"], Rit::Config.date_format + " %H")
    end
    new_params.delete("#{prefix}_date")
    new_params.delete("#{prefix}_hour")
    time
  end

end
