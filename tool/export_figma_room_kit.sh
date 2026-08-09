#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kit_dir="$repo_dir/design/figma_room_layout"
items_dir="$kit_dir/items"
background_dir="$kit_dir/background"
main_atlas="$repo_dir/assets/visuals/v2/main_item_atlas_v2.png"
reward_atlas="$repo_dir/assets/visuals/v2/reward_avatar_atlas_v2.png"
background="$repo_dir/assets/visuals/v2/empty_room_base_v2.png"
dimensions_csv="$kit_dir/asset_dimensions.csv"

for command_name in ffmpeg ffprobe; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "$command_name is required to export the Figma room kit." >&2
    exit 1
  fi
done

mkdir -p "$items_dir" "$background_dir"
cp "$background" "$background_dir/empty_room_base_v2.png"
printf 'item_id,pixel_width,pixel_height\n' > "$dimensions_csv"

export_item() {
  local item_id="$1"
  local source="$2"
  local columns="$3"
  local rows="$4"
  local column="$5"
  local row="$6"
  local output="$items_dir/$item_id.png"
  local image_size image_width image_height
  local cell_left cell_top cell_right cell_bottom cell_width cell_height
  local detected crop_width crop_height crop_left crop_top
  local padding=5
  local local_left local_top local_right local_bottom
  local output_width output_height absolute_left absolute_top

  image_size="$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=width,height -of csv=s=x:p=0 "$source")"
  image_width="${image_size%x*}"
  image_height="${image_size#*x}"

  cell_left=$((image_width * column / columns))
  cell_top=$((image_height * row / rows))
  cell_right=$((image_width * (column + 1) / columns))
  cell_bottom=$((image_height * (row + 1) / rows))
  cell_width=$((cell_right - cell_left))
  cell_height=$((cell_bottom - cell_top))

  detected="$(ffmpeg -hide_banner -loglevel verbose -loop 1 -i "$source" \
    -vf "crop=${cell_width}:${cell_height}:${cell_left}:${cell_top},alphaextract,cropdetect=limit=0.01:round=2:reset=0" \
    -frames:v 3 -f null - 2>&1 \
    | sed -n 's/.*crop=\([0-9][0-9]*:[0-9][0-9]*:[0-9][0-9]*:[0-9][0-9]*\)$/\1/p' \
    | tail -1)"
  if [[ -z "$detected" ]]; then
    echo "Could not detect non-transparent pixels for $item_id." >&2
    exit 1
  fi

  IFS=: read -r crop_width crop_height crop_left crop_top <<< "$detected"
  local_left=$((crop_left > padding ? crop_left - padding : 0))
  local_top=$((crop_top > padding ? crop_top - padding : 0))
  local_right=$((crop_left + crop_width + padding))
  local_bottom=$((crop_top + crop_height + padding))
  ((local_right > cell_width)) && local_right="$cell_width"
  ((local_bottom > cell_height)) && local_bottom="$cell_height"

  output_width=$((local_right - local_left))
  output_height=$((local_bottom - local_top))
  absolute_left=$((cell_left + local_left))
  absolute_top=$((cell_top + local_top))

  ffmpeg -hide_banner -loglevel error -y -i "$source" \
    -vf "crop=${output_width}:${output_height}:${absolute_left}:${absolute_top},format=rgba" \
    -frames:v 1 "$output"
  printf '%s,%s,%s\n' "$item_id" "$output_width" "$output_height" \
    >> "$dimensions_csv"
}

# Main focus progression items. Arguments after the atlas are:
# columns, rows, column, row.
export_item desk "$main_atlas" 4 3 0 0
export_item chair "$main_atlas" 4 3 1 0
export_item rug "$main_atlas" 4 3 3 0
export_item bookshelf "$main_atlas" 4 3 1 1
export_item candle "$main_atlas" 4 3 2 1
export_item wall_art "$main_atlas" 4 3 3 1
export_item hanging_plant "$main_atlas" 4 3 0 2
export_item sleeping_cat "$main_atlas" 4 3 1 2

# Gentle Goal Box collection items.
export_item tea_cup "$reward_atlas" 4 4 0 0
export_item night_fern "$reward_atlas" 4 4 0 1
export_item owl_figure "$reward_atlas" 4 4 1 1
export_item leaf_lantern "$reward_atlas" 4 4 2 1

echo "Figma room kit exported to: $kit_dir"
