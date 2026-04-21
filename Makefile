
info:
release:
	gh release create v0.2.0 --latest -t v0.2.0 -n "Release v0.2.0"
	git tag -d v0
	git push origin --delete v0
	git tag v0 2c7d2b2
	git push origin --tags
