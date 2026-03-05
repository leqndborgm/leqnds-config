# NixOS Konfigurationsdokumentation

Diese Dokumentation beschreibt die Struktur und die Verwendung der NixOS Konfiguration im Repository `leqnds-config`.

## Ordnerstruktur

```plaintext
leqnds-config/
├── configuration.nix  # Hauptkonfigurationsdatei für das NixOS-System
├── hardware-configuration.nix  # Hardware-spezifische Einstellungen
├── modules/  # Enthält verschiedene Module für spezifische Funktionen
│   └── example-module.nix  # Beispielmodul
└── services/  # Enthält konfigurationsbezogene Servicedateien
    └── example-service.nix  # Beispielservice
```

## Verwendung von zaneyos

Das Projekt verwendet `zaneyos`, ein NixOS-Framework zur einfachen Verwaltung von Konfigurationen. Weitere Informationen finden Sie in der [zaneyos-Dokumentation](https://github.com/zaneyos).

Viel Spaß beim Konfigurieren von NixOS!