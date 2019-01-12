require_relative "../models"

class MainController < ApplicationController
  before_action :require_login , :except => [:login, :register]

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
  def register_post
    render(text: "Missing email", status: 400) and return if params[:email].nil? || params[:email].empty?
    render(status: 400, text: "Invalid email.") and return unless params[:email] =~ /^\S+@\S+\.\S+$/
    render(status: 400, text: "User #{params[:email]} already exists.") and return if User[:email => params[:email]]
    render(status: 400, text: "Missing first name.") and return if params[:first_name].nil? || params[:first_name].empty?
    render(status: 400, text: "Missing last name.") and return if params[:last_name].nil? || params[:last_name].empty?
    render(status: 400, text: "Missing password.") and return if params[:password].nil? || params[:password].empty?
    user = User.new(:email => params[:email], :first_name => params[:first_name],
                    :last_name => params[:last_name], :permission => "readonly",
                    :is_verified => 0)
    user.set_password(params[:password])
    user.save
    text_body = <<-EOS.dedent
      Hello,

      This is a notification that #{user.first_name} #{user.last_name} has created an account on HasTea.
      If this was you, please use activation code #{activation_code} to activate your account at
    EOS
    
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
