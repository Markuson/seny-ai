# design-system.md

Format for `<docs>/project/design-system.md` (`<docs>` is the Seny docs root). App-wide: epic docs build on it and never repeat it. Be concrete: names, versions, values. Omit sections that don't apply.

Only for apps with UI. In brownfield, describe the tokens and components that actually exist; if there is no coherent system, say so instead of inventing one.

```markdown
# Design system

Status: <draft | approved (YYYY-MM-DD)>
Platform: <web | mobile | both>
References: <links, screenshots, Figma>

## Direction
<3–5 lines: personality, tone, what it must feel like, what to avoid>

## Tokens
Semantic names, mapped to the Tailwind / NativeWind theme in <path to config>.
| Token | Light | Dark | Use |
|---|---|---|---|
| color.bg | | | app background |
| color.surface | | | cards, sheets |
| color.text | | | body text |
| color.text-muted | | | secondary text |
| color.primary | | | main actions |
| color.danger | | | destructive actions, errors |
| color.border | | | dividers, inputs |

## Typography
| Role | Family | Size / line height | Weight |
|---|---|---|---|
| display | | | |
| title | | | |
| body | | | |
| caption | | | |

## Spacing, radius, elevation
<scale (e.g. 4-pt grid), radius steps, shadows or elevation levels>

## Motion
<durations, easing, what animates; reduced motion behaviour>

## Base components
| Component | Variants | States | Location |
|---|---|---|---|
| Button | primary, secondary, ghost, danger | default, hover/pressed, focus, disabled, loading | `components/ui/Button` |
| Input | text, password, search | default, focus, error, disabled | |

## Accessibility rules
- AA contrast for every text/background pair; check new tokens before adding them
- Visible focus (web); accessibility labels and roles (mobile)
- Touch targets ≥ 44×44 pt / 48×48 dp
- Dynamic type and 200% zoom without breaking layouts
- Reduced motion respected
```
