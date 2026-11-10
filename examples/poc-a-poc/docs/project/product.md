# Poc a poc — product

Source: the idea in chat, plus three conversations with parents (notes in chat)

## Vision
A calm habit tracker a whole family uses together. Small daily habits ("read 10 minutes", "water the plants"), done side by side, celebrated together. Progress without pressure: little by little.

## Users
- Parent (admin): creates the family, invites members, sets up habits for younger kids, wants to see everyone's week at a glance.
- Kid, 7–12: checks off their habits with big, friendly buttons; wants to see streaks grow. No email, no social features.
- Teen or second adult: manages their own habits, can share some with the family.

## Core needs
1. Check off today's habits in one tap — must
2. See streaks per habit, without comparing people — must
3. One family space, shared across several phones — must
4. Gentle reminders before a streak breaks — should
5. Weekly family summary — could

## MVP candidate
- In: families with invite codes, personal and shared habits, daily check-ins, streaks, reminders.
- Later: weekly summary, widgets, Apple Watch, rewards chosen by parents.

## Constraints
- iOS and Android from day one, phones only.
- Kids under 13 have no account of their own: a parent adds them as profiles (privacy and store rules).
- Free tier hosting until there are real users; costs under 20 €/month.
- Works offline for check-ins; syncs when back online.

## References
- Finch — the gentle tone and the lack of guilt.
- Streaks (iOS) — how fast a check-in feels.

## Risks
- Kids' privacy rules (COPPA, GDPR-K) shape auth and data.
- Time zones: a family split across two countries.

## Assumptions
- (assumption) Families have at most 8 members.
- (assumption) One family per person is enough for the MVP.

## Open questions
- ~~Can reminders be scheduled locally, without a server?~~ Answered by a spike, see `features/streaks/research.md`.
