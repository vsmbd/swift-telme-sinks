# TelmeSinks

A small, opinionated package that ships **default sinks** for Telme.

Right now it contains a single sink:

- `TelmeClickHouseSink`: batches Telme records and ships them over HTTP as **[JSON]** suitable for ClickHouse ingestion (direct to ClickHouse HTTP interface or to your own ingest proxy that forwards to ClickHouse).

This package intentionally keeps the surface area small so you can evolve your Telme schema and transport policies without turning `swift-telme` into an I/O-heavy dependency magnet.

## What this repo contains

- `TelmeSinks` target
  - `TelmeClickHouseSink`
  - small configuration types (`Config`, `BatchPolicy`, `RetryPolicy`)
  - minimal protocol expectations for an injected `HTTPClient`

## Integration model

You inject an `HTTPClient` that implements your networking contract (e.g. `swift-http-core`'s client adapter). The sink does **not** reach for `URLSession` directly.

### Suggested initializer shape

```swift
public final class TelmeClickHouseSink {
    public struct Config: Sendable {
        public var endpoint: URL              // e.g. https://<tunnel>/ingest
        public var headers: [String: String]  // e.g. Authorization, Content-Type
    }

    public init(
        http: HTTPClient,
        config: Config,
        batchPolicy: BatchPolicy = .default,
        retryPolicy: RetryPolicy = .default
    )
}
```

## Operational expectations

- Records are emitted in a single unified stream (no logs/metrics/traces split).
- Ordering must be preserved per session:
  - do not reorder within a batch
  - do not interleave record_ids incorrectly
- Retries may resend the same logical records; ClickHouse-side dedupe can be handled using `ReplacingMergeTree(send_mono_nanos)` (or equivalent).

## Development status

This repo is intentionally minimal right now:
- one target
- one sink
- no optional sink families (file, oslog, websocket, etc.) yet

Those can be added later as separate types inside the same target or split into additional targets only when required.
