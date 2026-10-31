--[[ RAWWERS for Lightroom Classic: deliver a gig's photos with "Export To: RAWWERS".

Built against the Lightroom Classic SDK 15.3. LrSdkMinimumVersion 13.0:
the last three major versions (13, 14, 15), owner's decision 8. Every SDK
call the plug-in makes exists since SDK 4.1 or earlier, so nothing newer is
required; Lightroom refuses to load it in a version below 13.
]]

return {
	LrSdkVersion = 15.3,
	LrSdkMinimumVersion = 13.0,
	LrToolkitIdentifier = 'com.rawwers.lightroom.delivery',
	LrPluginName = 'RAWWERS',
	LrExportServiceProvider = {
		title = 'RAWWERS',
		file = 'RawwersServiceProvider.lua',
	},
	VERSION = { major = 1, minor = 0, revision = 0, build = 0 },
}
