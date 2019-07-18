#!/bin/bash
echo "You are going to be prompted for some information in order to accomplish the following deployment. Please do not stop it because some steps take some time to finish, and add the information as required."
echo "Please enter a User for IAM, this will be fully dedicated to kops"
read uiam
aws iam create-group --group-name $uiam
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $uiam
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $uiam
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $uiam
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $uiam
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $uiam
aws iam create-user --user-name $uiam
aws iam add-user-to-group --user-name $uiam --group-name $uiam
aws iam create-access-key --user-name $uiam

echo "Please enter the name of the bucket for kops storage. Be very imaginative with the name of it, since S3 buckets are unique ;)"
read s3bucket
echo $s3bucket
echo "Creating s3 bucket with versioning for the kops state..."
aws s3api create-bucket --bucket $s3bucket --region us-east-1
aws s3api put-bucket-versioning --bucket $s3bucket --versioning-configuration Status=Enabled

sleep 8s

echo "Please enter a cluster name."
read clustername
clusterk8s="$clustername.k8s.local"
echo "Creating cluster..."
kops create cluster --node-count=2 --node-size=t2.xlarge --zones=us-east-1a --name $clusterk8s --state s3://$s3bucket

sleep 8m

kops update cluster --name $clusterk8s --state s3://$s3bucket --yes

sleep 8m

kops validate cluster

echo "Deploying Elasticsearch Cluster"
kubectl create -f es-k8s/elastic.yaml

echo "Deploying Mongodb CLuster"
kubectl apply -f mongodb/mongodb.yaml


echo "Please verify ES health with the following url in your browser"
elasticurl=$(kubectl describe service elasticsearch -n elastic | grep Ingress | awk '{print $3}')
echo "$elasticurl:9200/_cluster/health?pretty"

echo "In order to verify the MongoDB cluster please follow the instructions in the README.MD file in the HOW TO TEST IT"

echo "The process has finished."
