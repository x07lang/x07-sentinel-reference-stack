# Register the target

Use the template at:
- `sentinel/payloads/targets/k8s-target.template.json`

Required fields:
- `TARGET_ID`
- `TARGET_DISPLAY_NAME`
- `TARGET_BASE_URL`
- `CLUSTER_REF`
- `NAMESPACE`

Suggested target IDs:
- `target.aws.orders.dev`
- `target.gcp.orders.dev`

After registration, call validation and confirm the target is green in the console.
