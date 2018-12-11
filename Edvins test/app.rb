require "sinatra"
require "slim"

get("/") do
    slim(:index)
end



error 404 do
    slim(:notfound)
end