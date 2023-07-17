from __future__ import absolute_import, division, print_function

import inspect

import dosagelib.plugins.common
from .scraper import Scraper

try:
    import cssselect
except ImportError:
    cssselect = None

try:
    import pycountry
except ImportError:
    pycountry = None

from .output import out

from . import loader

def find_scrapers(comic, multiple_allowed=False):
    """Get a list comic scraper objects.

    Can return more than one entry if multiple_allowed is True, else it raises
    a ValueError if multiple modules match. The match is a case insensitive
    substring search.
    """
    if not comic:
        raise ValueError("empty comic name")
    candidates = []
    cname = comic.lower()
    for scrapers in get_scrapers(include_removed=True):
        lname = scrapers.name.lower()
        if lname == cname:
            # perfect match
            if not multiple_allowed:
                return [scrapers]
            else:
                candidates.append(scrapers)
        elif cname in lname and scrapers.url:
            candidates.append(scrapers)
    if len(candidates) > 1 and not multiple_allowed:
        comics = ", ".join(x.name for x in candidates)
        raise ValueError('multiple comics found: %s' % comics)
    elif not candidates:
        raise ValueError('comic %r not found' % comic)
    return candidates

def invent_scrapers(url):
    candidates = []
    for (name, x) in inspect.getmembers(dosagelib.plugins.common):
        if inspect.isclass(x) and issubclass(x, (Scraper,)):
            candidate = x(url)
            candidate.url = url
            candidates.append(candidate)
    return candidates

_scrapers = None


def get_scrapers(include_removed=False):
    """Find all comic scraper classes in the plugins directory.
    The result is cached.
    @return: list of Scraper classes
    @rtype: list of Scraper
    """
    global _scrapers
    if _scrapers is None:
        out.debug(u"Loading comic modules...")
        modules = loader.get_modules('plugins')
        plugins = list(loader.get_plugins(modules, Scraper))
        _scrapers = sorted([m for x in plugins for m in x.getmodules()],
                           key=lambda p: p.name)
        check_scrapers()
        out.debug(u"... %d modules loaded from %d classes." % (
            len(_scrapers), len(plugins)))
    if include_removed:
        return _scrapers
    else:
        return [x for x in _scrapers if x.url]


def check_scrapers():
    """Check for duplicate scraper names."""
    d = {}
    for scraper in _scrapers:
        name = scraper.name.lower()
        if name in d:
            name1 = scraper.name
            name2 = d[name].name
            raise ValueError('duplicate scrapers %s and %s found' %
                             (name1, name2))
        d[name] = scraper
