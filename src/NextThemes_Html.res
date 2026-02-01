/**
 * The `Html` module provides a React component wrapper for the `<html>` HTML tag.
 * This wrapper is designed to allow setting specific React props, such as
 * `suppressHydrationWarning`, on the root `<html>` element, which can be useful
 * in server-side rendering (SSR) contexts, for example, when integrating with
 * libraries like `next-themes` that might cause hydration mismatches.
 *
 * It contains:
 * - `domProps`: A type for the props accepted by the `Html.make` component.
 * - `make`: The React component function that renders the `<html>` element.
 */
type domProps = {
  ...JsxDOM.domProps,
  suppressHydrationWarning?: bool,
}

@variadic @module("react")
external createElement: (string, ~props: domProps=?, array<React.element>) => React.element =
  "createElement"

let make = (props: domProps) => createElement("html", ~props, [props.children->Option.getOrThrow])
