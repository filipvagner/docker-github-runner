# docker-github-runner
Docker configuration for GitHub Actions self-hosted runner

## Prerequisites

- Docker and Docker Compose installed
- GitHub Personal Access Token with `repo` scope
- A GitHub repository where you want to add the runner

## Quick Start

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set your values:
   - `GITHUB_TOKEN`: Your GitHub Personal Access Token
   - `GITHUB_REPOSITORY`: Your repository in `owner/repo` format
   - `RUNNER_NAME`: (Optional) Custom name for your runner
   - `RUNNER_LABELS`: (Optional) Custom labels for your runner

3. Build and run with Docker Compose:
   ```bash
   docker-compose up -d
   ```

4. Check the logs:
   ```bash
   docker-compose logs -f
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
