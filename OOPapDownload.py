from urllib.request import urlretrieve
import zipfile


urlretrieve("https://nightly.link/Sairion350/OOPapyrus/workflows/main/main/OOPapyrus.zip", "OOPapyrus.zip")
with zipfile.ZipFile("OOPapyrus.zip","r") as zip_ref:
    zip_ref.extractall()