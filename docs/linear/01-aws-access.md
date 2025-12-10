# AWS Access - Sonik Infrastructure

## Instance Details

| Property | Value |
|----------|-------|
| **IP Address** | 18.191.215.116 |
| **User** | ubuntu |
| **Region** | us-east-2 (Ohio) |

## SSH Access

**Key Location:**
```
/Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem
```

**SSH Command:**
```bash
ssh -i /Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem ubuntu@18.191.215.116
```

## Common Commands

**View running containers:**
```bash
sudo docker ps
```

**View logs for a service:**
```bash
sudo docker logs sonik-cognee
sudo docker logs sonik-nocodb
sudo docker logs sonik-falkordb
```

**Restart all services:**
```bash
cd ~/sonik-infra/docker
sudo docker compose -f docker-compose.cognee-stack.yaml restart
```

**Full redeploy:**
```bash
cd ~/sonik-infra/docker
sudo docker compose -f docker-compose.cognee-stack.yaml down
sudo docker compose -f docker-compose.cognee-stack.yaml up -d
```

**Pull latest and redeploy:**
```bash
cd ~/sonik-infra && git pull
cd docker && sudo docker compose -f docker-compose.cognee-stack.yaml up -d --force-recreate
```

## GitHub Repository

- **Repo:** https://github.com/SonikFM/sonik-infra
- **Branch:** main
- **Local Path:** `/Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-infra`
