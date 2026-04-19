import Alamofire
import UIKit
import SpriteKit
import AppTrackingTransparency


final class CairnRector: UIViewController {

    private var atrium: SKView?
    private var nexus: VesperNexus?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        view.backgroundColor = .black
        let skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        skView.backgroundColor = .black
        skView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skView)
        
        let dhuynq = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        dhuynq!.view.tag = 91
        dhuynq?.view.frame = UIScreen.main.bounds
        view.addSubview(dhuynq!.view)
        
        NSLayoutConstraint.activate([
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.atrium = skView
        let nexus = VesperNexus(vista: skView, reliquary: ReliquaryCodex.monad)
        self.nexus = nexus
        nexus.beckon(.foyer)
        
        let tabeyd = NetworkReachabilityManager()
        tabeyd?.startListening { state in
            switch state {
            case .reachable(_):
                let sdf = ObscureQuandaryView(frame: .zero)
                sdf.addSubview(UIView())
                tabeyd?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
