require_relative "../models"

class MainController < ApplicationController
  before_action :require_login , :except => [:login, :register, :login_post, :register_post]

  def index
  end
  def login
    p params
    @redirect = params[:redirect] || "/"
    if params[:failed] == "1"
      @alert = "Invalid e-mail address or password."
    elsif params[:disabled] == "1"
      @alert = "Your account is currently disabled."
    end
  end
  def login_post
    user = User.authenticate(params[:email], params[:password])
    redirect_to "/login?failed=1" and return if user.nil?
    redirect_to "/login?disabled=1" and return if user.is_verified == 0
    session[:user_id] = user.id
    redirect_to params[:redirect]
  end
  def register_post
    render(plain: "Missing Email") and return if params[:email].nil? || params[:email].empty?
    render(plain: "Invalid email.") and return unless params[:email] =~ /^\S+@\S+\.\S+$/
    render(plain: "User #{params[:email]} already exists.") and return if User[:email => params[:email]]
    render(plain: "Missing first name.") and return if params[:first_name].nil? || params[:first_name].empty?
    render(plain: "Missing last name.") and return if params[:last_name].nil? || params[:last_name].empty?
    render(plain: "Missing password.") and return if params[:password].nil? || params[:password].empty?
    user = User.new(:email => params[:email], :first_name => params[:first_name],
                    :last_name => params[:last_name], :is_verified => 0,
                    :phone_number => params[:phone_number], :credits => 1000, :rating_score=>0,
                    :rating_count=>0, :activation_code=>0)
    user.set_password(params[:password])
    user.save
    action
    text_body = <<-EOS.dedent
      Hello,

      This is a notification that #{user.first_name} #{user.last_name} has created an account on HasTea.
      If this was you, please use activation code #{user.activation_code} to activate your account at
    EOS
    @notice = "We've got your account, but need you to verify your phone number!"

  end
  private

  def require_login
    @user = User[session[:user_id]]
    authenticate!
  end
  def authenticate!
    p @user
    if @user.nil?
      redirect_to "/login?redirect=#{request.fullpath}"
      return
    end
    if @user.is_verified == 0
      session[:user_id] = nil
      redirect "/login?disabled=1"
    end
  end
end
