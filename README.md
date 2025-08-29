# Django Docker Project

Containerized Django web application with PostgreSQL database and Nginx reverse proxy using Docker and Docker Compose.

## Navigation

- [Back to Main Project](https://github.com/LesiaUKR/my-microservice-project/tree/main) - Main project overview and navigation to all lessons

## Project Overview

This project demonstrates a complete containerized web application stack featuring:

- **Django** - Python web framework for application logic
- **PostgreSQL** - Relational database for data persistence  
- **Nginx** - Web server and reverse proxy
- **Docker & Docker Compose** - Container orchestration

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Nginx    │    │   Django    │    │ PostgreSQL  │
│   (Port 80) │────│  (Port 8000)│────│ (Port 5432) │
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
```

## Project Structure

```
django-docker-project/
├── django_app/                 # Django application code
│   ├── myproject/              # Django project settings
│   │   ├── __init__.py
│   │   ├── settings.py         # Database and app configuration
│   │   ├── urls.py             # URL routing
│   │   └── wsgi.py             # WSGI application
│   ├── main/                   # Django main app
│   │   ├── __init__.py
│   │   ├── apps.py             # App configuration
│   │   ├── models.py           # Database models
│   │   ├── urls.py             # App-specific URLs
│   │   └── views.py            # Request handlers
│   └── manage.py               # Django management commands
├── nginx/
│   └── nginx.conf              # Nginx server configuration
├── docker-compose.yml          # Multi-container orchestration
├── Dockerfile                  # Django container definition
├── docker-entrypoint.sh        # Container startup script
└── requirements.txt            # Python dependencies
```

## Features

- **Multi-container Architecture** - Separate containers for web, database, and proxy
- **Database Integration** - PostgreSQL with Django ORM
- **Static Files Serving** - Nginx handles static content efficiently
- **Health Checks** - Container health monitoring and dependencies
- **Volume Persistence** - Database and static files persist across container restarts
- **Environment Configuration** - Configurable through environment variables

## API Endpoints

- **GET /** - Main application endpoint returning JSON response
- **GET /health/** - Health check endpoint
- **GET /admin/** - Django admin interface

## Quick Start

### Prerequisites

- Docker Desktop installed and running
- Git for version control

### Installation

1. Clone the repository:
```bash
git clone https://github.com/LesiaUKR/my-microservice-project.git
cd my-microservice-project
git checkout lesson-4
cd django-docker-project
```

2. Build and start all services:
```bash
docker-compose up --build
```

3. Access the application:
   - **Main app**: http://localhost
   - **Health check**: http://localhost/health/
   - **Admin panel**: http://localhost/admin/

### Expected Response

Visiting http://localhost should return:
```json
{
    "title": "Django + Docker + PostgreSQL + Nginx",
    "message": "Successfully deployed Django application with Docker!"
}
```

## Docker Services

### Django Application
- **Image**: Custom Python 3.9 slim
- **Port**: 8000 (internal)
- **Dependencies**: PostgreSQL database
- **Features**: Gunicorn WSGI server, automatic migrations, static file collection

### PostgreSQL Database
- **Image**: postgres:15
- **Port**: 5432 (internal)
- **Database**: myproject
- **Features**: Health checks, persistent data volume

### Nginx Reverse Proxy
- **Image**: nginx:alpine
- **Port**: 80 (exposed)
- **Features**: Proxy to Django, static file serving, health endpoint

## Development Commands

```bash
# Start services in background
docker-compose up -d

# View logs
docker-compose logs django
docker-compose logs db
docker-compose logs nginx

# Stop services
docker-compose down

# Rebuild containers
docker-compose up --build

# Execute commands in Django container
docker-compose exec django python manage.py createsuperuser
docker-compose exec django python manage.py shell
```