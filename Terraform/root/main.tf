module "vpc" {
    source = "../modules/vpc"
  
}

module "bacend" {
    source = "../modules/backend"
  
}
module "ecr" {
    source = "../modules/ecr"
  
}
module "ecs" {
    source = "../modules/Ecs"
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.subnets

  
}


    
  