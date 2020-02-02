class UsersController < ApplicationController

  before_action :load_user, except: [:index, :create, :new]
  before_action :authorize_user, except: [:index, :new, :create, :show]

  def index
    @users = User.all
  end

  def new
    redirect_to root_url, alert: 'Вы уже залогинены' if current_user.present?
    @user = User.new
  end

  def edit
  end

  def create
    redirect_to root_url, alert: 'Вы уже залогинены' if current_user.present?
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, notice: 'Пользователь успешно зарегистрирован'
    else
      render 'new'
    end
  end

  def show
    @user = User.find params[:id]
    @questions = @user.questions.order(created_at: :desc)
    count = @questions.count
    plural = Russian.p(count, "вопрос", "вопроса", "вопросов")
    @string = "у этого пользователя #{count} #{plural}"
    @new_question = @user.questions.build
    @questions_count = @questions.count
    @answers_count = @questions.where.not(answer: nil).count
    @unanswered_count = @questions_count - @answers_count
  end

  def update
    @user = load_user
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'Данные обновлены'
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to root_path, notice: 'Пользователь самоуничтожился :('
  end

  private

  def authorize_user
    reject_user unless @user == current_user
  end

  def load_user
    @user ||= User.find params[:id]
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :name, :username, :avatar_url, :email, :color)
  end

end
