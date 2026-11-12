# product.md

Format for `<docs>/project/product.md` (`<docs>` is the Seny docs root). App-wide: epic docs build on it and never repeat it. Be concrete: names, versions, values. Omit sections that don't apply.

What the product is and for whom. Written by `/seny:research project <idea>` for a new app. Existing codebases may skip it or add it later.

```markdown
# <Product name> — product

Status: <draft | approved (YYYY-MM-DD)>

Source: <the idea in chat | brief file path | BMAD PRD path>

## Vision
<what the product is and why it should exist, 3 lines>

## Users
- <user>: <what they need>

## Core needs
1. <job the product must do> — <priority>

## MVP candidate
- In: <the smallest version worth shipping>
- Later: <what waits>

## Constraints
<platforms (web, iOS, Android), hosting and cost, integrations, anything stated>

## References
- <similar product or site> — <what to take from it>
- <`inputs/<name>.md`> — <reference material kept out of this document: inventories, briefs, content, what an old version does>

## Risks

## Assumptions
- (assumption) <...>

## Open questions
```
