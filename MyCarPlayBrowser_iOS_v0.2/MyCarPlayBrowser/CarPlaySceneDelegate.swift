import CarPlay
import UIKit

/// CarPlay interface for the same MyCarPlayBrowser app.
/// No second/car-only app is created.
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private weak var interfaceController: CPInterfaceController?

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        interfaceController.setRootTemplate(makeRootTemplate(), animated: false)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    private func makeRootTemplate() -> CPTemplate {
        let services = Array(Services.all.prefix(8))
        let buttons = services.map { service in
            CPGridButton(
                titleVariants: [service.name],
                image: UIImage(systemName: icon(for: service.id)) ?? UIImage(systemName: "globe")!
            ) { [weak self] _ in
                self?.showService(service)
            }
        }
        return CPGridTemplate(title: "MyCarPlayBrowser", gridButtons: buttons)
    }

    private func showService(_ service: Service) {
        let item = CPListItem(
            text: service.name,
            detailText: "Open on iPhone to browse this service."
        )
        item.handler = { [weak self] _, completion in
            completion()
            // A CarPlay template cannot simply embed a normal WKWebView.
            // Native video/AirPlay playback will be connected in the video phase.
            self?.interfaceController?.popTemplate(animated: true)
        }
        let list = CPListTemplate(
            title: service.name,
            sections: [CPListSection(items: [item])]
        )
        interfaceController?.pushTemplate(list, animated: true)
    }

    private func icon(for id: String) -> String {
        switch id {
        case "youtube": return "play.rectangle.fill"
        case "netflix": return "play.tv.fill"
        case "disney": return "play.tv.fill"
        case "apple": return "apple.logo"
        case "prime": return "play.tv.fill"
        case "spotify": return "music.note"
        case "google": return "magnifyingglass"
        case "browser": return "globe"
        case "gmail": return "envelope.fill"
        case "instagram": return "camera.fill"
        case "facebook": return "person.2.fill"
        default: return "play.tv.fill"
        }
    }
}
