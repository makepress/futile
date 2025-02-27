FROM rust:1.60.0 AS chef
WORKDIR app
RUN cargo install cargo-chef --locked

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --bin emphasize

FROM debian:buster-slim AS runtime
WORKDIR app
COPY --from=builder /app/target/release/emphasize /usr/local/bin
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/emphasize"]

