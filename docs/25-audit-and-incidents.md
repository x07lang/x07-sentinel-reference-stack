# Audit and incidents

Check:
- Governance → Audit
- Changes → Releases
- Infrastructure → Deployment targets
- Infrastructure → Connections

You should see records for:
- target registration
- secret upload
- binding creation
- release submit
- release approval
- rollback

Optional incident walk-through:
1. break a binding value in a test environment
2. trigger a failing rollout or readiness state
3. inspect Services / Changes / Infrastructure
4. restore the binding or roll back the release
