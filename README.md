# Pressure Ruuvi

## An application showcasing Ruuvi Sensors' integration in collecting pressure readings.

The application lets users connect their Ruuvi Sensors via Bluetooth to collect pressure readings. Here, the 128-byte list of integers is interpreted into 31-byte pressure readings and stored in a CSV file. Specifically, the applications showcases the following:

* Connecting to a Ruuvi Sensor via Bluetooth
* Subscribe to specific characteristics
* Interpret the received 128-byte data into a 31-byte pressure reading
* Store the interpreted data into a CSV file and save it on the mobile device

## How to Use the Project

Assure that Flutter is already installed on your computer.

1. Clone the project
```
git clone https://github.com/Tristaaaaan/pressureruuvi
```

2. Open the project on your preferred IDE and add dependencies:
```
flutter pub add
```

3. Run the project:

* Open an Android emulator.
  
* Run the following command to build and run the project in development mode:
```
flutter build apk --debug --flavor development -t lib/main_development.dart
```

* To create a release version of the application run the command:
```
flutter build apk release --flavor production -t lib/main_production.dart
```

* To get the AAB of the project, run the command:
```
flutter build appbundle --flavor production -t lib/main_production.dart
```

## Contact

For inquiries:

* Email: markristanfabellar.pro@gmail.com
* GitHub: [Tristaaaaan](https://github.com/Tristaaaaan)




