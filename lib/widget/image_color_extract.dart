// import 'dart:math';
// import 'dart:typed_data';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' as svc;

// import 'package:image/image.dart' as image_extract;

// final List<String> photos = [
//   photo1,
//   photo2,
//   photo3,
//   photo4,
//   photo5,
//   photo6,
//   photo7,
//   photo8,
//   photo9,
//   photo10,
//   photo11
// ];

// String photo1 = 'https://iaa-network.com/wp-content/uploads/2021/03/Seychelles-arbitration-1.jpg';
// String photo2 = 'https://i.imgur.com/bmwGs4n.png';
// String photo3 = 'https://media.tac.com/media/attractions-splice-spp-674x446/07/6f/f1/aa.jpg';
// String photo4 = 'https://i.pinimg.com/originals/20/0b/95/200b95dfb2efa80d37479764a324b462.jpg';
// String photo5 = 'https://assets.rappler.co/612F469A6EA84F6BAE882D2B94A4B421/img/CDCC3B2965FC403F94CD4F3B158F1788/image-2019-01-21-3.jpg';
// String photo6 = 'https://c.wallpapersafari.com/68/60/HgzJbQ.jpg';
// String photo7 = 'https://wallpaperaccess.com/full/3879268.jpg';
// String photo8 = 'https://wallpapercave.com/wp/wp2461878.jpg';
// String photo9 = 'https://wallpapercave.com/wp/gLCTnod.jpg';
// String photo10 = 'https://c4.wallpaperflare.com/wallpaper/827/998/515/ice-cream-4k-in-hd-quality-wallpaper-preview.jpg';
// String photo11 = 'https://img5.goodfon.com/wallpaper/nbig/e/93/tort-malina-shokolad.jpg';

// String photo = photo1;

// int noOfPaletteColors = 4;

// class DDD extends StatefulWidget {
//   const DDD({super.key});

//   @override
//   State<DDD> createState() => _DDDState();
// }

// class _DDDState extends State<DDD> {
//   List<Color> colors = [];
//   List<Color> sortedColors = [];
//   List<Color> palette = [];

//   Color primary = Colors.blueGrey;
//   Color primaryText = Colors.black;
//   Color background = Colors.white;

//   late Random random;
//   Uint8List? imageBytes;

//   String keyPalette = 'palette';
//   String keyNoOfItems = 'noIfItems';

//   int noOfPixelsPerAxis = 12;

//   Color getAverageColor(List<Color> colors) {
//     int r = 0, g = 0, b = 0;

//     for (int i = 0; i < colors.length; i++) {
//       r += colors[i].red;
//       g += colors[i].green;
//       b += colors[i].blue;
//     }

//     r = r ~/ colors.length;
//     g = g ~/ colors.length;
//     b = b ~/ colors.length;

//     return Color.fromRGBO(r, g, b, 1);
//   }

//   Color abgrToColor(int argbColor) {
//     int r = (argbColor >> 16) & 0xFF;
//     int b = argbColor & 0xFF;
//     int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
//     return Color(hex);
//   }

//   List<Color> sortColors(List<Color> colors) {
//     List<Color> sorted = [];

//     sorted.addAll(colors);
//     sorted.sort((a, b) => b.computeLuminance().compareTo(a.computeLuminance()));

//     return sorted;
//   }

//   List<Color> generatePalette(Map<String, dynamic> params) {
//     List<Color> colors = [];
//     List<Color> palette = [];

//     colors.addAll(sortColors(params[keyPalette]));

//     int noOfItems = params[keyNoOfItems];

//     if (noOfItems <= colors.length) {
//       int chunkSize = colors.length ~/ noOfItems;

//       for (int i = 0; i < noOfItems; i++) {
//         palette.add(
//             getAverageColor(colors.sublist(i * chunkSize, (i + 1) * chunkSize)));
//       }
//     }

//     return palette;
//   }

//   List<Color> extractPixelsColors(Uint8List? bytes) {
//     List<Color> colors = [];

//     List<int> values = bytes!.buffer.asUint8List();
//     image_extract.Image? image = image_extract.decodeImage(values);

//     List<int?> pixels = [];

//     int? width = image?.width;
//     int? height = image?.height;

//     int xChunk = width! ~/ (noOfPixelsPerAxis + 1);
//     int yChunk = height! ~/ (noOfPixelsPerAxis + 1);

//     for (int j = 1; j < noOfPixelsPerAxis + 1; j++) {
//       for (int i = 1; i < noOfPixelsPerAxis + 1; i++) {
//         int? pixel = image?.getPixel(xChunk * i, yChunk * j);
//         pixels.add(pixel);
//         colors.add(abgrToColor(pixel!));
//       }
//     }

//     return colors;
//   }
  
//   Future<void> extractColors() async {
//     colors = [];
//     sortedColors = [];
//     palette = [];
//     imageBytes = null;

//     setState(() {});

//     noOfPaletteColors = random.nextInt(4) + 2;
//     photo = photos[random.nextInt(photos.length)];

//     imageBytes = (await svc.NetworkAssetBundle(Uri.parse(photo)).load(photo))
//         .buffer
//         .asUint8List();

//     colors = await compute(extractPixelsColors, imageBytes);
//     setState(() {});
//     sortedColors = await compute(sortColors, colors);
//     setState(() {});
//     palette = await compute(
//         generatePalette, {keyPalette: colors, keyNoOfItems: noOfPaletteColors});
//     primary = palette.last;
//     primaryText = palette.first;
//     background = palette.first.withOpacity(0.5);
//     setState(() {});
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }