#!/bin/bash
set -e -o pipefail

# Get admin user ARN
echo "Getting admin user identity..."
admin_arn=$(aws sts get-caller-identity --query 'Arn' --output text)
if [ $? -ne 0 ]; then
    echo "Failed to get admin identity"
    exit 1
fi
echo "Admin ARN: $admin_arn"

# Get node role ARN
echo "Getting node role ARN..."
node_role_arn=$(aws eks describe-nodegroup --cluster-name cluster --nodegroup-name udacity --query 'nodegroup.nodeRole' --output text)
echo "Node Role ARN: $node_role_arn"

# Update EKS configuration
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name cluster --region us-east-1

# Create aws-auth ConfigMap with both users and roles
echo "Creating aws-auth ConfigMap..."
cat << EOF > aws-auth-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${node_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: ${admin_arn}
      username: admin
      groups:
        - system:masters
EOF

# Apply the ConfigMap
echo "Applying aws-auth ConfigMap..."
kubectl apply -f aws-auth-configmap.yaml

# Wait for permissions to propagate
echo "Waiting for permissions to propagate..."
sleep 10

# Now proceed with github-action-user setup
echo "Fetching IAM github-action-user ARN"
userarn=$(aws iam get-user --user-name github-action-user | jq -r .User.Arn)

# Download authenticator
echo "Downloading aws-iam-authenticator..."
curl -X GET -L https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.2/aws-iam-authenticator_0.6.2_darwin_arm64 -o aws-iam-authenticator
chmod +x aws-iam-authenticator

echo "Updating permissions for github-action-user"
./aws-iam-authenticator add user --userarn="${userarn}" --username=github-action-role --groups=system:masters --kubeconfig="$HOME"/.kube/config --prompt=false

# Cleanup
echo "Cleaning up..."
rm aws-iam-authenticator aws-auth-configmap.yaml
echo "Done!"