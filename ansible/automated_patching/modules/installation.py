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
        subprocess.check_output(["sudo", "systemctl", "start", "nginx"], stderr=STDOUT)
    except subprocess.CalledProcessError as exception:  
        logging.error(exception.output)

def install_certbot():
    try:
        #get latest version of snapd
        subprocess.check_output(["sudo", "snap", "install", "core"], stderr=STDOUT)
        subprocess.check_output(["sudo", "snap", "refresh", "core"], stderr=STDOUT)

    except subprocess.CalledProcessError as exception:  
        logging.error(exception.output)
        return False

    try:
        #install certbot
        subprocess.check_output(["sudo", "snap", "install", "--classic", "certbot"], stderr=STDOUT)
    except subprocess.CalledProcessError as exception:   
        logging.error(exception.output)
        return False
    
    #set up certificate with nginx using a non-interactive mode with email, domain, and license agreement
    try: 
        subprocess.check_output(["sudo", "certbot", "--nginx", "-m", "walter.chang@smoothstack.com", "--agree-tos", "-d", args.domain, "--redirect", "-n"], stderr=STDOUT)
    except subprocess.CalledProcessError as exception:                                                                                                   
        logging.error(exception.output)
        return False

def install_openssh():

    #install openssh-client using apt
    try:
        subprocess.check_output(["sudo", "apt-get", "install", "openssh-client", "-y"], stderr=STDOUT)
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        return False
    
    #enable ssh as a service
    try:
        subprocess.check_output(["sudo", "systemctl", "enable", "ssh"], stderr=STDOUT)
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        return False
    
    #ufw allow ssh
    try:
        subprocess.check_output(["sudo", "ufw", "allow", "ssh"], stderr=STDOUT)
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        return False

def update_certbot():
    try:
        subprocess.check_output(["ls", "-l"], stderr=STDOUT)
        # subprocess.check_output(["sudo", "apt-get", "install", "--only-upgrade", "certbot"])
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        return False

def update_openssh():
    pass

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
        if args.update:
            update_openssh()
        else:
            install_openssh()
    else:
        install_nginx()
