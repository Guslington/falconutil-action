# CrowdStrike Falcon Utility GitHub Action

This GitHub Action allows you to use CrowdStrike's Falcon Utility to patch container images with the Falcon Container Sensor directly in your CI/CD pipeline.

## Features

- Patch application container images with Falcon Container Sensor
- Deploy container workloads with runtime security protection
- Customize patching parameters for various cloud platforms (ACA, ACI, ECS_FARGATE, CLOUDRUN)
- Support for various container deployment scenarios

## Prerequisites

### Create a CrowdStrike API Client

> [!NOTE]
> API clients are granted one or more API scopes. Scopes allow access to specific CrowdStrike APIs and describe the actions that an API client can perform. To create an API client, see [API Clients and Keys](https://falcon.crowdstrike.com/login/?unilogin=true&next=/api-clients-and-keys).

Ensure the following API scopes are assigned to the client:

- **Sensor Download**[read]
- **Falcon Images Download**[read]

### Create a GitHub Secret

This action relies on the environment variable `FALCON_CLIENT_SECRET` to authenticate with the CrowdStrike API.

Create a GitHub secret in your repository to store the CrowdStrike API Client secret created from the step above. For more information, see [Creating secrets for a repository](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository).

## Usage

To use this action in your workflow, add the following step:

```yaml
- name: Patch Container Image with Falcon Sensor
  uses: crowdstrike/falconutil-action@v1.0.0
  with:
    falcon_client_id: 'abcdefghijk123456789'
    falcon_region: 'us-2'
    source_image_uri: 'myregistry/myapp:latest'
    target_image_uri: 'myregistry/myapp:falcon'
    cid: '1234567890ABCDEFG'
  env:
    FALCON_CLIENT_SECRET: ${{ secrets.FALCON_CLIENT_SECRET }}
```

## Environment Variables

| Variable | Description | Required | Default | Example/Allowed Values |
|----------|-------------|----------|---------|---------|
| `FALCON_CLIENT_SECRET` | CrowdStrike API Client Secret for authentication | **Yes** | - | `${{ secrets.FALCON_CLIENT_SECRET }}` |

## Inputs

| Input | Description | Required | Default | Example/Allowed Values |
|-------|-------------|----------|---------|---------|
| `falcon_client_id` | CrowdStrike API Client ID for authentication | **Yes** | - | `abcdefghijk123456789` |
| `falcon_region` | CrowdStrike API region | **Yes** | `us-1` | Allowed values: `us-1, us-2, eu-1, us-gov-1, us-gov-2` |
| `version` | Falcon Container Sensor version to pull (*defaults to the latest*) | No | - | `7.20.0-5908` |
| `source_image_uri` | Source Image URI to be patched | **Yes** | - | `myregistry/myapp:latest` |
| `target_image_uri` | Expected URI for patched Target Image | **Yes** | - | `myregistry/myapp:falcon` |
| `cid` | Customer ID w/checksum to use | **Yes** | - | `1234567890ABCDEFG-XY` |
| `falcon_image_uri` | Falcon Container Sensor Image URI (*defaults to using the image pulled by the action*) | No | - | `my-falcon-sensor-image:latest` |
| `cloud_service` | Cloud Service platform the container will be deployed on | No | - | Allowed values: `ACA, ACI, ECS_FARGATE, CLOUDRUN` |
| `container` | Container name that can be used to identify the container on the Falcon console | No | - | `my-container` |
| `container_group` | Azure container group name | No | - | `my-container-group` |
| `falconctl_opts` | All falconctl options in a single string | No | - | `--tags=test --filter=include` |
| `image_pull_policy` | PullPolicy for Source and Falcon Container Sensor Image | No | `Always` | Allowed values: `IfNotPresent, Always` |
| `resource_group` | Azure resource group name | No | - | `my-resource-group` |
| `subscription` | Azure subscription id | No | - | `subscription-id` |

## Examples

### Basic container image patching

```yaml
- name: Patch Container Image
  uses: crowdstrike/falconutil-action@v1.0.0
  with:
    falcon_client_id: ${{ vars.FALCON_CLIENT_ID }}
    falcon_region: 'eu-1'
    source_image_uri: 'myregistry/myapp:latest'
    target_image_uri: 'myregistry/myapp:patched'
    cid: ${{ secrets.FALCON_CID }}
  env:
    FALCON_CLIENT_SECRET: ${{ secrets.FALCON_CLIENT_SECRET }}
```

### Azure Container Instance deployment

```yaml
- name: Patch Container Image for ACI
  uses: crowdstrike/falconutil-action@v1.0.0
  with:
    falcon_client_id: ${{ vars.FALCON_CLIENT_ID }}
    falcon_region: 'us-1'
    source_image_uri: 'myregistry/myapp:latest'
    target_image_uri: 'myregistry/myapp:patched'
    cid: ${{ secrets.FALCON_CID }}
    cloud_service: 'ACI'
    container_group: 'my-container-group'
    resource_group: 'my-resource-group'
    subscription: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  env:
    FALCON_CLIENT_SECRET: ${{ secrets.FALCON_CLIENT_SECRET }}
```

### AWS ECS Fargate deployment

```yaml
- name: Patch Container Image for ECS Fargate
  uses: crowdstrike/falconutil-action@v1.0.0
  with:
    falcon_client_id: ${{ vars.FALCON_CLIENT_ID }}
    falcon_region: 'us-2'
    source_image_uri: '123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:latest'
    target_image_uri: '123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:patched'
    cid: ${{ secrets.FALCON_CID }}
    cloud_service: 'ECS_FARGATE'
    image_pull_policy: 'IfNotPresent'
  env:
    FALCON_CLIENT_SECRET: ${{ secrets.FALCON_CLIENT_SECRET }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Support

This project is a community-driven, open source project designed to provide a simple way to run CrowdStrike's Falcon Utility in a GitHub Action.
While not a formal CrowdStrike product, this project is maintained by CrowdStrike and supported in partnership with the open source developer community.

For additional support, please see the [SUPPORT](SUPPORT.md) file.

## License

See [LICENSE](LICENSE)
