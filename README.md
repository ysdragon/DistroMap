# DistroMap API

[![Ring](https://img.shields.io/badge/Made%20with%20❤️%20Using-Ring-2D54CB)](https://ring-lang.net/)

A lightweight web API server that provides Linux distribution and release information based on codenames. Built with the Ring programming language, this API allows you to look up Linux distro versions by providing a product name and codename.

## Overview

DistroMap API is designed as a quick lookup service for Linux distribution information. You can query it with endpoints like `/distro/ubuntu/noble` and receive detailed version information and release data in return.

## API Endpoints

### Get Distribution Information
```
GET /distro/{product}/{codename}
```

**Parameters:**
- `product` - The Linux distribution/product name (e.g., "ubuntu", "debian")
- `codename` - The release codename OR version number (e.g., "noble", "jammy", "22.04", "11")

**Example Requests:**
```bash
# Using codename
curl http://localhost:8080/distro/ubuntu/noble

# Using version number
curl http://localhost:8080/distro/ubuntu/24.04
```

**Example Response:**
```json
{
  "name": "24.04",
  "codename": "Noble Numbat",
  "label": "24.04 'Noble Numbat' (LTS)",
  "releaseDate": "2024-04-25",
  "isLts": 1,
  "ltsFrom": null,
  "isEoas": 0,
  "eoasFrom": "2029-04-25",
  "isEol": 0,
  "eolFrom": "2029-04-25",
  "isEoes": 0,
  "eoesFrom": "2036-04-25",
  "isMaintained": 1,
  "latest": {
    "name": "24.04.3",
    "date": "2025-08-07",
    "link": "https://wiki.ubuntu.com/NobleNumbat/ReleaseNotes/"
  },
  "custom": null
}
```

### Health Check
```
GET /health
```

**Example Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2025-10-05 22:40:59",
  "database": {
    "loaded": 1,
    "product_count": 419,
    "last_update": "2025-10-05 22:37:44",
    "update_count": 1
  }
}
```

## Installation & Setup

### Prerequisites

- **[Ring Programming Language](https://ring-lang.net/download.html)** (version 1.24 or higher)

### Installation Methods

#### Using Ring Package Manager (Recommended)

You can install DistroMap using the Ring Package Manager with the following command:

```bash
ringpm install distromap from ysdragon
```

#### Manual Installation

1. **Clone or download** the project files
2. **Start the server:**
   ```bash
   ring main.ring
   ```

3. **Verify it's running:**
   ```bash
   curl http://localhost:8080/health
   ```

The server will start on `0.0.0.0:8080` by default and begin loading the product database from endoflife.date.

## Configuration

Configure the application using environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_HOST` | `0.0.0.0` | Server bind address |
| `SERVER_PORT` | `8080` | Server port |
| `UPDATE_INTERVAL` | `6` | Database update interval (hours) |
| `SSL_VERIFY_PEER` | `false` | Enable SSL certificate verification |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.