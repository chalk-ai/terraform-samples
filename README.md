# Chalk Sample Terraform

## Layout

- `envs/` contains terraform that configures all resources in an account that runs Chalk
- `modules/` contains terraform modules that are used by the account level configuration

`envs/` is intended to be a fully apply-able terraform configuration that will spin up 
all of the cloud resources needed to run Chalk. If you are deploying Chalk into an *existing* 
AWS account, you may prefer to use it as inspiration, and cherry pick the resources you need
from `modules/`.


## Other documentation

- General documentation about Chalk can be found at [chalk-docs](https://docs.chalk.ai/)
- An architecture diagram can be found at [chalk-architecture](https://docs.chalk.ai/docs/architecture)
- Documentation about Chalk's AWS deployment can be [found here](https://docs.chalk.ai/docs/aws-cloud-deployment)
- Documentation about Chalk's GCP deployment can be [found here](https://docs.chalk.ai/docs/gcp) 