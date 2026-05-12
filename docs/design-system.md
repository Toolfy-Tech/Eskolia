# Eskolia — Design System

> Dernière mise à jour : 2026-05-07  
> Thème unique : **Dark only** (pas de light mode)

---

## Palette de couleurs

Fichier source : `lib/core/constants/colors.dart`

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#6C63FF` | Violet — CTA principal, accents, liens |
| `secondary` | `#FF6584` | Rose/magenta — CTA secondaire, badges |
| `accent` | `#43E97B` | Vert néon — succès, progression, streak |
| `background` | `#0F0F1A` | Fond d'écran (navy très sombre) |
| `surface` | `#1A1A2E` | Fond des cartes et dialogues |
| `textPrimary` | `#FFFFFF` | Texte principal |
| `textSecondary` | `#B0B0C3` | Texte secondaire, labels, placeholders |

### Couleurs additionnelles (définies dans `app_theme.dart`)

| Usage | Valeur |
|-------|--------|
| `error` (colorScheme) | `#FF5252` |
| `overlay` (input fill) | `#FFFFFF14` (blanc 8 %) |
| `borderGlass` | `#FFFFFF33` (blanc 20 %) |
| `borderGlassFocused` | `#6C3CE180` (violet 50 %) |
| Divider | `textSecondary` à 25 % opacité |
| Progress track | `#FFFFFF22` (blanc 13 %) |

---

## Typographie

Fichier source : `lib/core/constants/typography.dart`

| Style | Fonte | Taille | Poids | Line height | Letter spacing |
|-------|-------|--------|-------|-------------|----------------|
| `display` | Poppins | 40 px | Bold (700) | 1.15 | -0.5 |
| `h1` | Poppins | 32 px | Bold (700) | 1.20 | -0.25 |
| `h2` | Poppins | 24 px | Bold (700) | 1.25 | — |
| `h3` | Poppins | 20 px | Bold (700) | 1.30 | — |
| `body` | Inter | 16 px | Regular (400) | 1.50 | — |
| `caption` | Inter | 12 px | Regular (400) | 1.35 | — |
| `label` | Poppins | 14 px | SemiBold (600) | 1.20 | +0.2 |

**Mapping Material TextTheme :**
- `displayLarge` → `display()`
- `headlineLarge` → `h1()`
- `headlineMedium` → `h2()`
- `headlineSmall` → `h3()`
- `bodyLarge` → `body()`
- `bodySmall` → `caption()`
- `labelLarge` → `label()`

Toutes les fontes viennent de `google_fonts` (chargées réseau + cache).

---

## Thème Material (`AppTheme.dark`)

Fichier source : `lib/core/theme/app_theme.dart`

| Composant | Spec |
|-----------|------|
| `useMaterial3` | `true` |
| `brightness` | `dark` |
| `scaffoldBackgroundColor` | `background` (#0F0F1A) |
| `AppBarTheme` | Transparent, elevation 0, titre `h3()` |
| `CardTheme` | `surface`, radius 20, elevation 0, no shadow |
| `InputDecorationTheme` | Fill `overlay`, radius 16, border glass |
| `SnackBarTheme` | `surface`, radius 12, floating |
| `DialogTheme` | `surface`, radius 20 |
| `DividerTheme` | `textSecondary` à 25 % |
| `ProgressIndicatorTheme` | color = `accent`, track = blanc 13 % |
| `IconButtonTheme` | min 48×48 px |

### Boutons

| Type | Fond | Texte | Radius | Padding |
|------|------|-------|--------|---------|
| `ElevatedButton` (primary) | `primary` violet | blanc | 16 | 24×14 |
| `FilledButton` (secondary) | `secondary` rose | blanc | 16 | 24×16 |
| `OutlinedButton` (ghost) | transparent | blanc | 16 | 24×14, bordure grise 45 % |
| `TextButton` | transparent | `primary` | — | — |

---

## Extensions de thème

Fichier source : `lib/core/theme/app_theme_extensions.dart`

### `GlassmorphismTheme`
Accédé via `Theme.of(context).extension<GlassmorphismTheme>()!`

| Propriété | Valeur |
|-----------|--------|
| `glassColor` | `surface` à 12 % opacité |
| `borderColor` | `primary` à 35 % opacité |
| `blur` | 14 (sigma BackdropFilter) |

### `NeonTheme`
Accédé via `Theme.of(context).extension<NeonTheme>()!`

| Propriété | Valeur |
|-----------|--------|
| `neonColor` | `primary` (#6C63FF) |
| `shadowColor` | `primary` (#6C63FF) |
| `intensity` | 1.0 |

---

## Layout constants

Fichier source : `lib/core/theme/eskolia_layout.dart`

| Constante | Valeur | Usage |
|-----------|--------|-------|
| `screenPaddingH` | 20.0 | Padding horizontal des écrans |
| `screenPaddingTop` | 8.0 | |
| `screenPaddingBottom` | 28.0 | |
| `minTouchTarget` | 48.0 | Taille minimale boutons/icônes |
| `contentMaxWidth` | 560.0 | Max width contenu mobile |
| `shellContentMaxWidth` | 920.0 | Max width shell desktop |
| `lessonDesktopMaxWidth` | 1120.0 | Max width leçon desktop |
| `cardRadius` | 20.0 | BorderRadius des cartes |
| `primaryButtonMinHeight` | 52.0 | Hauteur minimale bouton principal |

---

## Composants réutilisables (`lib/shared/widgets/`)

| Composant | Fichier | Description |
|-----------|---------|-------------|
| `EskoliaCard` | `eskolia_card.dart` | Carte glassmorphism avec BackdropFilter (blur 14), border glass, shadow douce. Paramètres : `borderRadius` (défaut 20), `padding`, `margin`. |
| `EskoliaButton` | `eskolia_button.dart` | Bouton avec lueur néon extérieure (`NeonTheme`). Variantes : `primary`, `secondary`, `ghost`. Props : `label`, `icon`, `expand`. |
| `GradientBorderCard` | `gradient_border_card.dart` | Carte avec bordure dégradée (gradient violet → rose). |
| `EskoliaGradientText` | `eskolia_gradient_text.dart` | Texte avec dégradé (LinearGradient `primary` → `secondary`). |
| `EskoliaAppBar` | `eskolia_app_bar.dart` | AppBar transparent customisé avec logo et action icônes. |
| `EskoliaShellBody` | `eskolia_shell_body.dart` | Wrapper de contenu avec padding horizontal et max width. |
| `EskoliaTextField` | `eskolia_text_field.dart` | Champ texte stylisé avec `InputDecorationTheme` glass. |
| `EskoliaLessonMarkdown` | `eskolia_lesson_markdown.dart` | Rendu markdown pour leçons Optimus (titres Poppins, code, images). |
| `EskoliaFlipCard` | `eskolia_flip_card.dart` | Carte retournable avec animation 3D (pour flashcards). |
| `EskoliaAmbientBackground` | `eskolia_ambient_background.dart` | Fond animé avec particules/gradients ambiants. |
| `UserStatusPill` | `user_status_pill.dart` | Pill compact affichant niveau + XP + streak de l'utilisateur. |

---

## Style glassmorphism

Le glassmorphism est utilisé dans **tous les écrans** via `EskoliaCard` et les overlays :

- **BackdropFilter** avec `ImageFilter.blur(sigmaX: 14, sigmaY: 14)`
- Fond semi-transparent : `surface` à 12 % (`#1A1A2E1F`)
- Bordure : `primary` à 35 % (`#6C63FF59`)
- Shadow douce : border color à 22 %, blurRadius 24, spreadRadius -4, offset (0, 8)
- Clip `antiAlias` sur `ClipRRect(borderRadius: 20)`

---

## Animations

### `flutter_animate` (^4.5.2)
Utilisé massivement dans les écrans pour les entrées/sorties :
- `.animate().fadeIn(duration: 300ms)`
- `.animate().slideY(begin: 0.2, end: 0.0)`
- `.animate().scale(begin: Offset(0.9, 0.9))`
- Combinaison `.then()` pour chaîner les animations

### `lottie` (^3.3.3)
Animations vectorielles pour :
- Écrans de résultat quiz (confettis, étoiles)
- Icônes animées dans achievements
- Loading states

### `rive` (^0.14.6)
Animations interactives pour :
- Personnages ou mascotte (si présents dans assets)
- Transitions spéciales

### Transitions GoRouter
Fichier : `lib/core/router/eskolia_page_transitions.dart`

Toutes les routes utilisent `eskoliaTransitionPage()` — animation personnalisée fade + slide :
- Durée : ~300 ms
- Courbe : ease-in-out
- Direction : slide depuis la droite (forward), vers la droite (back)
