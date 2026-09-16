# BRAIN 

Beyond Rational Artificial Intelligence Network

## Abstract
BRAIN is a ready-to-use Docker deployment for running your own community infrastructure. It bundles three proven, self-hosted services so you don't have to wire them together yourself:

- **[Matrix](https://matrix.org/)** — real-time communication for your community.
- **[Nextcloud](https://nextcloud.com/)** — files, calendars, forms and a shared space to build community around.
- **[WordPress](https://wordpress.org/)** — a landing page to present your community to the world.

On top of that, BRAIN adds a simple backup system (`make save` / `make load`) that snapshots your whole deployment to a Docker registry, with the target registry (Docker Hub or a private one) fully configurable.

## Services
| Service | Purpose |
|---|---|
| **Matrix** | Chat and communication backend (Synapse). |
| **Nextcloud** | Community hub: files, calendar, forms, profiles. |
| **WordPress** | Public-facing landing page / blog. |
| **MySQL** | Database for WordPress. |
| **MariaDB** | Database for Nextcloud. |
| **Redis** | Cache backend for Nextcloud. |

## Getting Started
1. Copy the sample environment file and fill in your own values:
   ```
   cp .env.sample .env
   ```
2. Start the stack:
   ```
   make start
   ```
3. Stop it when needed:
   ```
   make stop
   ```

See `.env.sample` for every configurable value: ports, domains, admin credentials and database credentials.

## Backups
BRAIN ships with a snapshot-based backup system built on Docker images rather than a traditional backup tool, so a full restore is just pulling a tagged image.

- `make save` — pauses the stack, packages `./data/volumes` into a Docker image, and pushes it tagged both `latest` and with today's date.
- `make load` — pulls the saved image, restores `./data/volumes` from it, and restarts the stack.

The destination for these images is configurable via `.env`:
- `DOCKER_HUB_USER` / `DOCKER_HUB_PROJECT` — the image namespace and repository name.
- `DOCKER_REGISTRY` — leave empty to use Docker Hub, or set it to your private registry host (e.g. `registry.example.com`) to push/pull backups there instead.

## Reverse Proxy
To expose the services behind nginx, something like this works as a starting point (adjust domains and upstream ports to match your `.env`):

```nginx
# Nextcloud
server {
        server_name your.cloud.domain;
        client_max_body_size 20G;
        client_body_buffer_size 400M;
        location ^~ /.well-known {
                # The rules in this block are an adaptation of the rules
                # in `.htaccess` that concern `/.well-known`.

                location = /.well-known/carddav { return 301 /remote.php/dav/; }
                location = /.well-known/caldav  { return 301 /remote.php/dav/; }

                location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
                location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

                # Let Nextcloud's API for `/.well-known` URIs handle all other
                # requests by passing them to the front-end controller.
                return 301 /index.php$request_uri;
        }

        location / {
                client_max_body_size 20G;
                client_body_buffer_size 400M;
                proxy_pass http://localhost:1001;
                proxy_set_header Host $host;
        }

        location = /custom_502.html {
                root /var/www/html;  # Path to your custom HTML file
                internal;
        }

        error_page 502 /custom_502.html;
}

# WordPress
server {
        server_name your.blog.domain;
        location /.well-known {
                alias /var/www/.well_known;
        }
        location / {
                proxy_pass http://localhost:1000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
        }
        location = /custom_502.html {
                root /var/www/html;  # Path to your custom HTML file
                internal;
        }

        error_page 502 /custom_502.html;
        listen 80;
}

# Matrix
server {
        server_name your.matrix.domain;
        location /.well-known {
                alias /var/www/.well_known;
        }
        location / {
                proxy_pass http://localhost:1007;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
        }
        location = /custom_502.html {
                root /var/www/html;  # Path to your custom HTML file
                internal;
        }

        error_page 502 /custom_502.html;
}
```

## Get Involved
BRAIN is meant as a starting point for anyone who wants to run their own community infrastructure without depending on third-party platforms — a school, a neighborhood, a family, or any group that wants to own its own chat, files and landing page.

Contributions are welcome: explore the repository, open issues, and share ideas to make the deployment simpler or more robust.

## License
Created by [ideniox](https://ideniox.com) and licensed as a [HaaT](https://github.com/JorgeMartinezPizarro/haat/blob/main/LICENSE.md)
