//
//  XPCSWrapper.swift
//  QLMarkdown
//
//  Created by adlerflow on 02/01/25.
//

import Foundation
import OSLog

class XPCWrapper {
    private static var connection: NSXPCConnection?
    private static var serviceAsync: QLMarkdownXPCHelperProtocol?
    private static var serviceSync: QLMarkdownXPCHelperProtocol?
    
    static func createNewConnection() -> NSXPCConnection {
        let connection = NSXPCConnection(serviceName: "org.advison.QLMarkdownXPCHelper")
        connection.invalidationHandler = {
            guard !((connection.exportedObject as? QLMarkdownXPCHelperProtocol)?.isHalted ?? false) else {
                return
            }
            os_log(
                "Unable to connect to QLMarkdownXPCHelper service!",
                log: OSLog.quickLookExtension,
                type: .error
            )
            print("Unable to connect to QLMarkdownXPCHelper service!")
        }
        
        connection.interruptionHandler = {
            os_log(
                "QLMarkdownXPCHelper interrupted",
                log: OSLog.quickLookExtension,
                type: .error
            )
            
            print("QLMarkdownXPCHelper interrupted!")
            connection.invalidate()
            if XPCWrapper.connection == connection {
                XPCWrapper.connection = nil
            }
        }
        connection.remoteObjectInterface = NSXPCInterface(with: QLMarkdownXPCHelperProtocol.self)
        connection.resume()
        return connection
    }
    
    static func getSharedConnection() -> NSXPCConnection {
        if connection == nil {
            connection = createNewConnection()
        }
        return connection!
    }
    
    static func invalidateSharedConnection() {
        serviceAsync?.shutdown()
        serviceAsync = nil
        
        serviceSync?.shutdown()
        serviceSync = nil
        
        connection?.invalidate()
        connection = nil
    }
    
    static func getAsynchronousService() -> QLMarkdownXPCHelperProtocol? {
        if serviceAsync == nil {
            serviceAsync = getSharedConnection().remoteObjectProxyWithErrorHandler { error in
                print("Received error:", error)
                os_log(
                    "Async QLMarkdownXPCHelper received error: %{public}s",
                    log: OSLog.quickLookExtension,
                    type: .error,
                    error.localizedDescription
                )
            } as? QLMarkdownXPCHelperProtocol
        }
        return serviceAsync
    }
    
    static func getSynchronousService() -> QLMarkdownXPCHelperProtocol? {
        if serviceSync == nil {
            serviceSync = getSharedConnection().synchronousRemoteObjectProxyWithErrorHandler { error in
                print("Received error:", error)
                os_log(
                    "Sync QLMarkdownXPCHelper received error: %{public}s",
                    log: OSLog.quickLookExtension,
                    type: .error,
                    error.localizedDescription
                )
            } as? QLMarkdownXPCHelperProtocol
        }
        return serviceSync
    }
}
