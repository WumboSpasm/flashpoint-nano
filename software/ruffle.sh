if [[ ! -f software/ruffle/ruffle || $(find software/ruffle/ruffle -mtime +1) ]]; then
	echo $0: downloading latest Ruffle nightly
	[[ ! -d software/ruffle ]] && mkdir -p software/ruffle
	curl https://github.com/$(curl -s https://api.github.com/repos/ruffle-rs/ruffle/releases?per_page=1 | grep -Eom1 ruffle-rs/.*?linux-x86_64.tar.gz) -Lsf | tar xzC software/ruffle &> /dev/null
fi

echo $0: launching $entry_launch_command using Ruffle
./software/ruffle/ruffle --proxy http://127.0.0.1:22500 --no-gui "$entry_launch_command"
