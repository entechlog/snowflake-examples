import fitz
doc = fitz.open('table.pdf')
text = ""
for page in doc:
   print(page.get_text())
