# Configure your paths and filenames
SOURCEBIN=$(basename $PWD)
DEBVERSION=1.0

DEBFOLDERNAME=$SOURCEBIN-$DEBVERSION

# Create your scripts source dir
mkdir $DEBFOLDERNAME

# Copy your script to the source dir
cp -r brief linux index.json brief-completion $DEBFOLDERNAME
cd $DEBFOLDERNAME

# Create the packaging skeleton (debian/*)
dh_make --indep --createorig --native || exit 1

# Remove make calls
grep -v makefile debian/rules > debian/rules.new
mv debian/rules.new debian/rules

# debian/install must contain the list of scripts to install 
# as well as the target directory
echo brief usr/bin > debian/install
echo linux usr/share/brief >> debian/install
echo index.json usr/share/brief >> debian/install
echo brief-completion/brief.bash usr/share >> debian/install

cp -f ../control debian/
cp -f ../postinst debian/

# Remove the example files
rm debian/*.ex

debuild -us -uc || exit 1

cd ..

rm -rf out

mkdir out

mv ${SOURCEBIN}_${DEBVERSION}_all.deb out/

rm -rf ${SOURCEBIN}_* ${SOURCEBIN}-*
