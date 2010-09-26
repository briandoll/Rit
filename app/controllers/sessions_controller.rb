class SessionsController < Clearance::SessionsController
  def create
    @user = ::User.authenticate(params[:session][:email],
                                params[:session][:password])
    if @user.nil?
      flash_failure_after_create
      render :template => 'sessions/new', :status => :unauthorized
    else
      unless @user.active?
        flash[:notice] = "User has been deactivated.  Please contact administrator."
        redirect_to(sign_in_url)
      else
        if @user.email_confirmed?
          sign_in(@user)
          flash_success_after_create
          redirect_back_or(url_after_create)
        else
          ::ClearanceMailer.deliver_confirmation(@user)
          flash_notice_after_create
          redirect_to(new_session_url)
        end
      end
    end
  end
end
