---
id: tutorial-3
language: en
genre: tutorial
audience: beginners
edit_mode: light
required_preservation:
  claims: ["a cookie is usually no more than 4 KB", "the browser sends the cookie back with every request", "HttpOnly cookies cannot be read from JavaScript"]
  conditions: []
  exceptions: []
  uncertainty: []
  terminology: ["HTTP cookies", "HttpOnly", "XSS"]
forbidden_additions: ["new size limits not in the source", "security claims beyond the source"]
expected_issues: ["wordiness", "filler phrases"]
allow_major_rewrite: false
---

## Source
In this tutorial we are going to learn how HTTP cookies actually work. A cookie is essentially a small piece of data — usually no more than 4 KB — that a server kindly asks the browser to store. On every single subsequent request the browser sends the cookie back, which is what allows the server to recognize you. It is worth noting that cookies marked as HttpOnly cannot be read from JavaScript; this is what protects session tokens from XSS attacks. Try it yourself: open the dev tools and inspect the cookies for any site.

## Gold edit
This tutorial explains how HTTP cookies work. A cookie is a small piece of data, usually up to 4 KB, that the server asks the browser to store. The browser sends it back with every request, so the server can recognize you. Cookies marked HttpOnly cannot be read from JavaScript — this protects session tokens from XSS attacks. Try it: open dev tools and inspect a site's cookies.
