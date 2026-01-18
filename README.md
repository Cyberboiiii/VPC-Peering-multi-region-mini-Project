Networking Components

Two VPCs:

Primary VPC in us-east-1 (10.0.0.0/16)
Secondary VPC in us-west-2 (10.1.0.0/16)
Subnets:

One public subnet in each VPC
Configured with auto-assign public IP
Internet Gateways:

One for each VPC to allow internet access
Route Tables:

Custom route tables with routes to internet and peered VPC
Routes for VPC peering traffic
VPC Peering Connection:

Cross-region peering between the two VPCs
Automatic acceptance configured
Compute Resources

EC2 Instances:

One t2.micro instance in each VPC
Running Amazon Linux 2
Apache web server installed
Custom web page showing VPC information
Security Groups:

SSH access from anywhere (port 22)
ICMP (ping) allowed from peered VPC
All TCP traffic allowed between VPCs
