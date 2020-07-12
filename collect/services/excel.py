import pandas as pd

class Excel:
    def __init__(self, filename="output.xlsx"):
        self.writer = pd.ExcelWriter(filename)
    
    def write(self, data, sheet_name):
        df = pd.DataFrame(data)
        df.to_excel(self.writer, sheet_name=sheet_name)
        self.writer.save()