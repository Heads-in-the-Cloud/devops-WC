import subprocess

def update_certbot():
    subprocess.run(["sudo", "apt-get", "install", "--only-upgrade", "certbot"])



if __name__ == "__main__":
    update_certbot()