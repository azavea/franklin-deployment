# franklin-deployment

* [AWS Credentials](#aws-credentials)
* [Terraform](#terraform)
* [Migrations](#migrations)

## AWS Credentials

Using the AWS CLI, create an AWS profile named `raster-foundry`:

```bash
$ aws configure --profile raster-foundry
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-1
Default output format [None]:
```

You will be prompted to enter your AWS credentials, along with a default region. These credentials will be used to authenticate calls to the AWS API when using Terraform and the AWS CLI.

## Terraform

To deploy the API, use the `infra` wrapper script to lookup the remote state of the infrastructure and assemble a plan for work to be done. Be sure to include `GIT_COMMIT` with the first 7 characters of a Git SHA. This value should correspond to a container image tag published to [Quay.io](https://quay.io/azavea/franklin).

```
$ docker-compose run --rm terraform
bash-5.0# GIT_COMMIT="..." ./scripts/infra plan
```

Once the plan has been assembled, and you agree with the changes, apply it:

```
bash-5.0# GIT_COMMIT="..." ./scripts/infra apply
```

This will attempt to apply the plan assembled in the previous step using Amazon's APIs. In order to change specific attributes of the infrastructure, inspect the contents of the environment's configuration file in Amazon S3.

## Migrations

- Select the most recent task definition for [FranklinAPIMigrations](https://console.aws.amazon.com/ecs/home?region=us-east-1#/taskDefinitions/FranklinAPIMigrations/status/ACTIVE)
- Select **Actions** -> **Run Task**
- Below the warning, click the blue link: "Switch to launch type"
- Select the following
  - **Launch type**: `EC2`
  - **Cluster**: `ecsProductionCluster`
- Click **Run Task**
- Monitor the [log output](https://papertrailapp.com/groups/4082183/events?q=franklin-api-migrations) for the newly created task
