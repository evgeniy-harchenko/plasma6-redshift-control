# Redshift control applet for the KDE Plasma 6

## Build instructions

### Requirements

- Install redshift.

### Install for current user
```bash
cd /where/your/downloaded/applet/source
./create-plasmoid-package.sh
cd buildWidget
```
for install:
```bash
kpackagetool6 -i plasma6-redshift-control-xxx.plasmoid -t Plasma/Applet
```
or for update:
```bash
kpackagetool6 -u plasma6-redshift-control-xxx.plasmoid -t Plasma/Applet
```
where xxx is the version of the widget (e.g. 2.1)

### Install for all users
```bash
cd /where/your/downloaded/applet/source
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make
make install
```
