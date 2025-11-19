# Beyond Rational Artificial Intelligence Network (BRAIN)
### Bridging humanity and technology with efficiency and purpose

## Abstract
Beyond Rational Artificial Intelligence Network (BRAIN) aims to create a sustainable and efficient integration between human creativity and technology. It fosters evolutionary efficiency, supported by AI, while prioritizing meaningful connections and solving real-world challenges. Without meaning, purpose is lost, and inefficiency prevails.

## Description
In a world full of cutting-edge technologies and constant innovation, BRAIN bridges the gap between STEAM education and practical technology applications. It leverages powerful tools and methodologies to create a sustainable balance between human creativity and technological progress. 

### Key Goals:
- Foster meaningful integration between devices and cloud services.
- Develop a **Planetary File System**, inspired by Tim Berners-Lee's SOLID and interconnection ideas.
- Utilize cutting-edge technologies to promote financial inclusion, efficiency, and collaboration.

### Core Technologies:
- **LND**: Local payment systems integration.
- **BTC**: Global payment network connections.
- **LLM**: Language Models for personal and contextual training.
- **SQL**: Structured data management.
- **RDF**: Semantic connections for knowledge representation.
- **ADN**: Human evolution metaphor and interconnection.

## Folder Structure
- **docker-compose/**: Modular services managed with Docker.
  - **lnd**: Local payment networks connecting to the global Lightning Network. [TODO]
  - **matrix**: Human networking and communication (Signal and bridges).
  - **nextcloud**: Profile management and file synchronization.
  - **wordpress**: Content sharing and experiences.
  - **nextjs**: Frontend with three main tabs:
    - **Monitoring**: Displays system stats. [DONE]
    - **Payment**: Manages LND connections. [TODO]
    - **Training**: Personal training using LLMs. [DONE]
- **volumes/**: Persistent system data stored in an external Docker registry.
- **Makefile**: System commands for managing the BRAIN environment.
- **default/**: System configuration synced with nginx in the host.
- **.env**: Default system values (passwords, users, etc.).

## Usage
### Basic Commands:
- `make start`: Start the BRAIN system for individual or organizational use.
- `make stop`: Shut down the BRAIN system containers.
- `make save`: Save the current BRAIN snapshot as a Docker tag.
- `make load`: Restore the BRAIN system from a saved Docker tag.

By installing tools like Nextcloud and Signal on your devices, you can:
- Synchronize files seamlessly for personal or institutional use.
- Communicate across networks like school, family, or work.

### Advanced Setup:

To start the services it is recommended to setup nginx or apache2 as follows:

```
## nextcloud login as a login umbrella for the nextjs container

# dev cloud
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
                # Allow only requests from the same domain (no external origins)
	        add_header 'Access-Control-Allow-Origin' "$scheme://$http_host" always;

        	# Block external cross-origin requests by not allowing any other headers/methods
	        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
	        add_header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept' always;
	        add_header 'Access-Control-Allow-Credentials' 'true' always;
	
		add_header 'Strict-Transport-Security' "max-age=15552000; includeSubDomains";
        }
        location /bookmarks {
                client_max_body_size 20G;
                client_body_buffer_size 400M;
		if ($http_cookie !~* "nc_session_id") {
                        return 302 https://your.cloud.domain/login;
                }
                proxy_pass http://localhost:1002;
                proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";

	        # Forward original host and other headers
	        proxy_set_header Host $host;	
		proxy_set_header X-Real-IP $remote_addr;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;

	        # Ensure WebSocket timeout settings
		proxy_read_timeout 86400s;
	        proxy_send_timeout 86400s;

		# Allow only requests from the same domain (no external origins)
	        add_header 'Access-Control-Allow-Origin' "$scheme://$http_host" always;

        	# Block external cross-origin requests by not allowing any other headers/methods
	        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
	        add_header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept' always;
	        add_header 'Access-Control-Allow-Credentials' 'true' always;
	
	}
        location = /custom_502.html {
		root /var/www/html;  # Path to your custom HTML file
		internal;
        }

        error_page 502 /custom_502.html;
}

# dev blog
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

# matrix net 
server {
        server_name solvantianet.ideniox.com;
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

## Civil Institutions
For institutions, BRAIN offers:
- **Financial Inclusion**: Enable lightweight payments with Lightning Network.
- **Efficiency**: Use affordable devices, like smartphones, for seamless integration.
- **Accessibility**: Promote inclusion without the need for expensive infrastructure.

## Use Cases
BRAIN adapts to real-world scenarios through practical applications. From simplifying daily tasks to empowering education and fostering financial inclusion, explore how BRAIN can make a difference.

- **[Paythering](INFO.md#paythering):** Revolutionizing daily transactions with efficient payment networks.
- **[Education and Politics: IA-Supported](INFO.md#education-and-politics-ia---supported-not-driven):** Enabling seamless learning and collaboration through technology.

For detailed examples, see the [Use Cases document](INFO.md).

## Get Involved
We believe in collaboration and shared purpose. Whether you're a programmer, educator, or philosopher, there's a place for you in BRAIN.

### How to Contribute:
1. Explore the repository and familiarize yourself with its structure.
2. Join discussions on community-driven platforms.
3. Share ideas and propose solutions to bridge humanity and technology.

### Open Issues:
- Discuss the use of Signal bridges to Matrix.
- Evaluate LND versus other Lightning implementations.
- Explore the integration of Paythering for meaningful transactions.
- Test and refine the Core Lightning implementation.
- Experiment with Matrix 2.0 proposals and ElementX.
- Try out nextcloud FORMS and ELEMENT plugins to manage data and user connections via web.
- Add usage of default to map the services

## Note

Locally, we always see a circle—closed, comprehensible, and complete.

## License

Created by [ideniox](https://ideniox.com) and licensed as a [HaaT](https://github.com/JorgeMartinezPizarro/haat/blob/main/LICENSE.md)
