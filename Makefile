
info:
release:
	gh release create v0.4.0 --latest -t v0.4.0 -n "Release v0.4.0 - wildcards in source"
	git tag -d v0
	git push origin --delete v0
	git tag v0 6ce345a
	git push origin --tags
	git pull
