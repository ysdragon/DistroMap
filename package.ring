aPackageInfo = [
	:name = "distromap",
	:description = "Web API server that provides Linux distribution and release information based on codenames",
	:folder = "distromap",
	:developer = "ysdragon",
	:email = "",
	:license = "MIT License",
	:version = "1.3.0",
	:ringversion = "1.24",
	:versions = 	[
		[
			:version = "1.3.0",
			:branch = "master"
		]
	],
	:libs = 	[
		[
			:name = "httplib",
			:version = "1.0.14",
			:providerusername = "ringpackages"
		],
		[
			:name = "simplejson",
			:version = "1.0.0",
			:providerusername = "ysdragon"
		],
		[
			:name = "libuv",
			:version = "1.0.11",
			:providerusername = "ringpackages"
		]
	],
	:files = 	[
		// Project files
		"Dockerfile",
		"docker-compose.yml",
		".env.example",
		".gitignore",
		"lib.ring",
		"main.ring",
		"LICENSE",
		"README.md",
		// Configuration
		"src/constants.ring",
		// Main entry point
		"src/distromap.ring",
		// Core modules
		"src/core/state.ring",
		"src/core/server.ring",
		"src/core/scheduler.ring",
		// Utilities
		"src/utils/color.ring",
		"src/utils/log.ring",
		"src/utils/validate.ring",
		"src/utils/response.ring",
		"src/utils/helpers.ring",
		// Services
		"src/services/database.ring",
		"src/services/search.ring",
		// Handlers
		"src/handlers/root.ring",
		"src/handlers/distro.ring",
		"src/handlers/products.ring",
		"src/handlers/compare.ring",
		"src/handlers/health.ring",
		"src/handlers/metrics.ring",
		// Public assets
		"src/public/index.html",
		"src/public/assets/style.css",
		"src/public/assets/app.js"
	],
	:ringfolderfiles = 	[

	],
	:windowsfiles = 	[

	],
	:linuxfiles = 	[

	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:freebsdfiles = 	[

	],
	:macosfiles = 	[

	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:freebsdringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = ""
]