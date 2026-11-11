// Coverage gate: dart run tool/coverage_check.dart <lcov> <dir prefix> <min %>
import 'dart:io';

class FileCoverage {
  FileCoverage(this.path, this.hit, this.total);

  final String path;
  final int hit;
  final int total;

  double get percent => total == 0 ? 100 : hit * 100 / total;
}

class CoverageResult {
  CoverageResult(this.files, this.threshold);

  final List<FileCoverage> files;
  final double threshold;

  List<FileCoverage> get failing =>
      files.where((f) => f.percent < threshold).toList();

  bool get passed => files.isNotEmpty && failing.isEmpty;
}

/// Parses lcov text into per-file line coverage (DA records), keyed by the
/// source path normalised to forward slashes.
Map<String, FileCoverage> parseLcov(String lcov) {
  final result = <String, FileCoverage>{};
  String? path;
  var hit = 0;
  var total = 0;
  for (final raw in lcov.split(RegExp(r'\r?\n'))) {
    final line = raw.trim();
    if (line.startsWith('SF:')) {
      path = line.substring(3).replaceAll(r'\', '/');
      hit = 0;
      total = 0;
    } else if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      total++;
      if (parts.length > 1 && (int.tryParse(parts[1]) ?? 0) > 0) hit++;
    } else if (line == 'end_of_record' && path != null) {
      result[path] = FileCoverage(path, hit, total);
      path = null;
    }
  }
  return result;
}

CoverageResult evaluate(String lcov, String prefix, double threshold) {
  final normalised = prefix.replaceAll(r'\', '/');
  final dir = normalised.endsWith('/') ? normalised : '$normalised/';
  final files =
      parseLcov(lcov).values.where((f) => f.path.startsWith(dir)).toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return CoverageResult(files, threshold);
}

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln(
      'Usage: dart run tool/coverage_check.dart <lcov> <dir> <min percent>',
    );
    exit(2);
  }
  final threshold = double.parse(args[2]);
  final result = evaluate(File(args[0]).readAsStringSync(), args[1], threshold);
  if (result.files.isEmpty) {
    stderr.writeln('No files under ${args[1]} found in ${args[0]}');
    exit(1);
  }
  for (final f in result.files) {
    stdout.writeln(
      '${f.percent.toStringAsFixed(1).padLeft(6)}%  ${f.hit}/${f.total}  ${f.path}',
    );
  }
  final failing = result.failing;
  if (failing.isNotEmpty) {
    stdout.writeln('FAIL: below $threshold%:');
    for (final f in failing) {
      stdout.writeln('  ${f.path} ${f.percent.toStringAsFixed(1)}%');
    }
    exit(1);
  }
  stdout.writeln('OK: all files >= $threshold%');
}
