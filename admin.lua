local base64 = require("base64")

loggedi = false

-- Function to read username and password from file
local function readCredentials()
    local file = io.open("settings.hr", "r")
    if file then
        local data = file:read("*a")
        file:close()
        if data ~= "" then
            local decoded = base64.decode(data)
            local username, password = decoded:match("([^:]+):([^:]+)")
            return username, password
        end
    end
    return nil, nil
end

-- Function to save username and password to file
local function saveCredentials(username, password)
    local encoded = base64.encode(username .. ":" .. password)
    local file = io.open("settings.hr", "w")
    file:write(encoded)
    file:close()
end

-- Function to change password
local function changePassword(newPassword)
    local username, _ = readCredentials()
    if username then
        saveCredentials(username, newPassword)
        print("Password changed successfully.")
    else
        print("No existing credentials found.")
    end
end

local function changeUsername(newusername)
    local _, password = readCredentials()
    if password then
        saveCredentials(newusername, password)
        print("username changed successfully.")
    else
        print("No existing credentials found.")
    end
end

-- Main function

function start()
	print('Welcome to the Admin console , please select an option (1-5)')
	while loggedi do
		main()
	end
end


function main()
    print("1. Save new username and password")
    print("2. Read current username and password")
    print("3. Change password")
	print("4. Change username")
	print("5. Exit")
	io.write('admin> ')
    local choice = io.read()
    if choice == "1" then
        print("Enter username:")
		io.write('admin> ')
        local username = io.read()
        print("Enter password:")
		io.write('admin> ')
        local password = io.read()
        saveCredentials(username, password)
        print("Credentials saved successfully.")
    elseif choice == "2" then
        local username, password = readCredentials()
        if username then
            print("Current username:", username)
            print("Current password:", password)
        else
            print("No existing credentials found.")
        end
    elseif choice == "3" then
        print("Enter new password:")
		io.write('admin> ')
        local newPassword = io.read()
        changePassword(newPassword)
	elseif choice == "4" then
		print("Enter new username:")
		io.write('admin> ')
		newusername = io.read()
		changeUsername(newusername)
	elseif choice == "5" or choice == 'Exit' or choice == 'exit' then
		os.exit()
    else
        print("Invalid choice. Please select a number from 1-5 ")
    end
end


function loggins()

	username, password = readCredentials()

	print('To access the admin console , please login again')
	io.write('Username: ')
	att_user = io.read()
	io.write('Password: ')
	att_pass = io.read()
	if att_pass == password and att_user == username then
		loggedi = true
		start()
	else
		print('Error: Wrong password')
	end
end

loggins()
