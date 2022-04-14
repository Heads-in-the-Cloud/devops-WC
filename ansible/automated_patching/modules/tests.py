from asyncio.subprocess import STDOUT
import logging, subprocess, sys, argparse


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("debug.log"),
        logging.StreamHandler(sys.stdout)
    ]
)

#Test dry run of renewing a certificate
def test_renew_cert():
    try:
        subprocess.check_output(["sudo", "certbot", "renew", "--dry-run"], stderr=STDOUT)
        return True
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        return False

#Test if the site is serving over HTTPS
def test_https():
    try:
        subprocess.check_output(["curl", "-i", "https://"+args.domain], stderr=STDOUT)
        logging.info("Application served over https")
        return True
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        return False

#Test if ssh is available
def test_ssh():
    try:
        subprocess.check_output(["timeout", "5", "bash", "-c", "</dev/tcp/"+args.domain+"/22"])
        return True
    except subprocess.CalledProcessError as exception:
        logging.error(exception.output)
        return False

if __name__ == "__main__":

    #parse arguments using argparse import
    parser=argparse.ArgumentParser()

    parser.add_argument("-c", "--certbot", help="install certbot", action="store_true")
    parser.add_argument("-o", "--openssh", help="install openssh client", action="store_true")
    parser.add_argument("-d", "--domain", help="domain name for service", type=str)
    args = parser.parse_args()

    if args.certbot:
        if test_renew_cert() and test_https():
            sys.exit(0)
        sys.exit(1)
    if args.openssh:
        if test_ssh():
            sys.exit(0)
        sys.exit(1)

    