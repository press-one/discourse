module Jobs

  class VerifyIdCard < Jobs::Base

    sidekiq_options queue: "default"

    def execute(args)
      user = User.find_by_id args[:user_id]
      user && user.user_identity.verify_id_card
    end
  end

end
