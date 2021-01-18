PREFIX ?= /usr/local
SCRIPTDIR = $(PREFIX)/etc/crons
CONFDIR = /etc/crons.conf.d

CRONS = portage-backup rootfs-backup smart-monitor disk-usage-monitor \
		clean-old-backups custom-backup
CRONS_SCRIPTS = $(addsuffix .sh, $(CRONS))
CRONS_CONFIGS = $(shell find etc/ -mindepth 1)

all:
	@echo "done"

install-scripts: $(CRONS_SCRIPTS)
	install -m0755 -d $(DESTDIR)/$(SCRIPTDIR)
	install -m0755 $^ $(DESTDIR)/$(SCRIPTDIR)

install-conf: $(CRONS_CONFIGS)
	install -m0750 -d $(DESTDIR)/$(CONFDIR)
	install -m0640 $^ $(DESTDIR)/$(CONFDIR)

install: install-scripts install-conf
