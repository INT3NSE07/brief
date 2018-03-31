# Configure your paths and filenames
SOURCEBIN=$(basename $PWD)
DEBVERSION=1.0

DEBFOLDERNAME=$SOURCEBIN-$DEBVERSION

# Create your scripts source dir
mkdir $DEBFOLDERNAME

# Copy your script to the source dir
cp -r tldr linux index.json autocomp.bash $DEBFOLDERNAME
cd $DEBFOLDERNAME

# Create the packaging skeleton (debian/*)
dh_make --indep --createorig || exit 1

# Remove make calls
grep -v makefile debian/rules > debian/rules.new
mv debian/rules.new debian/rules

# debian/install must contain the list of scripts to install 
# as well as the target directory
echo tldr usr/bin > debian/install
echo linux usr/share/tldr-pages >> debian/install
echo index.json usr/share/tldr-pages >> debian/install
echo autocomp.bash usr/share/tldr-pages >> debian/install

cp -f ../control debian/

# Remove the example files
rm debian/*.ex

debuild -us -uc || exit 1

cd ..

rm -rf out

mkdir out

mv ${SOURCEBIN}_${DEBVERSION}-1_all.deb out/

rm -rf $SOURCEBIN*
