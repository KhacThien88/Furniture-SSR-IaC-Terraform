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
  depends_on    = [module.set-master-default-router-associate , module.subnet_master_1 , module.sg-instances-master]
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
  depends_on    = [module.set-worker-default-router-associate , module.subnet_worker_1 , module.sg-instances-worker]
  ansible_playbook_path    = "ansible_templates/install_worker.yaml"
  region        = var.region-worker
  profile       = var.profile
  
}