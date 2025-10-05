aPackageInfo = [
	:name = "distromap",
	:description = "Web API server that provides Linux distribution and release information based on codenames",
	:folder = "distromap",
	:developer = "ysdragon",
	:email = "",
	:license = "MIT License",
	:version = "1.0.0",
	:ringversion = "1.24",
	:versions = 	[
		[
			:version = "1.0.0",
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
		"Dockerfile",
		"docker-compose.yml",
		"lib.ring",
		"main.ring",
		"src/constants.ring",
		"src/distromap.ring",
		"src/utils/color.ring",
		"src/utils/log.ring",
		"src/utils/validate.ring"
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