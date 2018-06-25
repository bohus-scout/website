class AnmalanController < ApplicationController
    def anmal
        @u = Thing(request, [:name, :email, :phone, :info])

        AnmalanMailer.with(user: @u).anmalan_email.deliver_now
    end


end

def Thing(params, members)
    return Struct.new(*members).new(*(members.map{|x| params[x]}))
end