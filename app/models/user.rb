require 'openssl'

class User < ApplicationRecord

  ITERATIONS = 20_000
  DIGEST = OpenSSL::Digest::SHA256.new

  attr_accessor :password

  has_many :questions
  before_validation :normalize_username
  validates :email, :username, presence: true

  validates :username, length: {maximum: 40}, format: {with: /\A[A-Za-z\d_]+\z/i}
  validates :email, :username, uniqueness: true
  validates :email, 'valid_email2/email': true
  validates :password, presence: true, on: :create

  validates_confirmation_of :password

  before_save :encrypt_password


  def normalize_username
    username.downcase!
  end
  def encrypt_password
    if password.present?
      # Создаем т. н. «соль» — рандомная строка усложняющая задачу хакерам по
      # взлому пароля, даже если у них окажется наша база данных.
      self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))

      # Создаем хэш пароля — длинная уникальная строка, из которой невозможно
      # восстановить исходный пароль. Однако, если правильный пароль у нас есть,
      # мы легко можем получить такую же строку и сравнить её с той, что в базе.
      self.password_hash = User.hash_to_string(
          OpenSSL::PKCS5.pbkdf2_hmac(
              password, password_salt, ITERATIONS, DIGEST.length, DIGEST
          )
      )

      # Оба поля окажутся записанными в базу при сохранении (save).
    end
  end

  # Служебный метод, преобразующий бинарную строку в 16-ричный формат,
  # для удобства хранения.
  def self.hash_to_string(password_hash)
    password_hash.unpack('H*')[0]
  end

  # Основной метод для аутентификации юзера (логина). Проверяет email и пароль,
  # если пользователь с такой комбинацией есть в базе возвращает этого
  # пользователя. Если нету — возвращает nil.
  def self.authenticate(email, password)
    # Сперва находим кандидата по email
    user = find_by(email: email)

    # Если пользователь не найдет, возвращаем nil
    return nil unless user.present?

    # Формируем хэш пароля из того, что передали в метод
    hashed_password = User.hash_to_string(
        OpenSSL::PKCS5.pbkdf2_hmac(
            password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST
        )
    )

    # Обратите внимание: сравнивается password_hash, а оригинальный пароль так
    # никогда и не сохраняется нигде. Если пароли совпали, возвращаем
    # пользователя.
    return user if user.password_hash == hashed_password

    # Иначе, возвращаем nil
    nil
  end
end
