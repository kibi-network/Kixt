# Kixt Transmissions

## Abstract {#abstract}

The following specification defines a transmission format for documents.
This format has been designed for use with [Unicode] and [Kixt charsets][Kixt Charset], although it may conceivably be adopted by other character sets as well.

<nav id="toc" markdown="block">
## Contents

+ Table of Contents
{:toc id="toc.contents"}
</nav>

## 1. Introduction {#introduction}

### 1.1 Purpose and Scope
{: id="introduction.purpose"}

This specification defines the <dfn id="Kixt_Transmission_Format">Kixt Transmission Format</dfn>, a means of encoding texts for transmission and storage.
It is a text-based format, which means that it is intended for use with sequences of codepoints which are intended to represent characters according to some character set.
It is not suitable for transmitting binary information.

<div role="note" markdown="block">
In essence, the [Kixt Transmission Format] is a container format (like OGG or MP4), but for plain text rather than multimedia.
</div>

This specification does not define the *means* of transmitting the codepoints of a [Kixt transmission][transmission], only the semantics that those codepoints entail.
It may conceivably be used in conjunction with networking protocols, or with files being read from or saved to disk.

<div role="note" markdown="block">
The file extension `.kixt` or `.kxt` is suggested for saved documents which are encoded according to the [Kixt Transmission Format].
</div>

### 1.2 Relationship to Other Specifications
{: id="introduction.related"}

This document is part of the [Kixt family of specifications][Kixt Overview].
It is also built upon [RDF] technologies.

In this document, the following prefixes are used to represent the following strings:

| Prefix | Expansion |
| :--: | --- |
| `kixt:` | `https://vocab.KIBI.network/Kixt/#` |

## 2. Character sets {#character}

A character set defined by a [Kixt Charset Definition] is <dfn id="dfn.transmission_compatible">transmission compatible</dfn> if and only if:

+ It does not assign the codepoints `FEFF` or `FFFE`.

+ The objects of the [compatibility properties][compatibility property] are equal to those defined in <https://charset.KIBI.network/Kixt/Transmission> for all characters so defined.

+ No other characters are given a `kixt:basicType` of `kixt:TRANSMISSION`.

The [Unicode] character set, as well as the ASCII subset thereof, is assumed to be transmission compatible.
Whether other character sets are transmission compatible is left undefined by this specification.

Outside of a [page], the character set of a [transmission] is <https://charset.KIBI.network/Kixt/Controls>.

In this specification, characters within a character set are identified by codepoint (always listed in hexadecimal).
For purposes of readability, the name used in <https://charset.KIBI.network/Kixt/Controls> is also provided.
However, there is no requirement that all [transmission compatible] character sets necessarily use these same names.

A character set is <dfn id="dfn.variable-width_compatible">variable-width compatible</dfn> if it only contains codepoints in the range `0000`–`FFFF`, and the set of bytes used for the most significant and least significant places of characters are disjoint for all codepoints greater than `0000`.

<div role="note" markdown="block">
The requirement of disjointedness for [variable-width compatible] character sets means that determining the codepoint a byte belongs to only requires looking at the previous or next byte.
</div>

The following characters in a [transmission compatible] character set are <dfn id="transmission_character">transmission characters</dfn>:

+ `01 HEAD`
+ `02 BEGIN`
+ `03 FINISH`
+ `04 DONE`
+ `16 IDLE`
+ `17 BREAK`
+ `18 CANCEL`
+ `19 END`
+ `1A INVALID`

A <dfn id="dfn.data_block">data block</dfn> is a sequence of codepoints which do not necessarily belong to the character set of the surrounding text.
Every data block begins with one or more <dfn id="dfn.opening_data_character">opening data characters</dfn>, and ends with zero or more <dfn id="dfn.closing_data_character">closing data characters</dfn>.
The <dfn id="dfn.data_contents">data contents</dfn> of a data block are the non–`00 NULL` codepoints between these two sequences, which must be in the range `0001`–`FFFD`.
The only data block defined by this specification is the sequence of codepoints beginning with an opening data character of a valid `0E LEAVE` and ending with a closing data character of a valid `0F RETURN`.
Other specifications may define other data blocks.

<div role="note" markdown="block">
Although the character sets of [data blocks][data block] are not necessarily known, [data contents] are nevertheless encoded the same as any other characters.
</div>

For the purposes of this specification, the characters in the [data contents] of a [data block] are neither [transmission characters][transmission character] nor [control characters][control character].

### 2.1 Overview of Characters
{: id="character.overview"}

The broad meanings and interpretation of the characters whose semantics are defined by this specification are given below.
Note that the specific usage of these characters will be clarified in later sections.

`00 NULL`

: A meaningless format character.
  This character may be used for byte-padding within a source text, and does not represent anything in itself.
  All programs should ignore `00 NULL` characters whenever they appear, treating them as though they were not present.

  <div role="note" markdown="block">
  Of particular importance, programs or algorithms which preform searching or sanitization functions must strip all `00 NULL` characters from their input before processing.
  Failure to do so may allow unsafe syntactic constructs to propagate to places where they should otherwise not be allowed.
  </div>

`01 HEAD`

: Begins a new [header].
  This character is only valid at the beginning of a [page]; in all other situations it should be replaced on reading with `1A INVALID`.

`02 BEGIN`

: Begins a new [text].
  This character is only valid at the beginning of a [page] or to close a [header]; in all other situations it should be replaced on reading with `1A INVALID`.

`03 FINISH`

: Ends a [page].
  Implies a closing of any open [header] or [text].

`04 DONE`

: Ends a [transmission].
  Only for use in networked contexts; should not be saved to disk.

`0E LEAVE`

: Opens a [data block] which effectively switches the character set to [Unicode] until `0F RETURN` is encountered, which closes the block.
  The characters in the [data contents] of this block must not be in the range `01`–`1F` or `7F`–`9F`.
  This character is only allowed in [headers][header]; elsewhere, or if no valid data block can be created, this character should be replaced on reading with `1A INVALID`.

`0F RETURN`

: Closes the [data block] begun by `0E LEAVE`.
  In all other situations, it should be replaced on reading with `1A INVALID`.

`16 IDLE`

: A meaningless transmission character.
  Unlike `00 NULL`, this character should not be ignored.
  However, it is given no meaning by this specification.

`17 BREAK`

: Ends a [transmission block].
  Only for use in networked contexts; should not be saved to disk.

`18 CANCEL`

: Ends a [transmission] by indicating that it was made in error.
  Only for use in networked contexts; should not be saved to disk.

`19 END`

: Closes a [document], signalling that it is complete.

`1A INVALID`

: Replaces an invalid character in a transmission on reading.

`1C VOLUME SEPARATOR`
`1D PART SEPARATOR`
`1E CHAPTER SEPARATOR`
`1F SECTION SEPARATOR`

: Format characters for subdividing a sequence of characters into progressively finer-grained divisions.
  These have special semantics inside of [headers][header]; their usage in [texts][text] is not defined (but not prohibited) by this specification.

### 2.2 Control Characters
{: id="character.control"}

The <dfn id="dfn.control_character">control characters</dfn> are, for any [Kixt charset][charset], any [character] with a `kixt:basicType` of `kixt:CONTROL`.
The Unicode control characters are any characters in the range `01`–`0D`, `10`–`1B`, or `7F`–`9F` which are not [transmission characters][transmission character].

<div role="note" markdown="block">
Note that this includes such [control characters][control character] as `09 NEXT` (`TAB`) and `0A ADVANCE` (`LINE FEED`), which are commonly-used in non-Kixt documents.
</div>

All [control characters][control character] are invalid within [documents][document] and should be replaced with `1A INVALID` on reading.
The meaning of control characters outside of documents is not defined by this specification.

<div role="note">
</div>

### 2.3 Unicode mappings
{: id="character.mapping"}

For any [Kixt charset][charset], the <dfn id="dfn.Unicode_mapping">Unicode mapping</dfn> of a sequence of codepoints is the sequence of [Unicode] characters which results from:

1. For each character which is not part of a [data block], replacing the corresponding assigned [Kixt character][character] with the codepoints, in order, indicated by the `kixt:unicode` property, or with `FFFD` if no character has been assigned.

2. For each [data block] which begins with `0E LEAVE` and ends with `0F RETURN`, replacing the data block with the codepoints which result from interpreting its [data contents] as a sequence of UTF-16 code units (as defined by [Unicode]), replacing any ill-formed code unit subsequence with `FFFD`.

3. For other [data blocks][data block], the single character `FFFC`, unless specified otherwise by a relevant specification.

For a sequence of Unicode characters, the Unicode mapping is the sequence itself.
For characters in other character sets, the Unicode mapping is not defined by this specification.

## 3. Kixt Transmission Format {#model}

### 3.1 Transmissions
{: id="model.transmission"}

A <dfn id="dfn.transmission">Kixt transmission</dfn> is a sequence of bytes conforming to the semantics of this specification.
Transmissions may be read from a file or transmitted over a network.

#### 3.1.1 Transmission encoding
{: id="model.transmission.encoding"}

An <dfn id="dfn.encoding_scheme">encoding scheme</dfn> is a means of representing a sequence of codepoints as a sequence of bytes.
Five possible encoding schemes are defined:

<dfn id="dfn.Generalized_UTF-8">Generalized UTF-8</dfn>
: As defined by the [WTF-8] specification

<dfn id="dfn.Fullwidth-BE">Fullwidth-BE</dfn>
: For Unicode, [UTF-16BE][UTF-16].
  For [Kixt charsets][charset], each codepoint is represented as a sequence of two bytes, with the most significant byte first.

<dfn id="dfn.Fullwidth-LE">Fullwidth-LE</dfn>
: For Unicode, [UTF-16LE][UTF-16].
  For [Kixt charsets][charset], each codepoint is represented as a sequence of two bytes, with the least significant byte first.

<dfn id="dfn.Variable-BE">Variable-BE</dfn>
: For [variable-width compatible]{::} character set, each codepoint is represented as a sequence of either:

  01. For characters for which one byte is `00`, the other byte.

  02. For all other characters, the codepoint a sequence two bytes, with the most significant byte first.

  For all other character sets, the same as [Fullwidth-BE].

<dfn id="dfn.Variable-LE">Variable-LE</dfn>
: For [variable-width compatible]{::} character set, each codepoint is represented as a sequence of either:

  01. For characters for which one byte is `00`, the other byte.

  02. For all other characters, the codepoint a sequence two bytes, with the least significant byte first.

  For all other character sets, the same as [Fullwidth-LE].

<div role="note" markdown="block">
For [transmission compatible] character sets, the `00` byte will always be the most significant byte.
</div>

The [encoding scheme] applies to all characters in a [transmission], regardless of character set.

If the first two bytes of a [transmission] are `FE` followed by `FF`, then the [encoding scheme] for the transmission is [Variable-BE].
If the first two bytes of a transmission are `FF` followed by `FE`, then the [encoding scheme] for the transmission is [Variable-LE].
In either case, these first two bytes are otherwise ignored.

<div role="note" markdown="block">
In transmissions, the `00 NULL` character is ignored.
This means that any [Fullwidth-BE]–encoded sequence of characters can safely be interpreted as [Variable-BE], and any [Fullwidth-LE]–encoded sequence of characters can safely be interpreted as [Variable-LE].
Consequently, separate encoding detection for [Fullwidth-BE] or [Fullwidth-LE] is not required.
</div>

Otherwise, the [encoding scheme] is [Generalized UTF-8].

#### 3.1.2 Transmission blocks
{: id="model.transmission.block"}

In certain networked situations, a transmission might need to be broken into multiple parts, known as <dfn id="transmission_block">transmission blocks</dfn>.
The character `17 BREAK` may be used to signal the end of a transmission block without implying that a transmission has terminated.

In non-network contexts, or in other contexts where [transmission blocks][transmission block] are not used, `17 BREAK` should be replaced with `1A INVALID` during reading, unless it is terminal (optionally followed by `04 DONE` or `18 CANCEL`), in which case it should be ignored.

#### 3.1.3 Transmission termination
{: id="model.transmission.termination"}

The end of a transmission may be signalled by the use of `04 DONE` or `18 CANCEL`.
The former of these characters signals a completed transmission, whereas the latter signals that a transmission was made in error and should be discarded.

The end of transmissions should generally only be signalled when communicating over a network.
Non-terminal `04 DONE` and `18 CANCEL` characters which appear in non-network contexts should be replaced with `1A INVALID` during reading.
Terminal `04 DONE` and `18 CANCEL` characters which appear in non-network contexts should be ignored.

### 3.2 Documents
{: id="model.document"}

A <dfn id="dfn.document">document</dfn> is a sequence of bytes which forms a cohesive whole.
Documents may consist of any number of [pages][page].
A [transmission] may consist of multiple documents, or only part of one.

A document is automatically opened within any [transmission] whenever no document is currently open and a character is encountered which, after reading, is not a [transmission character], [control character], or part of a [data block].
If no document is presently open, a new document may also be explicitly opened by `01 HEAD` or `02 BEGIN`.
Documents are closed by `19 END`.

<div role="note" markdown="block">
The “after reading” stipulation above is meant to indicate that characters which are ignored on reading (`00 NULL`), or which are replaced on reading with `1A INVALID`, do not open a new document.
</div>

The ends of documents should be signalled via `19 END` regardless of context (and even for saved files).
A lack of a `19 END` character indicates that a document is incomplete, perhaps because it was not fully saved, or because a transmission was ended before its end could be reached.

Files saved to disk should only contain a single document—and consequently, only a single, terminal `19 END` character.
Programs which concatenate documents should take care to only concatenate the *[pages][page]* of the documents, and not non-page content.
When reading a file from disk, a non-terminal `19 END` character should be replaced with `1A INVALID` during reading.

### 3.3 Pages
{: id="model.page"}

A <dfn id="dfn.page">page</dfn> is a section of a [document] consisting of an optional [header], followed by a [text].
Documents may contain any number of pages.
A new page is automatically opened in a document whenever no [page] is currently open and a character is encountered which, after reading, is not a [transmission character].
Pages can also explicitly be opened with a `01 HEAD` or `02 BEGIN` character.

Pages extend until the end of their document, or can be explicitly closed with a `03 FINISH` character (thus allowing the opening of a new page).

#### 3.3.1 Page headers
{: id="model.page.header"}

A <dfn id="dfn.header">header</dfn> provides metadata information about a [page].
It is opened by `01 HEAD` and continues until the start of the [text]{::} (signalled by `02 BEGIN`) or the end of the [page]{::}, whichever occurs first.
Headers must precede texts; consequently, a page with a header necessarily must begin with `01 HEAD` (optionally preceded by any number of `16 IDLE` or `1A INVALID` characters).

The contents of [headers][header] define [RDF triples][RDF triple] whose subject is a node representing the current document.
The predicate and object of each triple is separated by `1D PART SEPARATOR`, and the triples themselves are separated by `1C VOLUME SEPARATOR`.
If no triple can be formed from a sequence of characters so delineated (either because it does not consist of two components separated by a `1D PART SEPARATOR`, contains invalid characters, or does not conform to appropriate [RDF] semantics), the entire sequence (up until the next `1C VOLUME SEPARATOR`, or the end of the header) is ignored.

The sequence of characters representing the predicate of the [RDF triple] must have a [Unicode mapping] which is a valid [IRI].
The sequence of characters representing the object of the RDF triple must have a [Unicode mapping] which is one of the following:

 +  A valid [IRI].

 +  A [literal] which does not contain any characters in the range `00-1F` or `7F-9F`, which only contains assigned characters, and which is followed by `1F SECTION SEPARATOR` and a valid [datatype IRI].

 +  An [RDF Collection] whose ordered items are each one of the above, with each item separated by `1E CHAPTER SEPARATOR`.
    Collections cannot be nested.

##### header character sets

The character set of [headers][header] is initially <https://charset.KIBI.network/Kixt/Transmission>.
The predicate `kixt:charset` can be used to define the character set for all subsequent [RDF triples][RDF triple]; the object of this predicate is valid if it is an [IRI] representing a [transmission compatible] character set.
If multiple `kixt:charset` predicates with valid objects are declared in a header, all but the first are ignored.

The IRI `http://www.unicode.org/versions/latest/` identifies the [Unicode] character set.

<div role="note" markdown="block">
Because no character set has yet been declared, the use of `0E LEAVE` and `0F RETURN` is required to define the `kixt:charset` of a [header].
</div>

<div role="note" markdown="block">
For closely-related character sets, multiple `kixt:charset` predicates may be used to indicate fallbacks should the preferred character set not be available.
</div>

The meaning of other predicates besides `kixt:charset` is not defined by this specification.

#### 3.3.2 Page texts
{: id="model.page.text"}

A <dfn id="dfn.text">text</dfn> provides the text contents of a [page].
A new text is automatically opened in a page whenever no [header] is currently open and a character is encountered which, after reading, is not a [transmission character].
Texts can also be opened explicitly with a `02 BEGIN` character.
Texts continue until the end of the page.

If a [page] ends before a [text] is opened, it has an empty text.

If a `kixt:charset` with a valid object was declared in the [header] to the [page] containing a [text], it provides the character set of the text.
Otherwise, the character set of the text is left to programs to determine.
In the absence of prior knowledge, programs should assume that texts are in [Unicode].

<div role="note" markdown="block">
As a consequence of the above rules, and in the absence of any special configuration or knowledge, a plain-text [document] which contains no [transmission characters][transmission character] is assumed to consist of a single [page] with a single [Unicode]{::} [text].
</div>

## 4. Changelog {#changelog}

{: id="changelog.2019-05-03"} <time>2019-05-03</time>

: Initial specification.

{% include references.md %}
