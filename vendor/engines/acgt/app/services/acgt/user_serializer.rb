module Acgt

  class UserSerializer

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def to_h
      {
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email
      }
    end

  end

end
