# fix mapping error

## Option 1: Copy container config to host first

### Run container without mount first

```yaml
volumes: []
```

### Then start the container

```bash
docker compose up
```

### Copy the config out of the container

```bash
docker cp searxng:/usr/local/searxng ./searxng
```

### Now mount it

### Update your docker-compose.yml

```yaml
volumes:
  - ./searxng:/usr/local/searxng
```
