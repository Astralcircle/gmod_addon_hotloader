local function writeDefaultAddonJson( dir, id )
	file.Write( dir .. "/addon.json", util.TableToJSON( {
		ignore = {},
		title = string.format( "Hotloaded addon %s", id )
	} ) )
end

function HotLoad.StripGMALua( id, filename, done )
	local GMA = HotLoad.GMA
	local data = GMA.Read( filename )
	if not data then
		done( nil )
		return
	end

	local files = {}
	local tmpDir = string.format( "hotload_tmp/%s", id )
	file.CreateDir( tmpDir )
	for _, v in pairs( data.Files ) do
		local name = v.Name
		local content = v.Content
		if string.EndsWith( name, ".lua" ) then
			table.insert( files, name )
			HotLoad.fileContent[name] = content
		else
			local dirPath = string.GetPathFromFilename( name )
			file.CreateDir( tmpDir .. "/" .. dirPath )
			file.Write( tmpDir .. "/" .. name, content )
		end
	end

	writeDefaultAddonJson( tmpDir, id )

	GMA.Create( string.format( "hotload_tmp/%s_ws_content.txt", id ), "data/" .. tmpDir, true, false, function( path )
		done( {
			luaFileNames = files,
			contentGMAPath = path
		} )
	end )
end
