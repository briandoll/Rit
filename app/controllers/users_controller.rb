class UsersController < Clearance::UsersController
  # We have different functionality than the default Clearance controller so we skip :redirect_to_root
  skip_before_filter :redirect_to_root
  before_filter :authenticate_admin
  
  def index
    @users = User.find(:all)
  end
  
  def create
    @user = ::User.new params[:user]
    if @user.save
      ::ClearanceMailer.deliver_confirmation @user
      flash_notice_confirmation_email
      redirect_to users_url
    else
      # p @user.errors
      render :template => 'users/new'
    end
  end
  
  def show
    @user = User.find(params[:id])
    if @user.nil?
      flash[:error] = "User not found."
      redirect_to users_url
    end
  end
  
  def update
    @user = User.find(params[:id])
    unless @user.nil?
      old_email = @user.email
      if @user.update_attributes(params[:user])
        if @user.email != old_email
          # email changed, confirm again
          @user.email_confirmed = false
          @user.save
          ::ClearanceMailer.deliver_confirmation @user
          flash_notice_confirmation_email
        else
          flash[:notice] = 'User updated.'
        end
        redirect_to users_url
      else
        render :template => 'users/show'
      end
    else
      flash[:error] = "User not found."
      redirect_to users_url
    end
  end
  
  private
  
  def flash_notice_confirmation_email
    flash[:notice] = "The user will receive an email within the next few minutes.  " <<
      "It contains instructions for confirming their account."
  end
end
