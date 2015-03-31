import 'dart:io';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:analyzer/src/generated/scanner.dart';
import 'package:analyzer/src/generated/sdk_io.dart' show DirectoryBasedDartSdk;
import 'package:path/path.dart';

void main(args) {
  var sdkPath = args[0];
  var packagesPath = args[1];
  var files = new Directory(join(packagesPath, "stagexl")).listSync(recursive: true);
  var fileToResolve = join(packagesPath, "stagexl", "src", "animation", "tween.dart");

  JavaSystemIO.setProperty("com.google.dart.sdk", sdkPath);
  var sdk = DirectoryBasedDartSdk.defaultSdk;

  var resolvers = [
      new DartUriResolver(sdk),
      new PackageUriResolver([new JavaFile(packagesPath)]),
      new FileUriResolver()];

  var analysisContext = AnalysisEngine.instance.createAnalysisContext();
  analysisContext.sourceFactory = new SourceFactory(resolvers);

  var changeSet = new ChangeSet();
  files.forEach((File f) {
    Source s = new FileBasedSource.con1(new JavaFile(f.path));
    changeSet.addedSource(s);
  });

  analysisContext.applyChanges(changeSet);

  var source = new FileBasedSource.con1(new JavaFile(fileToResolve));
  var librarySource = new FileBasedSource.con1(new JavaFile(join(packagesPath, "stagexl", "stagexl.dart")));
  var library = analysisContext.computeLibraryElement(librarySource);
  print("Library: $library");
  var compilationUnit = analysisContext.resolveCompilationUnit(source, library);
  print("Compilation Unit: $compilationUnit");
}
