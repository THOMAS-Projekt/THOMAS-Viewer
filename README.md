# THOMAS-Viewer
## Kompilieren
```
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
```

## Installieren
```
sudo make install
sudo gtk-update-icon-cache /usr/share/icons/hicolor
```

## Patch für den X-Box Joystick
```
sudo apt-add-repository ppa:rael-gc/ubuntu-xboxdrv
sudo apt-get update
sudo apt-get install ubuntu-xboxdrv
```