Hey! Thanks for reviewing. 


I used a offline frist approach 

Offline-first (what we cache and why)
	•	Episodes
Episodes are stored in SwiftData as you browse. First launch loads page 1, then we page as you scroll.
We also save a small “feed state” (the API’s next URL and last refresh time) so we can resume cleanly and know when we’re at the end.
	•	Characters (episode details)
When you open an episode, we fetch only the characters for that episode (in small batches) and cache them in SwiftData. If you come back later, it’s instant.
	•	Locations
Implemented as a simple paginated, in-memory list (no persistence) to keep scope focused on the episode/character flow.

Background refresh
	•	The app registers a background task that can refresh already loaded episode pages in the background (e.g., if you had browsed a few pages earlier).
	•	This helps keep the offline cache fresh without you needing to pull to refresh.
	•	Note: iOS may throttle or batch background runs. Also, Simulator won’t execute background refresh tasks; use a device.

Code style
	•	SwiftFormat and SwiftLint are configured.

Might need local install: 

brew install swiftformat swiftlint
swiftformat .
swiftlint

Architecture


MVVM-light with a Coordinator — thin ViewModels, pragmatic Services/Repositories, a simple Coordinator for navigation, and SwiftData where offline makes sense.
Some screens (for example, episode list/detail) also use @Query to observe SwiftData directly for fast UI updates.

Scope note

A full Characters list screen was extra and did not make the cut due to time. The groundwork is in place (API operations, models, tiles), so adding it later is straightforward.

