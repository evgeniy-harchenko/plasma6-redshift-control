#!/bin/bash

find "../package/contents" -name \*.qml | sort | xargs xgettext \
--c++ --kde \
--from-code=UTF-8 \
-ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 \
-kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3 \
-kkli18n:1 -kkli18nc:1c,2 -kkli18np:1,2 -kkli18ncp:1c,2,3 \
-kI18N_NOOP:1 -kI18NC_NOOP:1c,2 -L JavaScript -o plasma_applet_org.kde.redshiftControl6.pot

for file in ./*/plasma_applet_org.kde.redshiftControl6.po; do msgmerge --update ${file} plasma_applet_org.kde.redshiftControl6.pot; done

rm plasma_applet_org.kde.redshiftControl6.pot
