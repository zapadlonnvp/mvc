class UsersController < ApplicationController
  # Загружаем юзера из базы для экшенов кроме :index, :create, :new
  before_action :load_user, except: [:index, :create, :new]

  # Проверяем имеет ли юзер доступ к экшену, делаем это для всех действий, кроме
  # :index, :new, :create, :show — к этим действиям есть доступ у всех, даже у
  # тех, у кого вообще нет аккаунта на нашем сайте.
  before_action :authorize_user, except: [:index, :new, :create, :show]

  def index
    # Создаём массив из двух болванок пользователей. Вызываем метод # User.new, который создает модель, не записывая её в базу.
    # У каждого юзера мы прописали id, чтобы сымитировать реальную
    # ситуацию – иначе не будет работать хелпер путей

    @users = User.all
  end

  def new
    redirect_to root_url, alert: 'Вы уже залогинены' if current_user.present?

    # Иначе, создаем болванку нового пользователя.
    @user = User.new
  end

  def edit
  end

  def create
    # Если пользователь уже авторизован, ему не нужна новая учетная запись,
    # отправляем его на главную с сообщением.
    redirect_to root_url, alert: 'Вы уже залогинены' if current_user.present?

    # Иначе, создаем нового пользователя с параметрами, которые нам предоставит
    # метод user_params.

    @user = User.new(user_params)

    # Пытаемся сохранить пользователя.
    if @user.save
      # Если удалось, отправляем пользователя на главную с сообщение, что
      # пользователь создан.
      session[:user_id] = @user.id
      redirect_to root_url, notice: 'Пользователь успешно зарегистрирован'
    else
      # Если не удалось по какой-то причине сохранить пользователя, то рисуем
      # (обратите внимание, это не редирект), страницу new с формой
      # пользователя, который у нас лежит в переменной @user. В этом объекте
      # содержатся ошибки валидации, которые выведет шаблон формы.
      render 'new'
    end
  end

  def show
    @user = User.find params[:id]
    # берём вопросы у найденного юзера
    @questions = @user.questions.order(created_at: :desc)
    count = @questions.count
    plural = Russian.p(count, "вопрос", "вопроса", "вопросов")
    @string = "у этого пользователя #{count} #{plural}"
    # Для формы нового вопроса создаём заготовку, вызывая build у результата вызова метода @user.questions.
    @new_question = @user.questions.build
    @questions_count = @questions.count
    @answers_count = @questions.where.not(answer: nil).count
    @unanswered_count = @questions_count - @answers_count
  end

  def update
    # Получаем параметры нового (обновленного) пользователя с помощью метода user_params
    @user = User.find user_params[:id]
    # пытаемся обновить юзера
    if @user.update(user_params)
      # Если получилось, отправляем пользователя на его страницу с сообщением
      redirect_to user_path(@user), notice: 'Данные обновлены'
    else
      # Если не получилось, как и в create, рисуем страницу редактирования
      # пользователя со списком ошибок
      render 'edit'
    end
  end

  private

  def authorize_user
    reject_user unless @user == current_user
  end

  # Загружаем из базы запрошенного юзера, находя его по params[:id].
  def load_user
    @user ||= User.find params[:id]
  end

  def user_params
    # берём объект params, потребуем у него иметь ключ
    # :user, у него с помощью метода permit разрешаем
    # набор инпутов. Ничего лишнего, кроме них, в пользователя не попадёт
    params.require(:user).permit(:password, :password_confirmation, :name, :username, :avatar_url, :email)
  end

end
