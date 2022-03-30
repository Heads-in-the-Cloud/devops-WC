# devops-WC

## Library for devOps files and resources for the Utopia Capstone Project.

### Ansible
Branches: feature-ansible-dev, feature-ansible-prod
**Directories:**  
**EKS_UP**: main playbook that creates an EKS cluster along with deployment, servies, namespaces, configmaps, secrets to run the microservices. Contains a Jenkinsfile
that calls the Ansible job using the Ansible plugin.  
**EKS_DOWN**: complementary playbook that deletes the EKS cluster and any attached resources to it (Route53 and iam policy attachment)  
**Microservices**: used for updating each microservice that is running on the EKS individually by updating the kubeconfig and performing a rollout restart.  
Deprecated: EC2 directory, has playbooks to create EC2's, target groups, and a load balancer to deploy microservices pulled from ECR.
