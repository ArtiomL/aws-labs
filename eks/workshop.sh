#!/usr/bin/env bash
# Create an EKS Cluster
# https://github.com/ArtiomL/aws-labs
# Artiom Lichtenstein
# v1.0.1, 17/10/2019

# Install kubectl
sudo curl --silent --location -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.13.7/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl

# Install JQ and envsubst
sudo yum -y install jq gettext

# Verify the binaries are in the path and executable
for command in kubectl jq envsubst
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done

read -s -p "Please verify the binaries are in the path and executable. Press enter to continue "; echo

# Update IAM settings for your workspace
read -s -p "Please update IAM settings for your workspace. Press enter to continue "; echo

# Remove an existing credentials file
rm -vf ${HOME}/.aws/credentials

# Configure our aws cli with our current region as default
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo "export ACCOUNT_ID=${ACCOUNT_ID}" >> ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region

# Validate the IAM role
aws sts get-caller-identity
read -s -p "Please validate the IAM role. Press enter to continue "; echo

# Clone the service repos
cd ~/environment
git clone https://github.com/brentley/ecsdemo-frontend.git
git clone https://github.com/brentley/ecsdemo-nodejs.git
git clone https://github.com/brentley/ecsdemo-crystal.git

# Generate SSH Key
ssh-keygen

# Upload the public key to your EC2 region
aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material file://~/.ssh/id_rsa.pub

# Download the eksctl binary
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin

# Confirm the eksctl command works
eksctl version
read -s -p "Please confirm the eksctl command works. Press enter to continue "; echo

# Create an EKS cluster
eksctl create cluster --name=eksworkshop-eksctl --nodes=3 --alb-ingress-access --region=${AWS_REGION}

# Confirm your Nodes
kubectl get nodes

# Export the Worker Role Name for use throughout the workshop
STACK_NAME=$(eksctl get nodegroup --cluster eksworkshop-eksctl -o json | jq -r '.[].StackName')
INSTANCE_PROFILE_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="InstanceProfileARN") | .OutputValue')
ROLE_NAME=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="InstanceRoleARN") | .OutputValue' | cut -f2 -d/)
echo "export ROLE_NAME=${ROLE_NAME}" >> ~/.bash_profile
echo "export INSTANCE_PROFILE_ARN=${INSTANCE_PROFILE_ARN}" >> ~/.bash_profile

# You now have a fully working Amazon EKS Cluster
