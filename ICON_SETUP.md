# Configuração do Ícone do LoadStock

## Descrição do Ícone
O ícone do LoadStock deve ser um símbolo de "Load" (carregamento/carga) com a letra "S" no meio, representando "Stock" (estoque).

## Design Sugerido
- Ícone circular ou arredondado
- Símbolo de setas circulares (representando "load"/carregamento)
- Letra "S" estilizada no centro
- Cores: Azul primário (#2563EB) e branco

## Como Adicionar o Ícone

### Opção 1: Usando flutter_launcher_icons (Recomendado)

1. Adicione a dependência no `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

2. Configure no `pubspec.yaml`:
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#2563EB"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

3. Coloque sua imagem do ícone (1024x1024 px) em `assets/icon/app_icon.png`

4. Execute:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### Opção 2: Manual

#### Android
Substitua os arquivos em:
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

#### iOS
Substitua os arquivos em:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

#### Web
Substitua:
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`
- `web/favicon.png`

## Ferramentas para Criar o Ícone

1. **Figma** - https://figma.com (Design profissional)
2. **Canva** - https://canva.com (Fácil de usar)
3. **Icon Kitchen** - https://icon.kitchen (Gerador de ícones Android)
4. **App Icon Generator** - https://appicon.co (Gera todos os tamanhos)

## Exemplo de Prompt para IA (DALL-E, Midjourney, etc.)

"Create a modern app icon for a POS (Point of Sale) system called LoadStock. The icon should feature circular loading arrows in blue (#2563EB) with a stylized letter 'S' in the center. Clean, minimalist design with a white background. Professional and modern look. 1024x1024 pixels."
