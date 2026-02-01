# Rescript bindings for next-themes

ReScript bindings for [next-themes](https://github.com/pacocoursey/next-themes), a library for perfect dark mode in Next.js applications.

## Installation

```bash
npm install @greenfinity/rescript-next-themes next-themes
# or
yarn add @greenfinity/rescript-next-themes next-themes
```

Add the dependency to your `rescript.json`:

```json
{
  "dependencies": [
    "@greenfinity/rescript-next-themes"
  ]
}
```

## Peer Dependencies

- `@rescript/react` ^0.14.0
- `next-themes` ^0.4.6
- `react` ^19.2.4
- `react-dom` ^19.2.4
- `rescript` ^12.1.0

## Usage

### ThemeProvider

Wrap your application with the `ThemeProvider` component. In Next.js App Router, add it to your root layout:

```rescript
// app/layout.res
@react.component
let make = (~children) => {
  <NextThemes.ThemeProvider
    attribute={NextThemes.ThemeProvider.AttributeProp.class}>
    {children}
  </NextThemes.ThemeProvider>
}
```

Example with all available props:

```rescript
// app/layout.res
@react.component
let make = (~children) => {
  <NextThemes.ThemeProvider
    attribute={NextThemes.ThemeProvider.AttributeProp.class}
    defaultTheme="system"
    enableSystem={true}>
    {children}
  </NextThemes.ThemeProvider>
}
```

#### ThemeProvider Props

| Prop | Type | Description |
| ---- | ---- | ----------- |
| `enableSystem` | `bool?` | Respect user's system theme preference (default: `true`) |
| `defaultTheme` | `string?` | Default theme if no preference is set (default: `"system"`) |
| `forcedTheme` | `string?` | Force a specific theme, disabling theme switching |
| `attribute` | `AttributeProp.t?` | How to apply the theme to the DOM |
| `children` | `React.element?` | Child components |

#### AttributeProp

The `AttributeProp` module defines how themes are applied to the DOM:

```rescript
// Use CSS class (e.g., <html class="dark">)
NextThemes.ThemeProvider.AttributeProp.class

// Use data attribute (e.g., <html data-theme="dark">)
NextThemes.ThemeProvider.AttributeProp.data("theme")
```

### useTheme Hook

Access and control the current theme:

```rescript
@react.component
let make = () => {
  let (theme, setTheme) = NextThemes.useTheme()

  <div>
    {switch theme {
    | Some(currentTheme) => React.string("Current theme: " ++ currentTheme)
    | None => React.string("Loading theme...")
    }}
    <button onClick={_ => setTheme("dark")}>
      {React.string("Dark")}
    </button>
    <button onClick={_ => setTheme("light")}>
      {React.string("Light")}
    </button>
  </div>
}
```

### useResolvedTheme Hook

Get the resolved theme value (actual `"light"` or `"dark"` even when theme is `"system"`):

```rescript
@react.component
let make = () => {
  let (resolvedTheme, setTheme) = NextThemes.useResolvedTheme()

  <div>
    {switch resolvedTheme {
    | Some("dark") => React.string("Dark mode")
    | Some("light") => React.string("Light mode")
    | _ => React.string("Loading theme...")
    }}
  </div>
}
```

### Html Component

A wrapper for the `<html>` element that supports `suppressHydrationWarning`, which prevents hydration mismatches when using `next-themes`:

```rescript
// app/layout.res
@react.component
let make = (~children) => {
  <NextThemes.Html lang="en" suppressHydrationWarning={true}>
    <body>
      <NextThemes.ThemeProvider attribute={NextThemes.ThemeProvider.AttributeProp.class}>
        {children}
      </NextThemes.ThemeProvider>
    </body>
  </NextThemes.Html>
}
```

## API Reference

### NextThemes

| Export | Type | Description |
| ------ | ---- | ----------- |
| `ThemeProvider` | Component | Theme context provider |
| `ThemeProvider.AttributeProp.class` | `AttributeProp.t` | Apply theme via CSS class |
| `ThemeProvider.AttributeProp.data` | `string => AttributeProp.t` | Apply theme via data attribute |
| `useTheme` | `unit => (option<string>, string => unit)` | Hook returning `(theme, setTheme)` |
| `useResolvedTheme` | `unit => (option<string>, string => unit)` | Hook returning `(resolvedTheme, setTheme)` |
| `Html` | Module | HTML element wrapper with `suppressHydrationWarning` support |

## Hydration Safety

Both `useTheme` and `useResolvedTheme` are designed to prevent hydration mismatches by:

1. Returning `None` during server-side rendering
2. Only updating to the actual theme value after the component mounts on the client

This ensures your UI renders consistently between server and client.

## License

MIT
