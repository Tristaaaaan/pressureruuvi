# Pressure Ruuvi

## An application showcasing Ruuvi Sensors' integration in collecting pressure readings.

The application lets users connect their Ruuvi Sensors via Bluetooth to collect pressure readings. Here, the 128-byte list of integers is interpreted into 31-byte pressure readings and stored in a CSV file. Specifically, the applications showcases the following:

* Connecting to a Ruuvi Sensor via Bluetooth
* Subscribe to specific characteristics
* Interpret the received 128-byte data into a 31-byte pressure reading
* Store the interpreted data into a CSV file and save it on the mobile device
