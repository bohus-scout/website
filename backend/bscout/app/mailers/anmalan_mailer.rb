class AnmalanMailer < ApplicationMailer
    default from: "zentabit@gmail.com"

    def anmalan_email
        @user = params[:user]
        

        mail(to: "emilbabayev14@gmail.com", subject: "Anmalan")
    end
end
