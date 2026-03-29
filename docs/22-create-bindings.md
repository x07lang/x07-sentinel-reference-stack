# Create bindings

This example uses four bindings:

1. `db.primary` — kind `postgres`
2. `msg.orders` — kind `amqp`
3. `obj.reports` — kind `s3`
4. `telemetry.otlp` — kind `otlp`

Upload secrets first:

```sh
bash sentinel/scripts/03-put-secrets.sh
```

Then create bindings:

```sh
bash sentinel/scripts/04-create-bindings.sh
```

Use Infrastructure → Connections to confirm status.
