# Cloudflare Dynamic DNS Updater

This project provides two scripts to automatically update a DNS A record on Cloudflare with your current public IP address.

- **PowerShell version (`run.ps1`)** for running on Windows or PowerShell environments
- **Bash version (`run.sh`)** designed for Linux environments and Docker

---

## Features

- Automatically detects your public IP via https://api.ipify.org  
- Checks if the Cloudflare DNS record IP matches current public IP  
- Updates the DNS record only if IP has changed  
- Supports Cloudflare API authentication with Bearer token  
- Designed for easy containerization with the Bash version  

---

## Prerequisites

- Cloudflare API Token with `Zone.DNS` permissions  
- DNS zone and record you want to update on Cloudflare  

---

## 1. PowerShell Version (`run.ps1`)

### Requirements

- PowerShell 7+  
- Windows, Linux, or macOS PowerShell environment  

### Setup

Create a file named `env.json` with the following structure:

```json
{
  "TOKEN": "your_cloudflare_api_token",
  "Zone": "example.com",
  "record": "sub.example.com"
}
```

### Run

```sh
.\run.ps1
```

The script will run continuously, checking every 5 minutes and updating your DNS record if needed.

---

## 2. Bash Version (`run.sh`) for Docker or Linux

### Requirements

- `bash`, `curl`, `jq` installed (the Docker image includes these)  
- Alpine Linux based Docker image recommended  

### Usage with Docker

Build the Docker image:

```sh
docker build -t cf-ip-updater .
```

Run the container passing environment variables:

```sh
docker run --rm \
  -e TOKEN=your_cloudflare_api_token \
  -e ZONE=example.com \
  -e RECORD=sub.example.com \
  cf-ip-updater
```

### Usage on Linux (without Docker)

Make sure `bash`, `curl`, and `jq` are installed. Export your variables:

```sh
export TOKEN=your_cloudflare_api_token
export ZONE=example.com
export RECORD=sub.example.com
```

Run the script:

```sh
bash run.sh
```

---

## Notes

- The Bash version reads config from environment variables; the PowerShell version reads from `env.json`.  
- The Bash version loops indefinitely with a 5-minute delay.  
- Logs success or failure of updates, including Cloudflare API responses on failure.  
- Customize the polling interval by editing the `sleep` command in the scripts.  

---

## Troubleshooting

- Make sure your API token has the correct permissions.  
- Verify your zone and record names are correct.  
- Check your network allows outbound HTTPS connections to Cloudflare API.  
- On Docker, ensure you pass env vars correctly using `-e` or `--env-file`.

---

If you want help with docker-compose, logging improvements, or healthchecks, just ask!
