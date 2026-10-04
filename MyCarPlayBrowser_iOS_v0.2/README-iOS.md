# MyCarPlayBrowser iOS v0.2

Ez ugyanannak a **MyCarPlayBrowser** alkalmazásnak a natív iOS alapja. Nem külön CarPlay alkalmazás.

## Mi készült el
- Natív SwiftUI iPhone alkalmazás
- WKWebView alapú böngésző
- MyCarPlayBrowser szolgáltatás-katalógus
- kártyák / Add Card
- nyelv, téma, indulási oldal, Car Mode beállítások
- előzmények és kedvencek alap
- böngészőadatok törlése
- CarPlay scene ugyanebben az app targetben
- CarPlay kezdőfelület CPGridTemplate + CPListTemplate használatával
- iPhone buildhez nincs bekapcsolva a CarPlay Video entitlement, így a projekt előkészíthető normál iPhone tesztelésre
- külön `CarPlay-Entitlements-When-Approved.plist` maradt az Apple-jóváhagyás utáni bekapcsoláshoz

## Fontos
A CarPlay Video App jogosultsága Apple által kezelt entitlement (`com.apple.developer.carplay-video`). Apple szerint ezt a CarPlay jogosultsági folyamaton keresztül kell kérni; a jogosultság nem jár automatikusan. A Video App támogatott autókban, parkolt állapotban használható.

A jelenlegi CarPlay kód szándékosan a böngésző-böngészés alapját készíti elő. A WKWebView tartalmát nem lehet egyszerűen CarPlay-re kirakni. A tényleges videólejátszási részhez Apple által támogatott AirPlay/video playback architektúrát kell hozzáépíteni.

## Fordítás
Windows alatt nem lehet natívan iOS-re fordítani/aláírni. Mac + Xcode szükséges. Az Xcode projektet Windowsról elő lehet készíteni, majd Macen megnyitni, Signing & Capabilities alatt a saját Apple Accounttal aláírni és iPhone-ra telepíteni.
