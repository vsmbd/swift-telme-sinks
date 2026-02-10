# NONGOALS

1. **Not an OpenTelemetry exporter**
   - This package does not translate Telme into OTel logs/metrics/traces or adopt OTel semantic conventions.

2. **Not a general-purpose ETL framework**
   - No schema registry, transformation DSL, streaming joins, or multi-hop pipelines.

3. **No “auto-discovery” of ClickHouse schema**
   - The sink will not introspect ClickHouse to discover tables/columns.
   - Schema alignment is an explicit contract.

4. **No guaranteed exactly-once delivery**
   - Retries may produce duplicates at the storage layer.
   - Dedupe is handled either:
     - by idempotent keys + ClickHouse table engine/versioning, or
     - by query-time aggregation (e.g. argMax on send_mono_nanos).
   - The sink aims for “at-least-once” delivery with bounded retries.

5. **No long-term on-device persistence (for now)**
   - No disk-backed queue, WAL, or crash-safe replay buffer.
   - The first iteration is a memory buffer + periodic flush.

6. **No UI**
   - This package does not include dashboards, Grafana provisioning, or visualizations.
