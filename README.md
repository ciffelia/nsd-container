# nsd-container

## Usage

### Start nsd

```sh
docker compose up --build -d
```

### Reload zone files (without restarting nsd)

```sh
docker compose exec nsd sh -c 'kill -HUP $(cat /var/nsd/chroot/var/run/nsd.pid)'
```

### Reload `nsd.conf` and zone files (restarts nsd)

```sh
docker compose restart
```

### Stop nsd

```sh
docker compose down
```

## Configuration

Edit `nsd.conf` and `*.zone` files in the `conf` directory as needed.
