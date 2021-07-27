from urllib.request import urlretrieve
import zipfile


urlretrieve("https://nightly.link/Sairion350/OOPapyrus/workflows/main/main/OOPapyrus.zip", "OOPapyrus.zip")
zip = ZipFile('OOPapyrus.zip')
zip.extractall()
zip.close()