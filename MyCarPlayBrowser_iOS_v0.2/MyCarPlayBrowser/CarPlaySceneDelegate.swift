import CarPlay
import UIKit

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
            CPGridButton(titleVariants: [service.name], image: UIImage(systemName: icon(for: service.id)) ?? UIImage(systemName: "globe")!) { [weak self] _ in
                self?.showService(service)
            }
        }
        return CPGridTemplate(title: "MyCarPlayBrowser", gridButtons: buttons)
    }

    private func showService(_ service: Service) {
        let open = CPListItem(text: service.name, detailText: "Open on iPhone")
        open.handler = { [weak self] _, completion in
            completion()
            self?.interfaceController?.popTemplate(animated: true)
        }
        let home = CPListItem(text: "Back to MyCarPlayBrowser", detailText: service.url)
        home.handler = { _, completion in completion() }
        interfaceController?.pushTemplate(CPListTemplate(title: service.name, sections: [CPListSection(items: [open, home])]), animated: true)
    }

    private func icon(for id: String) -> String {
        switch id {
        case "youtube": return "play.rectangle.fill"
        case "netflix": return "tv.fill"
        case "disney": return "sparkles.tv.fill"
        case "apple": return "apple.logo"
        case "prime": return "play.tv.fill"
        case "spotify": return "music.note"
        case "google": return "magnifyingglass"
        case "browser": return "safari.fill"
        default: return "globe"
        }
    }
}
