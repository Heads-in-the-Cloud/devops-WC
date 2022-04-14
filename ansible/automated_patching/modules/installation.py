from asyncio.subprocess import STDOUT
import subprocess, argparse, logging, sys

#set up logging levels
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("debug.log"),
        logging.StreamHandler(sys.stdout)
    ]
)

def install_nginx():
    try:
        subprocess.check_output(["sudo", "apt-get", "install", "nginx", "-y"], stderr=STDOUT)
        logging.info("NGINX is installed")
    except subprocess.CalledProcessError as exception:  
        logging.error(exception.output)
        sys.exit(1)

def install_certbot():
    try:
        #setup virtual environment and upgrade pip
        subprocess.check_output(["sudo", "apt", "install", "python3", "python3-venv", "libaugeas0", "-y"], stderr=STDOUT)
        subprocess.check_output(["sudo", "python3", "-m", "venv", "/opt/certbot/"], stderr=STDOUT)
        subprocess.check_output(["sudo", "/opt/certbot/bin/pip", "install", "--upgrade", "pip"], stderr=STDOUT)


        #install certbot
        subprocess.check_output(["sudo", "/opt/certbot/bin/pip", "install", "certbot", "certbot-nginx"], stderr=STDOUT)

        #set up symlink for cerbot command
        subprocess.check_output(["sudo", "ln", "-s", "/opt/certbot/bin/certbot", "/usr/bin/certbot"], stderr=STDOUT)

        #set up certificate with nginx using a non-interactive mode with email, domain, and license agreement
        subprocess.check_output(["sudo", "certbot", "--nginx", "-m", "walter.chang@smoothstack.com", "--agree-tos", "-d", args.domain, "--redirect", "-n"], stderr=STDOUT)
        logging.info("certbot certificate has been received")
    except subprocess.CalledProcessError as exception:                                                                                                   
        logging.error(exception.output)
        sys.exit(1)

def install_openssh():

    #install openssh-client using apt
    try:
        subprocess.check_output(["sudo", "apt-get", "install", "openssh-client", "-y"], stderr=STDOUT)
    
        #enable ssh as a service
        subprocess.check_output(["sudo", "systemctl", "enable", "ssh"], stderr=STDOUT)
    
        #ufw allow ssh
        subprocess.check_output(["sudo", "ufw", "allow", "ssh"], stderr=STDOUT)
        logging.info("openssh-client installed")
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        sys.exit(1)

def update_certbot():
    try:
        #update certbot, throw exit 1 if process failes
        subprocess.check_output(["sudo", "/opt/certbot/bin/pip", "install", "--upgrade", "certbot-nginx"])
        logging.info("certbot updated")
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        logging.error("Update certbot failed")


if __name__ == "__main__":

    #parse arguments using argparse import
    parser=argparse.ArgumentParser()

    parser.add_argument("-c", "--certbot", help="install certbot", action="store_true")
    parser.add_argument("-o", "--openssh", help="install openssh client", action="store_true")
    parser.add_argument("-d", "--domain", help="domain name for service", type=str)
    parser.add_argument("-u", "--update", help="update only", action="store_true")
    parser.add_argument("-n", "--nginx", help="update only", action="store_true")
    args = parser.parse_args()

    #if -c then install certbot, if -o install openssh-client, if -n then install nginx
    if args.certbot:
        if args.update:
            update_certbot()
        else:
            install_certbot()
    elif args.openssh:
        install_openssh()
    else:
        install_nginx()
