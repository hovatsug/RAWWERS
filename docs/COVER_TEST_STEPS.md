# Cover and card images: manual test steps

For the iOS simulators against dev (BETA_SCOPE #74 and its follow-ups, 2026-11-20). Sign in to the Pro app as `pro1@rawwers.dev` and to the client app as a client in pro1's city.

1. **Pro app, Your listing.** The card shows a photo, never a grey block. The line under it says where the photo comes from: "Your chosen cover, from your portfolio", or "Picked for you until you choose one…".
2. **Portfolio.** One tile has the "Cover" badge.
3. **Open another photo.** Three full-width buttons: Edit tags, Set as cover, Remove from portfolio. Remove reads light on the dark background.
4. **Set as cover on a portrait photo.** "Cover" and "Clients see this photo first." appear, and Set as cover goes away. Back in Your listing, the card shows the head and upper body, not the middle of the frame, and it is sharp.
5. **Client app, Discover** (pull to refresh). pro1's card shows the new cover, sharp, with the head kept. Open the profile: the header leans up too.
6. **Client app, Home.** Tiles and the carousel at the top are sharp (they were soft before 2026-11-20). A portrait tile shows its top; landscape tiles are as before.
7. **Set as cover on a landscape photo.** The card is centred, as before.
8. **Remove the cover.** pro1 is live with 12 photos, so add one first. Open the cover, then Remove from portfolio: the confirmation says "This is your cover. Another photo will be used until you choose a new one." Your listing then shows the automatic photo with "Picked for you…".
9. **A new photographer.** Before any upload, Your listing shows the placeholder and "Add photos to your portfolio. The first one is shown until you choose a cover." Upload one photo: once processed, Your listing shows it, sharp.
10. **A photo published from Lightroom** (if you test the plug-in): once it shows in the portfolio, Set as cover works on it, and its card is sharp.

What to look for everywhere: no grey card while the photographer has a ready photo, no soft photo on a card, a tile or the carousel, and no portrait cut at the forehead.
