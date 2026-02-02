class PdfViewerScreen extends StatelessWidget {
  final String path;
  const PdfViewerScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: SfPdfViewer.file(File(path)),
    );
  }
}