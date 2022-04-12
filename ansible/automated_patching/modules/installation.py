import subprocess
import argparse

def install_certbot():
    try:
        output = subprocess.check_output(["sudo", "apt", "install", "certbot", "python3-certbot-nginx", "-y"])
        print(output)
    except subprocess.CalledProcessError as exception:                                                                                                   
        print("error code", exception.returncode, exception.output)
    try: 
        subprocess.check_output(["sudo", "certbot", "--nginx", "-m", "walter.chang@smoothstack.com", "--agree-tos", "-d", "certbot.hitwc.link", "--redirect", "-n"])
    except subprocess.CalledProcessError as exception:                                                                                                   
        print("error code", exception.returncode, exception.output)

def install_openssh():
    try:
        output = subprocess.check_output(["sudo", "apt-get", "install", "openssh-client", "-y"])
    except subprocess.CalledProcessError as exception:
        print("error code", exception.returncode, exception.output)
    try:
        output = subprocess.check_output(["sudo", "systemctl", "enable", "ssh"])
    except subprocess.CalledProcessError as exception:
        print("error code", exception.returncode, exception.output)
    try:
        output = subprocess.check_output(["sudo", "ufw", "allow", "ssh"])
    except subprocess.CalledProcessError as exception:
        print("error code", exception.returncode, exception.output)

if __name__ == "__main__":

    parser=argparse.ArgumentParser()

    parser.add_argument("-c", "--certbot", help="install certbot", action="store_true")
    parser.add_argument("-o", "--openssh", help="install openssh client", action="store_true")
    args = parser.parse_args()
    if args.certbot:
        install_certbot()
    elif args.openssh:
        install_openssh()
