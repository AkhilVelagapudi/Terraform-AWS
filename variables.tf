provider "aws" {
  region = "us-east-2" 
  access_key = "hidden"
  secret_key = "hidden"
}

variable "vpcname" {
    type = string
    default = "main"
}

variable "sshport" {
    type = number
    default = 22
}

variable "enabled" {
    default = true
}

variable "mylist" {
    type = list(string)
    default = ["Value1", "Value2"]
}

variable "mymap" {
    type = map
    default = {
        Key1 = "Value1"
        Key2 = "Value2"
    }
}

variable "inputname"{
    type = string
    description = "Set the name of the vpc"
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" 
  
  tags = {
    Name = var.inputname
  }
}

output "myoutput" {
    value = main.myvpc.id
}

variable "mytuple" {
    type = tuple([string, number, string])
    default = ["cat", 1, "dog"]
}

variable "myobject" {
    type = object({name = string, port = list(number)})
    default = {
        name = "Akhil"
        port = [22, 25, 80]

    }
}

module "ec2" {
    source = "./ec2"
    for_each = toset(["dev", "test", "prod"]) #This creates 3 ec2 instances
    count = 3 #Also creates 3 ec2 instances --> this is allowed only in the older versions
}
