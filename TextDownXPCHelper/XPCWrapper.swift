//
//  XPCSWrapper.swift
//  TextDown
//
//  Created by adlerflow on 02/01/25.
//

import Foundation
import OSLog

class XPCWrapper {
    private static var connection: NSXPCConnection?
    private static var serviceAsync: TextDownXPCHelperProtocol?
    private static var serviceSync: TextDownXPCHelperProtocol?
    
    static func createNewConnection() -> NSXPCConnection {
        let connection = NSXPCConnection(serviceName: "org.advison.TextDownXPCHelper")
        connection.invalidationHandler = {
            guard !((connection.exportedObject as? TextDownXPCHelperProtocol)?.isHalted ?? false) else {
                return
            }
            os_log(
                "Unable to connect to TextDownXPCHelper service!",
                log: OSLog.quickLookExtension,
                type: .error
            )
            print("Unable to connect to TextDownXPCHelper service!")
        }
        
        connection.interruptionHandler = {
            os_log(
                "TextDownXPCHelper interrupted",
                log: OSLog.quickLookExtension,
                type: .error
            )
            
            print("TextDownXPCHelper interrupted!")
            connection.invalidate()
            if XPCWrapper.connection == connection {
                XPCWrapper.connection = nil
            }
        }
        connection.remoteObjectInterface = NSXPCInterface(with: TextDownXPCHelperProtocol.self)
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
    
    static func getAsynchronousService() -> TextDownXPCHelperProtocol? {
        if serviceAsync == nil {
            serviceAsync = getSharedConnection().remoteObjectProxyWithErrorHandler { error in
                print("Received error:", error)
                os_log(
                    "Async TextDownXPCHelper received error: %{public}s",
                    log: OSLog.quickLookExtension,
                    type: .error,
                    error.localizedDescription
                )
            } as? TextDownXPCHelperProtocol
        }
        return serviceAsync
    }
    
    static func getSynchronousService() -> TextDownXPCHelperProtocol? {
        if serviceSync == nil {
            serviceSync = getSharedConnection().synchronousRemoteObjectProxyWithErrorHandler { error in
                print("Received error:", error)
                os_log(
                    "Sync TextDownXPCHelper received error: %{public}s",
                    log: OSLog.quickLookExtension,
                    type: .error,
                    error.localizedDescription
                )
            } as? TextDownXPCHelperProtocol
        }
        return serviceSync
    }
}
