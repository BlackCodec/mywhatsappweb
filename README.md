# MyWhatsAppWeb
My WhatsApp Web application rewrite in vala with support for multiple session.

Startup parameters:

 - --session=session_name: to start a specific session (if not specified the default session name is "default")
 - --incognito: to start a session that does not store anything on disk (like a private session)
 - --level=level_to_set: set the logger level to the specified level. Possible values are: none, error, info, debug. If not specified the default value is error
---

## Installation

### Using script

Launch the script *install.sh* if you want to install globally with sudo.

### Manual installation

 - Copy the icon mywhatsappweb.png in $HOME/.local/share/icons/ or /usr/share/icons/ .
 - Copy the file in bin (or the file that you compile with build.sh script) in ${HOME}/.local/bin/ or /usr/local/bin/ and make sure you have that folder in your $PATH env variable.
 - Check also that the bin is executable.
 - Replace @image_path@ in mywhatsappweb.desktop file with the path where you put the icon in the previous step.
 - Replace @bin_path@ in mywhatsappweb.desktop file with the path where you put the bin file in the previous step.
 - Copy the desktop file mywhatsappweb.desktop in $HOME/.local/share/applications/ or /usr/share/applications/ .

### How to build

From source use the *build.sh* script.

You need vala with libnotify, gtk+ 3.0 and webkit2gtk-4.0.

---

## Release

**Latest: 20230504.1000**

### History

#### 20230504.1000
 - Add support for show number of unread notification on icon in tray


#### 20230404.1430
 - Add support for close to tray options from the tray menu
 - Implemented logging class and level (also as startup parameter)
 - Support for store configurations per session
 - Click on tray icon now hide or show the window based on the current window status


#### 20230314.1600
 - First release for this vala version
