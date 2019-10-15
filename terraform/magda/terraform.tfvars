# See variables.tf for more detailed description

project = "test-x-project-3"

region = "australia-southeast1-a"

namespace = "magda-trial"

# Replace with your key file location
credential_file_path = "/Users/xxxx/test-x-project-cluster.json"
# turn on kubernetes dashboard or not; By default: false
kubernetes_dashboard = true

aws_access_key = "xxxxxxx"

aws_secret_key = "xxxxx"

# 
external_domain_root = "testing.magda.io"

external_domain_zone = "magda.io"

cert_s3_bucket = "magda-files"

cert_s3_folder = "magda_trial_cert"

# Optional Default: 30
cert_min_days_remaining = 30

# Optional; default is staging endpoint
acme_server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"