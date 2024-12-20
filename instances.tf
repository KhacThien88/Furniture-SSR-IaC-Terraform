module "MasterAmi" {
  source = "./modules/aws_ssm_parameter"
  providers = {
    aws = aws.region-master
  }
  name_ami = var.ami_master
}
module "WorkerAmi" {
  source = "./modules/aws_ssm_parameter"
  providers = {
    aws = aws.region-worker
  }
  name_ami = var.ami_worker
}
module "master-key" {
  source = "./modules/aws_key_pair"
  providers = {
    aws = aws.region-master
  }
  path_to_file = var.path_to_file_key
  key_name     = "sshkey"
}
module "worker-key" {
  source = "./modules/aws_key_pair"
  providers = {
    aws = aws.region-worker
  }
  path_to_file = var.path_to_file_key
  key_name     = "sshkey"
}
module "sg-instances-lb" {
  source = "./modules/aws_security_group_lb"
  providers = {
    aws = aws.region-master
  }
  vpc_master_id = module.vpc_master.id_vpc
  depends_on = [ module.vpc_master ]
}
module "sg-instances-master" {
  source = "./modules/aws_security_group_instance"
  providers = {
    aws = aws.region-master
  }
  external_ip = var.external_ip
  sg-lb-id    = module.sg-instances-lb.id
  vpc_id      = module.vpc_master.id_vpc
  subnet_1    = var.cidr_block_worker_subnet_1
  depends_on = [ module.vpc_master ]
}
module "sg-instances-worker" {
  source = "./modules/aws_security_group_instance"
  providers = {
    aws = aws.region-worker
  }
  external_ip = var.external_ip
  sg-lb-id    = module.sg-instances-lb.id
  vpc_id      = module.vpc_master.id_vpc
  subnet_1    = var.cidr_block_master_subnet_1
  depends_on = [ module.vpc_worker ]
}
module "master-control-plane" {
  source = "./modules/aws_instance"
  providers = {
    aws = aws.region-master
  }
  ami           = module.MasterAmi.value
  instance-type = var.instance-type
  key_name      = module.master-key.key_name
  subnet_id_1   = module.subnet_master_1.id
  sg_id         = module.sg-instances-master.id
  tag           = "master_control_plane_tf"
  depends_on    = [module.set-master-default-router-associate , module.subnet_master_1]
  ansible_playbook_path     = "ansible_templates/install_plugins.yaml"
  region        = var.region-master
  profile       = var.profile
}
module "worker" {
  source = "./modules/aws_instance"
  providers = {
    aws = aws.region-worker
  }
  ami           = module.WorkerAmi.value
  instance-type = var.instance-type
  key_name      = module.worker-key.key_name
  subnet_id_1   = module.subnet_worker_1.id
  sg_id         = module.sg-instances-worker.id
  tag           = "worker_tf"
  depends_on    = [module.set-worker-default-router-associate , module.subnet_worker_1]
  ansible_playbook_path    = "ansible_templates/install_worker.yaml"
  region        = var.region-master
  profile       = var.profile
  
}