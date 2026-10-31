--[[ The plug-in's version and the server it talks to.

build.sh writes both into the built copy (rawwers.lrplugin); this source
copy points at a development server on this Mac, which is what loading the
.lrdevplugin folder in Lightroom's Plug-in Manager is for.
]]

return {
	version = '1.0.0',
	--- Used when the Export dialog's Server field is left empty.
	baseUrl = 'http://localhost:8000',
}
