"""Reconstruct verified translated resources using the user's own MW2 files."""
import argparse
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import sys
import zlib

ROOT = Path(__file__).resolve().parent

def digest(data):
    return hashlib.sha256(data).hexdigest()

def safe_child(root, relative):
    path = (root / relative).resolve()
    if not path.is_relative_to(root.resolve()):
        raise ValueError('Path outside package/game directory: ' + relative)
    return path

def prepare(game):
    manifest = json.loads((ROOT/'manifest.json').read_text(encoding='utf-8-sig'))
    deltas = json.loads((ROOT/'delta-manifest.json').read_text(encoding='utf-8'))
    recipes = {r['path']: r for r in deltas['files']}
    if not (game/'iw4sp.exe').is_file():
        raise ValueError('MW2 not found: ' + str(game))
    # Complete source preflight before creating any resources. No game writes.
    sources = {}
    for item in manifest['files']:
        relative = item['path']
        output = safe_child(ROOT/'payload', relative)
        if output.is_file() and digest(output.read_bytes()) == item['patch_sha256']:
            continue
        if relative not in recipes:
            raise ValueError('Missing/corrupt distributed payload: ' + relative)
        candidates = [safe_child(game/'Codex_MW2_zhTW_Backup', relative), safe_child(game, relative)]
        source = next((p for p in candidates if p.is_file() and digest(p.read_bytes()) == item['original_sha256']), None)
        if source is None:
            raise ValueError('Unsupported original file / build: ' + relative)
        recipe_path = safe_child(ROOT, recipes[relative]['delta'])
        if digest(recipe_path.read_bytes()) != recipes[relative]['delta_sha256']:
            raise ValueError('Delta integrity check failed: ' + relative)
        sources[relative] = source
    for item in manifest['files']:
        relative = item['path']
        if relative not in sources:
            print('Verified existing payload: ' + relative, flush=True)
            continue
        source_bytes = sources[relative].read_bytes()
        if digest(source_bytes) != item['original_sha256']:
            raise ValueError('Source changed during preparation: ' + relative)
        recipe_path = safe_child(ROOT, recipes[relative]['delta'])
        recipe = json.loads(gzip.decompress(recipe_path.read_bytes()))
        if recipe['path'] != relative:
            raise ValueError('Delta path mismatch')
        raw = bytearray(zlib.decompress(source_bytes[21:]))
        if len(raw) != recipe['raw_size']:
            raise ValueError('Uncompressed size mismatch: ' + relative)
        previous_end = 0
        for offset, encoded in recipe['changes']:
            block = base64.b64decode(encoded, validate=True)
            end = offset + len(block)
            if offset < previous_end or end > len(raw) or not block:
                raise ValueError('Invalid or overlapping delta range')
            raw[offset:end] = block
            previous_end = end
        header = base64.b64decode(recipe['header'], validate=True)
        if len(header) != 21:
            raise ValueError('Invalid FF header')
        translated = header + zlib.compress(raw, deltas['compression_level'])
        if digest(translated) != item['patch_sha256']:
            raise ValueError('Recompression hash differs; no game files changed. '
                'Verified Python/zlib: ' + deltas['verified_python'] + '/' + deltas['verified_zlib']
                + '; current: ' + sys.version.split()[0] + '/' + zlib.ZLIB_RUNTIME_VERSION)
        output = safe_child(ROOT/'payload', relative)
        output.parent.mkdir(parents=True, exist_ok=True)
        temporary = output.with_suffix(output.suffix + '.tmp')
        temporary.write_bytes(translated)
        os.replace(temporary, output)
        print('Reconstructed and verified: ' + relative, flush=True)
        del source_bytes, raw, translated
    print('All ' + str(len(manifest['files'])) + ' resources verified. Ready to install.', flush=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--game', default='D:/SteamLibrary/steamapps/common/Call of Duty Modern Warfare 2')
    args = parser.parse_args()
    try:
        prepare(Path(args.game).resolve())
    except Exception as error:
        print('Preparation stopped: ' + str(error), file=sys.stderr)
        sys.exit(1)
