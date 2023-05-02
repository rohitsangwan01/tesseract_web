// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tesseract_web/tesseract_web.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      home: HomeView(),
    ),
  );
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TesseractWorker? _tesseractWorker;
  TesseractLogs? logs;
  String result = "";
  Uint8List? selectedimage;
  bool isLoading = false;

  initTesseract() async {
    _tesseractWorker = await TesseractWeb.getWorker(
      languages: ['Devanagari', 'eng'],
      args: {
        "psm": "2",
        "preserve_interword_spaces": "2",
      },
      logsCallback: onWorkerUpdateCallback,
      languageFolder: "lang-data",
    );
  }

  getImageFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    Uint8List? uint8list = result?.files.single.bytes;
    String? name = result?.files.single.name;

    if (uint8list != null && name != null) {
      loadText(uint8list);
      setState(() {
        selectedimage = uint8list;
      });
    }
  }

  getFileFromAsset() async {
    loadText('assets/test.png');
    ByteData bytes = await rootBundle.load('assets/test.png');
    setState(() {
      selectedimage = bytes.buffer.asUint8List();
    });
  }

  void onWorkerUpdateCallback(TesseractLogs data) {
    //print(data.toJson().toString());
    setState(() {
      logs = data;
    });
  }

  loadText(filePath) async {
    setState(() {
      result = "";
      isLoading = true;
    });
    String text = await _tesseractWorker?.extractText(filePath);
    setState(() {
      result = text;
      isLoading = false;
    });
  }

  @override
  void initState() {
    initTesseract();
    super.initState();
  }

  @override
  void dispose() {
    _tesseractWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tesseract JS'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("WorkerID : ${logs?.workerId}"),
                Text("  Status : ${logs?.status}   "),
                Text("JobID :${logs?.jobId}"),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                value: logs?.progress ?? 0.0,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    getImageFile();
                  },
                  child: const Text('Pick image'),
                ),
                ElevatedButton(
                  onPressed: () {
                    getFileFromAsset();
                  },
                  child: const Text('Load Asset'),
                ),
              ],
            ),
            const Divider(),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: selectedimage == null
                              ? const SizedBox()
                              : Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.memory(selectedimage!),
                                )),
                        ),
                        Expanded(
                            child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(result,
                                        style: const TextStyle(fontSize: 20)))),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
