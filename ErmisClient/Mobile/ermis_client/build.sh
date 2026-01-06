#!/bin/bash

flutter clean
flutter pub get
dart run flutter_launcher_icons
dart run intl_utils:generate
dart run build_runner build --delete-conflicting-outputs

# Compile SVG doodle icons into a binary format that is
# faster to parse and can optimize SVGs to reduce the amount
# of clipping, masking, and overdraw.
cd assets/chat_backgrounds/doodle_icons
rm -r vg
i=0
for f in SVG/**/*.svg; do
  out="vg/$i.vg"
  mkdir -p "$(dirname "$out")"
  dart run vector_graphics_compiler -i "$f" -o "$out"
  ((i++))
done

