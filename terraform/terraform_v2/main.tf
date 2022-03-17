

module "networks" {

  source                = "./modules/networks"
  vpc_cidr_block        = "10.10.0.0/16"
  subnet1_cidr_block    = "10.10.1.0/24"
  subnet2_cidr_block    = "10.10.2.0/24"
  subnet3_cidr_block    = "10.10.3.0/24"
  subnet4_cidr_block    = "10.10.4.0/24"
  anywhere_ipv4         = "0.0.0.0/0"
  vpc_name              = "WC-vpc"
  pc_name               = "WC-Jenkins-pc"
  peering_rt_name       = "JenkinsPrivate"
  internet_gw_name      = "WC-ig"
  peering_vpc_name      = var.peering_vpc_name
  aws_account_id        = var.aws_account_id
  region                = var.region
  environment           = var.environment
  cluster_name          = var.cluster_name #tag identifier for ALB ingress controller
}

module "rds" {

  source                = "./modules/rds"
  db_instance           = "db.t2.micro"
  db_identifier         = "database-wc"
  db_name               = "utopia"
  db_engine             = "mysql"
  db_engine_version     = "8.0"
  instance_type         = "t2.micro"
  key_name              = var.key_name
  environment           = var.environment
  db_user               = "wc_db_admin"
  rds_ingress           = [
                          {
                            description      = "Allow HTTP from any IPv4",
                            from_port        = 80,
                            to_port          = 80,
                            protocol         = "tcp",
                            cidr_blocks      = ["0.0.0.0/0"],
                          },
                          {
                            description      = "Allow connection to MYSQL",
                            from_port        = 3306,
                            to_port          = 3306,
                            protocol         = "tcp",
                            cidr_blocks      = ["0.0.0.0/0"],           
                          }
                          ]
  rds_egress            = [{
                            description      = "Allow egress to anywhere ipv4/ipv6",
                            from_port        = 0,
                            to_port          = 0,
                            protocol         = "-1",
                            cidr_blocks      = ["0.0.0.0/0"],
                            ipv6_cidr_blocks = ["::/0"]
                          }]
  ec2_ingress           = [{
                            description      = "Allow SSH from anywhere",
                            from_port        = 22,
                            to_port          = 22,
                            protocol         = "tcp",
                            cidr_blocks      = ["0.0.0.0/0"], 
                          }]
  ec2_egress            = [{
                          description      = "Allow egress to anywhere ipv4/ipv6",
                          from_port        = 0,
                          to_port          = 0,
                          protocol         = "-1",
                          cidr_blocks      = ["0.0.0.0/0"],
                          ipv6_cidr_blocks = ["::/0"]
                          }]
  ssm_path              = var.ssm_path
  subnet_group_id       = module.networks.subnet_group_id
  public_subnet_id      = element(module.networks.public-subnet-ids, 0)
  vpc_id                = module.networks.vpc.id
}