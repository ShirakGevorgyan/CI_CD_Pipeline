# Input variables
variable "vpc_cidr" {
    type    = string
    default = "10.0.0.0/16"
}
variable "public_cidrs" {
    default = [
    "10.0.0.0/24",
    "10.0.2.0/24",
    "10.0.4.0/24"
    # "10.0.6.0/24"
    ]
}

variable "private_cidrs" {
    default = [
    "10.0.1.0/24",
    "10.0.3.0/24",
    "10.0.5.0/24"
    # "10.0.7.0/24"
    ]
}

variable "main_vol_size" {
    type    = number
    default = 8
}

variable "key_name" {
    type    = string
    default = "DemoKey"
}

variable "public_key_path" {
    type    = string
    default = "/home/marshal/.ssh/id_rsa.pub"
}



# variable "public_cidrs" {
#     type = list(string)
#     default = [ 
#         "10.0.1.0/24",   # Նոր CIDR բլոկներ, որոնք համընկնում են VPC CIDR սահմանների հետ
#         "10.0.2.0/24",
#         "10.0.3.0/24",
#         "10.0.4.0/24"
#     ]
# }

# variable "private_cidrs" {
#     type = list(string)
#     default = [ 
#         "10.0.5.0/24",   # Նոր CIDR բլոկներ, որոնք համընկնում են VPC CIDR սահմանների հետ
#         "10.0.6.0/24",
#         "10.0.7.0/24",
#         "10.0.8.0/24"
#     ]
# }

# variable "vpc_cidr" {
#     type = string
#     default = "10.0.0.0/16"
# }
# variable "access_ip" {
#     type =  list(string)
#     default = ["0.0.0.0/0"]
# }
# variable "main_vol_size" {
#     type = number
#     default = "20"
# }
# variable "key_name" {
#     type = string
#     default = "Demo-key"
# }

# variable "public_key_path" {
#     description = "Path to the public key file"
#     default     = "/home/marshal/.ssh/id_rsa.pub"
# }
