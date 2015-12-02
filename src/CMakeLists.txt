# Kompilieranweisungen
include (ValaPrecompile)
vala_precompile (VALA_C
    config.vala
    Application.vala
    MainWindow.vala
    Widgets/ConfigurationPage.vala
    Widgets/CameraPage.vala
    Widgets/MapsPage.vala
    Widgets/MapTab.vala
    Widgets/SideBar.vala
    Backend/SettingsManager.vala
    Backend/BusManager.vala
    Backend/UDPRenderer.vala
    Backend/Joystick.vala
    Backend/JoystickManager.vala
    Backend/ServiceBrowser.vala
PACKAGES
    gtk+-3.0
    gio-2.0
    granite
    posix
    linux-joystick
    avahi-gobject
    avahi-client
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi/
    --thread
    --target-glib=2.32
)

# C-Warnungen ausblenden
add_definitions (-w)

# Ausführbare Datei hinzufügen
add_executable (${CMAKE_PROJECT_NAME} ${VALA_C})

# Installation
install (TARGETS ${CMAKE_PROJECT_NAME} RUNTIME DESTINATION bin)