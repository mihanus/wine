# Generic Makefile for Spicey applications

CURRYOPTIONS=:set -time

# Target directory where the compiled cgi programs, style sheets, etc
# should be stored, e.g.: $(HOME)/public_html
WEBSERVERDIR=$(HOME)/public_html/SAM/wine

# Definition of the root of the Curry system to be used:
#export CURRYHOME=$(HOME)/pakcs
#export CURRYHOME=$(HOME)/kics2
export CURRYHOME=/opt/kics2

# Curry bin directory to be used:
export CURRYBIN=$(CURRYHOME)/bin

CURRYOPTIONS=:set -time

# Executable of the Curry Package Manager CPM:
CPM := $(CURRYBIN)/cypm

# The root directory of the sources of the Spicey application:
SRCDIR := $(CURDIR)/src

# The load path for the Spicey application:
export CURRYPATH := $(SRCDIR):$(SRCDIR)/Model

# Executable of the curry2cgi:
CURRY2CGI := $(shell which curry2cgi)

############################################################################

.PHONY: all
all:
	@echo "make: deploy install compile load run save restore clean?"

# Install the packages required by the generated Spicey application:
.PHONY: install
install:
	$(CPM) install

# check presence of tools required for deployment and install them:
.PHONY: checkdeploy
checkdeploy:
	@if [ ! -x "$(CURRY2CGI)" ] ; then \
	   echo "Installing required executable 'curry2cgi'..." ; \
           $(CPM) install html2 ; fi

# Compile the generated Spicey application:
.PHONY: compile
compile:
	$(CURRYBIN)/curry $(CURRYOPTIONS) :load Main :quit

# Load the generated Spicey application into the Curry system so that
# one can evaluate some expressions:
.PHONY: load
load:
	$(CURRYBIN)/curry $(CURRYOPTIONS) :load Main

# Runs the generated Spicey application by evaluating the main expression.
# This might be useful to test only the initial web page without a web server
.PHONY: run
run:
	$(CURRYBIN)/curry $(CURRYOPTIONS) :load Main :eval main :q

# Deploy the generated Spicey application, i.e., install it in the
# web directory WEBSERVERDIR:
.PHONY: deploy
deploy: checkdeploy
	mkdir -p $(WEBSERVERDIR)
	$(MAKE) $(WEBSERVERDIR)/spicey.cgi
	# copy other files (style sheets, images,...)
	cp -r public/* $(WEBSERVERDIR)
	chmod -R go+rX $(WEBSERVERDIR)
	# recreate directory for storing local session data:
	#/bin/rm -r $(WEBSERVERDIR)/data
	mkdir -p $(WEBSERVERDIR)/data # create private data dir
	cp -p data/htaccess $(WEBSERVERDIR)/data/.htaccess # and make it private
	chmod 700 $(WEBSERVERDIR)/data
	mkdir -p $(WEBSERVERDIR)/sessiondata # create private data dir
	cp -p data/htaccess $(WEBSERVERDIR)/sessiondata/.htaccess # and make it private
	chmod 700 $(WEBSERVERDIR)/sessiondata

$(WEBSERVERDIR)/spicey.cgi: src/*.curry src/*/*.curry
	$(CPM) exec $(CURRY2CGI)  --system="$(CURRYHOME)" \
	  -i Controller.Category \
	  -i Controller.SpiceySystem \
	  -i Controller.Wine \
	  -o $@ Main.curry

# Save the current database in term files
.PHONY: save
save:
	cd $(SRCDIR)/Model && $(CURRYBIN)/curry $(CURRYOPTIONS) :load Wine :eval saveDB :q

# Restore the current database from term files
.PHONY: save
restore:
	cd $(SRCDIR)/Model && $(CURRYBIN)/curry $(CURRYOPTIONS) :load Wine :eval restoreDB :q

# clean up generated the package directory
.PHONY: clean
clean: 
	$(CPM) clean

# clean everything, including the deployed files
.PHONY: cleanall
cleanall: clean
	/bin/rm -rf $(WEBSERVERDIR)
