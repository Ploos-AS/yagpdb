# YAGPDB container

Production-oriented OCI packaging of upstream YAGPDB.

This image pins upstream YAGPDB v2.83.1 at commit `7d2a3ba8975a4d0b30c814ada06ca43a969d7348`. The Ploos AS container version is `0.1.0`.

The default Compose stack uses YAGPDB + PostgreSQL + Valkey. Upstream documents Valkey as a Redis-compatible drop-in replacement.

Default deployment is reverse-proxy-first: YAGPDB listens on HTTP port 5000 internally with external HTTPS enabled logically using `-https=false -exthttps=true`.

Required Discord redirect URIs:

- `https://YOUR_HOST/confirm_login`
- `https://YOUR_HOST/manage`

Persistent state is stored in PostgreSQL, Valkey, and the soundboard volume. The YAGPDB container runs as UID/GID 1000.

Packaging and upstream YAGPDB are MIT licensed. See `NOTICE`.
