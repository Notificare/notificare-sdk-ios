# Release process

1. Update the `MARKETING_VERSION` in each module.
2. Update the `NOTIFICARE_VERSION` in `NotificareKit/Sources/Internals/Version.swift`.
3. Update the `CHANGELOG.md`.
4. Run `ruby build.rb NEW_VERSION_HERE`.
5. Push the generated changes to the repo.
6. Create a GitHub release with the contents of the `CHANGELOG.md` and upload the contents of `.build/outputs` as artefacts of the release.
7. Run `pod trunk push Notificare.podspec` to update the CocoaPods CDN.
