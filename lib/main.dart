// ignore_for_file: lines_longer_than_80_chars

import "dart:developer";
import "dart:io";

import "package:csvwriter/csvwriter.dart";
import "package:document_file_save_plus/document_file_save_plus.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:universal_html/html.dart" as uni;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Generate & Download CSV Demo",
      theme: themeData(Brightness.light),
      darkTheme: themeData(Brightness.dark),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData themeData(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: Colors.blue,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate & Download CSV Demo"),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "This is a simple app that helps you make and get CSV files. You can use it on Android, iOS, and the web.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "On Android, if you click Generate CSV, the file will be saved in your Downloads folder.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "For iOS, when you press Generate CSV, a menu will pop up with choices like copying the file or saving it.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "If you're using the web version, hitting Generate CSV can either ask you to download the file or save it straight to your Downloads folder.",
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: generateCSVFile,
                  child: const Text("Generate CSV"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generateCSVFile() async {
    final StringSink stringSink = StringBuffer();
    CsvWriter csvWriter = CsvWriter(stringSink, 0);
    try {
      csvWriter = CsvWriter.withHeaders(
        stringSink,
        <String>[
          "Column #1",
          "Column #2",
          "Column #3",
          "Column #4",
          "Column #5",
        ],
      );
      for (int i = 1; i <= 10; i++) {
        csvWriter.writeData(
          data: <String, dynamic>{
            "Column #1": "Row #$i",
            "Column #2": "Row #$i",
            "Column #3": "Row #$i",
            "Column #4": "Row #$i",
            "Column #5": "Row #$i",
          },
        );
      }
    } on Exception catch (e) {
      log("CsvWriter Exception: $e");
    } finally {
      await csvWriter.close();
    }
    final String stringData = stringSink.toString();
    const String fileName = "sample.csv";
    const String mimeType = "text/csv";
    final Uint8List uint8 = Uint8List.fromList(stringData.codeUnits);
    if (kIsWeb) {
      final uni.Blob blob = uni.Blob(<String>[stringData], mimeType, "native");
      final String href = uni.Url.createObjectUrlFromBlob(blob);
      uni.AnchorElement(
        href: href,
      )
        ..setAttribute("download", fileName)
        ..click();
      log("Web Completed!");
    } else if (Platform.isAndroid || Platform.isIOS) {
      await DocumentFileSavePlus.saveFile(uint8, fileName, mimeType);
      if (Platform.isAndroid) {
        if (mounted) {
          const String msg = "The file saved successfully at Downloads folder.";
          const SnackBar snack = SnackBar(content: Text(msg));
          ScaffoldMessenger.of(context).showSnackBar(snack);
          log("Android Completed!");
        } else {}
      } else if (Platform.isIOS) {
        log("iOS Completed!");
      } else {}
    } else {
      log("Unsupported Platform");
    }
    return Future<void>.value();
  }
}
