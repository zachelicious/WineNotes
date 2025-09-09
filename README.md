# WineNotes (one-hand wine review app)

**Goal:** Capture a wine review with one hand in under 30s, store it locally, find it via in-app search + Spotlight, and generate a short tasting note via an LLM.

## Repo layout
```
Sources/                 # SwiftUI + SwiftData code
Project.yml              # XcodeGen project description
Info.plist
worker/worker.js         # Cloudflare Worker for the LLM endpoint
```

## Build in the cloud (no Mac)
We recommend **Codemagic**:
1. Connect this repo.
2. Add a prebuild step to install XcodeGen and run `xcodegen generate`.
3. Configure App Store Connect API key for signing & upload to TestFlight.
4. Put your Worker URL into `Sources/LLMService.swift`.

## Cloudflare Worker
- Add secret `OPENAI_API_KEY`
- Deploy and copy the public URL, then set it in `LLMService.swift`.

## Local development (optional, needs a Mac)
- `brew install xcodegen && xcodegen generate`
- Open the generated Xcode project and run.