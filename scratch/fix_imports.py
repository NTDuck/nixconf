import os
import glob

for path in glob.glob("den/v1/modules/features/**/*.nix", recursive=True):
    with open(path, "r") as f:
        content = f.read()
    
    # fix the paths: replace 5 ../ with 4 ../
    new_content = content.replace("../../../../../modules/", "../../../../modules/")
    
    with open(path, "w") as f:
        f.write(new_content)
