import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_scanner/constant.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  // Here is the result value, by default is unknown
  String _scanBarcode = 'Unknown';
  bool clockIn = true;
  bool success = false;
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      //Do some validation here
      if (barcodeScanRes.startsWith('http', 0) ||
          barcodeScanRes.startsWith('https', 0)) {
        _scanBarcode = barcodeScanRes;
        success = true;
        currentDate = DateTime.now();
      } else {
        _scanBarcode = "Unknown Link Format";
        success = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Attandance')),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () async {
                            await scanQR();
                            clockIn = true;
                          },
                          child: const Text('Clock In'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await scanQR();
                            clockIn = false;
                          },
                          child: const Text('Clock Out'),
                        ),
                        Text('Scan result : $_scanBarcode\n',
                            style: normalTextStyle),
                        success
                            ? Center(
                                child: clockIn
                                    ? Text(
                                        '$clockInMsg at ${DateFormat('yyyy-MM-dd - kk:mm').format(currentDate)}',
                                        style: normalTextStyle,
                                      )
                                    : Text(
                                        '$clockOutMsg at ${DateFormat('yyyy-MM-dd - kk:mm').format(currentDate)}',
                                        style: normalTextStyle,
                                      ))
                            : const SizedBox(height: 0, width: 0),
                      ]));
            })));
  }
}
