if [[ ! -f software/ruffle/build || $(find software/ruffle/ruffle -mtime +0) ]]; then
	external_build=$(curl -s https://api.github.com/repos/ruffle-rs/ruffle/releases?per_page=1 | grep -Eom1 '"Nightly .*?"')
	if [[ $external_build != $(cat software/ruffle/build 2> /dev/null) ]]; then
		echo $0: downloading latest Ruffle nightly
		mkdir -p software/ruffle
		curl https://github.com/$(curl -s https://api.github.com/repos/ruffle-rs/ruffle/releases?per_page=1 | grep -Eom1 ruffle-rs/.*?linux-x86_64.tar.gz) -Lsf | tar xzC software/ruffle &> /dev/null
		echo $external_build > software/ruffle/build
	fi
fi

echo $0: launching $entry_launch_command using Ruffle
./software/ruffle/ruffle --proxy http://127.0.0.1:22500 --no-gui "$entry_launch_command"
