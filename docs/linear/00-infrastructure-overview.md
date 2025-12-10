# Sonik Infrastructure Overview

## Purpose

This project contains all infrastructure documentation for Sonik's backend services. It serves as a bridge to Forge and the source of truth for:

- AWS access and commands
- Credential locations
- Service configurations
- Database connections

## Document Index

| # | Document | Description |
|---|----------|-------------|
| 01 | [AWS Access](./01-aws-access.md) | SSH access, common commands, GitHub repo |
| 02 | [Credential Locations](./02-credential-locations.md) | Where all secrets are stored |
| 03 | [Cognee Stack Services](./03-cognee-stack-services.md) | All services, ports, health checks |
| 04 | [Supabase](./04-supabase.md) | Database connections, pooler vs direct |

## Quick Reference

### SSH into AWS
```bash
ssh -i /Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem ubuntu@18.191.215.116
```

### Service URLs
| Service | URL |
|---------|-----|
| Cognee API | http://18.191.215.116:8000/docs |
| NocoDB | http://18.191.215.116:8080 |
| Grist | http://18.191.215.116:8484 |
| RedisInsight | http://18.191.215.116:8001 |

### Credential Location
```
AWS Server: ~/sonik-infra/docker/.env
```

## Related Resources

- **GitHub:** https://github.com/SonikFM/sonik-infra
- **Supabase:** https://supabase.com/dashboard/project/jjdofmqlgsfgmdvnuakv
- **Schema Updates:** `docs/SCHEMA-UPDATES-UNFINISHED-12-10.MD`

## Deployment Date

- **Initial Deployment:** 2025-12-10
- **Last Updated:** 2025-12-10
