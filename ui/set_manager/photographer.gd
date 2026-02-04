class_name Photographer
extends SubViewportContainer

const IMAGE_PATH = "user://TileImages/"

@onready var subviewport: SubViewport = $%SubViewport
@onready var tile_preview: TilePreview = $%TilePreview

func generate_images_of_tiles(subjects: Array[Tile]):
  for subject in subjects:
    var img_path = IMAGE_PATH + subject.id + ".png"
    if File.file_exists(img_path):
      continue
    tile_preview.set_tile(subject)
    subviewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    await RenderingServer.frame_post_draw
    var img: Image = tile_preview.get_image()
    File.write_image_as_png(img_path, img)
    print("Generated image for tile %s at %s" % [subject.name, img_path])
