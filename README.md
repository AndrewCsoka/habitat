# Habitat

If you use a laptop at work you might plug it in to a monitor and start some programs. You might then get sick of doing it every day. This aims to takes care of all that.

## Getting Started

See the example.conf file and edit it based on your requirements.

The actions taken are determined by the variables set in a config file. A present but empty variable will still trigger that action. For example, if WEBPAGES is an empty string, chrome will still be opened. If the variable is missing entirely from the config, that action will be skipped.

1. Switch to an external monitor as primary if present and set resolution
  * string
  * e.g. `PRIMARY_MONITOR='HDMI2'`
         `PRIMARY_MONITOR_RESOLUTION='1920x1080'`
         `SECONDARY_MONITOR='eDP1'`
         `SECONDARY_MONITOR_RESOLUTION='1368x768'`
2. Start Chrome with certain webpages in a certain profile
  * string
  * e.g. `WEBPAGES="mail.google.com google.com"`
3. Specify the chrome profile to be used
  * string
  * e.g. `CHROME_PROFILE="Default"`
4. Start some other programs
  * array
  * e.g. `PROGRAMS=( slack skype )`
5. Echo a file (e.g. todo list) to screen
  * string
  * e.g. `TODO_LIST='~/todo'`
6. Mute speakers
  * string
  * e.g. `MUTE_SPEAKERS='true'`
7. Enable Bluetooth
  * string
  * e.g. `BLUETOOTH='true'`

#### To find the Chrome profile you'd like to load:
 * `cat ~/.config/google-chrome/Local\ State | jq .profile`

## Running the script
`./habitat --config example.conf`

You may wish to have multiple config files if you use various desks.

Also, an alias might be handy:
  * `alias worksetup='habitat --config ~/.config/habitat/work.conf'`


## Authors

* **Andrew Csoka** - [AndrewCsoka](https://github.com/AndrewCsoka)

## License

This project is licensed under the GNU GPLv3 License - see the [LICENSE](LICENSE) file for details
