/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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


import 'package:ermis_client/client/io/byte_buf.dart';

void main() {
  ByteBuf buffer = ByteBuf.smallBuffer(growable: true);
  buffer.markReaderIndex();
  buffer.writeInt(3405);
  for (var i = 0; i < 20000; i++) {
    buffer.writeInt(i);
  }
  buffer.resetReaderIndex();

  final regex = RegExp(r'^[^!"#\$%&\()*+,\-./:;<=>?@\[\]^_`{|}~]*$');

  final validInput = "ilias";
  final invalidInput = "ilias";

  print(regex.hasMatch(validInput)); // true (valid input)
  print(regex.hasMatch(invalidInput)); // false (invalid input)
}

// class ErmisDoodlePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey.withOpacity(0.2) // Subtle doodle color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     // Draw Circles
//     for (double x = 0; x < size.width; x += 50) {
//       for (double y = 0; y < size.height; y += 50) {
//         canvas.drawCircle(Offset(x, y), 15, paint);
//       }
//     }

//     // Draw Wavy Lines
//     for (double y = 20; y < size.height; y += 100) {
//       final path = Path();
//       path.moveTo(0, y);
//       for (double x = 0; x < size.width; x += 50) {
//         path.quadraticBezierTo(x + 25, y + 20, x + 50, y);
//       }
//       canvas.drawPath(path, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false; // Redraw only if necessary
//   }
// }

// class ErmisChatBackground extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Ermis Chat')),
//       body: Stack(
//         children: [
//           // Custom doodle background
//           CustomPaint(
//             painter: ErmisDoodlePainter(),
//             size: MediaQuery.of(context).size,
//           ),
//           // Chat messages
//           ListView.builder(
//             itemCount: 20,
//             padding: EdgeInsets.all(10),
//             itemBuilder: (context, index) {
//               return Align(
//                 alignment: index % 2 == 0
//                     ? Alignment.centerLeft
//                     : Alignment.centerRight,
//                 child: Container(
//                   margin: EdgeInsets.symmetric(vertical: 5),
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: index % 2 == 0
//                         ? Colors.blue.shade100
//                         : Colors.green.shade100,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     "Message $index",
//                     style: TextStyle(color: Colors.black),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CircleScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Circle to Rectangle')),
//       body: Center(
//         child: GestureDetector(
//           onTap: () {
//             // Navigate to the next screen
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => RectangleScreen()),
//             );
//           },
//           child: Hero(
//             tag: 'circle-to-rectangle',  // Unique Hero tag for this animation
//             child: PersonalProfilePhoto(radius: 50),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class RectangleScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Rectangle Transformation')),
//       body: Center(
//         child: Hero(
//           tag: 'circle-to-rectangle',  // Same tag for the Hero animation
//           child: PersonalProfilePhoto(radius: 80),
//         ),
//       ),
//     );
//   }
// }