from shutil import copyfile

languages = ["JAPANESE", "CZECH", "FRENCH", "GERMAN", "ITALIAN", "POLISH", "RUSSIAN", "SPANISH"]

for i in languages:
	copyfile("Interface/translations/OStim_ENGLISH.txt", "Interface/translations/OStim_" + i + ".txt")