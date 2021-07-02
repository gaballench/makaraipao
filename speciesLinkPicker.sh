# this script uses slicer, a small program in bash that I wrote for that specific purpose. located at programs/general_scripts
# SPLINKFILE is the path to the specieslink file directory
SPLINKFILE=speciesLink_all_49771_20190521013813.txt


# Callichthyidae
slicer Callichthyidae $SPLINKFILE
cp *out callichthyidae/
rm *out

# Lepidosiren
slicer Lepidosiren $SPLINKFILE
cp *out lepidosiren/
rm *out

# Phractocephalus
slicer Phractocephalus $SPLINKFILE
cp *out phractocephalus/
rm *out

# Serrasalmidae
slicer Serrasalmidae $SPLINKFILE
cp *out serrasalmidae/
rm *out

