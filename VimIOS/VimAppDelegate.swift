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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var url: URL?
        
        url = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL
        
        //Start Vim!
        performSelector(onMainThread: #selector(AppDelegate.VimStarter(_:)), with: url, waitUntilDone: false)
        return true
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:], completionHandler: ((Bool) -> Void)? = nil) {
        var file:String
        if (url.isFileURL) {
            // Opens file in place:
            file = url.path
        } else {
            // Can probably remove now?
            file = url.path.replacingOccurrences(of: " ", with: "\\ ")
        }
        let newUrl = NSURL.fileURL(withPath: file)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        var file:String
        if (url.isFileURL) {
            // Opens file in place:
            file = url.path
        } else {
            // Can probably remove now?
            file = url.path.replacingOccurrences(of: " ", with: "\\ ")
        }
        let newUrl = NSURL.fileURL(withPath: file)
        // Step 1: reveal the file
        guard let documentBrowserViewController = window?.rootViewController as? VimViewController else { return false }
        
        documentBrowserViewController.revealDocument(at: newUrl, importIfNeeded: true) {
            (revealedDocumentURL, error) in
            guard error == nil else {
                os_log("Failed to reveal the document at %@. Error: %@",
                       log: OSLog.default,
                       type: .error,
                       url as CVarArg,
                       error! as CVarArg)
                return
            }
            
            guard let revUrl = revealedDocumentURL else {
                os_log("No URL revealed",
                       log: OSLog.default,
                       type: .error)
                
                return
            }
            
            // You can do something
            // with the revealed document here...
            os_log("Revealed URL: %@",
                   log: OSLog.default,
                   type: .debug,
                   revUrl.path)
            // Step 2: "open" the file (documentViewController doesn't exist, so break)
            let document = UIDocument(fileURL: newUrl)
            document.open(completionHandler: { (success) in
                if success {
                    // Display the content of the document, e.g.:
                    // self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
                } else {
                    // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
                }
            })
        }
        // Now the file is managed by vim
        let command = "tabedit " + file
        do_cmdline_cmd(command)
        do_cmdline_cmd("redraw!".char)
        do_cmdline_cmd("map <d-c> \"*y")
        do_cmdline_cmd("map <d-v> \"*p")
        return true
        // return false
    }
    
    
    func VimStarter(_ url: URL?) {
        guard let vimPath = Bundle.main.resourcePath else {return}
        let runtimePath = vimPath + "/runtime"
        vim_setenv("VIM".char, vimPath.char)
        vim_setenv("VIMRUNTIME".char, runtimePath.char)
        //            print("VimPath: \(vimPath)")
        //            print("VimRuntime: \(runtimePath)")
        let homeDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("homeDir: \(homeDir)")
        
        vim_setenv("HOME".char, homeDir.char)
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
