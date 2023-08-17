#!/usr/bin/env bash

showHelp () {
    echo "Usage:";
    echo;
    echo "  `basename $0` <command>";
    echo;
    echo "Commands:";
    echo;
    echo "  init                         # initializes the application & creates a skiplist";
    echo "  add <name>                   # Adds the song to skiplist";
    echo "  add current                  # Adds the current song to the skiplist";
    echo "  show                         # Outputs the skipfile";
    echo;
    showAPIHelp
}

# Function to get the currently playing song from Spotify
current_song() {
    osascript -e 'tell application "Spotify" to return name of current track & "," & album of current track & "," & artist of current track'
}

# Initial song
previous_song=$(current_song)

skiplist="skiplist.csv"

if [ ! -f "$skiplist" ]; then
    touch skiplist.csv
    echo "Your skiplist has been created!"
fi



#Running without arguments
if [ $# = 0 ]; then
    # Loop to monitor for changes
    while true; do
        current_song=$(current_song)
    
        if [ "$current_song" != "$previous_song" ]; then
            echo "Now playing: $current_song"
            previous_song="$current_song"
        fi
        
        #Searching for the song in list
        grep_result=$(grep -F "$current_song" "$skiplist")

        if [ -n "$grep_result" ]; then
            echo "Skip worthy song found, going to next track." ;
            osascript -e 'tell application "Spotify" to next track';
        fi

        sleep 5  # Checks every 60 seconds
done
#Check if spotify is installed
else
	if [ ! -d /Applications/Spotify.app ] && [ ! -d $HOME/Applications/Spotify.app ]; then
		echo "The Spotify application must be installed."
		exit 1
	fi

    if [ $(osascript -e 'application "Spotify" is running') = "false" ]; then
        osascript -e 'tell application "Spotify" to activate' || exit 1
        sleep 2
    fi
fi
#Running with arguments
while [ $# -gt 0 ]; do
    arg=$1;

    case $arg in
        "add"    )
            if [ "$2" = "current" ]; then
                current_song=$(current_song)
                echo "$current_song" >> "$skiplist"
            else
            # adds the second argument(song/album/artist) to csv file
                echo "$2," >> "$skiplist"
                if [ $# = 1 ]; then
                    echo "Enter which song you want to add to skiplist"
                fi
            fi
            break ;;

        "show"    )
            cat "$skiplist"

        
            if [ $# != 1 ]; then
                # There are additional arguments, they shouldn't be
                showHelp;

            fi
            break ;;

        "help" )
            showHelp;
            break ;;
        * )
            showHelp;
            exit 1;

    esac
done