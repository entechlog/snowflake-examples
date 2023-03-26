# !pip install PDFQuery
# !pip install PyPDF2
# !pip install "camelot-py[base]"

from pdfquery import PDFQuery
from PyPDF2 import PdfReader
import camelot

pdf = PDFQuery('invoice1.pdf')
pdf.load()

# # Use CSS-like selectors to locate the elements
# text_elements = pdf.pq('LTTextLineHorizontal')

# # Extract the text from the elements
# text = [t.text for t in text_elements]

# print(text)

#convert the pdf to XML
pdf.tree.write('customers.xml', pretty_print = True)

# creating a pdf reader object
reader = PdfReader('invoice1.pdf')

# printing number of pages in pdf file
print(len(reader.pages))

# getting a specific page from the pdf file
page = reader.pages[0]

# extracting text from page
text = page.extract_text()
print(text)

# PDF file to extract tables from
file = "table.pdf"

# extract all the tables in the PDF file
tables = camelot.read_pdf(file)

# number of tables extracted
print("Total tables extracted:", tables.n)

print(tables[0].df)

# export individually as CSV
tables[0].to_json("foo.json")
