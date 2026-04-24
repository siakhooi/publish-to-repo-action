
info:
release:
	gh release create v0.3.0 --latest -t v0.3.0 -n "Release v0.3.0 - add outputs"
	git tag -d v0
	git push origin --delete v0
	git tag v0 7867fe0
	git push origin --tags
