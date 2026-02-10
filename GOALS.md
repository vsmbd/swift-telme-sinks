# GOALS

## Primary goals

1. **Ship a default ClickHouse sink**
   - Provide `ClickHouseTelmeSink` that can ingest Telme records into a ClickHouse-backed observability sandbox.
   - Work with either:
     - ClickHouse HTTP insert endpoint directly, or
     - a local ingest proxy (recommended when ClickHouse must remain localhost-only).

2. **Keep Telme core clean**
   - `swift-telme` should stay focused on record representation and deterministic ordering.
   - All I/O and transport policy lives in `TelmeSinks`.

3. **Injection-first networking**
   - The sink must accept an `HTTPClient` abstraction via initializer injection.
   - No direct dependency on `URLSession` at the sink implementation boundary.

4. **Deterministic, unified stream semantics**
   - Preserve Telme’s “one stream” philosophy:
     - no forced separation into logs/traces/metrics
     - ordering preserved per session
     - batching must not reorder records.

5. **Demo-ready defaults**
   - Provide sensible defaults for batching and retry suitable for a demo app:
     - flush every N seconds and/or N records
     - exponential backoff with a cap
     - bounded memory

## Secondary goals

- Make the sink portable across Apple platforms.
- Keep the public API small and stable while the backend schema evolves.
