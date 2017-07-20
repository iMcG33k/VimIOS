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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var file:String
        if (url.isFileURL) {
            // Opens file in place:
            file = url.path
        } else {
            // Path name can contain spaces
            file = url.path.replacingOccurrences(of: " ", with: "\\ ")
        }
        let inputURL =  URL(fileURLWithPath: file)
        
        guard inputURL.isFileURL else { return false }
        let share = inputURL.startAccessingSecurityScopedResource()
        if (!share) { return false }
        let doc:UIDocument = UIDocument(fileURL: inputURL)
        // Now the file is managed by vim
        let command = "tabedit " + file
        do_cmdline_cmd(command)
        do_cmdline_cmd("redraw!")
        do_cmdline_cmd("map <d-c> \"*y")
        do_cmdline_cmd("map <d-v> \"*p")
        return true
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

