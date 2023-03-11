import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Scanner&Genetor',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController cLink = TextEditingController();
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey();
  bool flash = false;
  List<String> resultData = [];
  bool isObscure = true;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: const TabBar(tabs: [
              Tab(
                icon: Icon(Icons.qr_code_2),
                child: Text('Generator'),
              ),
              Tab(
                icon: Icon(Icons.qr_code_scanner),
                child: Text('Scanner'),
              ),
            ]),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: cLink,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(fontSize: 22),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    cLink.text.isNotEmpty
                        ? QrImage(
                            data: cLink.text,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          )
                        : const Text('Text field in Empty'),
                  ],
                ),
              ),
              Stack(
                children: [
                  _buildQrView(context),
                  Positioned(
                    top: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                onPressed: () async {
                                  await controller?.toggleFlash();
                                  flash = !flash;
                                  setState(() {});
                                },
                                icon: Icon(
                                  flash
                                      ? Icons.flash_on_sharp
                                      : Icons.flash_off_sharp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                              right: 0,
                              child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      resultData.clear();
                                      result = null;
                                      controller!.resumeCamera();
                                    });
                                  },
                                  icon: const Icon(Icons.refresh_sharp),
                                  label: const Text('Refresh'))),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: result != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 30),
                            // height: 100,
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                    child: resultData.isEmpty
                                        ? Text(
                                            'Data: ${result!.code}',
                                            style:
                                                const TextStyle(fontSize: 20),
                                            overflow: TextOverflow.clip,
                                          )
                                        : Column(
                                            children: [
                                              Text(
                                                  'SSID: ${resultData[2].split(':')[1]}'),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text('Password: '),
                                                    GestureDetector(
                                                      onTap: () => setState(() {
                                                        isObscure = !isObscure;
                                                      }),
                                                      child: Text(isObscure
                                                          ? "*" *
                                                              resultData[1]
                                                                  .split(':')[1]
                                                                  .length
                                                          : resultData[1]
                                                              .split(':')[1]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                  'Security: ${resultData[0].split(':')[2]}')
                                            ],
                                          )),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: result != null
                                            ? result!.code
                                            : null,
                                      ),
                                    );

                                    showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      constraints: BoxConstraints(
                                          minWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5),
                                      isDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          width: double.minPositive,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          height: 50,
                                          child: const Text(
                                            'Copy Successfully',
                                            style: TextStyle(
                                                color: Colors.lightGreen,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.copy_sharp),
                                )
                              ],
                            ),
                          )
                        : Container(
                            height: 100,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: const Center(
                                child: Text(
                              'Scan your Code.',
                              style: TextStyle(fontSize: 22.0),
                            )),
                          ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: const Color.fromARGB(255, 128, 196, 251),
        borderRadius: 15,
        borderLength: 30,
        borderWidth: 6,
        cutOutSize: MediaQuery.of(context).size.width * 0.6,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    setState(() {
      resultData.clear();
      result = null;
      isObscure = true;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result!.code!.split(';').length > 3) {
          result!.code!.split(';').forEach((value) => resultData.add(value));
        } else {
          result = scanData;
        }
        controller.pauseCamera();
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
