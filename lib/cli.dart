import 'package:args/args.dart';
import 'package:qcsp/qcsp.dart';

void noop() {}

class CommandRunner {
  static const version = "0.1.0";
  final supportedAlgorihms = SupportedHashAlgorithm.toStringIterable();
  late final ArgParser _parser;

  CommandRunner() {
    _parser = ArgParser();
    _parser.addOption("algorithm",
        abbr: "a",
        allowed: supportedAlgorihms,
        defaultsTo: SupportedHashAlgorithm.sha256.name,
        help: "Algorithm supported by the CSP 2 standard");
    _parser.addFlag("help",
        abbr: "h", negatable: false, help: "Print usage information");
  }

  get help {
    return _help(_parser.usage);
  }

  Future<void> run(List<String> args) async {
    final results = _parser.parse(args);

    if (results.rest.isEmpty || results["help"]) {
      print(_help(_parser.usage));
      return;
    }

    final algo = SupportedHashAlgorithm.parse(results["algorithm"]);
    final paths = results.rest;

    for (final path in paths) {
      final hash = await hashFile(path, algo);
      final base64 = hashToBase64String(hash);
      final source = toHashSource(base64, algo);
      final String? maybePath = paths.length > 1 ? path : null;

      print([maybePath, source].nonNulls.join(":"));
    }
  }

  String _help(String usage) {
    return [
      "qcsp $version — Generate CSP compliant hash sources with a few keystrokes",
      "",
      "Usage: qcsp file [files] [options]",
      usage
    ].join("\n");
  }
}
