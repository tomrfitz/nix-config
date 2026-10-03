---
name: zotero
description: Conventions and methods for the user's Zotero library — records that describe the exact PDF held, preprint and published pairs, bulk imports through zotero-cli, metadata lookups, OCR, and getting full texts. Use when adding, importing, fixing or auditing Zotero items.
---

# Zotero

The library is reachable through the Zotero MCP server (`mcp__plugin_hm_zotero__*`) and its CLI, `zotero-cli`, both from `modules/shared/home/zotero.nix` in nix-config. Local mode needs Zotero running. The library's state and open follow-ups are in `~/Documents/notes/zotero-library.org`; the contact email for metadata APIs is in `~/Documents/notes/agent-context.org`.

## Records match the PDF held

The user cites what they actually read, so each record describes the exact file attached to it:

- A reprint in an anthology or reader → a `bookSection` of that volume: its editors, publisher and year, and the pages as printed in the PDF. The original goes in Extra as `Original Date: YYYY` plus a `Reprinted from … https://doi.org/…` line. Clear the original's DOI and ISSN, which a type change keeps.
- A chapter or excerpt of a monograph or handbook → a `bookSection` with the chapter's own title and pages, one record per PDF (two parts of one chapter share a record). A whole-book PDF → `book`.
- Page ranges come from the PDF's printed folios, checked against the publisher's table of contents. Note partial coverage in Extra. Taylor & Francis e-book chapter pages can run ahead of print, so always check those against the folios.
- A pre-publication version (an arXiv or PsyArXiv preprint, an NIH/HHS author manuscript, an author-site draft) → a `preprint` record holding that PDF (genre, repository, archive ID), plus a separate record for the published version. Each one's Extra points to the other. A published record whose PDF isn't freely available gets the tag `needs published PDF`, for a batch Find Full Text from a network with access.
- File size never matters (storage is unlimited). Accuracy, complete metadata and filing in the right collection do.

## Bulk work

One MCP call per item is too slow for imports. Use `zotero-cli --json`:

- `zotero-cli add doi <DOI> -c '<Parent/Child>' --create-collections --attach-mode none`, then `zotero-cli attach <KEY> --file <path> [--filename <name>]`.
- `zotero-cli collections manage --item-keys <a,b> --add-to <KEY> --remove-from <KEY>`.
- If the wrapper isn't on PATH: `uv tool uvx --from 'zotero-mcp-server[pdf]@latest' zotero-cli`.
- `zotero_set_item_parent` moves an attachment under another item and keeps its annotations; the attachment leaves its collection by itself. `zotero_delete_item` moves items to the trash, which is recoverable.

Import gotchas:

- `add bibtex` writes `Citation Key: <key>` into Extra, which Better BibTeX treats as a pinned key: clear it with `edit <KEY> --extra ""`. It also drops `bookauthor`; set the creators with `edit --creators`.
- CrossRef imports Wiley chapter DOIs as `document`, and its bookSections arrive without bookTitle or editors.
- A type change keeps DOI, ISSN and `Issue:` lines in Extra.

## Metadata and OCR

- CrossRef returns 429 at about 8 concurrent requests. OpenAlex takes 40–50 DOIs in one request (`filter=doi:a|b`). Send the contact email (`mailto=` / `email=`) for the polite pool, and pass it to any delegated agent.
- To identify a scan with no text layer: Apple Vision OCR through `uv run --with ocrmac --with pypdfium2`.
- To add a text layer: `nix shell nixpkgs#ocrmypdf -c ocrmypdf --skip-text --rotate-pages --deskew in.pdf out.pdf`. Pages with empty text objects need `--force-ocr` instead. Keep the originals somewhere durable, not in a session scratchpad, until the user has checked the results. Afterwards Zotero's full-text index is stale: Settings → Search → Rebuild Index.

## Full texts

- Find Full Text (Zotero 10, `Zotero.Attachments.getFileResolvers`) tries the doi.org page, the item's URL, Zotero's open-access lookup, then custom resolvers from the hidden pref `extensions.zotero.findPDFs.resolvers`. It never uses the OpenURL resolver: institutional access comes from the network the machine is on. It skips items that already hold a PDF.
- No API triggers it on existing items. The scripted route is Tools → Developer → Run JavaScript with `Zotero.Attachments.addAvailableFiles(items)`. Its open-access resolver can attach a submitted version to a published record, so check what arrived.
- Publisher sites refuse scripted downloads even from an entitled network (ScienceDirect and Oxford Academic answer 403; APA and MUSE return HTML). What works: the user downloads in the browser to `~/Downloads`, then match each file by its content, confirm it's the published version, and attach it.
