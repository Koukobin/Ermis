import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

LinkMode getLinkMode(LinkModePreference preference) {
  if (preference == LinkModePreference.dynamic ||
      preference == LinkModePreference.preferDynamic) {
    return DynamicLoadingBundled();
  }
  assert(preference == LinkModePreference.static ||
      preference == LinkModePreference.preferStatic);
  return StaticLinking();
}

void main(List<String> args) async {
  await build(args, (BuildConfig config, output) async {
    final packageName = config.packageName;
    // Define paths
    final outDir = config.outputDirectory;

    final goFile = 'src/$packageName.go';
    final outputLibrary = 'build/lib$packageName.so'; // Adjust for target platform (.dll, .dylib)

    // final linkMode = getLinkMode(config.codeConfig.linkModePreference);
    // final libUri = outDir.resolve(config.codeConfig.targetOS.libraryFileName(name, linkMode));

    // Ensure the output directory exists
    final outputDir = Directory('build');
    outputDir.createSync(recursive: true);

    // Go build command
    final result = await Process.run(
      'go',
      [
        'build',
        '-o',
        outputLibrary,
        '-buildmode=c-shared',
        goFile,
      ],
    );

    if (result.exitCode != 0) {
      stderr.writeln('Failed to build Go library:');
      stderr.writeln(result.stderr);
      exit(1);
    } else {
      stdout.writeln('Successfully built Go library: $outputLibrary');
    }

    // Optional: Log build details
    final logger = Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) => stdout.writeln(record.message));
    logger.info('Go library built: $outputLibrary');
    // final cbuilder = CBuilder.library(
    //   name: packageName,
    //   assetName: '$packageName.dart',
    //   optimizationLevel: OptimizationLevel.o3,
    //   sources: [
    //     'src/$packageName.c',
    //   ],
    // );
    // await cbuilder.run(
    //   config: input,
    //   output: output,
    //   logger: Logger('')
    //     ..level = Level.ALL
    //     ..onRecord.listen((record) => print(record.message)),
    // );
  });
}