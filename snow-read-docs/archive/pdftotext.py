import pdftotext
import io

# pdf file object
pdfFileObj=open('invoice9.pdf','rb')
pdf = pdftotext.PDF(pdfFileObj)

# Iterate over all the pages
for page in pdf:
    print(page)