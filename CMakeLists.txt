cmake_minimum_required(VERSION 3.16)
project(plasma6-redshift-control)

set(QT_MIN_VERSION "6.0.0")
set(KF6_MIN_VERSION "6.0.0")

find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)

find_package(Plasma REQUIRED)
find_package(KF6I18n)

plasma_install_package(package org.kde.redshiftControl6)

ki18n_install(po)
