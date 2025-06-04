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

Create a file named `env.json` with the following structure: ([env.example.json](./env.example.json))

```json
{
  "TOKEN": "your_cloudflare_api_token",
  "ZONE": "example.com",
  "RECORD": "sub.example.com"
}
```

### Run the powershell

```powershell
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
record
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


### Kubernetes
If youd like to run the script on Kubernetes:
  - either remove the do while true loop from bash script and run it as cron-job
  - or define deployment & a secret like this:

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-ip-updater-env
  namespace: kube-system
data:
  TOKEN: yourtokenBase64encoded==
  ZONE: yourzoneBase64encoded==
  RECORD: yourrecordBase64encoded==

```


```yaml
# deploymen.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudflare-ip-updater
  namespace: kube-system
  labels:
    app: cloudflare-ip-updater
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudflare-ip-updater
  template:
    metadata:
      labels:
        app: cloudflare-ip-updater
    spec:
      containers:
      - name: updater
        image: ghcr.io/fabiotavernini/cloudflare-ip-updater:latest
        imagePullPolicy: Always
        env:
        - name: TOKEN
          valueFrom:
            secretKeyRef:
              name: cloudflare-ip-updater-env
              key: TOKEN
        - name: ZONE
          valueFrom:
            secretKeyRef:
              name: cloudflare-ip-updater-env
              key: ZONE
        - name: RECORD
          valueFrom:
            secretKeyRef:
              name: cloudflare-ip-updater-env
              key: RECORD
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"

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
- On Kubernetes, triple check env vars in secret (watch out for \n newline characters in encoded string)

---

If you want help with docker-compose, logging improvements, or healthchecks, just ask!
