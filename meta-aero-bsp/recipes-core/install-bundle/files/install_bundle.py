#!/usr/bin/env python3
# TO Be Fixed : Bundle is not installed + no signal from completed api
import dbus
import dbus.mainloop.glib
import time
if __name__ == "__main__":
    # Initialize the DBus main loop
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    
    # Connect to the session bus
    bus = dbus.SystemBus()
    
    # Get proxy object
    proxy = bus.get_object(
        "de.pengutronix.rauc",
        "/"
    )
    
    # Get the interface (you'll need to specify the interface name)
    # Assuming it's "de.pengutronix.rauc.Installer" - adjust if needed
    interface = dbus.Interface(proxy, "de.pengutronix.rauc.Installer")
    
    completed = [False]
    # Signal handler for Completed signal
    def on_completed(result):
        completed[0] = True
        if result == 0:
            print(f"Installation completed successfully (result: {result})")
        else:
            print(f"Installation failed (result: {result})")
    
    # Connect to the Completed signal
    interface.connect_to_signal("Completed", on_completed)
    
    path = input("Bundle path: ")
    
    # Call the InstallBundle method
    print("Installing bundle ...")
    ret = interface.InstallBundle(path, {})

    while completed[0] is not True:
        time.sleep(0.2)
    
    print("Done.")