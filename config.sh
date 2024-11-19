gamedata_path="games"
legacy_path="games/legacy"
database_file="database/flashpoint.sqlite"
gameserver_file="software/server/FlashpointGameServer"

gamedata_sources=(
	"https://download.unstable.life/gib-roms/Games"
	"https://unstable.life/updater-data/12-1/Data/Games"
	"https://infinity.unstable.life/Flashpoint/Data/Games"
)
database_sources=(
	"https://download.unstable.life/flashpoint.sqlite"
	"https://unstable.life/updater-data/12-1/Data/flashpoint.sqlite"
	"https://infinity.unstable.life/Flashpoint/Data/flashpoint.sqlite"
)

platform_overrides=(
	"HTML5" "software/palemoon.sh"
)
application_path_overrides=(
	"^FPSoftware/Flash/" "software/ruffle.sh"
)
launch_command_overrides=(
	"\.swf($|\?)" "software/ruffle.sh"
)
