# Custom Apollo Router image with Rhai scripts

## Context

## Building the Image

In building a custom Router image, we want to keep the integrity of the pre-built router appliance as much as posable. For cases that only require configuration and Rhai scripts, this means downloading the binary as apposed to building the Router from source.

Lucky for us, Apollo has a very good example Dockerfile for us to use. We start with a Debian slim image, load up some essentials such as cURL, download the router binary, and setup some debugging abilities.

## Configuration

To use router in a container image, it is required to change the default listening address. By default, the router binary will listen on localhost `127.0.0.1:4000`, in a container context it's necessary to change the listening address to `0.0.0.0:4000` in the router config.

```yaml
supergraph:
  listen: 0.0.0.0:4000
```

To utilize Rhai scripts, the router config must contain a `rhai` key and must contain at least one of a scripts key or a main key

```
rhai:
  scripts: "/dist/rhai"
  main: "test.rhai"
```

A complete example can be found in the `router.yaml` config file. Full Rhai scripting reference can be found in the [Rhai scripting docs](https://www.apollographql.com/docs/router/customizations/rhai).

Additional reference for availible configuration can be found in the [configuration Docs](https://www.apollographql.com/docs/router/configuration/overview).

## Running the Image

To utilize the image in a container, map the 4000 port to the port of your choice on the container and provide [Environmental Variables](https://www.apollographql.com/docs/router/configuration/overview#environment-variables) to specify either a local schema file `APOLLO_ROUTER_SUPERGRAPH_PATH` or Apollo Supergraph `APOLLO_KEY` and `APOLLO_GRAPH_REF`.
