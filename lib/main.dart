import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: PhotoDisplayer(),
    );
  }
}

class PhotoDisplayer extends StatefulWidget {
  const PhotoDisplayer({super.key});

  @override
  State<PhotoDisplayer> createState() => _PhotoDisplayerState();
}

class _PhotoDisplayerState extends State<PhotoDisplayer> {
  List<AssetEntity> albums = [];
  @override
  void initState() {
    () async {
      try {
        final permission = await PhotoManager.requestPermissionExtend(
            requestOption: const PermissionRequestOption(
          androidPermission:
              AndroidPermission(type: RequestType.image, mediaLocation: true),
        ));
        print(permission);
        final List<AssetPathEntity> paths =
            await PhotoManager.getAssetPathList();
        // you can use dropdown or anything to select the path
        // here I just use the first path
        final assets = await paths[0].getAssetListPaged(page: 1, size: 100);
        albums = assets;
        setState(() {});
      } catch (e) {
        print(e);
      }
    }.call();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Displayer'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: albums[index].originBytes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final bytes = snapshot.data;
                if (bytes != null) {
                  return Image.memory(bytes, fit: BoxFit.cover);
                }
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
