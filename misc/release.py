import os
import shutil

print("building starry...")
assert os.system("just --set RELEASE speed build-starry") == 0

if os.path.exists("dist"):
	print("dist/ directory already exists, cleaning up")
	shutil.rmtree("dist")

print("copying files...")
starryexe = "starry.exe" if os.name == "nt" else "starry.bin"

os.makedirs("dist")

# no extension is more unixpilled
shutil.copy2(starryexe, f"dist/{starryexe.replace(".bin", "")}")
# not strictly necessary but why not
if os.name == "nt":
	shutil.copy2("starry.pdb", "dist/starry.pdb")

shutil.copy2("LICENSE", "dist/LICENSE.txt")
shutil.copy2("3rdparty_licenses.txt", "dist/3rdparty_licenses.txt")
shutil.copytree("lualibs", "dist/lualibs")
shutil.copytree("samples", "dist/samples")
shutil.copytree("docs", "dist/docs", ignore=lambda _, __: "docs/dev")

print("creating shortcuts...")
samples = ["hello"]
for sample in samples:
	if os.name == "nt":
		with open(f"dist/samples/{sample}.cmd", 'w') as f:
			f.write("@echo off\r\n")
			f.write(f"\"%~dp0\\..\\starry.exe\" -app-dir:%~dp0\\{sample}\r\n")
	else:
		with open(f"dist/samples/{sample}.sh", 'w') as f:
			f.write("#!/usr/bin/sh\n")
			f.write(f"../starry -app-dir:{sample}\n")

		assert os.system(f"chmod +x dist/samples/{sample}.sh") == 0
