from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
import os

def create_pdfs(num_pdfs, output_folder=r"D:\PDF"):
    # Make sure the directory exists
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for i in range(1, num_pdfs + 1):
        file_path = os.path.join(output_folder, f"document_{i}.pdf")
        c = canvas.Canvas(file_path, pagesize=A4)
        c.drawString(100, 750, f"This is PDF number {i}")
        c.save()
        print(f"✅ Created: {file_path}")

# Run it
create_pdfs(5)
