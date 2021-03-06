# Okta Advanced Server Access: Using the Terraform Provider on GCP (WIP)

The following is an example of using [Terraform](https://www.terraform.io/) to deploy GCP infrastructure with Okta Advanced Server Access managing identities on Linux compute engine instances through a local agent that is installed via a userdata script.

[Advanced Server Access](https://www.okta.com/products/advanced-server-access/) is an Okta application that automates identity & access across distributed Linux and Windows server fleets, extending a seamless Single Sign-On experience to SSH and RDP workflows.

This code example deploys a new VPC (default: europe-north1) with one subnet. In the subnet, a single Debian 9 compute engine instance is deployed as a bastion host, and N (default: 3) Debian 9 compute engine instances. In parallel, a new Okta ASA Project is created, and select Groups are assigned. The compute engine instances spun up are enrolled with the newly created Okta ASA Project, and the target instances are configured to hop through the bastion instance.

## Prerequisites

- An Okta Advanced Server Access Team
- A GCP service account 
- A Terraform Cloud account
- Terraform 0.13

## Terraform Providers

- [GCP Provider](https://github.com/hashicorp/terraform-provider-google)
- [Okta Advanced Server Access Provider](https://github.com/oktadeveloper/terraform-provider-oktaasa)

## Setup

### Create an Okta ASA Service User

In order to interact with the Okta ASA API, you'll need to create a Service User. Service Users are non-human accounts that are authenticated against the API. This example creates resources via API, so the Service User must belong to a Group that has Admin rights. Follow this [documentation article](https://help.okta.com/en/prod/Content/Topics/Adv_Server_Access/docs/service-users.htm) to create a Service User and an API key. You will need the API key and secret as input variables for Terraform.

### Create an service account in GCP

In order to create the VPC environment on GCP, you'll need an service account with full IAM rights to Compute Engine. Follow [this documentation article](https://cloud.google.com/iam/docs/creating-managing-service-accounts) to create a service account. You will need a key and secret for this account as input variables for Terraform.

## Input Variables

You'll need a number of input variables for this example to execute. Variables can be set as ENV variables locally, in a terraform.tfvars file, or via Terraform Cloud. The GCP and Okta credential input variables are sensitive, and should be stored in a secure location, and never published to a public repository.

### Okta Advanced Server Access

#### `oktaasa_key`, `oktaasa_secret`

The API key and secret for the Service User to interface with the Okta Advanced Server Access API

#### `oktaasa_team`

The name of your Okta Advanced Server Access Team (don't have one? [Sign up here](https://app.scaleft.com/p/signup).)

#### `oktaasa_project`

The name of the Project you would like to create. 

#### `oktaasa_groups`

A list of names of the Groups you would like to assign to the newly created Project. Note: these Groups must already exist in your Okta Advanced Server Access Team.

#### `sftd_version`

The version number of the Okta Advanced Server Access Server Agent (default: 1.44.6)

### Google Cloud Platform

#### `GOOGLE_CREDENTIALS`

An Environment Variable for the service account key and secret for the GCP SA to create the GCP environment. You must flatten the JSON (remove newlines) before pasting it into Terraform Cloud. Run `cat <key file>.json | jq -c`.

#### `name`

The Name tag value for the created resources (default: okta-asa)

#### `environment`

The Environment tag value for the created resources (default: okta-asa-env)

### Config

#### `instances`

The number of target compute engine instances to deploy in the private subnet (default: 3)

## Run the example

First, run the command `terraform init` to initialize the providers and modules used.

Then, run the command `terraform apply` and be sure to check Terraform's output for errors. Make sure your Terraform version is at least 0.13.

## Check the output

Give it a few minutes for the environment to spin up. The Okta Advanced Server Access Server Agent is installed via a userdata script included in this repository. When the service first starts up, it enrolls the instance with the newly created Project, and creates the respective local user and group accounts. The Server Agent then communicates with the backend API to get notified of any changes to user status or group membership.

You'll see in your Okta Advanced Server Access Dashboard that the new Project was created, and the Groups were assigned. Every member of the assigned Group is created a local Linux account on each downstream server. The compute engine instances are enrolled with the Project, which means that the users who belong to this Project can connect via SSH through the [Okta Advanced Server Access Client](https://help.okta.com/en/prod/Content/Topics/Adv_Server_Access/docs/sft.htm).

If you are logged into Okta and have the Client installed, from the CLI, you can see the newly created instances by running `sft list-servers`. Login to any one of the target hosts by running `sft ssh <target-instance>`. If your user account is authorized, you will be securely connected via SSH using a short-lived Client Certificate minted on-demand. You will be logged into the compute engine instance as your Okta user account, not a shared user account.








