# DistroMap API

[![Ring](https://img.shields.io/badge/Made%20with%20❤️%20Using-Ring-2D54CB)](https://ring-lang.net/)

A lightweight web API server that provides Linux distribution and release information based on codenames. Built with the Ring programming language, this API allows you to look up Linux distro versions by providing a product name and codename.

## Overview

DistroMap API is designed as a quick lookup service for Linux distribution information. You can query it with endpoints like `/distro/ubuntu/noble` and receive detailed version information and release data in return.

## Features

- **Fuzzy Matching** - Automatic typo correction using Levenshtein distance algorithm
- **Smart Suggestions** - Returns similar product names when a query doesn't match
- **Release Comparison** - Compare two releases side-by-side with recommendations
- **Prometheus Metrics** - Built-in metrics endpoint for monitoring
- **CORS Support** - Configurable Cross-Origin Resource Sharing
- **Response Caching** - Configurable cache headers for better performance

## API Endpoints

### Get Distribution Information

#### Get Specific Release
```
GET /distro/{product}/{codename}
```

**Parameters:**
- `product` - The product name (e.g., "ubuntu", "debian", "nodejs")
- `codename` - The release codename OR version number (e.g., "noble", "jammy", "22.04", "11")

**Example Requests:**
```bash
# Using codename
curl http://localhost:8080/distro/ubuntu/noble

# Using version number
curl http://localhost:8080/distro/ubuntu/24.04

# Fuzzy matching (typo correction)
curl http://localhost:8080/distro/ubunt/noble  # Still finds Ubuntu
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

#### Get All Releases for a Product
```
GET /distro/{product}
```

**Example:**
```bash
curl http://localhost:8080/distro/ubuntu
```

**Example Response:**
```json
{
  "product": "ubuntu",
  "releaseCount": 15,
  "releases": [...]
}
```

---

### List Products

#### Get All Products
```
GET /products
```

Returns a list of all available products with their release counts.

**Example Response:**
```json
{
  "count": 428,
  "products": [
    {"name": "ubuntu", "releaseCount": 43},
    {"name": "debian", "releaseCount": 18},
    ...
  ]
}
```

#### Get Product Details
```
GET /products/{product}
```

Returns all releases for a specific product.

---

### Compare Releases
```
GET /compare/{product1}/{version1}/{product2}/{version2}
```

Compare two releases and get recommendations.

**Example:**
```bash
curl http://localhost:8080/compare/ubuntu/22.04/ubuntu/24.04
```

**Example Response:**
```json
{
  "comparison": {
    "release1": {
      "product": "ubuntu",
      "version": "22.04",
      "data": {...}
    },
    "release2": {
      "product": "ubuntu",
      "version": "24.04",
      "data": {...}
    },
    "analysis": {
      "eolComparison": "Release 2 has longer support (EOL: 2029-04-25 vs 2027-04-01)",
      "ltsComparison": "Both releases are LTS",
      "recommendation": "Release 2 is recommended (longer support period)"
    }
  }
}
```

---

### Health Check
```
GET /health
```

**Example Response:**
```json
{
  "status": "healthy",
  "version": "1.1.0",
  "timestamp": "2025-10-05 22:40:59",
  "uptime": "2d 5h 30m 15s",
  "database": {
    "loaded": true,
    "product_count": 419,
    "last_update": "2025-10-05 22:37:44",
    "update_count": 1
  },
  "upstream": {
    "endoflife_date": "reachable",
    "last_check": "2025-10-05 22:40:59",
    "api_url": "https://endoflife.date/api/v1/products/full"
  }
}
```

---

### Metrics (Prometheus)
```
GET /metrics
```

Returns Prometheus-compatible metrics for monitoring.

**Example Response:**
```
# HELP distromap_requests_total Total number of HTTP requests
# TYPE distromap_requests_total counter
distromap_requests_total 1234

# HELP distromap_requests_successful Total successful requests
# TYPE distromap_requests_successful counter
distromap_requests_successful 1200

# HELP distromap_requests_failed Total failed requests
# TYPE distromap_requests_failed counter
distromap_requests_failed 34

# HELP distromap_fuzzy_matches_total Total fuzzy match hits
# TYPE distromap_fuzzy_matches_total counter
distromap_fuzzy_matches_total 56

# HELP distromap_uptime_seconds Server uptime in seconds
# TYPE distromap_uptime_seconds gauge
distromap_uptime_seconds 86400

# HELP distromap_database_products Number of products in database
# TYPE distromap_database_products gauge
distromap_database_products 419
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

### Server Settings
| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_HOST` | `0.0.0.0` | Server bind address |
| `SERVER_PORT` | `8080` | Server port |
| `BASE_URL` | `http://localhost:8080` | Public base URL for the API (used in frontend templates) |
| `UPDATE_INTERVAL` | `6` | Database update interval (hours) |
| `SSL_VERIFY_PEER` | `true` | Enable SSL certificate verification |

### CORS Settings
| Variable | Default | Description |
|----------|---------|-------------|
| `CORS_ENABLED` | `true` | Enable CORS headers |
| `CORS_ORIGIN` | `*` | Allowed origins |
| `CORS_METHODS` | `GET, OPTIONS` | Allowed HTTP methods |
| `CORS_HEADERS` | `Content-Type, Accept` | Allowed headers |

### Caching & Logging
| Variable | Default | Description |
|----------|---------|-------------|
| `CACHE_MAX_AGE` | `300` | Cache-Control max-age in seconds |
| `REQUEST_LOGGING` | `true` | Enable request logging |
| `DEBUG` | `false` | Enable debug mode |

### Metrics
| Variable | Default | Description |
|----------|---------|-------------|
| `METRICS_ENABLED` | `false` | Enable `/metrics` endpoint |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.