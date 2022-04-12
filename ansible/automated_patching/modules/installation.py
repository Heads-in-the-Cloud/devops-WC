import subprocess, argparse, logging

def install_certbot():
    try:
        subprocess.check_output(["sudo", "apt", "install", "certbot", "python3-certbot-nginx", "-y"])
    except subprocess.CalledProcessError as exception:   
        logging.error(exception.output)
        f = open("logs.txt", "a")
        f.write(exception.output)
        f.close()
        print("error code", exception.returncode, exception.output)
    try: 
        subprocess.check_output(["sudo", "certbot", "--nginx", "-m", "walter.chang@smoothstack.com", "--agree-tos", "-d", "certbot.hitwc.link", "--redirect", "-n"])
    except subprocess.CalledProcessError as exception:                                                                                                   
        print("error code", exception.returncode, exception.output)

def install_openssh():
    try:
        subprocess.check_output(["sudo", "apt-get", "install", "openssh-client", "-y"])
    except subprocess.CalledProcessError as exception:
        print("error code", exception.returncode, exception.output)
    try:
        subprocess.check_output(["sudo", "systemctl", "enable", "ssh"])
    except subprocess.CalledProcessError as exception:
        print("error code", exception.returncode, exception.output)
    try:
        subprocess.check_output(["sudo", "ufw", "allow", "ssh"])
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
