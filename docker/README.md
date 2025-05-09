# run docker

```bash
export MUID=$(id -u)
export MGID=$(id -g)
export MUSER=$USER

docker compose build
```


# run
```bash
docker compose run --remove-orphans --rm --service-ports base

```
