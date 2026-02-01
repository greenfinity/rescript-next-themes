@@directive("'use client';")

/**
 * Bindings for the `ThemeProvider` component from the `next-themes` library.
 *
 * This module provides a ReScript interface to the `ThemeProvider`, which is used
 * to manage application themes (e.g., light/dark mode) in Next.js applications.
 *
 * It includes:
 * - `AttributeProp`: A helper module to define how themes are applied to the DOM
 *   (e.g., using CSS classes or data attributes).
 * - `make`: The React component function for `ThemeProvider`.
 *
 * For detailed usage and options of the underlying library, refer to the
 * [next-themes documentation](https://github.com/pacocoursey/next-themes).
 *
 * ### `AttributeProp` Module
 *
 * Defines the type and constructors for the `attribute` prop of the `ThemeProvider`.
 * - `AttributeProp.t`: The opaque type for the attribute value.
 * - `AttributeProp.class`: A value representing `"class"`. Sets the theme using a CSS class on the `<html>` element (e.g., `class="dark"`).
 * - `AttributeProp.data(name)`: A function that returns a value representing `` `data-${name}` ``. Sets the theme using a data attribute (e.g., `data-theme="dark"` if `name` is `"theme"`).
 *
 * ### `make` Component Props
 *
 * The `make` function creates an instance of the `ThemeProvider` component.
 *
 * - `~enableSystem: bool?`: (Optional) If `true` (the default in `next-themes`), the theme provider will respect the user's system theme preference.
 * - `~defaultTheme: string?`: (Optional) The theme to apply by default if no user preference is set or
 *   if system preference is disabled. Defaults to `"system"` in `next-themes`.
 * - `~forcedTheme: string?`: (Optional) If set, this theme will be applied, and theme switching will be disabled.
 * - `~attribute: AttributeProp.t?`: (Optional) Specifies how the theme is applied to the DOM.
 *   Use values from the `AttributeProp` module (e.g., `AttributeProp.class` or `AttributeProp.data("theme")`).
 *   If not provided, `next-themes` defaults to applying themes via the `data-theme` attribute.
 * - `~children: React.element?`: (Optional) The child components to be wrapped by the `ThemeProvider`.
 */
module ThemeProvider = {
  module AttributeProp = {
    type t
    external raw: string => t = "%identity"
    let class = "class"->raw
    let data = name => `data-${name}`->raw
  }

  @react.component @module("next-themes")
  external make: (
    ~enableSystem: bool=?,
    ~defaultTheme: string=?,
    ~forcedTheme: string=?,
    ~attribute: AttributeProp.t=?,
    ~children: React.element=?,
  ) => React.element = "ThemeProvider"
}

type useThemeReturn = {
  theme: option<string>,
  resolvedTheme: option<string>,
  setTheme: string => unit,
}
@module("next-themes") external useThemeExternal: unit => useThemeReturn = "useTheme"

/**
 * @hook useTheme
 * A hook that provides access to the current theme and a function to set it.
 * This hook wraps the `useTheme` hook from `next-themes` to manage theme state
 * on the client side, 
 * 
 * - ensuring that no hydration mismatches occur when the theme is set on the server
 * - consolidates the signature from `next-themes` to one more consistent with `useState`.
 *   `(value, setValue)` are returned as a tuple, instead of a record.
 *
 *
 * @example
 * ```rescript
 * @react.component
 * let make = () => {
 *   let (theme, _setTheme) = NextThemes_Client.useTheme()
 *
 *   <div>
 *     {switch theme {
 *      | Some(currentTheme) => React.string("Current theme: " ++ currentTheme)
 *      | None => React.string("Loading theme...")
 *      }}
 *   </div>
 * }
 * ```
 */
let useTheme = () => {
  open ReactWithErrorHandling

  let {theme, setTheme} = useThemeExternal()
  let onError = useOnError()

  let (clientTheme, setClientTheme) = React.useState(() => None)
  React.useEffect(() => {
    (
      () =>
        switch theme {
        | Some(theme) => setClientTheme(_ => Some(theme))
        | None => ()
        }
    )->withErrorHandling(onError)
    None
  }, [theme])

  // Adhere to usual setState signature
  (clientTheme, setTheme)
}

/**
 * @hook useResolvedTheme
 * A hook that provides access to the resolved theme and a function to set it.
 * Unlike `useTheme`, this returns the actual resolved theme value (e.g., "light" or "dark")
 * even when the theme is set to "system".
 *
 * This hook wraps the `useTheme` hook from `next-themes` to manage theme state
 * on the client side,
 *
 * - ensuring that no hydration mismatches occur when the theme is set on the server
 * - consolidates the signature from `next-themes` to one more consistent with `useState`.
 *   `(value, setValue)` are returned as a tuple, instead of a record.
 *
 * @example
 * ```rescript
 * @react.component
 * let make = () => {
 *   let (resolvedTheme, _setTheme) = NextThemes_Client.useResolvedTheme()
 *
 *   <div>
 *     {switch resolvedTheme {
 *      | Some("dark") => React.string("Dark mode")
 *      | Some("light") => React.string("Light mode")
 *      | _ => React.string("Loading theme...")
 *      }}
 *   </div>
 * }
 * ```
 */
let useResolvedTheme = () => {
  open ReactWithErrorHandling

  let {resolvedTheme, setTheme} = useThemeExternal()
  let onError = useOnError()

  let (clientResolvedTheme, setClientResolvedTheme) = React.useState(() => None)
  React.useEffect(() => {
    (
      () =>
        switch resolvedTheme {
        | Some(theme) => setClientResolvedTheme(_ => theme->Some)
        | None => ()
        }
    )->withErrorHandling(onError)
    None
  }, [resolvedTheme])

  // Adhere to usual setState signature
  (clientResolvedTheme, setTheme)
}
