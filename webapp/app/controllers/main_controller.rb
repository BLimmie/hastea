require_relative "../models"

class MainController < ApplicationController
  before_action :require_login , :except => [:login, :register, :login_post, :register_post, :activation, :activation_post]

  def index
  end
  def login
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
    @user.email = params[:email]
    @user.phone_number = params[:phone_number]
    @user.first_name = params[:first_name]
    @user.last_name = params[:last_name]
    @user.set_password(params[:password]) if params[:password] && !params[:password].empty?

    if params[:avatar]
      file = params[:avatar]
      # Create directories if they do not exist already
      Dir.mkdir("./public/uploads/users/#{@user.id}") unless Dir.exist?("./public/uploads/users/#{@user.id}")
      # Dir.mkdir("./public/uploads/users/#{@user.id}/avatar") unless Dir.exist?("./public/uploads/users/#{@user.id}/avatar")
      File.delete("./public/uploads/users/#{@user.id}/user_avatar.png") if File.exist?("./public/uploads/users/#{@user.id}/user_avatar.png")
      File.open("./public/uploads/users/#{@user.id}/user_avatar.png", 'wb') do |f|
        f.write(file.read)
      end
    end
    redirect_to "/user/preferences"
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
    user.save_changes
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

    render(plain: "Invalid activation code.") and return if (params[:activation].nil? || !params[:activation].to_i.between?(0,9999))
    render(plain: "Wrong activation code.") and return if (user.activation_code != params[:activation].to_i)

    user.is_verified = 1
    user.save_changes
    redirect_to "/login"
  end
  def new_order
    render(plain: "Missing order") and return if params[:order_desc].nil? || params[:order_desc].empty?
    render(plain: "Missing run") and return if params[:run_id].nil?
    order = Order.new(:run_id => params[:run_id], :user_id=>@user.id, :order_desc => params[:order_desc], :status => 1, :cost => 0)
    order.save()
    redirect_to "/index"
  end
  def new_run_post
    render(plain: "No location selected") and return if params[:business_id].nil?
    render(plain: "Max Orders not set") and return if params[:max_orders].nil?
    render(plain: "Date not set") and return if params[:date].nil?
    render(plain: "Time not set") and return if params[:time].nil?
    render(plain: "No destination address set") and return if params[:pickup_addr].nil?

    run = Run.new(:runner_id => @user.id,
                  :business_id => params[:business_id],
                  :datetime => Time.strptime(params[:date]+" "+params[:time], "%m/%d/%Y %l:%M %p"),
                  :order_cap => params[:max_orders],
                  :status => 0,
                  :delivery_method => params[:delivery_method],
                  :pickup_addr => params[:pickup_addr],
                  :notes => params[:notes])
    p run
    run.save
    redirect_to "/index"
  end

  def new_comment
    comment = Comment.new(:run_id => params[:run_id], :author_id => @user.id, :content => params[:content])

    if params[:announce] == '1'
      client = Twilio::REST::Client.new
      if comment.author_id == Run[comment.run_id].runner_id
        Order.where(run_id: comment.run_id).each do |order|
          client.messages.create({
            from: Rails.application.credentials.twilio_phone_number,
            to: '+1'+User[order.user_id].phone_number,
            body: "Hastea Alert:\nRunner "+ User[order.user_id].first_name+" made a comment on a run you ordered from: "+comment.content
          })
        end
      else
        client.messages.create({
          from: Rails.application.credentials.twilio_phone_number,
          to: '+1'+User[Run[comment.run_id].runner_id].phone_number,
          body: "Hastea Alert:\nOrderer "+ User[Run[comment.run_id].runner_id].first_name+" made a comment on your run: "+comment.content
        })
      end
    end
    comment.save
    redirect_to "/index"
  end
  def runner_edit_post
    params.keys.each do |param|
      if param.match(/^\d+$/)
        order = Order[param.to_i]
        order.cost = (params[param].to_f*100).to_i
        order.save
      end
    end
  end
  def run_edit
  end
  def run_edit_post
    if params[:drinks]
      file = params[:drinks]
      # Create directories if they do not exist already
      Dir.mkdir("./public/uploads/runs/#{params[:id]}") unless Dir.exist?("./public/uploads/runs/#{params[:id]}")
      # Dir.mkdir("./public/uploads/users/#{@user.id}/avatar") unless Dir.exist?("./public/uploads/users/#{@user.id}/avatar")
      File.delete("./public/uploads/runs/#{params[:id]}/drinks.png") if File.exist?("./public/uploads/runs/#{params[:id]}/drinks.png")
      File.open("./public/uploads/runs/#{params[:id]}/drinks.png", 'wb') do |f|
        f.write(file.read)
      end
    end
    if params[:receipt]
      file = params[:receipt]
      # Create directories if they do not exist already
      Dir.mkdir("./public/uploads/runs/#{params[:id]}") unless Dir.exist?("./public/uploads/runs/#{params[:id]}")
      # Dir.mkdir("./public/uploads/users/#{@user.id}/avatar") unless Dir.exist?("./public/uploads/users/#{@user.id}/avatar")
      File.delete("./public/uploads/runs/#{params[:id]}/receipt.png") if File.exist?("./public/uploads/runs/#{params[:id]}/receipt.png")
      File.open("./public/uploads/runs/#{params[:id]}/receipt.png", 'wb') do |f|
        f.write(file.read)
      end
    end
    redirect_to "/run_edit/#{params[:id]}"
  end
  def run_state_onwards
    run = Run[params[:id]]
    if run.status == 0
      render(plain: "No Drinks Picture") and return if not File.exist?("./public/uploads/runs/#{params[:id]}/drinks.png")
      render(plain: "No Receipt Picture") and return if not File.exist?("./public/uploads/runs/#{params[:id]}/receipt.png")
      Order.where(run_id: run.id).each do |order|
        render(plain: "Cost of all orders has to be more than 0") and return if order.cost <= 0
      end
      Order.where(run_id: run.id).each do |order|
        user = User[order.user_id]
        user.credits -= order.cost
        user.save
      end
      run.status = 1
      run.save
    elsif run.status == 5
      render(plain: "Run already ended") and return
    else
      run.status += 1
      run.save
    end
    redirect_to "/run_edit/#{params[:id]}"
  end 
  private


  def require_login
    @user = User[session[:user_id]]
    authenticate!
  end
  def authenticate!
    if @user.nil?
      redirect_to "/login?redirect=#{request.fullpath}"
      return
    end
    if @user.is_verified == 0
      session[:user_id] = nil
      redirect "/login?disabled=1"
    end
  end
  def get_runs
    return Run.where[status: true].first()
  end
  def update
    @runs = get_runs
  end

end
def get_business_name (business_id)
  @client = GooglePlaces::Client.new(Rails.application.credentials.maps_api)
  spot = @client.spot(business_id)
  spot.name
end
