import nougat
import os
from pathlib import Path
import io

def patch_rasterize():
    nougat_dir = Path(nougat.__file__).parent
    rasterize_file = nougat_dir / "dataset" / "rasterize.py"
    
    print(f"Patching {rasterize_file}...")
    content = rasterize_file.read_text()
    
    # Patch 1: Fix Path object issue in pypdfium2
    old_cast = "pdf = pypdfium2.PdfDocument(pdf)"
    new_cast = "pdf = pypdfium2.PdfDocument(str(pdf))"
    
    if old_cast in content:
        content = content.replace(old_cast, new_cast)
        print("Applied Patch 1: Cast Path to str")
    elif new_cast in content:
        print("Patch 1 already applied")
    else:
        print("Warning: Could not find code for Patch 1")

    # Patch 2: Replace parallel render with serial render (fixes API and segfaults)
    old_render_block = """        renderer = pdf.render(
            pypdfium2.PdfBitmap.to_pil,
            page_indices=pages,
            scale=dpi / 72,
        )
        for i, image in zip(pages, renderer):
            if return_pil:
                page_bytes = io.BytesIO()
                image.save(page_bytes, "bmp")
                pils.append(page_bytes)
            else:
                image.save((outpath / ("%02d.png" % (i + 1))), "png")"""

    new_render_block = """        for i in pages:
            page = pdf[i]
            bitmap = page.render(scale=dpi / 72)
            image = bitmap.to_pil()
            if return_pil:
                page_bytes = io.BytesIO()
                image.save(page_bytes, "bmp")
                pils.append(page_bytes)
            else:
                image.save((outpath / ("%02d.png" % (i + 1))), "png")"""

    if old_render_block in content:
        content = content.replace(old_render_block, new_render_block)
        print("Applied Patch 2: Serial rendering")
    elif new_render_block in content:
        print("Patch 2 already applied")
    else:
        # Fallback: Try to find it with slightly different whitespace or context if needed
        # But for now, we assume standard install.
        print("Warning: Could not find code for Patch 2")
        
    rasterize_file.write_text(content)
    print("Patches written to disk.")

if __name__ == "__main__":
    patch_rasterize()
