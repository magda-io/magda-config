# Magda Boilerplate

This is a simple boilerplate that allows you to quickly set up a Magda instance.

# Getting Started
Before you start you need a kubernetes cluster, kubectl and helm.

1. Fork this repository - this means you can make your own customisations, but still pull in updates.

2. `git clone` it to your local machine open a terminal in the directory

3. Look at config.yml and make sure to customise the uncommented lines. Everything else can be left as default for now.

4. Run the create secrets script in a command line and follow the prompts
```
    ./create-secrets/index-linux
    # OR
    ./create-secrets/index-macos
    # OR
    create-secrets\index.win.exe
```
Output should look something like so:
```
magda-create-secrets tool version: 0.0.47-0
? Are you creating k8s secrets for google cloud or local testing cluster? Local Testing Kubernetes Cluster
? Which local k8s cluster environment you are going to connect to? docker
? Do you need to access SMTP service for sending data request email? YES
? Please provide SMTP service username: abc
? Please provide SMTP service password: def
? Do you want to create google-client-secret for oAuth SSO? NO
? Do you want to create facebook-client-secret for oAuth SSO? NO
? Do you want to manually input the password used for databases? Generated password: up3Saeshusoequoo
? Specify a namespace or leave blank and override by env variable later? YES (Specify a namespace)
? What's the namespace you want to create secrets into (input `default` if you want to use the `default` namespace)? default
? Do you want to allow environment variables (see --help for full list) to override current settings at runtime? YES (Any environment variable can ove
ride my settings)
? Do you want to connect to kubernetes cluster to create secrets now? YES (Create Secrets in Cluster now)
Successfully created secret `smtp-secret` in namespace `default`.
Successfully created secret `db-passwords` in namespace `default`.
Successfully created secret `auth-secrets` in namespace `default`.
All required secrets have been successfully created!
```

5. Add the magda chart repo to helm
```
helm repo add magda-io https://charts.magda.io
```

6. Install magda
```
helm upgrade magda magda-io/magda --wait --timeout 30000 --install -f config.yaml
```

This will take a while for it to get everything set up. If you want to watch progress, run `kubectl get pods -w` in another terminal.

7. Once helm is finished, run `kubectl get services -w` and wait for `gateway` to receive an external IP. It'll look something like this:

```
gateway                           LoadBalancer   10.102.57.74     123.456.789.123     80:31519/TCP        1m
```

At this point you should be able to go to http://<external ip> in your browser and see the Magda UI. Note that the search won't work until it's finished indexing regions - to see the progress of this, run `kubectl logs -f -lservice=indexer`. Unless you've got a lot of processing power this will take quite a while - sorry! We're working on making it better.

By default, data.gov.au will be crawled on startup so you'll start with some data.