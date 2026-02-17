# docker-github-runner
Docker configuration for GitHub Actions self-hosted runner

## Prerequisites

- Docker and Docker Compose installed
- GitHub Personal Access Token with `repo` scope
- A GitHub repository where you want to add the runner

## Quick Start

### Local Development with Docker Compose

1. Create a `.env` file with your values:
   ```bash
   GITHUB_TOKEN=your_github_token
   GITHUB_REPOSITORY=owner/repo
   RUNNER_NAME=my-runner  # Optional
   RUNNER_LABELS=docker,linux  # Optional
   ```

2. Build and run:
   ```bash
   docker-compose up -d
   ```

3. Check the logs:
   ```bash
   docker-compose logs -f
   ```

### Azure Container Instances Deployment

1. Build and push the image to a container registry:
   ```bash
   docker build -t your-registry.azurecr.io/github-runner:latest .
   docker push your-registry.azurecr.io/github-runner:latest
   ```

2. Deploy to Azure Container Instances with environment variables:
   ```bash
   az container create \
     --resource-group your-rg \
     --name github-runner \
     --image your-registry.azurecr.io/github-runner:latest \
     --environment-variables \
       GITHUB_TOKEN=your_token \
       GITHUB_REPOSITORY=owner/repo \
       RUNNER_NAME=azure-runner \
       RUNNER_LABELS=azure,docker \
     --cpu 1 --memory 2
   ```

   Or using secure environment variables:
   ```bash
   az container create \
     --resource-group your-rg \
     --name github-runner \
     --image your-registry.azurecr.io/github-runner:latest \
     --secure-environment-variables \
       GITHUB_TOKEN=your_token \
     --environment-variables \
       GITHUB_REPOSITORY=owner/repo \
       RUNNER_NAME=azure-runner \
       RUNNER_LABELS=azure,docker \
     --cpu 1 --memory 2
   ```

## Manual Docker Build

Build the image:
```bash
docker build -t github-runner .
```

Run the container:
```bash
docker run -d \
  -e GITHUB_TOKEN=your_token \
  -e GITHUB_REPOSITORY=owner/repo \
  -e RUNNER_NAME=my-runner \
  -e RUNNER_LABELS=docker,linux \
  github-runner
```

## Configuration

### Environment Variables

- `GITHUB_TOKEN` (required): GitHub Personal Access Token with repo scope
- `GITHUB_REPOSITORY` (required): Repository in format `owner/repo`
- `RUNNER_NAME` (optional): Custom runner name (default: `docker-runner-<hostname>`)
- `RUNNER_LABELS` (optional): Comma-separated labels (default: `docker`)

### Docker-in-Docker

If your workflows need to run Docker commands, the docker-compose.yml mounts the Docker socket. Alternatively, you can run Docker-in-Docker by modifying the Dockerfile.

## Stopping the Runner

```bash
docker-compose down
```

The runner will be automatically removed from GitHub when the container stops.

## Security Notes

- Never commit your `.env` file with real credentials
- Use GitHub Personal Access Tokens with minimal required scopes
- Consider using GitHub Apps for better security in production
- Regularly update the runner version in the Dockerfile
