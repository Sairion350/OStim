from urllib.request import urlretrieve
import zipfile


urlretrieve("https://nightly.link/Sairion350/OOPapyrus/workflows/main/main/OOPapyrus.zip", "OOPapyrus.zip")
zip = ZipFile('file.zip')
zip.extractall()
zip.close()