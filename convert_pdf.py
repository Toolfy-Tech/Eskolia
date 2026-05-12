import fitz  # PyMuPDF
import os

# Noms de tes fichiers (à adapter si besoin)
pdf_path = "Cours TIP Hardware et Reseau.pdf"
md_path = "cours_complet.md"
image_dir = "images"

# Création du dossier d'images s'il n'existe pas
os.makedirs(image_dir, exist_ok=True)

# Ouverture du PDF
doc = fitz.open(pdf_path)
md_content = "# Cours Complet\n\n"
image_counter = 1

print(f"Début de la conversion de {len(doc)} pages...")

for page_num in range(len(doc)):
    page = doc[page_num]
    
    # 1. Extraction du texte
    text = page.get_text()
    md_content += text + "\n\n"
    
    # 2. Extraction des images
    images = page.get_images(full=True)
    for img_index, img in enumerate(images):
        xref = img[0]
        base_image = doc.extract_image(xref)
        image_bytes = base_image["image"]
        image_ext = base_image["ext"]
        
        # Formatage du nom : image_001.png
        image_name = f"image_{image_counter:03d}.{image_ext}"
        image_filepath = os.path.join(image_dir, image_name)
        
        # Sauvegarde de l'image
        with open(image_filepath, "wb") as f:
            f.write(image_bytes)
            
        # Ajout du lien dans le Markdown
        md_content += f"![Image {image_counter}](./{image_dir}/{image_name})\n\n"
        image_counter += 1

# Sauvegarde du fichier Markdown
with open(md_path, "w", encoding="utf-8") as f:
    f.write(md_content)

print(f"Succès ! {image_counter - 1} images extraites et sauvegardées dans {md_path}")
