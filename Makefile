PACKAGE_NAME ?= brief
PREFIX ?= usr
BINDIR ?= ${PREFIX}/bin
SHARE_PREFIX ?= ${PREFIX}/share
DEBVERSION ?= 1.0
DEBFOLDERNAME ?= ${PACKAGE_NAME}-${DEBVERSION}
OUT_DIR ?= out

all: build install

.PHONY: all build install clean

clean:
	rm -rf ${PACKAGE_NAME}_${DEBVERSION}* ${PACKAGE_NAME}-${DEBVERSION} ${OUT_DIR}

build:  clean
	mkdir ${DEBFOLDERNAME}
	mkdir ${OUT_DIR}
	cp -r brief linux index.json brief-completion ${DEBFOLDERNAME}
	cd ${DEBFOLDERNAME}; \
	dh_make -y --indep --createorig --native; \
	grep -v makefile debian/rules > debian/rules.new; \
	mv debian/rules.new debian/rules; \
	echo brief ${BINDIR} > debian/install; \
	echo linux ${SHARE_PREFIX}/${PACKAGE_NAME} >> debian/install; \
	echo index.json ${SHARE_PREFIX}/${PACKAGE_NAME} >> debian/install; \
	echo brief-completion ${SHARE_PREFIX} >> debian/install; \
	cp -f ../control debian/; \
	cp -f ../postinst debian/; \
	rm debian/*.ex; \
	debuild -us -uc;
	mv ${PACKAGE_NAME}_${DEBVERSION}_all.deb ${OUT_DIR}/

install:
	sudo dpkg -i out/${PACKAGE_NAME}_${DEBVERSION}_all.deb
