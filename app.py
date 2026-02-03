from flask import Flask
import platform
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return f"""
    <h1>Hello DevOps!</h1>
    <p>Server: {socket.gethostname()}</p>
    <p>Platform: {platform.system()} {platform.release()}</p>
    <p>This app is running in a container!</p>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)