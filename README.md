# devops-WC

**Description:** Library for devOps files and resources for the Utopia Capstone Project.

## Ansible
**Branches**: feature-ansible-dev, feature-ansible-prod  
**Directories:**  
  
**EKS_UP**: main playbook that creates an EKS cluster along with deployment, servies, namespaces, configmaps, secrets to run the microservices. Contains a Jenkinsfile
that calls the Ansible job using the Ansible plugin.   
  
**EKS_DOWN**: complementary playbook that deletes the EKS cluster and any attached resources to it (Route53 and iam policy attachment)  
  
**Microservices**: used for updating each microservice that is running on the EKS individually by updating the kubeconfig and performing a rollout restart.  
Deprecated: EC2 directory, has playbooks to create EC2's, target groups, and a load balancer to deploy microservices pulled from ECR.
  

## ECS
**Branches**: ecs-dev, ecs-prod  
  
**Directories:**  
**ecs-cli**: 
  - **definition files**: contains the cloudformation template to create an ALB, a docker-compose.yaml (template), and an ecs-params.yaml (template). 
  - **ecs_down**: Jenkins pipeline to stop all services in the given ECS cluster, delete the ecs cluster, and the cloudformation stack  
  - **ecs_up**: Jenkins pipeline to create the ECS cluster, cloudformation stack, and services and task definitions using the definition files.  
   
**Deprecated**:  
**ecs-context**: docker-compose via ecs context. Docker-compose yaml with secrets injected via docker secrets. No Jenkins pipeline.
**cloudformation**: creates the ECS cluster using a vanilla cloudformation template

## Kubernetes   
  
**Directories:**  
  
**eks:** contains YAML files for resources that need to be deployed into the eks cluster. Contains Jenkinsfile to create the cluster and apply YAML files in sequence.  
  
 **local:** contains YAML files to similar to the eks directory above, but for local deployment.
 
 ## Terraform
 

 **Branches:** terraform, terraform-networks, terraform-rds
   
 **Directories:**
   
 **terraform_v1:** original terraform script that includes ECS module and Load Balancer modules.
   
 **terraform_v2:** terraform script which deploys its own VPC and network resources as well as a peering connection to the Jenkins (default) vpc. Contains the RDS module.
   
 **networks:** terraform script that creates only networking resources.
   
 **rds:** terraform script that creates only resources for the RDS deployment. Gets the network resources ID's that it needs from the Secrest Manager.
