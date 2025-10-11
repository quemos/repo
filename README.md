```
cd repo
```

```
dpkg-scanpackages pool /dev/null > dists/stable/main/binary-amd64/Packages
```

```
gzip -k dists/stable/main/binary-amd64/Packages
```
