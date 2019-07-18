# **DESCRIPTION**

Automate bringing up of kubernetes cluster on ec2 and provide a way to deploy an Elasticsearch cluster and a mongodb cluster

## Prerequisites
**Install aws, kubectl and kops.
We will need AWS CLI to access AWS via CLI and have preconfigured he SecretAccessKey and the AccessKeyId.**

# **How it works**
You will see bellow in the "HOW TO USE IT" section how to use this repository. This is just an explanation of what it does.

This is a deployment using Kubernetes aka k8s. This repository is going to setup a Kubernetes cluster and deploy an Elasticsearch and a MongoDB clusters on it in AWS with everything prompted in the terminal.

In order to build clusters within AWS a dedicated IAM user will be created for kops. This user requires API credentials in order to use kops.
These are going to be the permissions:
* AmazonEC2FullAccess
* AmazonRoute53FullAccess
* AmazonS3FullAccess
* IAMFullAccess
* AmazonVPCFullAccess

A S3 versioned bucket will be created in order to store the state of the k8s cluster.

The cluster is going to be created with kops commands, such as create, update and once it has finished it's going to be validated for you to see the outcome.

App deployments in K8S are declarative and configured via JSON/YAML files. Both of our clusters are going to be deployed using StatefulSet.
A StatefulSet manages Pods that are based on an identical container spec. A StateFulSet maintains a sticky identity for each of their Pods.
A StatefulSet operates under the same pattern as any other Controller. You define your desired state in a StatefulSet object, and the StatefulSet controller makes any necessary updates to get there from the current state.

The YAML files provisioned for this to work can be modified if required. They are templates of images that are going to provision information such as API version of kubernetes in which StatefulSet is available, type of resource that we are creating, name of the resource, Name of the init-container and so on.

**Services:** A Kubernetes service is an abstraction which defines a logical set of pods and a policy to access them. This helps a containerized app to identify another containerized app or its own instance in another pod.

With all of that being written the deployment is going to be done with the command of kubectl "create" specifying each of the YAML files.
The create command is a generic command used for creating any resource within K8S.


# HOW TO USE IT
Clone this repository and locate yourself in the folder named K8S.
Use the following command to make the SH file executable:

**chmod +x script.sh**

To run the script just use this command:

**./script.sh**

What the script does is just to pass variables within the file that are going to be prompted to you and execute commands in order to deploy the clusters using Kubernetes.

## HOW TO TEST IT
If you run the following commands you'll see listed elastic and mongo which correspond to each deployment

**kubectl get namespaces**

**kubectl get pods --all-namespaces**

You can check the health of the ElasticSearch nodes by going to the url that is going to be provisioned at the end of the process in the terminal.

You can view the components by running the follwing commands:

**kubectl -n elastic get all'**

**kubectl -n mongo get all**

As you can see, that the service for mongo has no Cluster-IP and neither an External-IP, it is a headless service. This service will directly resolve to Pod-IPs for our Stateful Sets.

In order to verify the DNS resolution for the MongoDB cluster use:

**kubectl run my-shell --rm -i --tty --image ubuntu -- bash**

Once inside do a sudo apt update and a sudo apt install dnsutils and run the following command:

**DiG 9.11.3-1ubuntu1.1-Ubuntu <<>> mongo.mongo +search +noall +answer**

You'll get the dns for service and the stateful sets pod ips This can be tested by running a nslookup over these, from inside the cluster.

**nslookup {$THE_IP_PROVISIONED_BY_THE_DIG_COMMAND}**

### **_Now you can access the nodes._**
