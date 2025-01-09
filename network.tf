//Create VPC
module "vpc_master" {
  source = "./modules/aws_vpc"
  providers = {
    aws = aws.region-master
  }
  cidr_block_vpc = var.cidr_block_master_vpc
  tag            = "master-vpc"
}
module "vpc_worker" {
  source = "./modules/aws_vpc"
  providers = {
    aws = aws.region-worker
  }
  cidr_block_vpc = var.cidr_block_worker_vpc
  tag            = "worker-vpc"
}
//Create IGW
module "igw-master" {
  source = "./modules/aws_internet_gateway"
  providers = {
    aws = aws.region-master
  }
  id_vpc = module.vpc_master.id_vpc
  tag    = "IGW-MasterVPC"
}
module "igw-worker" {
  source = "./modules/aws_internet_gateway"
  providers = {
    aws = aws.region-worker
  }
  id_vpc = module.vpc_worker.id_vpc
  tag    = "IGW-WorkerVPC"
}
//Create data az
module "available_master" {
  source = "./modules/aws_availability_zones"
  providers = {
    aws = aws.region-master
  }
}
module "available_worker" {
  source = "./modules/aws_availability_zones"
  providers = {
    aws = aws.region-worker
  }
}
//Create subnet
module "subnet_master_1" {
  source = "./modules/aws_subnet"
  providers = {
    aws = aws.region-master
  }
  cidr_block_subnet = var.cidr_block_master_subnet_1
  vpc_id            = module.vpc_master.id_vpc
  tag               = "subnet_master_1"
  az                = element(module.available_master.names,0)

}
module "subnet_master_2" {
  source = "./modules/aws_subnet"
  providers = {
    aws = aws.region-master
  }
  az                = element(module.available_master.names,1)
  cidr_block_subnet = var.cidr_block_master_subnet_2
  tag               = "subnet_master_2"
  vpc_id            = module.vpc_master.id_vpc

}
module "subnet_master_3" {
  source = "./modules/aws_subnet"
  providers = {
    aws = aws.region-master
  }
  az                = element(module.available_master.names,0)
  cidr_block_subnet = var.cidr_block_master_subnet_3
  tag               = "subnet_master_3"
  vpc_id            = module.vpc_master.id_vpc

}
module "subnet_master_4" {
  source = "./modules/aws_subnet"
  providers = {
    aws = aws.region-master
  }
  az                = element(module.available_master.names,1)
  cidr_block_subnet = var.cidr_block_master_subnet_4
  tag               = "subnet_master_4"
  vpc_id            = module.vpc_master.id_vpc

}
module "subnet_worker_1" {
  source = "./modules/aws_subnet"
  providers = {
    aws = aws.region-worker
  }
  az                = element(module.available_worker.names,0)
  cidr_block_subnet = var.cidr_block_worker_subnet_1
  vpc_id            = module.vpc_worker.id_vpc
  tag               = "subnet_worker_1"
}
//Create vpc-peering
module "apsoutheast1-apsoutheast2" {
  source = "./modules/aws_vpc_peering_connection"
  providers = {
    aws = aws.region-master
  }
  id_vpc_master = module.vpc_master.id_vpc
  id_vpc_worker = module.vpc_worker.id_vpc
  region-worker = var.region-worker
  depends_on    = [module.vpc_worker, module.vpc_master]
}
module "accept_peering" {
  source = "./modules/aws_vpc_peering_connection_accepter"
  providers = {
    aws = aws.region-worker
  }
  id_vpc_peering_connection = module.apsoutheast1-apsoutheast2.id_peering
}
//create route-table
module "route-table-master" {
  source = "./modules/aws_route_table"
  providers = {
    aws = aws.region-master
  }
  vpc_id         = module.vpc_master.id_vpc
  igw-id         = module.igw-master.id_igw
  cidr_valid     = var.cidr_block_worker_subnet_1
  vpc-peering-id = module.apsoutheast1-apsoutheast2.id_peering
  tag            = "Master-Region-Route-Table"
}
module "set-master-default-router-associate" {
  source = "./modules/aws_main_route_table_association"
  providers = {
    aws = aws.region-master
  }
  route_table_id = module.route-table-master.id
  vpc_id         = module.vpc_master.id_vpc
}
module "route-table-worker" {
  source = "./modules/aws_route_table"
  providers = {
    aws = aws.region-worker
  }
  vpc_id         = module.vpc_worker.id_vpc
  igw-id         = module.igw-worker.id_igw
  cidr_valid     = var.cidr_block_master_subnet_1
  vpc-peering-id = module.apsoutheast1-apsoutheast2.id_peering
  tag            = "Worker-Region-Route-Table"
}
module "set-worker-default-router-associate" {
  source = "./modules/aws_main_route_table_association"
  providers = {
    aws = aws.region-worker
  }
  vpc_id         = module.vpc_worker.id_vpc
  route_table_id = module.route-table-worker.id
}