# Docker Base Images from Brandon Mitchell

These base images include:

- /etc/entrypoint.d for all entrypoint scripts
- `wait-for-it.sh` from https://github.com/vishnubob/wait-for-it
- `fix-perms` to match uid/gid of user inside container to a mounted volume
- `gosu` to run commands as a non-root user after setup in the entrypoint
- Secrets imported into environment variables 
- `save-volume` and `load-volume` to cache and initialize volume data from the
  image in scenarios where docker would not normally do this
- `stop-on-trigger` which can stop the container on a condition

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
  from root to the requested user (see potential issues writing to /dev/stdout
  below)

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

If you extend an alpine image, the shadow package needs to be installed for
the fix-perms script. If you use volume caching with the `-d` option, rsync
needs to be installed.

## Volume Caching

Volume caching scripts are useful for the following scenarios:

- When docker does not initialize host volumes for you.
- When using a tmpfs volume and need the content to be initialized.
- When using a pre-initialized volume that needs to be updated on every startup
  with data from the image.

Caching is a two step process:

1. Calling `RUN save-volume /path/to/dir` in your Dockerfile for any directory
   to cache in the image. This directory will be moved into cache storage,
   so make it the last step on this directory that you run during your build.
2. Calling `load-volume /path/to/dir`, or use the `entrypointd.sh` which loads
   all volumes you have previously saved with the flags passed to `save-volume`.

The `save-volume` and `load-volume` scripts have the following options:

- `-d`: delete files from the mounted volume, this uses/depends on `rsync`.
- `-u`: update a volume even if it already exists. This overwrites any changes
  in the volume, but does not delete or modify files that were not previously
  cached.

The `load-volume` script will:

- Create a symlink if there is no volume mount to update.
- If the `-d` flag was used, run `rsync` to reset the volume to the cached
  state.
- If the volume mount is empty or `-u` was used, run a `cp -a` to initialize
  the volume.

Note: caching a volume with the above steps results in the directory being
moved which will double the size of the directory in the docker layers when
performed as a separate build step. When possible, merge the `save-volume`
step with any other commands used to create the volume folder. If copying
files between stages in a multi-stage build, include `/.volume-cache`.

## Stop On Trigger

The `stop-on-trigger` script can be used to stop a container on a condition.
This would be launched as a background process in an entrypoint script. When
the condition is met, all processes are sent a SIGTERM, followed by a delay,
and then a SIGKILL. However, pid 1 will not receive this signal inside of the
container so you need to use `tini` to run your app as a child pid. This is
done by setting `ENV USE_INIT=1` in the image when using entrypointd.sh. A
sample entrypointd script would look like:

```
#!/bin/sh
stop-on-trigger -m /etc/certs/host.pem
```

Which would stop the container when the file is modified, and any container
restart policy would result in a new container running, using that new
certificate file.

## Examples

The nginx example shows:

- Extending the nginx image with the scratch base image
- Running the application as uid 5000 inside the container
- Volume caching to automatically populate host and tmpfs volumes
- Entrypoint to automatically fix the uid to match the developer volume mount
- Using curl for a healthcheck

## Errors Writing to /dev/stdout

There are scenarios where writing to /dev/stdout and /dev/stderr may fail with
permission problems when the container starts as root and changes to another
user. Should you encounter this, try to add the user to the tty group and
configure the container with a tty. See the following issue for more details:
https://github.com/moby/moby/issues/31243#issuecomment-406879017

