#!/usr/bin/env python3
"""Check complete locale keys and placeholder parity before code generation."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parent.parent / 'lib/l10n'
base = json.loads((root / 'app_en.arb').read_text())
keys = {key for key in base if not key.startswith('@')}
for path in sorted(root.glob('app_*.arb')):
    messages = json.loads(path.read_text())
    actual = {key for key in messages if not key.startswith('@')}
    if actual != keys:
        raise SystemExit(f'{path.name}: missing={keys-actual}, extra={actual-keys}')
    for key in keys:
        if not isinstance(messages[key], str) or not messages[key].strip():
            raise SystemExit(f'{path.name}: empty message {key}')
        expected = set(base.get('@' + key, {}).get('placeholders', {}))
        used = set(re.findall(r'\{(\w+)(?:\}|,)', messages[key]))
        if used != expected:
            raise SystemExit(f'{path.name}: placeholder mismatch in {key}: {used} != {expected}')
print(f'OK: {len(keys)} messages across five complete locale catalogs.')
