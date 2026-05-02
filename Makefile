
info:
release:
	gh release create v0.5.0 --latest -t v0.5.0 -n "Release v0.5.0 - items matched"
	git tag -d v0
	git push origin --delete v0
	git tag v0 b77be1a
	git push origin --tags
	git pull
