# VimIOS - A port of Vim to iOS 9+

*Disclaimer*: This is a side project of mine - no promises and no warranties. If you like it, feel free to let me know, and please feel free to improve on it, there is a lot to do.

This project is based on the [Vim port of applidium](https://github.com/applidium/Vim), which has been inactive for a few years. Nonetheless, it is a full working port of Vim. However, in the meantime iOS has gained many features of which this port did not take advantage. I rewrote large parts of it with the goal of improving the Vim experience under iOS 9, in particular on iPads with an external keyboard. This latest version includes "open-in-place", an iOS 11 feature.

The new key features are:

* Split View and Slide Over support
* Full external keyboard support
* Importing and exporting files from Vim to other apps is now possible. 
* Open-in-place is now possible (open files inside other apps sandboxes)
* The app now looks great on retina displays.
* Upgrade to Vim 7.4

## Acknowledgements
Obviously, I used the code of [Applidiums Vim port](https://github.com/applidium/Vim), and Vim itself. I had to make minor changes in the Vim source code a few times, so I include a modified version of the [Vim code base](https://github.com/vim/vim). Note that Vim is charity ware, see [here for the Vim license](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license). The app icon was taken from [here](http://usevim.com/2014/07/25/flat-vim-icons/).

## Setup
Clone the repository and use XCode to compile it for your iOS 11+ device. 

## Usage
Open the app and just start typing. If you have an external keyboard, you should be all set. If you need an escape key, or F1, longpress anywhere on the screen. This will open a tool bar with a few buttons. But instead of escape, you can also use `<C-[>`. 

You can get this help by using the command `:help ios`.

### File management.
This version of Vim comes with a version of the netrw file browser. Use the command `Explore .` to start it. You will likely see the following items:

```
.vim/
Inbox/
.viminfo
.vimrc
```
If `.vimrc` does not exist, you can create it, if you wish. 

You can write your files anywhere inside the "Documents" folder, except for the `Inbox/` folder.
Use `F1` to get help on how to use the file browser. You can create directories with `d` and delete directories/files with `D'. 

All swap files are in ../Documents/.vim/swapfiles (because we can't put them next to the files if we open-in-place). You will have to create the "swapfiles" folder. 

The default configuration file is "vimrc", inside "VimIOS/resources" folder in the source code. If you are sideloading, it might be easier to edit it on the Mac side. 

### Open-In-Place

If you want to open files that are in the sandbox of another app, simply type 
* :Import 
It will open a document browser that lets you access files on iCloud and on your iOS device, including files in other apps sandboxes. 

In reverse, you can also access files in Vim sandbox from other apps, and from iTunes. 

Vim places a lock on each file as it opens it, and releases it every time the app goes in the background. To avoid surprises, all open files are saved every time the app goes in the background. Simply closing the file with `:w` does not release the lock (because Vim keeps the buffer available). If you really want to close the buffer and release the file, you have to use `:bd` (buffer delete). 

### Importing files from other applications
From another app, if you click on "Share" or "Export", you can chose "Open in VimIOS". In that case, the file will also be opened in place, inside your other app sandbox. 

If the other app does not support "Open-In-Place", the file will be copied to VimIOS  "Documents" folder. 

Files copied from iTunes will also appear in the "Documents" folder, and you can copy them back. 

## Exporting files to other applications
I added two commands to commands to Vim which allow you to export files.
 
* `:Share` opens the standard iOS dialog "Open in other app". You can also export your file via Airdrop.
* `:Mail` opens a slightly different dialog, which allows you to export your text as the body of an email. 

## Customization
In the `.vim` folder (create it, if it doesn't exist), you can add plugins and themes as usual. I have not tested many plugins; obviously those utilizing many features external to Vim will not work, as iOS does not provide a shell to Vim.

You can create and customize a `.vimrc` file as usual. Some graphical features will probably not work. 

## Todo
* Add iOS alerts for the dialogs and popups. 
* Add the ability to open a file from another application. Opening the "vim://path/to/file/" already starts Vim, but it doesn't get the right to access the file. 

