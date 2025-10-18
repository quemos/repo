```
cd repo
```

```
dpkg-scanpackages pool /dev/null > dists/stable/main/binary-amd64/Packages
```

```
gzip -k dists/stable/main/binary-amd64/Packages
```

```
xz -kf dists/stable/main/binary-amd64/Packages
```

```
apt-ftparchive -c=apt-ftparchive.conf release dists/stable > dists/stable/Release
```

```
gpg --clearsign -u EA6CF030909C9B9 -o dists/stable/InRelease dists/stable/Release
```

```
gpg -abs -u EA6CF030909C9B9 -o dists/stable/Release.gpg dists/stable/Release
```
