# Cognee Stack Services - Sonik Infrastructure

## Architecture Overview

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                    COGNEE (Orchestrator)                    │
                    │         Knowledge Graph + AI Memory + Semantic Search       │
                    │                      Port: 8000                             │
                    └─────────────────┬──────────────────┬──────────────────┬─────┘
                                      │                  │                  │
                             ┌────────▼───────┐ ┌────────▼───────┐ ┌───────▼────────┐
                             │   PostgreSQL   │ │   FalkorDB     │ │    LanceDB     │
                             │   (External)   │ │ (on Redis 7.4) │ │   (Embedded)   │
                             │ Supabase Cloud │ │   Port: 6379   │ │   Local Files  │
                             └────────────────┘ └────────────────┘ └────────────────┘

                                                ┌────────────────┐
                                                │    RedisVL     │
                                                │ Semantic Cache │
                                                │   Port: 6380   │
                                                └────────────────┘

                        ┌───────────┐    ┌───────────┐
                        │  NocoDB   │    │   Grist   │
                        │   :8080   │    │   :8484   │
                        └───────────┘    └───────────┘
```

## Service Details

### Cognee (AI Memory Orchestration)
| Property | Value |
|----------|-------|
| **Port** | 8000 |
| **URL** | http://18.191.215.116:8000/docs |
| **Container** | sonik-cognee |
| **Purpose** | Knowledge graph + AI memory + semantic search |
| **Backends** | FalkorDB (graph), LanceDB (vectors), PostgreSQL (relational) |

### FalkorDB (Graph Database)
| Property | Value |
|----------|-------|
| **Port** | 6379 |
| **Protocol** | Redis (OpenCypher queries) |
| **Container** | sonik-falkordb |
| **Purpose** | Knowledge graph storage |
| **Data Volume** | falkordb_data |

### RedisVL (Semantic Cache)
| Property | Value |
|----------|-------|
| **Port** | 6380 |
| **UI Port** | 8001 (RedisInsight) |
| **URL** | http://18.191.215.116:8001 |
| **Container** | sonik-redisvl |
| **Purpose** | Semantic caching for LLM responses |
| **Status** | Running but NOT integrated yet |

### NocoDB (Spreadsheet UI)
| Property | Value |
|----------|-------|
| **Port** | 8080 |
| **URL** | http://18.191.215.116:8080 |
| **Container** | sonik-nocodb |
| **Purpose** | Spreadsheet interface for databases |
| **Metadata** | SQLite (local) |
| **External DBs** | Connect via UI after login |

### Grist (Smart Spreadsheets)
| Property | Value |
|----------|-------|
| **Port** | 8484 |
| **URL** | http://18.191.215.116:8484 |
| **Container** | sonik-grist |
| **Purpose** | Smart spreadsheets with formulas |
| **Org** | sonik |

### LanceDB (Vector Store)
| Property | Value |
|----------|-------|
| **Type** | Embedded (inside Cognee) |
| **Path** | /data/lancedb (container volume) |
| **Purpose** | Vector embeddings for semantic search |

## Health Checks

**Quick status:**
```bash
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Service-specific:**
```bash
# Cognee
curl http://18.191.215.116:8000/health

# FalkorDB (Redis ping)
redis-cli -h 18.191.215.116 -p 6379 ping

# RedisVL (requires password)
redis-cli -h 18.191.215.116 -p 6380 -a <password> ping
```

## Telemetry Status

All services have telemetry disabled:

| Service | Method |
|---------|--------|
| Cognee | `TELEMETRY_DISABLED=true` |
| NocoDB | `NC_DISABLE_TELE=true` |
| Grist | `GRIST_ALLOW_AUTOMATIC_VERSION_CHECKING=false` |
| FalkorDB | No telemetry built-in |
| RedisVL | No telemetry built-in |
