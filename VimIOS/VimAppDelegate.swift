//
//  AppDelegate.swift
//  VimIOS
//
//  Created by Lars Kindler on 27/10/15.
//  Copyright © 2015 Lars Kindler. All rights reserved.
//

import UIKit

import os.log

@UIApplicationMain
//
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var url: URL?
        
        url = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL
        
        //Start Vim!
        performSelector(onMainThread: #selector(AppDelegate.VimStarter(_:)), with: url, waitUntilDone: false)
        return true
        
    }
    
    
    func uniqueFileName(_ application: UIApplication, target:URL) -> URL {
        let ext = target.pathExtension
        let basename = target.deletingPathExtension()
        var nameSuffix = 1
        var newTarget = target
        
        do {
            while try newTarget.checkPromisedItemIsReachable() {
                newTarget = URL(fileURLWithPath: basename.path + "-\(nameSuffix)." + ext)
                nameSuffix += 1
            }
        } catch {
            print("Could not create unique filename for ", target, " Error = ", [error .localizedDescription])
            return URL(fileURLWithPath: "")
        }
        return newTarget
    }
    
    
    func application(_ app: UIApplication, open openURL: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let shouldOpenInPlace:Bool = (options[UIApplicationOpenURLOptionsKey.openInPlace] != nil);
        var newURL = openURL
        if (openURL.scheme == "vim") {
            // I need to change the URL scheme from vim:// to file://
            var components = URLComponents(url: openURL, resolvingAgainstBaseURL: false)
            components?.scheme = "file";
            newURL = (components?.url)!
            // This doesn't work because openURL contains permission flags
            // But when it does, it'll be awesome
        }
        if (newURL.isFileURL) {
            if (shouldOpenInPlace) {
                if (newURL.startAccessingSecurityScopedResource()) {
                    let vc:VimViewController = app.keyWindow?.rootViewController as! VimViewController
                    vc.urls.append(newURL)
                    let filename = newURL.path.replacingOccurrences(of: " ", with: "\\ ")
                    // Now the file is managed by vim
                    let command = "tabedit " + filename
                    do_cmdline_cmd(command)
                    do_cmdline_cmd("redraw!")
                    do_cmdline_cmd("map <d-c> \"*y")
                    do_cmdline_cmd("map <d-v> \"*p")
                    return true
                } else { return false }
            }
            // Can't open in place, so must import
            // Can't test this on iOS 11 -- you either have permission or you don't
            let uniquePath = uniqueFileName(app, target: newURL)
            // Coordinate reading on the source path and writing on the destination path to copy.
            let readIntent = NSFileAccessIntent.readingIntent(with: newURL, options: [])
            let writeIntent = NSFileAccessIntent.writingIntent(with: uniquePath, options: .forReplacing)
            let coordinationQueue = OperationQueue()
            coordinationQueue.name = "com.applidium.vim-import.coordinationQueue"
            NSFileCoordinator().coordinate(with: [readIntent, writeIntent], queue: coordinationQueue) { error in
                if error != nil {
                    return
                }
                do {
                    try FileManager.default.copyItem(at: readIntent.url, to: writeIntent.url)
                    let filename = writeIntent.url.path.replacingOccurrences(of: " ", with: "\\ ")
                    // Now the file is managed by vim
                    let command = "tabedit " + filename
                    do_cmdline_cmd(command)
                    do_cmdline_cmd("redraw!")
                    do_cmdline_cmd("map <d-c> \"*y")
                    do_cmdline_cmd("map <d-v> \"*p")
                    return
                }
                catch {
                    fatalError("Unexpected error during trivial file operations: \(error)")
                }
            }
            return true
        }
        return false
    }

    func VimStarter(_ url: URL?) {
        guard let vimPath = Bundle.main.resourcePath else {return}
        let runtimePath = vimPath + "/runtime"
        vim_setenv("VIM", vimPath)
        vim_setenv("VIMRUNTIME", runtimePath)
        //            print("VimPath: \(vimPath)")
        //            print("VimRuntime: \(runtimePath)")
        let homeDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("homeDir: \(homeDir)")
        
        vim_setenv("HOME", homeDir)
        FileManager.default.changeCurrentDirectoryPath(homeDir)
        // vim_setenv("SHARED".char, sharedWorkingDir.char)
        // FileManager.default.changeCurrentDirectoryPath(sharedWorkingDir)
        
        var numberOfArguments = 0
        var file: String?

        if let url = url, url.isFileURL {
            let filename = url.lastPathComponent
            // iOS 11:
            file = filename
            numberOfArguments += 1
        }
        vimHelper(Int32(numberOfArguments),file)
    }
    
}




extension String {
    // In Swift 3 compiler automatically translates String to "const char *"
    var char: String {
        return self
    }
    
    func each(_ closure: (String) -> Void ) {
        for digit in self.characters
        {
            closure(String(digit))
        }
    }
    
}

