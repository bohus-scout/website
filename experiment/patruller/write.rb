
def write(scoutnet)
    file = File.open("database.txt", 'w:UTF-8')
    data_string = ""
    scoutnet["data"].each do |key, value|
        data_string += "#{value["first_name"]["value"]} #{value["last_name"]["value"]} #{value["unit"]["value"]}\n"
    end
    file.write(data_string)
end