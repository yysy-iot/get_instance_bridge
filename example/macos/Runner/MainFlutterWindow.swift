import Cocoa
import FlutterMacOS
import instance_bridge_core

final class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        InstancesManager.register(type: TestRepository.self)
        super.awakeFromNib()
    }
}
