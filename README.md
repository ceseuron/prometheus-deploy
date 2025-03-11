## Prometheus Deploy Exercise

### Summary
The purpose of this repository is to demonstrate an extremely simple deployment of Prometheus in a federated architecture using a combination of standard DevOps tools.

* Terraform is used for infrastructure orchestration.
* Ansible is used for Prometheus deployment and basic configuration.

**Warning:** This is simply a demonstration of a prototype deployment. It is *not* production ready and does not implement best practices for security, nor does it take into account specific organizational needs. Do not use this code as is for a production deployment or expect it to function in a production capacity. You *can* take this code and make the extensive modifications necessary to get it to a production state, but this is just a simple prototype demonstration. 

### General Requirements
This demonstration assumes that you meet the following requirements:

1. You have an AWS account.
2. You have an accessible S3 bucket in which to store Terraform state. Bonus points if it's a versioned bucket.
3. You are using IAM Identity Center for user logins (SSO). I did not implement this demonstration to function out of the box with AWS access keys or session tokens.
4. You have an IAM role that has sufficient access policies to store the Terraform state in your bucket, as well as being able to perform the necessary Terraform operations. See the below example JSON for my IAM role used.
5. You have both IAM Identity Center permission to assume the above described role, and the role itself has a trust relationship that allows it to be assumed by your user.
6. You have a secret in AWS Secrets Manager that contains an SSH key pair to use with your instances. I'll cover this later in this documentation.

IAM Role S3 Policy Example
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*Object"
            ],
            "Resource": "arn:aws:s3:::ceseuron-terraform/*"
        }
    ]
}
```
IAM Role Operation Policy Example
```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"ec2:*",
				"ssm:Get*",
				"secretsmanager:Describe*",
				"secretsmanager:Get*"
			],
			"Resource": [
				"*"
			]
		}
	]
}
```
**Warning**: The above policy is not intended for production use! It does not adhere to the philosophy of Least Permissions and should not be copied for use in a production capacity.

### AWS Secrets Manager for SSH Key Pair
This demonstration requires that you pre-create a suitable SSH keypair and insert them into an AWS Secrets Manager Secret, as follows:

1. Generate a suitable keypair on your local machine. We need both the public and the private key: `ssh-keygen -t ed25519`
2. Log into the AWS console.
3. Go to Secrets Manager.
4. Chose **Store a new secret**.
5. Choose **Other type of secret**
6. In the **Key** field, enter **public_key**. In the value column, paste the public key you created in Step 1.
7. In the **Key** field, enter **private_key**. In the value column, paste the private key you created in Step 1.
8. Click **Next**. 
9. Enter **aws-ec2-ssh-key** as the secret name. Give it any description and tags you want and save the secret.

### Terraform Requirements
To run the Terraform section of this demonstration, you will need to use a supported version. If you aren't already using it, I recommend `tfenv` to manage your local terraform installations, as you can install multiple versions and switch between them easily. This demonstration was created with the following Terraform version:
```
Terraform v1.11.1
on linux_amd64
```
You will need to make some changes to a few files if you plan on running this in your environment.

1. `variables.tf`: Change the `aws_account_id` and `aws_region` to reflect your account and target region.
2. `terraform.tf`: Change the backend S3 configuration to reflect your environment. Spefically `bucket` should be your S3 bucket name, `profile` should be the AWS profile you plan to use, and `region` should reflect the correct region. `role_arn` should point to the ARN of the deployment role Terraform will use and should have enough permissions to write to the `bucket`.
3. `provider.tf`: Change `region` and `profile` to match your target region and AWS profile respectively. `role_arn` should point to the ARN of the deployment role Terraform will use.

From the `terraform` folder, run `terraform init` followed by `terraform plan`. If all goes according to plan, then `terraform apply` to deploy the infrastructure.

### Ansible Requirements
To run the Ansible portion of this demonstration, you will need a supported version. Mine is as follows:
```
ansible [core 2.16.3]
  config file = /home/ceseuron/Repos/prometheus-deploy/ansible/ansible.cfg
  configured module search path = ['/home/ceseuron/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/ceseuron/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, Feb  4 2025, 14:48:35) [GCC 13.3.0] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True
```
In addition, ensure that the following OS environment variables are set:
1. `AWS_PROFILE`: The AWS profile being used.
2. `AWS_REGION`: The target AWS region that the EC2 containers are running in.

From the `ansible` folder:
1. Ensure that you have installed the required Galaxy collections: `ansible-galaxy install -r requirements.yml`
2. Run the playbook: `ansible-playbook -i inventory/aws_ec2.yml prometheus.yml`
