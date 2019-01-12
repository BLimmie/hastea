require_relative "../models"

class MainController < ApplicationController
  before_action :require_login , :except => [:login, :register, :login_post, :register_post, :activation, :activation_post]

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
  def logout
    session[:user_id] = nil
    redirect_to "/login"
  end
  def user_edit
  end
  def user_edit_post
    if params[:avatar]
      p params[:avatar]
      file = params[:user[avatar]]
      # Create directories if they do not exist already
      Dir.mkdir("./uploads/users/#{@user.id}") unless Dir.exist?("./uploads/users/#{@user.id}")
      # Dir.mkdir("./uploads/users/#{@user.id}/avatar") unless Dir.exist?("./uploads/users/#{@user.id}/avatar")
      File.delete("./uploads/users/#{@user.id}/user_avatar.png") if File.exist?("./uploads/users/#{@user.id}/user_avatar.png")
      File.open("./uploads/users/#{@user.id}/user_avatar.png", 'wb') do |f|
        f.write(file.read)
      end
    end
  end
  def register_post
    render(plain: "Missing Email") and return if params[:email].nil? || params[:email].empty?
    render(plain: "Invalid email.") and return unless params[:email] =~ /^\S+@\S+\.\S+$/
    render(plain: "User #{params[:email]} already exists.") and return if User[:email => params[:email]]
    render(plain: "Missing first name.") and return if params[:first_name].nil? || params[:first_name].empty?
    render(plain: "Missing last name.") and return if params[:last_name].nil? || params[:last_name].empty?
    render(plain: "Missing password.") and return if params[:password].nil? || params[:password].empty?
    activation = rand 0..9999
    user = User.new(:email => params[:email], :first_name => params[:first_name],
                    :last_name => params[:last_name], :is_verified => 0,
                    :phone_number => params[:phone_number], :credits => 1000, :rating_score=>0,
                    :rating_count=>0, :activation_code=>activation)
    user.set_password(params[:password])
    user.save
    text_body = <<-EOS
    Hello,

    This is a notification that #{user.first_name} #{user.last_name} has created an account on HasTea.
    If this was you, please use activation code #{user.activation_code} to activate your account at url.com/activation
    EOS

    client = Twilio::REST::Client.new
      client.messages.create({
        from: Rails.application.credentials.twilio_phone_number,
        to: '+1'+user.phone_number,
        body: text_body
      })
    @notice = "We've got your account, but need you to verify your phone number!"

  end
  def activation_post
    render(plain: "Missing email") and return if params[:email].nil? || params[:email].empty?
    render(plain: "Invalid email.") and return unless params[:email] =~ /^\S+@\S+\.\S+$/
    user = User.first(email: params[:email])
    p user
    p user.activation_code
    p params[:activation].to_i
    p user.activation_code.to_i != params[:activation].to_i
    render(plain: "Invalid activation code.") and return if (params[:activation].nil? || !params[:activation].to_i.between?(0,9999))
    render(plain: "Wrong activation code.") and return if (user.activation_code != params[:activation].to_i)

    user.is_verified = 1
    user.save_changes
    redirect_to "/login"
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
