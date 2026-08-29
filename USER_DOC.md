# User Documentation

This document explains how an end user or administrator can interact with the Inception stack.

## Understand the Services
This infrastructure provides a fully functional, containerized WordPress website running securely over HTTPS. It consists of:
- **NGINX**: The web server acting as a reverse proxy and the sole entry point via HTTPS (port 443).
- **WordPress**: The application running on PHP-FPM, processing dynamic web pages.
- **MariaDB**: The database management system safely storing all WordPress data.

## Start and Stop the Project
- **To start the project**: Navigate to the root directory and run `make`. This will build the Docker images and launch the containers in the background.
- **To stop the project**: Run `make clean` to gracefully stop all running containers.
- **To completely remove the project (including volumes)**: Run `make fclean` or `make down`.

## Access the Website and Administration Panel
Once the project is running:
- The main website is accessible at: `https://msabr.42.fr`
- The administration panel is accessible at: `https://msabr.42.fr/wp-admin/`
*(Note: You will need to accept the self-signed SSL certificate warning in your browser since it is a self-generated local cert).*

## Locate and Manage Credentials
Credentials (like database passwords and WordPress admin accounts) are strictly managed via environment variables. 
- You can locate and modify these in the `srcs/.env` file.
- **Never** commit this file to a public repository. If compromised, change the credentials immediately and rebuild the environment.

## Check Services are Running Correctly
To verify the infrastructure is running smoothly, execute:
```bash
docker ps 
```
You should see three containers (`nginx`, `wordpress`, `mariadb`) with the status "Up".
To check the logs of a specific service if it fails to load, run:
```bash
docker logs <container_name>
```
