<p align="center">
  <img src="https://github.com/evgeniy-harchenko/plasma6-redshift-control/blob/master/assets/logo.png" width=150 />
  <h1 align="center">Redshift control applet for the KDE Plasma 6</h1>
  <p align="center">A simple control widget for KDE Plasma 6. Allows enabling and disabling redshift process. Provides advanced redshift settings and mouse-wheel manual screen temperature, brightness and gamma controlling.</center>
</p>

<p align="center">
  <img src="https://github.com/evgeniy-harchenko/plasma6-redshift-control/blob/master/assets/image.png"/>
</p>

## Build instructions

### Requirements

- Install redshift.

### Install for current user (Preferred way)
1. Right click on the desktop
2. Click on "Add Widgets"
3. Click on "Get New Widgets"
4. Click on "Download New Plasma Widgets"
5. Search for "Redshift control for Plasma 6"
6. Click on "Install"

### Install for current user (Manual)
1. Download [plasma6-redshift-control-**xxx**.plasmoid](https://github.com/evgeniy-harchenko/plasma6-redshift-control/releases/latest)
2. Right click on the desktop
3. Click on "Add Widgets"
4. Click on "Get New Widgets"
5. Click on "Install Widget From Local File"
6. Select downloaded plasma6-redshift-control-**xxx**.plasmoid file
7. Click on "Open"

### Install for current user (Terminal)
```bash
cd /where/your/downloaded/applet/source
./create-plasmoid-package.sh
cd buildWidget
```
for install:
<pre>
kpackagetool6 -i plasma6-redshift-control-<b>xxx</b>.plasmoid -t Plasma/Applet
</pre>
or for update:
<pre>
kpackagetool6 -u plasma6-redshift-control-<b>xxx</b>.plasmoid -t Plasma/Applet
</pre>
where **xxx** is the version of the widget (e.g. 2.1).

### Install for all users
```bash
cd /where/your/downloaded/applet/source
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make
make install
```
