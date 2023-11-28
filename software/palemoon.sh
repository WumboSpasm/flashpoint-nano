external_signature=$(curl -Lsf "https://www.palemoon.org/download.php?mirror=sig&bits=64&type=linuxgtk3")
if [[ ! -f software/palemoon/palemoon.sig || $external_signature != $(cat software/palemoon/palemoon.sig) ]]; then
	echo $0: downloading latest Pale Moon release
	curl -Lsf "https://www.palemoon.org/download.php?mirror=us&bits=64&type=linuxgtk3" | unxz | tar xC software &> /dev/null
	echo "$external_signature" > software/palemoon/palemoon.sig
	mkdir -p software/palemoon/profile
fi

echo $0: launching $entry_launch_command using Pale Moon
./software/palemoon/palemoon --no-remote --profile software/palemoon/profile "$entry_launch_command"
