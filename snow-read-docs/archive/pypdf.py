from PyPDF2 import PdfReader
reader = PdfReader("invoice5.pdf")
num_of_pages = reader.pages
if num_of_pages:
	print("Found {} pages".format(len(num_of_pages)))
	pages_content = []
	for page in reader.pages:
		text = page.extract_text()
		pages_content.append(text)
		print(text)
else:
	print("Empty PDF, nothing to read")