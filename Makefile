VALASRC := $(shell find src -type f -name "*.vala")
PKGS := --pkg gtk+-3.0 --pkg gio-2.0

all: maildirnotify

maildirnotify: $(VALASRC)
	valac $(PKGS) $(VALASRC) -o maildirnotify
