# Docker Base Images from Brandon Mitchell

These base images include:

- /etc/entrypoint.d for all entrypoint scripts
- `wait-for-it.sh` from https://github.com/vishnubob/wait-for-it
- `fix-perms` to match uid/gid of user inside container to a mounted volume
- `gosu` to run commands as a non-root user after setup in the entrypoint
- Secrets imported into environment variables 

## Platform specific additions

Debian base image includes:

- `apt-install`: runs apt update and install with non-interactive options and
  performs a cleanup

Alpine base image includes:

- `apk-install`: runs an `apk add` with options to avoid caching
- The "shadow" package is required for useradd, usermod, and groupmod

## Using /etc/entrypoint.d/

- Files named "*.env" will be sourced if readable and may contain environment
  variables
- Files named "*.sh" will be executed if executable
- Files will be processed in order

## Using /etc/healthcheck.d/

- This mirrors entrypoint.d functionality, first sourcing any "*.env" files,
  and then running all "*.sh" scripts. If any script fails, the healtcheck
  will fail.

## Environment variables

- `ORIG_ENTRYPOINT`: If set to a non-empty value, this is prepended to the
  command being run
- `USE_INIT`: If set to any non-empty value, tini will be used to run the
  command, providing repaing of zombie processes
- `RUN_AS`: If set to any non-empty value, gosu will be used to drop privledges
  from root to the requested user

## Converting Secrets to Environment Variables

Environment variables with the value `{DOCKER_SECRET:xyz}` will be replaced
with the contents of `/run/secrets/xyz`. This also works for a substring,
e.g. `USERPASS=root@{DOCKER_SECRET:root_login}` would lookup root_login
and replace it with something like `USERPASS=root@passw0rd`.

Note that environment variables are inherently less secure than the secret file
since they may be read by other processes with access to /proc, and often get
written to debugging logs. Be sure to understand the risks of using these
variables before adding them to your application architecture.

## Using scratch

The scratch image is designed to for extending other images, e.g.:

```
FROM your_base_image
COPY --from=sudobmitch/base:scratch / /
```

If you extend an alpine image, the shadow package needs to be installed.

## Examples

The nginx example shows:

- Extending the nginx image with the scratch base image
- Running the application as uid 5000 inside the container
- Entrypoint to automatically fix the uid to match the developer volume mount
- Using curl for a healthcheck
- For details on the need for a TTY when writing to /dev/stdout and /dev/stderr
  see: https://github.com/moby/moby/issues/31243#issuecomment-406879017

