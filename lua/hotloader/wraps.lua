_OldInclude = _OldInclude or include
_OldAddCSLuaFile = _OldAddCSLuaFile or AddCSLuaFile

HotLoad._hotLoadincludeLocalPath = nil

local function normalizePath( path )
	local normalized = string.gsub( path, "\\", "/" )
	return normalized
end

---@param addon LoadedAddon
---@return table<string, any>
function HotLoad.GetWraps( addon )
	local includeOverride = function( filename )
		local localPath = HotLoad._hotLoadIncludeLocalPath

		local luaFilename = filename
		if not string.StartsWith( luaFilename, "lua/" ) then
			luaFilename = "lua/" .. luaFilename
		end
		if file.Exists( luaFilename, "WORKSHOP" ) then
			addon:runLua( { luaFilename } )
			return
		end

		if not localPath then
			return _OldInclude( filename )
		end

		local relativePath = localPath .. filename

		addon:runLua( { relativePath } )
	end

	local AddCSLuaFileOverride = function( filename )
		local callSource = debug.getinfo( 2, "S" ).source
		local identifierData = HotLoad.parseIdentifier( callSource )
		if not identifierData.isAddonLoader then
			return _OldAddCSLuaFile( filename )
		end
	end

	local funcPrinter = function( ... )

	end

	return {
		include = includeOverride,
		AddCSLuaFile = AddCSLuaFileOverride,
		resource = {
			AddFile = funcPrinter,
			AddSingleFile = funcPrinter,
			AddWorkshop = funcPrinter,
		}
	}
end
