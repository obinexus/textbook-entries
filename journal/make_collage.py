import os
from PIL import Image

# Path to your images
folder = r"C:\Users\OBINexus\OneDrive\Pictures\Art"
output_file = os.path.join(folder, "collage.png")

# File extensions to include
extensions = [".png", ".jpg", ".jpeg"]

# Collect all image paths
image_files = [os.path.join(folder, f) for f in os.listdir(folder)
               if os.path.splitext(f.lower())[1] in extensions]

if not image_files:
    raise ValueError("No images found in the folder.")

# Open all images
images = [Image.open(img).convert("RGB") for img in image_files]

# Resize all images to the same size (smallest image size to keep it safe)
min_width = min(img.width for img in images)
min_height = min(img.height for img in images)
images = [img.resize((min_width, min_height)) for img in images]

# Collage grid size (square-ish)
import math
cols = math.ceil(math.sqrt(len(images)))
rows = math.ceil(len(images) / cols)

# Create blank canvas
collage = Image.new("RGB", (cols * min_width, rows * min_height), color=(255, 255, 255))

# Paste images into grid
for idx, img in enumerate(images):
    x = (idx % cols) * min_width
    y = (idx // cols) * min_height
    collage.paste(img, (x, y))

# Save collage
collage.save(output_file)
print(f"Collage saved at: {output_file}")

