# Magda Config

This is a simple boilerplate that allows you to quickly set up a Magda instance - the idea is that you can fork this config, commit changes but keep merging in master in order to stay up to date.

## Quickstart Instructions

For new users setting up Magda for the first time we recommend using these instructions - these use [Terraform](https://www.terraform.io/intro/index.html) to set you up with a instance running on Google Cloud Engine very quickly (about 5 minutes of entering commands / editing config and 20 minutes of waiting), and gives you a basic instance, and in another 30-60 minutes of waiting will get you HTTPS working on your own domain.

If you want to run it locally in something like Minikube, or want to be a bit more direct, the old quickstart is still available at [legacy.md](./legacy.md).

### 1. Clone this repo

```bash
git clone https://github.com/magda-io/magda-config.git
```

or download it with the "Clone or download" button in Github.

### 2. Install Terraform

Go to [https://learn.hashicorp.com/terraform/getting-started/install.html](https://learn.hashicorp.com/terraform/getting-started/install.html) for instructions

### 3. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/downloads-interactive)

Go to [https://cloud.google.com/sdk/docs/downloads-interactive](https://cloud.google.com/sdk/docs/downloads-interactive) for instructions.

Once `Google Cloud SDK` is installed, you also need to install gcloud beta components by the following command:

```bash
gcloud components install beta
```

### 4. Create a Google Cloud Project

Before you start the deployment process, you need to create a [google cloud project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) via [Google Cloud Console](https://console.cloud.google.com/) and note down the `Project Id`. Note that this isn't necessarily exactly the same as the id you specified - if it's already been taken, Google will append some numbers to it. Make sure by checking the "Select a Project" dialog in Google Cloud:

![Google Cloud Select a Project Dialog](./gcp-projects.png)

### 5. Set Default Project

Set the project id you noted down to an environment variable, because you'll need it in a few places - this will work in bash. If you're using another shell use the equivalent command or just manually replace `$PROJECT_ID` with your project id.

```bash
export PROJECT_ID=[your-project-id]
```

Then set it as the default in Google Cloud

```bash
gcloud config set project $PROJECT_ID
```

#### 6. Enable required services & APIs for your project

```bash
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```

#### 7. Create service account for the deployment

```bash
gcloud iam service-accounts create magda-robot
```

Feel free to use a name other than `magda-robot` if you like.

#### 8. Find out service account email

You need to find out the service account email of your newly created service account to be used as the identifier in other commands.

To do so, first list all service accounts:

```bash
gcloud iam service-accounts list
```

Find the row of your service account. The service account email should be something similar to `magda-robot@[your-project-id].iam.gserviceaccount.com`. You'll need this a few times, so it's worth saving it to an environment variable - once again, if you're not using a shell that supports this you can just manually replace $SERVICE_ACCOUNT_EMAIL with the email address itself.

```bash
export SERVICE_ACCOUNT_EMAIL=[your-service-account-email]
```

#### 9. Create an access key for your service account

First go to the `terraform/magda` directory inside your cloned version of this repository.

```bash
cd terraform/magda
```

```bash
gcloud iam service-accounts keys create key.json --iam-account=$SERVICE_ACCOUNT_EMAIL
```

You will now have a `key.json` file in `terraform/magda`, containing a private key. We suggest you put this somewhere safe like a password manager.
DO NOT CHECK IT INTO SOURCE CONTROL.

#### 10. Grant service account permission

Grant `editor` role to your service account:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_EMAIL --role roles/editor
```

Grant `k8s admin` role to your service account:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_EMAIL --role roles/container.admin
```

#### 11. Initiate Terraform

To do so, run:

```bash
terraform init
```

After a bit of waiting you should get this message:

```console
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

#### 12. Edit terraform config

Edit `terraform/magda/terraform.tfvars` and supply the follow parameters:

- `Project id`: the id of the google cloud project that you created (`echo $PROJECT_ID`)
- `Deploy Region`: which region you want to deploy magda to
- `credential_file_path`: the path of the service account key file (`key.json`) that we just generated
- `namespace`: which kubernetes namespace you want to deploy Magda to (generally this should just be "default")
- `external_domain`: Optional: what domain you want the Magda server to be accessed from (which requires a bit of extra configuration). Leave blank to just access your instance through a temporary domain. You can set this later if necessary.

Other optional settings and their default values (if not set) are:

- `cluster_node_pool_machine_type`: The machine type to use, see [https://cloud.google.com/compute/vm-instance-pricing](https://cloud.google.com/compute/vm-instance-pricing) for more details. Default: `n1-standard-4`
- `kubernetes_dashboard`: Whether turn on [kubernetes_dashboard](https://github.com/kubernetes/dashboard) or not; Default: `false`

You can find full list of configurable options from [here](./terraform/magda/variables.tf).

#### 13. Edit default helm config

Look at [config.yaml](./config.yaml). It has reasonable defaults but you might want to edit something - it will give you a new instance with a standard colour scheme/logos and no datasets (yet).

#### 14. Deploy!

```bash
terraform apply -auto-approve
```

This will take quite a while (like 20 minutes), but it should update you about its progress. Take this opportunity to make a cup of tea or stretch!

Once the deployment is complete, you should get a bunch of output including something like this:

```console
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

external_access_url = http://34.98.120.7.xip.io/
external_ip = 34.98.120.7
```

You should be able to go to `http://[external_ip]` right away and see your Magda homepage come up. If you didn't specify `external_domain`, then the `external_access_url` will also work, otherwise see below:

##### Use Your Own Domain

If you specified `external_domain`, you need to create a DNS `A` record in your DNS registrar's system. The `A` record needs to point to the `external_ip` that was generated when deploying Magda.

##### SSL / HTTPS Access

As long as you specified `external_domain` in config file `terraform/magda/terraform.tfvars` and you've set an `A` record from that domain to the value that came back from `external_ip`, the SSL certificate will be automatically generated and set up for you. The process is going to take 30 to 60 minutes as [specified by Google](https://cloud.google.com/load-balancing/docs/ssl-certificates):
> With a correct configuration the total time for provisioning certificates is likely to take from 30 to 60 minutes.

##### Upgrade Your Site for SSL / HTTPS Access

If you didn't supply a value for `external_domain` config field during your initial deployment, you can edit the config file and update your deployment by re-running:

```bash
terraform apply -auto-approve
```

#### 11. What now?

Start playing around!

- If you want to get some datasets into your system, turn the `connectors` tag to `true` in [config.yaml](./config.yaml) and re-run `terraform apply -auto-approve`. A connector job will be created and start pulling datasets from `data.gov.au`... or you can modify `connectors:` in [config.yaml](./config.yaml) to pull in datasets from somewhere else.
- In the Google Cloud console, go to Kubernetes Engine / Clusters and click the "Connect" button, then use the `kubectl` command (should be installed along with the Google Cloud command line) to look at your new Magda cluster.

![Google Kubernetes Engine Connect Button](./gke-clusters.png)

Use `kubectl get pods` to see all of the running containers and `kubectl logs -f <container name>` to tail the logs of one. You can also use `kubectl port-forward combined-db-0 5432` to open a tunnel to the database, and use psql, PgAdmin or equivalent to investigate the database - you can find the password in terraform.tfstate.

- Sign up for an API key on Facebook or Google, and put it in terraform.tfvars in order to enable sign in.
- Configure an SMTP server in terraform.tfvars and switch the `correspondence` flag to true in order to be able to send emails from the app.
- Set `scssVars` in [config.yaml](./config.yaml) to change the colours
- Ask us questions on gitter.im/magda-data
- Send us an email at contact@magda.io to tell us about your new Magda server.
