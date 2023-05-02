// inject tesseractJs file first
var script = document.createElement("script");
script.src = "https://unpkg.com/tesseract.js@3.0.2/dist/tesseract.min.js";
document.head.appendChild(script);

// method to get Tessearct Worker
async function _initWorker(mapData, onLogs, onError, lang_path) {
  let worker_args = {};
  if (onLogs != null) {
    worker_args.logger = function (m) {
      onLogs(JSON.stringify(m));
    };
  }
  if (lang_path != null) {
    worker_args.langPath = lang_path;
  }
  if (onError != null) {
    worker_args.errorHandler = function (e) {
      onError(JSON.stringify(e));
    };
  }
  var worker = Tesseract.createWorker(worker_args);
  await worker.load();
  await worker.loadLanguage(mapData.language);
  await worker.initialize(mapData.language);
  await worker.setParameters(mapData.args);
  return worker;
}

// method to get text out of worker
async function _extractText(imagePath, worker) {
  var rtn = await worker.recognize(imagePath, {}, worker.id);
  return rtn.data.text;
}

// Close Worker
async function _closeWorker(worker) {
  await worker.terminate();
}
