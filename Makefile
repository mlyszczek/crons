PREFIX ?= /usr/local
SCRIPTDIR = $(PREFIX)/etc/crons
CONFDIR = $(PREFIX)/etc/crons.conf.d

CRONS = portage-backup rootfs-backup smart-monitor
CRONS_SCRIPTS = $(addsuffix .sh, $(CRONS))
CRONS_CONFIGS = $(addprefix etc/, $(addsuffix .conf, $(CRONS)))

all:
	@echo "done"

install-scripts: $(CRONS_SCRIPTS)
	install -d $(DESTDIR)/$(SCRIPTDIR)
	install $^ $(DESTDIR)/$(SCRIPTDIR)

install-conf: $(CRONS_CONFIGS)
	install -d $(DESTDIR)/$(CONFDIR)
	install $^ $(DESTDIR)/$(CONFDIR)

install: install-scripts install-conf
