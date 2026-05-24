import os

image_set = set()
for cd, dirs, files in os.walk("."):
    for file in files:
        if file == "print-trans.py":
            continue
        path = os.path.join(cd, file)
        if not (path.endswith(".yaml") or path.endswith(".yml") or path.endswith(".sh")):
            continue

        with open(path, "r", encoding='utf8') as f:
            for line in f.readlines():
                if 'trans-image-name ' not in line:
                    continue
                line = line.split('trans-image-name ')[-1].split(')')[0].split('`')[0].strip('\\ )\n')
                if ':' not in line:
                    continue
                if '{' in line:
                    continue
                image_set.add(line)

for img in image_set:
    print(img)
