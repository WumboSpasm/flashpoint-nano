source config.sh

function error_unspecified_id {
	echo $0: no ID was specified
	exit 1
}
function error_invalid_id {
	echo $0: no entry with ID $entry_id exists in the database
	exit 1
}
function error_invalid_database {
	echo $0: the database located at $database_file does not exist or is invalid
	exit 1
}
function error_unsupported_entry {
	echo $0: no applicable overrides for entry with ID $entry_id
	exit 1
}
function error_all_downloads_failed {
	echo $0: all attempts to download $1 were unsuccessful
	exit 1
}

[[ ${#1} == 0 ]] && error_unspecified_id
entry_id=$1
addapp_id=$2

[[ ! -d $database_file ]] && mkdir -p "${database_file%/*}"
if [[ ! -f $database_file ]]; then
	for database_source in ${database_sources[@]}; do
		echo $0: downloading $database_source
		curl "$database_source" -sfo "$database_file"
		
		[[ $? == 0 ]] && break
		echo $0: failed to download from desired source
	done
	
	[[ ! -f $database_file ]] && error_all_downloads_failed "$database_file"
fi

echo $0: querying database for entry properties corresponding to ID $entry_id
entry_query=$(sqlite3 --separator $'\n' "file:${database_file}?mode=ro" ".param set :id $entry_id" "select game_data.path, game.platformName, coalesce(game_data.applicationPath, game.applicationPath), coalesce(game_data.launchCommand, game.launchCommand) from game left join game_data on game.id = game_data.gameId where game.id = :id" 2> /dev/null)
[[ $? > 0 ]] && error_invalid_database

readarray -t entry_properties <<< $entry_query
[[ ${#entry_properties[@]} == 0 ]] && error_invalid_id

entry_is_legacy=false
[[ ${#entry_properties[0]} == 0 ]] && entry_is_legacy=true

entry_gamedata_file=${entry_properties[0]}
entry_primary_platform=${entry_properties[1]}
entry_application_path=${entry_properties[2]//\\//}
entry_launch_command=${entry_properties[3]}

if [[ ${#addapp_id} > 0 ]]; then
	echo $0: querying database for additional app properties corresponding to ID $addapp_id
	addapp_query=$(sqlite3 --separator $'\n' "file:${database_file}?mode=ro" ".param set :id $addapp_id" "select applicationPath, launchCommand from additional_app where id = :id" 2> /dev/null)
	
	readarray -t addapp_properties <<< $addapp_query
	if [[ ${#addapp_properties[@]} > 0 ]]; then
		entry_application_path=${addapp_properties[0]//\\//}
		entry_launch_command=${addapp_properties[1]}
	fi
fi

found_match=false
for i in $(seq 0 2 $((${#launch_command_overrides[@]}-1))); do
	if echo $entry_launch_command | grep -E "${launch_command_overrides[$i]}" > /dev/null; then
		entry_application_path=${launch_command_overrides[$(($i+1))]}
		found_match=true
		break
	fi
done
for i in $(seq 0 2 $((${#application_path_overrides[@]}-1))); do
	if echo $entry_application_path | grep -E "${application_path_overrides[$i]}" > /dev/null; then
		entry_application_path=${application_path_overrides[$(($i+1))]}
		found_match=true
		break
	fi
done
for i in $(seq 0 2 $((${#platform_overrides[@]}-1))); do
	if [[ $entry_primary_platform == ${platform_overrides[$i]} ]]; then
		entry_application_path=${platform_overrides[$(($i+1))]}
		found_match=true
		break
	fi
done
[[ $found_match == false ]] && error_unsupported_entry

if [[ $entry_is_legacy == false ]]; then
	[[ ! -d $gamedata_path ]] && mkdir -p "$gamedata_path"
	if [[ ! -f "$gamedata_path/$entry_gamedata_file" ]]; then
		for gamedata_source in ${gamedata_sources[@]}; do
			echo $0: downloading $gamedata_source/$entry_gamedata_file
			curl "$gamedata_source/$entry_gamedata_file" -sfo "$gamedata_path/$entry_gamedata_file"
		
			[[ $? == 0 ]] && break
			echo $0: failed to download from desired source
		done

		[[ ! -f "$gamedata_path/$entry_gamedata_file" ]] && error_all_downloads_failed "$entry_gamedata_file"
	fi
fi

echo $0: initializing game server
(
	trap "kill 0" SIGINT
	exec "./$gameserver_file" -rootPath= -gameRootPath="$gamedata_path" -legacyHTDOCSPath="$legacy_path" -handleLegacyRequests=true -useInfinityServer=true &
	[[ $entry_is_legacy == false ]] && curl -X POST -d "{\"filePath\":\"$entry_gamedata_file\"}" http://localhost:22501/fpProxy/api/mountzip &
	source "./$entry_application_path" &
	wait
)
