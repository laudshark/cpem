import 'dart:io';

// Work around Windows web debug runs that break when Flutter passes a symlinked
// web SDK path through to the frontend server.
Future<void> main(List<String> args) async {
  final File dartExecutable = File(Platform.resolvedExecutable);
  final Directory binDirectory = dartExecutable.parent;
  final String runtimePath = _binaryPath(binDirectory.path, 'dartaotruntime');
  final String frontendServerSnapshotPath = [
    binDirectory.path,
    'snapshots',
    'frontend_server_aot.dart.snapshot',
  ].join(Platform.pathSeparator);

  final Process compiler = await Process.start(
    runtimePath,
    <String>[frontendServerSnapshotPath, ...normalizeFrontendServerArgs(args)],
    mode: ProcessStartMode.inheritStdio,
  );

  exit(await compiler.exitCode);
}

List<String> normalizeFrontendServerArgs(List<String> args) {
  final List<String> normalizedArgs = <String>[];

  for (int index = 0; index < args.length; index += 1) {
    final String argument = args[index];

    if (argument == '--sdk-root' && index + 1 < args.length) {
      normalizedArgs
        ..add(argument)
        ..add(normalizeSdkRootArgument(args[++index]));
      continue;
    }

    if (argument.startsWith('--sdk-root=')) {
      normalizedArgs.add(
        '--sdk-root=${normalizeSdkRootArgument(argument.substring('--sdk-root='.length))}',
      );
      continue;
    }

    if (argument == '--platform' && index + 1 < args.length) {
      normalizedArgs
        ..add(argument)
        ..add(normalizePlatformArgument(args[++index]));
      continue;
    }

    if (argument.startsWith('--platform=')) {
      normalizedArgs.add(
        '--platform=${normalizePlatformArgument(argument.substring('--platform='.length))}',
      );
      continue;
    }

    normalizedArgs.add(argument);
  }

  return normalizedArgs;
}

String normalizeSdkRootArgument(String value) {
  final String? resolvedPath = _resolveDirectoryPath(value);
  final String normalizedPath = _normalizeSeparators(resolvedPath ?? value);
  return normalizedPath.endsWith('/') ? normalizedPath : '$normalizedPath/';
}

String normalizePlatformArgument(String value) {
  try {
    final Uri uri = Uri.parse(value);
    if (uri.scheme != 'file') {
      return value;
    }

    final File platformFile = File.fromUri(uri);
    if (!platformFile.existsSync()) {
      return value;
    }

    final String resolvedPath = platformFile.resolveSymbolicLinksSync();
    return Uri.file(resolvedPath, windows: Platform.isWindows).toString();
  } on FileSystemException {
    return value;
  } on FormatException {
    return value;
  }
}

String _binaryPath(String directoryPath, String fileStem) {
  final String extension = Platform.isWindows ? '.exe' : '';
  return [directoryPath, '$fileStem$extension'].join(Platform.pathSeparator);
}

String? _resolveDirectoryPath(String rawPath) {
  final String candidatePath = _stripTrailingSeparators(rawPath);
  final Directory directory = Directory(candidatePath);
  if (!directory.existsSync()) {
    return null;
  }

  try {
    return directory.resolveSymbolicLinksSync();
  } on FileSystemException {
    return directory.absolute.path;
  }
}

String _stripTrailingSeparators(String value) {
  if (RegExp(r'^[A-Za-z]:[\\/]*$').hasMatch(value)) {
    return value;
  }

  return value.replaceFirst(RegExp(r'[\\/]+$'), '');
}

String _normalizeSeparators(String value) => value.replaceAll('\\', '/');
