import re as regex
from tika import parser
import xmltodict

parse_entire_pdf = parser.from_file('invoice5.pdf', xmlContent=True)
for key, values in parse_entire_pdf.items():
    if key == 'content':
        print(values)

# parsed = parser.from_file('invoice5.pdf')
# print(parsed["metadata"])
# print(parsed["content"])

# parse_entire_pdf = parser.from_file('invoice5.pdf', xmlContent=True)
# my_dict = xmltodict.parse(parse_entire_pdf["content"])

# print(my_dict)