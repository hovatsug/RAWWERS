--[[ RAWWERS for Lightroom Classic: deliver a gig's photos with "Export To: RAWWERS",
and put photos in the portfolio with the "RAWWERS Portfolio" publish service (1.1.0),
adding niches to the profile from Lightroom (1.2.0); Save works once
connected (1.2.1, 1.2.2); publishing again is safe (1.2.3); so is exporting again (1.2.4);
a niche or a photo removed in the RAWWERS Pro app is never published into or sent again (1.2.5).

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
		{ title = 'RAWWERS', file = 'RawwersServiceProvider.lua' },
		{ title = 'RAWWERS Portfolio', file = 'RawwersPublishProvider.lua' },
	},
	VERSION = { major = 1, minor = 2, revision = 5, build = 0 },
}
