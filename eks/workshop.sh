#!/usr/bin/env bash

# Create the default ~/.kube directory for storing kubectl configuration
mkdir -p ~/.kube

# Install kubectl
sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl

# Install AWS IAM Authenticator
go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator
sudo mv ~/go/bin/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

# Install JQ and envsubst
sudo yum -y install jq gettext

# Verify the binaries are in the path and executable
for command in kubectl aws-iam-authenticator jq envsubst
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done

read -s -p "Please verify the binaries are in the path and executable. Press enter to continue "; echo

# Clone the service repos
cd ~/environment
git clone https://github.com/brentley/ecsdemo-frontend.git
git clone https://github.com/brentley/ecsdemo-nodejs.git
git clone https://github.com/brentley/ecsdemo-crystal.git

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
eksctl create cluster --name=eksworkshop-eksctl --nodes=3 --node-ami=auto --region=${AWS_REGION}

# Confirm your Nodes
kubectl get nodes

# Export the Worker Role Name for use throughout the workshop
INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep nodegroup)
INSTANCE_PROFILE_ARN=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Arn')
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
echo "export ROLE_NAME=${ROLE_NAME}" >> ~/.bash_profile
echo "export INSTANCE_PROFILE_ARN=${INSTANCE_PROFILE_ARN}" >> ~/.bash_profile
