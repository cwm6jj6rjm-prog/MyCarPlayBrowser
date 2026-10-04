import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case en, de, hu, ru, uk
    var id: String { rawValue }
    var title: String {
        switch self { case .en: return "English"; case .de: return "Deutsch"; case .hu: return "Magyar"; case .ru: return "Русский"; case .uk: return "Українська" }
    }
}

enum AppTheme: String, CaseIterable { case dark, light }

struct Service: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let icon: String
    let url: String
}

enum Services {
    static let all: [Service] = [
        .init(id: "youtube", name: "YouTube", icon: "▶", url: "https://www.youtube.com/"),
        .init(id: "netflix", name: "Netflix", icon: "N", url: "https://www.netflix.com/"),
        .init(id: "disney", name: "Disney+", icon: "D+", url: "https://www.disneyplus.com/"),
        .init(id: "apple", name: "Apple TV", icon: "", url: "https://tv.apple.com/"),
        .init(id: "prime", name: "Prime Video", icon: "▶", url: "https://www.primevideo.com/"),
        .init(id: "google", name: "Google", icon: "G", url: "https://www.google.com/"),
        .init(id: "browser", name: "Browser", icon: "🌐", url: "https://www.google.com/"),
        .init(id: "spotify", name: "Spotify", icon: "●", url: "https://open.spotify.com/"),
        .init(id: "facebook", name: "Facebook", icon: "f", url: "https://www.facebook.com/"),
        .init(id: "tiktok", name: "TikTok", icon: "♪", url: "https://www.tiktok.com/"),
        .init(id: "gmail", name: "Gmail", icon: "✉", url: "https://mail.google.com/"),
        .init(id: "instagram", name: "Instagram", icon: "◎", url: "https://www.instagram.com/")
    ]
}

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    @Published var language: AppLanguage = .hu { didSet { save() } }
    @Published var theme: AppTheme = .dark { didSet { save() } }
    @Published var startup: String = "home" { didSet { save() } }
    @Published var carMode = false { didSet { save() } }
    @Published var autoCarMode = false { didSet { save() } }
    @Published var cards: [String] = [] { didSet { save() } }
    @Published var history: [HistoryItem] = [] { didSet { save() } }
    @Published var favorites: [HistoryItem] = [] { didSet { save() } }

    private init() { load() }
    private func save() {
        let d = UserDefaults.standard
        d.set(language.rawValue, forKey: "language")
        d.set(theme.rawValue, forKey: "theme")
        d.set(startup, forKey: "startup")
        d.set(carMode, forKey: "carMode")
        d.set(autoCarMode, forKey: "autoCarMode")
        d.set(cards, forKey: "cards")
        if let data = try? JSONEncoder().encode(history) { d.set(data, forKey: "history") }
        if let data = try? JSONEncoder().encode(favorites) { d.set(data, forKey: "favorites") }
    }
    private func load() {
        let d = UserDefaults.standard
        if let v = d.string(forKey: "language"), let x = AppLanguage(rawValue: v) { language = x }
        if let v = d.string(forKey: "theme"), let x = AppTheme(rawValue: v) { theme = x }
        startup = d.string(forKey: "startup") ?? "home"
        carMode = d.bool(forKey: "carMode")
        autoCarMode = d.bool(forKey: "autoCarMode")
        cards = d.stringArray(forKey: "cards") ?? []
        if let data = d.data(forKey: "history"), let x = try? JSONDecoder().decode([HistoryItem].self, from: data) { history = x }
        if let data = d.data(forKey: "favorites"), let x = try? JSONDecoder().decode([HistoryItem].self, from: data) { favorites = x }
    }
}

struct HistoryItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var url: String
    var date: Date
    init(title: String, url: String) { id = UUID(); self.title = title; self.url = url; date = Date() }
}

func t(_ key: String, _ language: AppLanguage) -> String {
    let values: [String: [AppLanguage: String]] = [
        "home": [.en:"Home", .de:"Startseite", .hu:"Kezdőlap", .ru:"Главная", .uk:"Головна"],
        "favorites": [.en:"Favorites", .de:"Favoriten", .hu:"Kedvencek", .ru:"Избранное", .uk:"Обране"],
        "history": [.en:"History", .de:"Verlauf", .hu:"Előzmények", .ru:"История", .uk:"Історія"],
        "bookmarks": [.en:"Bookmarks", .de:"Lesezeichen", .hu:"Könyvjelzők", .ru:"Закладки", .uk:"Закладки"],
        "settings": [.en:"Settings", .de:"Einstellungen", .hu:"Beállítások", .ru:"Настройки", .uk:"Налаштування"],
        "about": [.en:"About", .de:"Über", .hu:"Névjegy", .ru:"О приложении", .uk:"Про програму"],
        "browser": [.en:"Browser", .de:"Browser", .hu:"Böngésző", .ru:"Браузер", .uk:"Браузер"],
        "quick": [.en:"Quick access", .de:"Schnellzugriff", .hu:"Gyorselérés", .ru:"Быстрый доступ", .uk:"Швидкий доступ"],
        "add": [.en:"Add card", .de:"Karte hinzufügen", .hu:"Kártya hozzáadása", .ru:"Добавить карточку", .uk:"Додати картку"],
        "language": [.en:"Language", .de:"Sprache", .hu:"Nyelv", .ru:"Язык", .uk:"Мова"],
        "appearance": [.en:"Appearance", .de:"Darstellung", .hu:"Megjelenés", .ru:"Оформление", .uk:"Вигляд"],
        "startup": [.en:"Startup page", .de:"Startseite beim Start", .hu:"Indulási oldal", .ru:"Стартовая страница", .uk:"Сторінка запуску"],
        "carMode": [.en:"Car Mode", .de:"Auto-Modus", .hu:"Autó mód", .ru:"Авто-режим", .uk:"Авто-режим"],
        "clear": [.en:"Clear browser data", .de:"Browserdaten löschen", .hu:"Böngészőadatok törlése", .ru:"Очистить данные браузера", .uk:"Очистити дані браузера"],
        "cancel": [.en:"Cancel", .de:"Abbrechen", .hu:"Mégsem", .ru:"Отмена", .uk:"Скасувати"],
        "delete": [.en:"Delete", .de:"Löschen", .hu:"Törlés", .ru:"Удалить", .uk:"Видалити"]
    ]
    return values[key]?[language] ?? key
}
