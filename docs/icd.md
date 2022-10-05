# Interface Control Document (ICD) - `votive-web`

<center>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/eldencat/terraform/raw/main/src/shared/eldencat-banner-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/eldencat/terraform/raw/main/src/shared/eldencat-banner.png">
  <img alt="Eldencat logo in light and dark." style="height:300px" src="https://github.com/eldencat/terraform/raw/main/src/shared/eldencat-banner.png">
</picture>

</center>

:exclamation: This document is intended for internal use.
## :telescope: Overview

This document details interfaces unique to this microservice.

## :books: Related Documents

Document | Description
--- | ---
:construction: Requirements & User Stories - `votive-web` :construction: | Requirements and user stories
[Concept of Operations (CONOPS) - `votive-web`](./conops.md) | Module overview
[Software Design Document (SDD) - `votive-web`](./sdd.md) | Module software design
:construction: High-Level Interface Control Document (ICD) :construction: | Interfaces shared by all microservices.

## :wave: Public API
### :file_folder: Files

File locations for REST/GraphQL/gRPC files.

Filename | Description
--- | ---
`<root>/schema/example.graphql`

### :guardsman: Authorization

See the High-Level ICD.

### :mailbox_with_mail: Endpoints

| Endpoint | Type | Arguments | Description |
| ---- | --- | ---- | ---- |

## :revolving_hearts: Private API

### :file_folder: Files
File locations for gRPC/MQTT/ZeroMQ/etc. files

Filename | Description
--- | ---
`<root>/schema/example.proto`

### :guardsman: Authorization

See the High-Level ICD.

### :mailbox_with_mail: Server Methods

| Service | Description | Authorized Clients
| ---- | ---- | ---
| `exampleService` | Description of service | `svc-example`: Needs something
