class UsersController < ApplicationController
  @questions = [
      Question.new(text: 'Как дела?', created_at: Date.parse('27.03.2016'))
  ]

  def index
    # Создаём массив из двух болванок пользователей. Вызываем метод # User.new, который создает модель, не записывая её в базу.
    # У каждого юзера мы прописали id, чтобы сымитировать реальную
    # ситуацию – иначе не будет работать хелпер путей

    @users = User.all
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Если удачно, отправляем пользователя на главную с помощью метода redirect_to
      # с сообщением
      redirect_to root_url, notice: 'Пользователь успешно зарегистрирован!'
    end
  end

  def show
    @user = User.new(
        name: 'Vadim',
        username: 'installero',
        avatar_url: 'https://secure.gravatar.com/avatar/' \
      '71269686e0f757ddb4f73614f43ae445?s=100'
    )
    @questions = [
        Question.new(text: 'Как дела?', created_at: Date.parse('27.03.2016'))
    ]
    @new_question = Question.new
  end

  private

  def user_params
    # берём объект params, потребуем у него иметь ключ
    # :user, у него с помощью метода permit разрешаем
    # набор инпутов. Ничего лишнего, кроме них, в пользователя не попадёт
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :name, :username, :avatar_url)
  end
end
