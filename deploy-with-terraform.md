# Deploy with Terraform

Deploy Magda to Google Cloud could be difficult as it's a lengthy process that involves many Google Cloud specific configurations that are not included by our Helm chart.

[Terraform](https://www.terraform.io/intro/index.html) is a deployment tool which support a wide range of cloud / service provider APIs rather than [Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/) APIs only like Helm.

Thanks to `Terraform`, we can codify the more complete deployment process and make it more automated. Moreover, it requires less tools to complete the deployment process as it uses its own plugins to talks to different APIs.


## Installing Prerequisites
- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html): Follow the link to install `Terraform`: https://learn.hashicorp.com/terraform/getting-started/install.html
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/downloads-interactive): Follow the link to install `Google Cloud SDK`: https://cloud.google.com/sdk/docs/downloads-interactive

Once `Google Cloud SDK` is installed, you also need to install gcloud beta components by the following command:

```bash
gcloud components install beta
```

## Create a Google Cloud Project 

Before you start the deployment process, you need to create a [google cloud project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) via [Google Cloud Console](https://console.cloud.google.com/) and note down the `Project Id`.


### Deploy Magda with Terraform

To deploy the Magda, just follow the steps below:

#### 1. Set Default Project

```bash
gcloud config set project [project id]
```

Here, you need to replace the `[project id]` with the actual project id that you've noted down previously.

#### 2. Enable required services & APIs for your project


```bash
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```

#### 3. Create service account for the deployment

```bash
gcloud iam service-accounts create [my service account name]
```

Here, you need to replace the `[my service account name]` with your intended meaningful account name.

#### 4. Find out service account email:

You need to find out the service account email of your newly created service account to be used as the identifier in other commands.

To do so, you can firstly, list all service accounts:

```bash
gcloud iam service-accounts list
```

Find the row of your service account. The service account email should be something similar to:
`xxx-xxx-xxxx@xxxx-xxx-xxxx.iam.gserviceaccount.com`

#### 5. Create an access key for your service account:

```bash
gcloud iam service-accounts keys create key.json --iam-account=[service account email]
```

Here, key.json is the service account key file name that you want to save locally.

Before run this command, you need to replace `[service account email]` with the actual service account email that you've found out in previous step.

#### 6. Grant service account permission:

Grant `editor` role to your service account:

```bash
gcloud projects add-iam-policy-binding [project-id] --member serviceAccount:[service account email] --role roles/editor
```

Grant `k8s admin` role to your service account:
```bash
gcloud projects add-iam-policy-binding [project-id] --member serviceAccount:[service account email] --role roles/container.admin
```

Here, you need to replace `[project-id]` with the actualproject id and replace the `[service account email]` with the actual service account email that you've found out in previous steps.

#### 7. Clone this repo & Initiate Terraform

You need to Clone this repo to you local folder, enter the [terraform](./terraform) directory of the cloned local repo and run:

```bash
terraform init
```

#### 8. Edit terraform config

Edit [terraform/magda/terraform.tfvars](./terraform/magda/terraform.tfvars) and supply the follow parameters:
- `Project id`: the id of the google cloud project that you created
- `Deploy Region`: which region you want to deploy magda to
- `credential_file_path`: the path of service account key file that we just generated
- `namespace`: which namespace you want to deploy Magda to
- `external_domain`: If it's not set, HTTPS access will not be setup. You can access your instance through a temporary domain generated. 

Other optional settings and their default values (if not set) are:
- `cluster_node_pool_machine_type`: The machine type to use, see https://cloud.google.com/sql/pricing for more details. Default: `n1-standard-4`
- `kubernetes_dashboard`: Whether turn on [kubernetes_dashboard](https://github.com/kubernetes/dashboard) or not; Default: `false`

You can find full list of configurable options from [here](./terraform/magda/variables.tf).

#### 9. Edit default helm config

Edit [config.yaml](./config.yaml). You can find more information of the config options from the comments in that file.

You also can use the content of [config.yaml.sample](./config.yaml.sample) if you want to have a quick test without going through every options.


#### 10. eploy using terraform

```bash
terraform apply -auto-approve
```

Once the deployment is complete, you should be able to find the access URL from `external_access_url` variable of the output on the screen.

You should also note down the `external_ip` variable from the output if you want to access through your own domain.


### Use Your Own Domain

If you want to use your own domain, you need to create an DNS `A` record in your DNS registrar's system. The `A` record needs to point to the `external_ip` that generated when deploy Magda.

#### SSL / HTTPS Access

As long as you specified `external_domain` in config file [terraform/magda/terraform.tfvars](./terraform/magda/terraform.tfvars), the SSL certificate will be automatically generated and set up for you. The process is going to take 30 to 60 minutes as [specified by Google](https://cloud.google.com/load-balancing/docs/ssl-certificates):
> With a correct configuration the total time for provisioning certificates is likely to take from 30 to 60 minutes.

##### Upgrade Your Site for SSL / HTTPS Access

If you didn't supply a value for `external_domain` config field during your ininitial deployment, you can edit the config file and update your deployment by re-run:

```bash
terraform apply -auto-approve
```