PREFIX ?= /usr/local
SCRIPTDIR = $(PREFIX)/etc/crons
CONFDIR = /etc/crons.conf.d

CRONS = portage-backup rootfs-backup smart-monitor disk-usage-monitor \
		clean-old-backups
CRONS_SCRIPTS = $(addsuffix .sh, $(CRONS))
CRONS_CONFIGS = $(shell find etc/ -mindepth 1)

all:
	@echo "done"

install-scripts: $(CRONS_SCRIPTS)
	install -d -m0755 $(DESTDIR)/$(SCRIPTDIR)
	install $^ -m0755 $(DESTDIR)/$(SCRIPTDIR)

install-conf: $(CRONS_CONFIGS)
	install -d -m0750 $(DESTDIR)/$(CONFDIR)
	install $^ -m0640 $(DESTDIR)/$(CONFDIR)

install: install-scripts install-conf
