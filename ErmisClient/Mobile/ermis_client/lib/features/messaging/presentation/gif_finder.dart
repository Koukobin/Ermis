/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../theme/app_colors.dart';

final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class GifFinder extends StatefulWidget {
  const GifFinder({super.key});

  @override
  State<GifFinder> createState() => _GifFinderState();
}

class _GifFinderState extends State<GifFinder> {
  static const int limit = 19;

  late Future<Map> gifsFuture;

  String _search = '';
  int _offset = 0;

  Future<Map> _getGifs() async {
    if (_search.isEmpty) {
      _search = "trending";
    }

    http.Response response;
    response = await http.get(Uri.parse(
        'https://api.giphy.com/v1/gifs/search?api_key=IyO7FLT2n9WFb7wJA4qx1cXf68IoBq42&q=$_search&limit=$limit&offset=$_offset&rating=g&lang=pt'));

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    gifsFuture = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Scaffold(
        backgroundColor: appColors.tertiaryColor,
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.clear),
                  labelText: S().search,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                textAlign: TextAlign.center,
                onSubmitted: (text) {
                  setState(() {
                    _search = text;
                    _offset = 0;
                  });
      
                  gifsFuture = _getGifs();
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: gifsFuture,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      debugPrint('${snapshot.data}');
                      if (snapshot.hasError || snapshot.data?['data'] == null) {
                        return const SizedBox();
                      }

                      final data = snapshot.data!['data'];

                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            "Nothing found",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: data.length + 1,
                        itemBuilder: (context, index) {
                          if (index == data.length) {
                            return GestureDetector(
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 60.0,
                                  ),
                                  Text(
                                    "Loading...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (data.length < limit) {
                                  return;
                                }

                                setState(() {
                                  _offset += limit;
                                });

                                gifsFuture = _getGifs();
                              },
                            );
                          }

                          final image =
                              data[index]['images']['fixed_height']['url'];

                          return GestureDetector(
                            child: FadeInImage.memoryNetwork(
                              placeholder: _kTransparentImage,
                              image: image,
                              height: 300.0,
                              fit: BoxFit.cover,
                            ),
                            onTap: () {
                              Navigator.pop(context, image);
                            },
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
