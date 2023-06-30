import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../providers/image_provider.dart';

class ImageCompressionSection extends StatefulWidget {
  const ImageCompressionSection({super.key});

  @override
  State<ImageCompressionSection> createState() => _ImageCompressionSectionState();
}

class _ImageCompressionSectionState extends State<ImageCompressionSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Selector<AppImageProvider, Uint8List?>(
            selector: (_, provider) => provider.displayedImageBytes,
            builder: (context, imageBytes, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    width: constraints.maxWidth * 0.6,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: imageBytes != null ? Image.memory(imageBytes) : const PlaceholderWidget(),
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<AppImageProvider>().pickImage();
                  },
                  child: const Text(
                    "Upload Image",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Selector<AppImageProvider, Tuple2<Completer<dynamic>?, Completer<dynamic>?>>(
                  shouldRebuild: (previous, next) {
                    final prevCompressImageCompleter = previous.item1;
                    final nextCompressImageCompleter = next.item1;
                    final prevDecompressImageCompleter = previous.item2;
                    final nextDecompressImageCompleter = next.item2;

                    //previous != next || previous?.isCompleted != next?.isCompleted || (previous?.isCompleted ?? false)
                    final provider = context.read<AppImageProvider>();
                    final actionState = provider.imageActionType;

                    if (actionState == ImageActionType.compress) {
                      return prevCompressImageCompleter != nextCompressImageCompleter || prevCompressImageCompleter?.isCompleted != nextCompressImageCompleter?.isCompleted || (prevCompressImageCompleter?.isCompleted ?? false);
                    }

                    if (actionState == ImageActionType.decompress) {
                      return prevDecompressImageCompleter != nextDecompressImageCompleter || prevDecompressImageCompleter?.isCompleted != nextDecompressImageCompleter?.isCompleted || (prevDecompressImageCompleter?.isCompleted ?? false);
                    }

                    return true;
                  },
                  builder: (context, tuple, child) {
                    final compressImageCompleter = tuple.item1;
                    final decompressImageCompleter = tuple.item2;
                    final actionState = context.read<AppImageProvider>().imageActionType;
                    // check if one of the completer is not null
                    if (compressImageCompleter != null || decompressImageCompleter != null) {
                      // check if one of the completer is not completed and not null
                      // then display the loading widget
                      if (actionState == ImageActionType.compress) {
                        if (compressImageCompleter != null && !compressImageCompleter.isCompleted) {
                          return loadingWidget();
                        }
                      } else if (actionState == ImageActionType.decompress) {
                        if (decompressImageCompleter != null && !decompressImageCompleter.isCompleted) {
                          return loadingWidget();
                        }
                      }
                    }

                    return Selector<AppImageProvider, String?>(
                      builder: (context, imageExtension, child) {
                        if (imageExtension == null) {
                          return const SizedBox();
                        }

                        if (imageExtension.toLowerCase() == 'li') {
                          return ElevatedButton(
                            onPressed: () {
                              context.read<AppImageProvider>().decompressImage();
                            },
                            child: const Text("Decompress"),
                          );
                        }

                        return ElevatedButton(
                          onPressed: () {
                            context.read<AppImageProvider>().compressImage();
                          },
                          child: const Text("Compress"),
                        );
                      },
                      selector: (context, provider) => provider.pickedImageExtension,
                    );
                  },
                  selector: (context, provider) => Tuple2(provider.compressedImageCompleter, provider.decompressedImageCompleter),
                ),
                Selector<AppImageProvider, Uint8List?>(
                  builder: (context, compressedImage, child) {
                    if (compressedImage == null) {
                      return const SizedBox();
                    }
                    return Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.read<AppImageProvider>().downloadCompressedImage();
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text("Download file"),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Compressed Image Size: ${compressedImage.lengthInBytes / 1000} KB",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                  selector: (context, provider) => provider.downloadableImageBytes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  loadingWidget() {
    final provider = context.read<AppImageProvider>();
    final String state = provider.imageActionType == ImageActionType.compress ? "Compressing" : "Decompressing";
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        Text("$state image"),
        const Text("Please Wait... This may take a while"),
        const SizedBox(
          height: 16,
        ),
        const CircularProgressIndicator(),
      ],
    );
  }
}

class PlaceholderWidget extends StatefulWidget {
  const PlaceholderWidget({super.key});

  @override
  State<PlaceholderWidget> createState() => _PlaceholderWidgetState();
}

class _PlaceholderWidgetState extends State<PlaceholderWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AppImageProvider>().pickImage();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) => SizedBox(
                  width: constraints.maxWidth * 0.4,
                  child: Image.asset(
                    "assets/images/image_placeholder.png",
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
