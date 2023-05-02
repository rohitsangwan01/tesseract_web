// ignore_for_file: avoid_print

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:tesseract_web/tesseract_web.dart';

class TesseractWorker {
  /// [worker] is a JavaScript object
  dynamic worker;

  /// each [worker] will have different Id's
  String? id;

  TesseractWorker({required this.worker, this.id});

  ///get text from image [imagePath] can be a path of assets or bytes of file as well
  extractText(dynamic imagePath) async {
    var promiseData = _extractText(imagePath, worker);
    var rtn = await promiseToFuture(promiseData);
    return rtn;
  }

  ///[dispose] worker after using
  dispose() {
    _closeWorker(worker);
  }
}

class TesseractWeb {
  /// Get a Tesseract `Worker` instance of JS and use that for other Operations
  /// Either Create a single `Worker` for all operations
  /// or multiple workers for each operation , but make sure to call `dispose` after usage
  /// pass `language` code like `eng` or multiple languages like , `eng+hin`
  /// pass `arg` parameters , same as tessearct official documentation
  /// to add multiple Languages , all tessdata in a folder , and place that folder in web/
  /// and pass folder name in `languageFolder`
  static Future<TesseractWorker> getWorker({
    List<String> languages = const ["eng"],
    Map? args,
    Function(TesseractLogs)? logsCallback,
    Function(String)? errorsCallback,
    String? languageFolder,
  }) async {
    String? lang;
    for (var element in languages) {
      lang = (lang == null) ? element : "$lang+$element";
    }

    var promiseData = _initWorker(
      jsify({
        "language": lang,
        "args": args!,
      }),
      allowInterop((logs) {
        logsCallback?.call(TesseractLogs.fromJson(logs));
      }),
      allowInterop((err) {
        errorsCallback?.call(err.toString());
      }),
      languageFolder == null ? null : "../$languageFolder",
    );
    var tesseractWorker = await promiseToFuture(promiseData);
    return TesseractWorker(worker: tesseractWorker, id: tesseractWorker.id);
  }
}

@JS('_initWorker')
external dynamic _initWorker(dynamic args, onLogs, onError, String? langPath);

@JS('_closeWorker')
external dynamic _closeWorker(dynamic worker);

@JS('_extractText')
external dynamic _extractText(dynamic imagePath, dynamic worker);
