"""
Couche de compatibilité : préférez `from settings import get_settings, Settings`.

Conservé pour ne pas casser les imports existants (`from config import get_settings`).
"""

from settings import Settings, get_settings

__all__ = ["Settings", "get_settings"]
