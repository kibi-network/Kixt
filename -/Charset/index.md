# Kixt Charset

## Abstract {#abstract}

The following specification defines a mechanism for defining character sets (*charsets*) which may be used in a [Kixt transmission][transmission] or rendering system.
[Kixt charsets][charset] are, as their name implies, sets of [Kixt characters][character], mapping each one to a codepoint and assigning it particular character properties.
This document details the meaning of these properties within the [Kixt Charset Model].
Finally, this document introduces a plain-text document format, the [Kixt Charset Definition], for describing such charsets.

<nav id="toc" markdown="block">
## Contents

+ Table of Contents
{:toc id="toc.contents"}
</nav>

## 1. Introduction {#introduction}

### 1.1 Purpose and Scope
{: id="introduction.purpose"}

The purpose of [Kixt] is to reduce the barriers of entry for developing unconventional, experimental encodings and text processing systems, particularly those of characters or scripts which are unlikely to gain mainstream acceptance.
The [Kixt Charset Model], defined in this document, is one piece in an interlocking set of specifications working towards this goal.

The [Kixt Charset Model] is not, and does not attempt to be, a replacement for [Unicode].
In fact, every assigned Kixt [character] is required to have a defined Unicode mapping.
If you are building an application which needs to process characters in a wide variety of scripts, languages, and/or directionalities, Unicode is the correct solution for you.

### 1.2 Relationship to Other Specifications
{: id="introduction.related"}

This document is part of the [Kixt family of specifications][Kixt Overview].
It is also built upon the technologies of [RDF] and [OWL].
It makes minor use of the [Ordered List Ontology] for defining its ordered lists.

In this document, the following prefixes are used to represent the following strings:

| Prefix | Expansion |
| :--: | --- |
| `kixt:` | `https://vocab.KIBI.network/Kixt/#` |
| `rdf:` | `http://www.w3.org/1999/02/22-rdf-syntax-ns#` |
| `xsd:` | `http://www.w3.org/2001/XMLSchema#` |
| `olo:` | `http://purl.org/ontology/olo/core#` |

## 2. Data Model {#model}

A <dfn id="dfn.character">Kixt character</dfn> is an abstract representation of a unit of text, with associated properties and assignment to a single codepoint.
In Kixt, all codepoints are integer values between `0` and `65535`, inclusive.

A <dfn id="dfn.charset">Kixt charset</dfn> is a collection of [Kixt characters][character].

Within a [Kixt charset][charset], [characters][character] may be collected into <dfn id="dfn.block">blocks</dfn>.
Blocks may have “gaps,” but must otherwise be contiguous across assigned characters; this is enforced by the [Kixt Charset Definition] syntax.
Each character may belong to only one block.

Similarly, [Kixt characters][character] may be collected into <dfn id="dfn.script">scripts</dfn>.
Scripts are intended to allow for searching, accessing, and categorizing characters based on their histories or communities of usage.
This specification makes no requirements on the structure of scripts, except to specify that each character may only belong to one.

The <dfn id="dfn.Model">Kixt Charset Model</dfn> is an [RDF graph] which associates [charsets][charset], [characters][character], and their properties with one another according to the rules outlined in this document.
The vocabulary for this model is the [Kixt Ontology] ([OWL] document), which normatively defines several classes and properties for use with the Model.

Although the [Kixt Charset Model] is defined using [RDF] and [OWL], it is not expected that most or even many applications which make use of it will be fully-fledged OWL reasoners.
It is not presently recommended that applications interfacing with [Kixt charsets][charset] load their information from anything other than a [Kixt Charset Definition], whose resultant [RDF graph] is well-defined by this specification and may be abstracted as required.
(However, its basis in RDF and OWL means that extensions to the Kixt Charset Model, as well as alternate means of loading and processing Kixt charsets, may conceivably be designed in the future.)

### 2.1 Types of Resource
{: id="model.resources"}

There are two major types of resource in the Kixt Charset Model: [charsets][charset] and [characters][character].
These are represented by the classes `kixt:Charset` and `kixt:Character`.
In addition to these, `kixt:Block` and `kixt:Script` represent [blocks][block] and [scripts][script] of characters, respectively.
Only `kixt:Charset` need explicitly be declared as the [`rdf:type`] of a resource; the remaining classes are implied through an instance's assignment to various properties (`kixt:character`, `kixt:block`, `kixt:script`).

Many other classes of resource are defined in the [Kixt Ontology].
However, knowledge of their existence is not required for the processes described in this document.

### 2.2 Datatypes
{: id="model.datatypes"}

As an [RDF]-based model, the [Kixt Charset Model] naturally inherits the various datatypes introduced in [RDF Concepts], including those inherited from [XSD Datatypes] and elsewhere.
It also introduces five new datatypes:

+ `kixt:BasicType`: One of the following [`xsd:anyURI`]s:

    + `https://vocab.KIBI.network/Kixt/#UNASSIGNED`
    + `https://vocab.KIBI.network/Kixt/#CONTROL`
    + `https://vocab.KIBI.network/Kixt/#MESSAGING`
    + `https://vocab.KIBI.network/Kixt/#FORMAT`
    + `https://vocab.KIBI.network/Kixt/#DATA`
    + `https://vocab.KIBI.network/Kixt/#NONSPACING`
    + `https://vocab.KIBI.network/Kixt/#SPACING`
    + `https://vocab.KIBI.network/Kixt/#PRIVATEUSE`
    + `https://vocab.KIBI.network/Kixt/#NONCHARACTER`

+ `kixt:Name`: An [`xsd:string`] matching the [`<Name>`] production below.

+ `kixt:Scalar`: An [`xsd:unsignedInt`] with a [`maxInclusive`] restriction of `1114111`.

+ `kixt:String`: An [`xsd:string`] matching the [`<String>`] production below.

+ `kixt:Ternary`: An [`xsd:string`] whose value is either `YES`, `NO`, or the empty string.

As [OWL] datatypes, you should not use these to type [RDF] literals; use [`xsd:anyURI`], [`xsd:string`], [`xsd:integer`] or similar instead.
However, they are useful for expressing constraints on relations.

## 3. Charset Definitions {#definition}

```abnf
CharsetDefinition =
	[%xFEFF] CharsetDeclaration *(
		BlockDeclaration
		/ ScriptDeclaration
		/ CharacterDefinition
		/ Comment
		/ Blank
	)
```
{: id="prod.CharsetDefinition"}

A <dfn id="dfn.Definition">Kixt Charset Definition</dfn> is a [UTF-8] or [UTF-16]–encoded file (determined by a leading BOM, and defaulting to UTF-8 if no BOM is present) consisting of any number of block or script declarations, interspersed with any number of codepoint definitions, comments, or lines of whitespace.
This section describes the syntax of such documents, in [ABNF] and prose.
It also describes how processors can use [Kixt Charset Definitions][Kixt Charset Definition] to generate [RDF graphs][RDF graph].

<div role="note" markdown="block">
The file extension `.kichar` or `.kch` is suggested for [Kixt Charset Definitions][Kixt Charset Definition].
</div>

### 3.1 Null Handling

Programs which process Kixt Charset Definitions must *ignore* any `U+0000 NULL` characters which appear in a document, behaving as though they were not present.

<div role="note" markdown="block">
This effectively allows a [UTF-16]–encoded document to be processed without a BOM if it only contains codepoints in the ASCII range.
</div>

### 3.2 End-of-Line Handling
{: id="definition.eol"}

```abnf
Break = %x2028
	; A Unicode line separator
	; This is effectively just a placeholder for whatever manner of linebreak a document happens to use; see spec description
```
{: id="prod.break"}

`U+2028 LINE SEPARATOR` is the only formally recognized line separator in a [Kixt Charset Definition].
However, to ease in the use of Kixt Charset Definitions on platforms for which support for `U+2028 LINE SEPARATOR` is lacking, programs which process Kixt Charset Definitions must behave as though they normalized all of the following, on input and before parsing, to a single `U+2028 LINE SEPARATOR`:

+ the two-character sequence `<U+000D, U+000A>`
+ the two-character sequence `<U+000D, U+0085>`
+ the single character `U+000A LINE FEED`
+ the single character `U+0085 NEXT LINE`
+ any `U+000D CARRIAGE RETURN` character that is not immediately followed by `U+000A LINE FEED` or `U+0085 NEXT LINE`.

### 3.3 Basic Syntaxes
{: id="definition.basic"}

```abnf
Space = %x20
	; An ordinary Unicode breaking space
Blank = *Space Break
	; A line consisting only of whitespace
```
{: id="prod.Space"}

`U+0020 SPACE` is the only space character in a [Kixt Charset Definition].
Spaces and line separators are not interchangeable.

```abnf
ECMA6Char = %x21-22 / %x25-3F / %x41-5A / %x5F / %x61-7A
	; The invariant printing characters from ECMA-6 (also ISO/IEC 646); documents written using only these characters (plus some manner of ASCII linebreak as described above) will be comprehensible in any ECMA-6 character set
	; The core Kixt Character Definition syntax (with the exception of linebreaks) only uses characters from this set
```
{: id="prod.ECMA6Char"}
```abnf
ASCIIChar = %x21-7E
	; Non-control, non-space ASCII characters
```
{: id="prod.ASCIIChar"}
```abnf
UCSChar =
	%xA0-D7FF / %xF900-FDCF / %xFDF0-FFEF
		; Basic Multilingual Plane
		; (minus surrogates and specials)
	/ %x10000-1FFFD
		; Supplementary Multilingual Plane
	/ %x20000-2FFFD
		; Supplementary Ideographic Plane
	/ %x30000-3FFFD
		; Tertiary Ideographic Plane
	/ %x40000-4FFFD
		; Plane 4
	/ %x50000-5FFFD
		; Plane 5
	/ %x60000-6FFFD
		; Plane 6
	/ %x70000-7FFFD
		; Plane 7
	/ %x80000-8FFFD
		; Plane 8
	/ %x90000-9FFFD
		; Plane 9
	/ %xA0000-AFFFD
		; Plane 10
	/ %xB0000-BFFFD
		; Plane 11
	/ %xC0000-CFFFD
		; Plane 12
	/ %xD0000-DFFFD
		; Plane 13
	/ %xE1000-EFFFD
		; Supplementary Special-purpose Plane
		; Note the first 1000 characters are excluded
	; Non-special, non-privateuse, non-ASCII characters
	; This is the same definition as used for IRIs
```
{: id="prod.UCSChar"}
```abnf
PrivateUse = %xE000-F8FF / %xF0000-FFFFD / %x100000-10FFFD
	; Unicode private-use characters
```
{: id="prod.PrivateUse"}

Specials, such as controls or noncharacters, are not allowed in a [Kixt Charset Definition].
(This does not prevent you from using their codepoints in the [`<UnicodeMapping>`] of [`<CharacterDefinition>`]s.)

```abnf
NoSlash = %x20-2E %x30-7E / UCSChar / PrivateUse
```
{: id="prod.NoSlash"}
```abnf
NoSpace = ASCIIChar / UCSChar / PrivateUse
```
{: id="prod.NoSpace"}
```abnf
NoBreak = NoSpace / Space
```
{: id="prod.NoBreak"}
```abnf
AnyChar = NoBreak / Break
```
{: id="prod.AnyChar"}

You may, generally speaking, use non-ASCII and private-use characters in a [Kixt Charset Definition], except in restricted productions like [`<Name>`].

```abnf
Zero = %x30
```
{: id="prod.Zero"}
```abnf
One = %x31
```
{: id="prod.One"}
```abnf
Bit = Zero / One
```
{: id="prod.Bit"}
```abnf
NonZero = %x31-39
```
{: id="prod.NonZero"}
```abnf
Decimal = %x30-39
```
{: id="prod.Decimal"}

Decimal numbers use the standard ASCII digits.

```abnf
NonZeroHex = %x31-39 / %x41-46
```
{: id="prod.NonZeroHex"}
```abnf
UpperHex = %x30-39 / %x41-46
```
{: id="prod.UpperHex"}
```abnf
Hex = %x30-39 / %x41-46 / %x61-66
	; Case-insensitive hexadecimal used by IRI syntax
```
{: id="prod.Hex"}

Hexadecimal numbers ([`<UpperHex>`]) use only the digits `0`–`9` and the uppercase ASCII letters `A`–`F`.
The [`<Hex>`] production, which also allows lowercase `a`–`f`, is only used in [`<IRI>`]s.

```abnf
UpperAlpha = %x41-5A
```
{: id="prod.UpperAlpha"}
```abnf
Alpha = %x41-5A / %x61-7A
```
{: id="prod.Alpha"}

A number of productions in [Kixt Charset Definitions][Kixt Charset Definition] use only the capital ASCII alphabetic characters ([`<UpperAlpha>`]).
[`<IRI>`]s make use of the small ASCII alphabetic characters as well ([`<Alpha>`]).

```abnf
IRI =
	URI-scheme %x3A IRI-hier-part
	[%x3F IRI-query]
	[%x23 IRI-fragment]
```
{: id="prod.IRI"}
```abnf
IRI-hier-part =
	%x2F.2F IRI-authority IRI-path-abempty
	/ IRI-path-absolute
	/ IRI-path-rootless
	/ IRI-path-empty
```
{: id="prod.IRI-hier-part"}
```abnf
IRI-authority =
	[IRI-userinfo %x40]
	IRI-host
	[%x3A URI-port]
```
{: id="prod.IRI-authority"}
```abnf
IRI-userinfo =
	*(
		IRI-unreserved
		/ URI-pct-encoded
		/ URI-sub-delims
		/ %x3A
	)
```
{: id="prod.IRI-userinfo"}
```abnf
IRI-host =
	URI-IP-literal
	/ URI-IPv4address
	/ IRI-reg-name
```
{: id="prod.IRI-host"}
```abnf
IRI-reg-name =
	*(
		IRI-unreserved
		/ URI-pct-encoded
		/ URI-sub-delims
	)
```
{: id="prod.IRI-reg-name"}
```abnf
IRI-path-abempty = *(%x2F IRI-segment)
```
{: id="prod.IRI-abempty"}
```abnf
IRI-path-absolute =
	%x2F [
		IRI-segment-nz
		*(%x2F IRI-segment)
	]
```
{: id="prod.IRI-path-absolute"}
```abnf
IRI-path-rootless = IRI-segment-nz *(%x2F IRI-segment)
```
{: id="prod.IRI-path-rootless"}
```abnf
IRI-path-empty = 0IRI-pchar
```
{: id="prod.IRI-path-empty"}
```abnf
IRI-segment = *IRI-pchar
```
{: id="prod.IRI-segment"}
```abnf
IRI-segment-nz = 1*IRI-pchar
```
{: id="prod.IRI-segment-nz"}
```abnf
IRI-pchar =
	IRI-unreserved
	/ URI-pct-encoded
	/ URI-sub-delims
	/ %x3A-40
```
{: id="prod.IRI-pchar"}
```abnf
IRI-query = *(IRI-pchar / Privateuse / %x2F / %x3F)
```
{: id="prod.IRI-query"}
```abnf
IRI-fragment = *(IRI-pchar / %x2F / %x3F)
```
{: id="prod.IRI-fragment"}
```abnf
IRI-unreserved =
	Alpha / Decimal / %x2D-2E / %x5F / %x7E
	/ UCSChar
```
{: id="prod.IRI-unreserved"}
```abnf
URI-scheme = Alpha *(Alpha / Decimal / %x2B / %x2D-2E)
```
{: id="prod.URI-scheme"}
```abnf
URI-port = *Decimal
```
{: id="prod.URI-port"}
```abnf
URI-IP-literal =
	%x5B (
		URI-IPv6address
		/ URI-IPvFuture
	) %x5D
```
{: id="prod.URI-IP-literal"}
```abnf
URI-IPvFuture =
	(%x56 / %x76) 1*Hex %x2E
	1*(URI-unreserved / URI-sub-delims / %x5B)
```
{: id="prod.URI-IPvFuture"}
```abnf
URI-IPv6address =
	6(URI-h16 %x3A) URI-ls32
	/ %x3A.3A
		5(URI-h16 %x3A) URI-ls32
	/ [URI-h16] %x3A.3A
		4(URI-h16 %x3A) URI-ls32
	/ [*1(URI-h16 %x3A) URI-h16] %x3A.3A
		3(URI-h16 %x3A) URI-ls32
	/ [*2(URI-h16 %x3A) URI-h16] %x3A.3A
		2(URI-h16 %x3A) URI-ls32
	/ [*3(URI-h16 %x3A) URI-h16] %x3A.3A
		URI-h16 %x3A URI-ls32
	/ [*4(URI-h16 %x3A) URI-h16] %x3A.3A
		URI-ls32
	/ [*5(URI-h16 %x3A) URI-h16] %x3A.3A
		URI-h16
	/ [*6(URI-h16 %x3A) URI-h16] %x3A.3A
```
{: id="prod.URI-IPv6address"}
```abnf
URI-h16 = 1*4Hex
	; 16 bits of address represented in hexadecimal
```
{: id="prod.URI-h16"}
```abnf
URI-ls32 = (URI-h16 %x3A URI-h16) / IPv4address
	; Least significant 32 bits of address
```
{: id="prod.URI-ls32"}
```abnf
URI-IPv4address =
	URI-dec-octet
	%x2E URI-dec-octet
	%x2E URI-dec-octet
	%x2E URI-dec-octet
```
{: id="prod.URI-IPv4address"}
```abnf
URI-dec-octet =
	%x32 %x35 %x30-35
		; 250--255
	/ %x32 %x30-34 Decimal
		; 200--249
	/ One 2Decimal
		; 100--199
	/ NonZero Decimal
		; 10--99
	/ Decimal
		; 0--9
```
{: id="prod.URI-dec-octet"}
```abnf
URI-pct-encoded = %x25 Hex Hex
```
{: id="prod.URI-pct-encoded"}
```abnf
URI-unreserved = Alpha / Decimal / %x2D-2E / %x5F / %x7E
```
{: id="prod.URI-unreserved"}
```abnf
URI-sub-delims = %x21 / %x24 / %x26-2C / %x3B / %x3D
```
{: id="prod.URI-sub-delims"}

[IRI]s must be [`<IRI>`]s as defined by [RFC3987], from which the above productions were taken.

```abnf
NonEmptyString = NoSpace *([Space] NoSpace)
```
{: id="prod.NonEmptyString"}
```abnf
String = [NonEmptyString]
	; May be empty
```
{: id="prod.String"}
```abnf
CommentString = [NoSpace [*NoBreak NoSpace]]
	; May be empty
```
{: id="prod.CommentString"}

Ordinary strings cannot begin or end with spaces, or have multiple spaces appear in sequence.
Comment strings allow multiple spaces in sequence.
Neither allows linebreaks.

```
NameChar = UpperAlpha / Decimal / %x20 / %x2D
	; Valid characters for use in names
```
{: id="prod.NameChar"}
```abnf
NameSpaceSequence =
	Space (
		UpperAlpha
			; A letter
		/ (%x2D (UpperAlpha / Decimal))
			; A hyphen followed by a letter or digit
	)
		; Rules for including a space in a name
```
{: id="prod.NameSpaceSequence"}
```abnf
NameHyphenSequence =
	%x2D (
		UpperAlpha
			; A letter
		/ Decimal
			; A digit
		/ NameSpaceSequence
			; A space (and then some) as defined above
	)
		; Rules for including a hyphen
```
{: id="prod.NameHyphenSequence"}
```abnf
Name =
	UpperAlpha *(
		UpperAlpha
		/ Decimal
		/ NameSpaceSequence
		/ NameHyphenSequence
	)
		; Valid character, block, and script names
```
{: id="prod.Name"}

Names must start with an uppercase ASCII letter, and may consist of uppercase ASCII letters, ASCII digits, `U+002D HYPHEN-MINUS`, or spaces.
Hyphens and spaces must not end a name or appear in sequence.
Hyphens must not be surrounded by spaces, and digits must not be preceded by a space.

```
Codepoint =
	*Zero NonZeroHex *3UpperHex
		; Any nonzero value
	/ 1*Zero
		; Zero
```
{: id="prod.Codepoint"}
```abnf
UnicodeCodepoint =
	%x55 %x2B
	(
		*Zero (One Zero / NonZeroHex) *4UpperHex
			; Any nonzero value
		/ 1*Zero
			; Zero
	)
```
{: id="prod.UnicodeCodepoint"}
```abnf
BinaryCodepoint =
	*(Zero [Space]) One *15([Space] Bit)
	/ Zero *([Space] Zero)
```
{: id="prod.BinaryCodepoint"}
```abnf
Integer =
	Zero
	/ NonZeroHex *3UpperHex
```
{: id="prod.Integer"}

<div role="note" markdown="block">
The rules defined above are designed to facilitate first-match-wins, greedy matching.
</div>

Ordinary codepoints must be hexadecimal numbers in the range `0000`–`FFFF` but may be preceded by any number of zeroes.

Unicode codepoints must be preceded with the string `U+` and may be padded with any number of zeroes.
Only codepoints in the range `U+0000..U+10FFFF` are valid Unicode codepoints.

Binary codepoints may have single spaces between their digits.

Integer values are expressed as hexadecimal numbers from `0`–`FFFF`, with no leading zeroes.

### 3.4 Comment
{: id="definition.comment"}

```abnf
SingleLineComment =
	*Space %x2F
	*Space CommentString
	*Space Break
```
{: id="prod.SingleLineComment"}
```abnf
InnerCommentLine =
	(
		NoSlash
		/ %x2F NoSlash
		/ %x2F.2F NoSlash
		/ %x2F.2F.2F NoBreak
	)  *NoBreak Break
```
{: id="prod.InnerCommentLine"}
```abnf
MultiLineComment =
	%x2E.2E.2E Break
	*InnerCommentLine
	%x2F.2F.2F Break
```
{: id="prod.MultiLineComment"}
```abnf
Comment =
	SingleLineComment
	/ MultiLineComment
```
{: id="prod.Comment"}

A single-line comment is a single line beginning with `U+002F SOLIDUS` and then followed by any number of other characters.
Multi-line comments begin with three `U+002E FULL STOP` characters and end with three `U+002F SOLIDUS` characters.
Comments should be ignored during processing.

<div role="note" markdown="block">
Note that multi-line comments can only appear on the "top level" and not inside of character declarations or other productions.
</div>

### 3.5 Common Constructs
{: id="definition.common"}

The following productions are used in multiple types of declaration, with similar meanings.

#### 3.5.1 Aliases
{: id="definition.common.aliases"}

```abnf
Alias =
	*Space %x3D
	*Space Name
	*Space Break
	*SingleLineComment
```
{: id="prod.Alias"}
```abnf
Aliases = 1*Alias
```
{: id="prod.Aliases"}

An [`<Aliases>`] gives alternate [`<Name>`]s by which a `kixt:Block` or `kixt:Character` might be known.
It consists of one or more lines, each beginning with an `U+003D EQUALS SIGN`, and followed by a [`<Name>`].

Upon reaching an [`<Aliases>`], for each [`<Name>`], create a new [RDF triple] with <var>current parent</var> as its subject, <code>kixt:alias</code> as its predicate, and the value of the [`<Name>`] as its object, as an [`xsd:string`].

#### 3.5.2 Other names
{: id="definition.common.other_names"}

```abnf
OtherName =
	*Space %x2D
	*Space NonEmptyString
	*Space Break
	*SingleLineComment
```
{: id="prod.OtherName"}
```abnf
OtherNames = 1*OtherName
```
{: id="prod.OtherNames"}

An [`<OtherNames>`] gives alternate names for a `kixt:Charset`, `kixt:Block`, `kixt:Script`, or `kixt:Character`, which may be more freeform than the [`<Name>`] production allows.
It consists of one or more lines, each beginning with an `U+002D HYPHEN-MINUS`, and followed by a [`<NonEmptyString>`].

Upon reaching an [`<OtherNames>`], for each [`<NonEmptyString>`], create a new [RDF triple] with <var>current parent</var> as its subject, <code>kixt:alsoKnownAs</code> as its predicate, and the value of the [`<NonEmptyString>`] as its object, as an [`xsd:string`].

#### 3.5.3 Notes
{: id="definition.common.notes"}

```abnf
Note =
	*Space %x2A
	*Space NonEmptyString
	*Space Break
	*SingleLineComment
```
{: id="prod.Note"}
```abnf
Notes = 1*Note
```
{: id="prod.Notes"}

A [`<Notes>`] gives a freeform space for adding informative notes to a `kixt:Charset`, `kixt:Block`, `kixt:Script`, or `kixt:Character`.
It consists of one or more lines, each beginning with an `U+002A ASTERISK`, and followed by a [`<NonEmptyString>`].

Upon reaching a [`<Notes>`], for each [`<NonEmptyString>`], create a new [RDF triple] with <var>current parent</var> as its subject, <code>kixt:note</code> as its predicate, and the value of the [`<NonEmptyString>`] as its object, as an [`xsd:string`].

### 3.6 Charset Declaration
{: id="definition.charset"}

```abnf
CharsetDeclaration =
	CharsetIdentifier
	CharsetProperties
	[OtherNames]
	[Notes]
```
{: id="prod.CharsetDeclaration"}

A [`<CharsetDeclaration>`] defines the [Kixt Charset Definition]'s `kixt:Charset`.
It must be the first thing in a Kixt Charset Definition, after an optional `U+FEFF Byte Order Mark`, with no leading spaces or breaks.

#### 3.6.1 Charset identifier
{: id="definition.charset.identifier"}

```abnf
CharsetIdentifier =
	%x3B.43.48.41.52.53.45.54.3C
		; `;CHARSET<`
	IRI %x3E [
		Integer
		[%x2E Integer]
	] *Space Break
	*SingleLineComment
```
{: id="prod.CharsetInfo"}

A [`<CharsetIdentifier>`] defines the IRI and version for a [Kixt Charset Definition]'s `kixt:Charset`.
Upon reaching a [`<CharsetIdentifier>`], set the <var>current charset</var> to the IRI specified by [`<IRI>`].
Set <var>current parent</var> to <var>current charset</var>.
Create an [RDF triple] with the <var>current charset</var> as its subject, [`rdf:type`] as its predicate, and `kixt:Charset` as its object.

If a first [`<Integer>`] is present, create an [RDF triple] with the <var>current charset</var> as its subject, `kixt:version` as its predicate, and the value of the first [`<Integer>`] as its object, as an [`xsd:integer`].
If a second [`<Integer>`] is present, create an RDF triple with the <var>current charset</var> as its subject, `kixt:revision` as its predicate, and the value of the second [`<Integer>`] as its object, as an [`xsd:integer`].

Finally, set <var>current script</var> to `kixt:UNKNOWN`; this is the default [script].

#### 3.6.2 Charset properties
{: id="definition.charset.properties"}

```abnf
Variable = %x56.41.52.49.41.42.4C.45
	; `VARIABLE`
```
{: id="prod.Variable"}
```abnf
CharsetProperties =
	[
		*Space %x26
		*Space Variable
		*Space Break
		*SingleLineComment
	]
```
{: id="prod.CharsetProperties"}

A [`<CharsetProperties>`] defines additional properties on a `kixt:Character`.
At the moment, the only additional property defined is a promise as to whether the character set is [variable-width compatible].
This property must be present if the production is nonempty.
[`<CharsetProperties>`] begins with an `U+0026 AMPERSAND`.

Upon reaching a [`<CharsetProperties>`]:

01. Create a new [RDF triple] with <var>current charset</var> as its subject, `kixt:supportsVariableEncoding` as its predicate, and an object of `true`, as an [`xsd:boolean`], if [`<Variable>`] is present, and `false`, as an [`xsd:boolean`], otherwise.

### 3.7 Block Declaration
{: id="definition.block"}

```abnf
BlockDeclaration =
	BlockName
	[Aliases]
	[OtherNames]
	[Notes]
```
{: id="prod.BlockDeclaration"}

A [`<BlockDeclaration>`] defines a new `kixt:Block`.

#### 3.7.1 Block name
{: id="definition.block.name"}

```abnf
BlockName =
	*Space %x25
	*Space Name
	*Space Break
	*SingleLineComment
```
{: id="prod.BlockName"}

A [`<BlockName>`] names a `kixt:Block`.
It begins with a `U+0025 PERCENT SIGN`, which is followed by the block name.

The special name `NO BLOCK` signifies no block.
A [`<BlockDeclaration>`] with a [`<Name>`] of `NO BLOCK` must not have a [`<Aliases>`], [`<OtherNames>`], or [`<Notes>`].

Upon reaching a [`<BlockName>`], if the value of [`<Name>`] is `NO BLOCK`, set <var>in a block</var> to <i>false</i>.
Otherwise, set <var>in a block</var> to <i>true</i>, set <var>current block</var> to a new [blank node], and set <var>current parent</var> to <var>current block</var>.

If <var>in a block</var> is <i>true</i>, create a new [RDF triple] with <var>current block</var> as its subject, `kixt:name` as its predicate, and the value of [`<Name>`] as its object, as a [`xsd:string`].

### 3.8 Script Declaration
{: id="definition.script"}

```abnf
ScriptDeclaration =
	ScriptIdentifier
	[OtherNames]
	[Notes]
```
{: id="prod.ScriptDeclaration"}

A [`<ScriptDeclaration>`] defines a new `kixt:Script`.

#### 3.8.1 Script identifier
{: id="definition.script.identifier"}

```abnf
ScriptIdentifier =
	*Space %x27
	*Space %x3C IRI %x3E
	*Space Break
	*SingleLineComment
```
{: id="prod.ScriptIdentifier"}

A [`<ScriptIdentifier>`] sets the IRI for the current `kixt:Script`.
It begins with a `U+0027 APOSTROPHE`, which is followed by the script [`<IRI>`].

Three special scripts are defined in the [Kixt Ontology]:

+ `kixt:COMMON`, for characters which do not belong to a single script
+ `kixt:INHERITED`, for combining characters which inherit their script from some base character
+ `kixt:UNKNOWN`, for characters whose script is unknown

<div role="note" markdown="block">
The above values are given prefixed, but the actual value of [`<IRI>`] must be a full (expanded) [IRI].
</div>

Upon reaching a [`<ScriptIdentifier>`], set <var>current script</var> to [`<IRI>`] and <var>current parent</var> to <var>current script</var>.

### 3.9 Character Definition
{: id="definition.character"}

```abnf
CharacterDefinition =
	UnicodeMapping
	CharacterInfo
	CompatibilityMapping
	DecompositionMapping
	AdditionalProperties
	[Aliases]
	[OtherNames]
	[Notes]
	[References]
	[Glyphs]
```
{: id="prod.CharacterDefinition"}

A [`<CharacterDefinition>`] defines a single `kixt:Character`.
The [`<UnicodeMapping>`] and [`<CharacterInfo>`] productions are required; the [`<CompatibilityMapping>`], [`<DecompositionMapping>`], and [`<AdditionalProperties>`] productions are required but may be empty; all other productions are optional but must be specified in the order above.

Upon reaching a [`<CharacterDefinition>`], set <var>current character</var> to a new [blank node].
Set <var>current parent</var> to <var>current character</var>.
Create a new [RDF triple] with <var>current charset</var> as its subject, `kixt:character` as its predicate, and <var>current character</var> as its object.

If <var>in a block</var> is <i>true</i>, create a new [RDF triple] with <var>current character</var> as its subject, `kixt:block` as its predicate, and <var>current block</var> as its object.

Create a new [RDF triple] with <var>current character</var> as its subject, `kixt:script` as its predicate, and <var>current script</var> as its object.

#### 3.9.1 Unicode mapping
{: id="definition.character.unicode"}

```abnf
Unicode =
	*Space UnicodeCodepoint
	[1*Space CommentString]
	*Space Break
	*SingleLineComment
```
{: id="prod.Unicode"}
```abnf
UnicodeMapping = 1*Unicode
```
{: id="prod.UnicodeMapping"}

A [`<UnicodeMapping>`] defines a the [Unicode] scalar values to which a given `kixt:Character` maps.
These are given as [`<UnicodeCodepoint>`]s, one per line, each optionally followed by a comment.

The [Kixt Charset Definition] format requires every [`<CharacterDefinition>`] to have a [`<UnicodeMapping>`].
The character `U+FFFD REPLACEMENT CHARACTER` can be used in situations where no mapping is desired.
However, the use of private-use mappings is generally preferable.

Upon reaching a [`<UnicodeMapping>`], set <var>current sequence</var> to a new [blank node].
Create a new [RDF triple] with <var>current sequence</var> as its subject, [`olo:length`] as its predicate, and total number of [`<UnicodeCodepoint>`]s within the [`<UnicodeMapping>`] as its object, as an [`xsd:integer`].

For each [`<UnicodeCodepoint>`]:

01. Set <var>current slot</var> to a new [blank node].
    Create a new [RDF triple] with <var>current slot</var> as its subject, [`olo:index`] as its predicate, and the one-based index of the [`<UnicodeCodepoint>`] within the [`<UnicodeMapping>`] as its object, as an [`xsd:integer`].

02. Set <var>current item</var> to a new [blank node].
    Create a new [RDF triple] with <var>current item</var> as its subject, [`rdf:value`] as its predicate, and the value of the [`<UnicodeCodepoint>`] as its object, as an [`xsd:integer`].

03. Create a new [RDF triple] with <var>current slot</var> as its subject, [`olo:item`] as its predicate, and <var>current item</var> as its object.

04. Create a new [RDF triple] with <var>current sequence</var> as its subject, [`olo:slot`] as its predicate, and <var>current slot</var> as its object.

Finally, create a new [RDF triple] with <var>current character</var> as its subject, `kixt:unicode` as its predicate, and <var>current sequence</var> as its object.

<div role="note" markdown="block">
In [Turtle], the resulting [RDF graph] produced by the above steps will look something like the following:

```ttl
[ ] kixt:unicode [
	olo:length 1;
	olo:slot [
		olo:index 1 ;
		olo:item [ rdf:value 65533 ] ] ]
```
</div>

#### 3.9.2 Character info
{: id="definition.character.info"}

```abnf
BasicType =
	%x43.4F.4E.54.52.4F.4C
		; `CONTROL`
	/ %x4D.45.53.53.41.47.49.4E.47
		; `MESSAGING`
	/ %x46.4F.52.4D.41.54
		; `FORMAT`
	/ %x44.41.54.41
		; `DATA`
	/ %x4E.4F.4E.53.50.41.43.49.4E.47
		; `NONSPACING`
	/ %x53.50.41.43.49.4E.47
		; `SPACING`
	/ %x50.52.49.56.41.54.45.55.53.45
		; `PRIVATEUSE`
	/ %x4E.4F.4E.43.48.41.52.41.43.54.45.52
		; `NONCHARACTER`
	; It is not possible to define an `UNASSIGNED` character
```
{: id="prod.BasicType"}
```abnf
CharacterInfo =
	*Space %x3B
	*Space (BinaryCodepoint *Space %x2F / Codepoint Space)
	*Space Name
	*Space %x28 BasicType %x29
	*Space Break
	*SingleLineComment
```
{: id="prod.CharacterInfo"}

A [`<CharacterInfo>`] defines the basic aspects of a `kixt:Character`.
It begins with a `U+003B SEMICOLON`, followed by a codepoint in either hexadecimal or binary, followed by the name and basic type of the character.

Upon reaching a [`<CharacterInfo>`], perform the following steps:

01. If there is already some subject [node] which is an object of the predicate `kixt:character` on the subject <var>current charset</var>, for whom the object of the predicate `kixt:codepoint` is the value of the [`<Codepoint>`] or [`<BinaryCodepoint>`] (whichever is present), replace <var>current character</var> with the first such node in all [RDF triples][RDF triple] in which <var>current character</var> is a subject or object, and set <var>current character</var> to this new node.

    <div role="note" markdown="block">
    This handles the case where a `kixt:Character` with this codepoint has already been created as part of a decomposition mapping.
    </div>

    Otherwise, create a new [RDF triple] with <var>current character</var> as its subject, `kixt:codepoint` as its predicate, and the value of either [`<Codepoint>`] or [`<BinaryCodepoint>`] as its object, as an [`xsd:integer`].

02. Create a new [RDF triple] with <var>current character</var> as its subject, `kixt:name` as its predicate, and the value of [`<Name>`] as its object, as an [`xsd:string`].

03. Create a new [RDF triple] with <var>current character</var> as its subject, `kixt:basicType` as its predicate, and the value of [`<BasicType>`], appended to the end of the string `https://vocab.KIBI.network/Kixt/#`, as its object, as an [`xsd:anyURI`].

    <div role="note" markdown="block">
    Note that this is a [literal] with a [datatype IRI] of [`xsd:anyURI`], *not* an [RDF IRI][IRI].
    </div>

#### 3.9.3 Compatibility mapping
{: id="definition.character.compatibility"}

```abnf
CompatibilityMapping =
	[
		*Space %x28
		*Space [%x3C IRI %x3E]
		*Space Codepoint
		*(1*Space Codepoint)
		*Space Break
		*SingleLineComment
	]
```
{: id="prod.CompatibilityMapping"}

A [`<CompatibilityMapping>`] defines a compatibility decomposition for a `kixt:Character`.
It begins with a `U+0028 LEFT PARENTHESIS`, followed by an optional [`<IRI>`] mode, followed by a sequence of [`<Codepoint>`]s giving the mapping.
The entire production may be empty; if so, the character's compatibility decomposition is to itself.

The value `kixt:GENERIC` indicates a generic compatibility mode and is the default.

Upon reaching a [`<CompatibilityMapping>`], set <var>current sequence</var> to a new [blank node].
Create a new [RDF triple] with <var>current sequence</var> as its subject, [`olo:length`] as its predicate, and the total number of [`<Codepoint>`]s within the [`<CompatibilityMapping>`], or `1` if [`<CompatibilityMapping>`] is empty, as its object, as an [`xsd:integer`].

For each [`<Codepoint>`], or if the [`<CompatibilityMapping>`] is empty:

01. Set <var>current slot</var> to a new [blank node].
    Create a new [RDF triple] with <var>current slot</var> as its subject, [`olo:index`] as its predicate, and the one-based index of the [`<Codepoint>`] within the [`<CompatibilityMapping>`], or `1` if [`<CompatibilityMapping>`] is empty, as its object, as an [`xsd:integer`].

02. If [`<CompatibilityMapping>`] is empty, set <var>current item</var> to <var>current character</var>.
	Otherwise, if there is already some subject [node] which is an object of the predicate `kixt:character` on the subject <var>current charset</var>, for whom the object of the predicate `kixt:codepoint` is the value of the current [`<Codepoint>`], set <var>current item</var> to that node.
    Otherwise:

    01. Set <var>current item</var> to a new [blank node].

    02. Create a new [RDF triple] with <var>current charset</var> as its subject, `kixt:character` as its predicate, and <var>current item</var> as its object.

    03. Create a new [RDF triple] with <var>current item</var> as its subject, `kixt:codepoint` as its predicate, and the value of [`<Codepoint>`] as its object, as an [`xsd:integer`].

03. Create a new [RDF triple] with <var>current slot</var> as its subject, [`olo:item`] as its predicate, and <var>current item</var> as its object.

04. Create a new [RDF triple] with <var>current sequence</var> as its subject, [`olo:slot`] as its predicate, and <var>current slot</var> as its object.

05. Create a new [RDF triple] with <var>current sequence</var> as its subject, `kixt:compatibilityMode` as its predicate, and the value of [`<IRI>`], or `https://vocab.KIBI.network/Kixt/#GENERIC` if [`<IRI>`] is not present, as its object, as an [IRI].

Finally, create a new [RDF triple] with <var>current character</var> as its subject, `kixt:compatibility` as its predicate, and <var>current sequence</var> as its object.

<div role="note" markdown="block">
In [Turtle], the resulting [RDF graph] produced by the above steps will look something like the following:

```ttl
[ ] kixt:compatibility [
	olo:length 1;
	kixt:mode <example:mode> ;
	olo:slot [
		olo:index 1 ;
		olo:item [ kixt:codepoint: 69 ] ] ]
```
</div>

#### 3.9.4 Decomposition mapping
{: id="definition.character.decomposition"}

```abnf
DecompositionMapping =
	[
		(
			*Space %x3C
			*Space Codepoint
			*(1*Space Codepoint)
			*Space Break
		) / (
			*Space %x3C.3C
			*Space Codepoint
			1*(1*Space Codepoint)
			*Space Break
		)
		*SingleLineComment
	]
```
{: id="prod.DecompositionMapping"}

A [`<DecompositionMapping>`] defines a canonical decomposition for a `kixt:Character`.
It begins with either one or two `U+003C LESS-THAN SIGN`s (indicating whether the decomposed form is preferred), followed by a sequence of [`<Codepoint>`]s giving the mapping.
The entire production may be empty; if so, the character's canonical decomposition is to itself.

<div role="note" markdown="block">
A decomposition mapping to a single character is *always* preferred, so the two-`U+003C LESS-THAN SIGN` form is only permitted when defining a mapping to two or more codepoints.
</div>

Upon reaching a [`<DecompositionMapping>`], set <var>current sequence</var> to a new [blank node].
Create a new [RDF triple] with <var>current sequence</var> as its subject, [`olo:length`] as its predicate, and total number of [`<Codepoint>`]s within the [`<DecompositionMapping>`], or `1` if [`<DecompositionMapping>`] is empty, as its object, as an [`xsd:integer`].

For each [`<Codepoint>`], or if the [`<DecompositionMapping>`] is empty:

01. Set <var>current slot</var> to a new [blank node].
    Create a new [RDF triple] with <var>current slot</var> as its subject, [`olo:index`] as its predicate, and the one-based index of the [`<Codepoint>`] within the [`<DecompositionMapping>`], or `1` if [`<DecompositionMapping>`] is empty, as its object, as an [`xsd:integer`].

02. If [`<DecompositionMapping>`] is empty, set <var>current item</var> to <var>current character</var>.
    If there is already some subject [node] which is an object of the predicate `kixt:character` on the subject <var>current charset</var>, for whom the object of the predicate `kixt:codepoint` is the value of the current [`<Codepoint>`], set <var>current item</var> to that node.
    Otherwise:

    01. Set <var>current item</var> to a new [blank node].

    02. Create a new [RDF triple] with <var>current charset</var> as its subject, `kixt:character` as its predicate, and <var>current item</var> as its object.

    03. Create a new [RDF triple] with <var>current item</var> as its subject, `kixt:codepoint` as its predicate, and the value of [`<Codepoint>`], converted from hexadecimal, as its object, as an [`xsd:integer`].

03. Create a new [RDF triple] with <var>current slot</var> as its subject, [`olo:item`] as its predicate, and <var>current item</var> as its object.

04. Create a new [RDF triple] with <var>current sequence</var> as its subject, [`olo:slot`] as its predicate, and <var>current slot</var> as its object.

05. Create a new [RDF triple] with <var>current sequence</var> as its subject, `kixt:preferred` as its predicate, and an object of `true`, as an [`xsd:boolean`], if [`<DecompositionMapping>`] contains two `U+003C LESS-THAN SIGN`s or only one [`<Codepoint>`], and `false`, as an [`xsd:boolean`], otherwise.

Finally, create a new [RDF triple] with <var>current character</var> as its subject, `kixt:decomposition` as its predicate, and <var>current sequence</var> as its object.

<div role="note" markdown="block">
In [Turtle], the resulting [RDF graph] produced by the above steps will look something like the following:

```ttl
[ ] kixt:decomposition [
	olo:length 1;
	kixt:preferred true ;
	olo:slot [
		olo:index 1 ;
		olo:item [ kixt:codepoint: 105 ] ] ]
```
</div>

#### 3.9.5 Additional properties
{: id="definition.character.additional"}

```abnf
Deprecated = %x44.45.50.52.45.43.41.54.45.44
	; `DEPRECATED`
```
{: id="prod.Deprecated"}
```abnf
CharacterWidth =
	%x50.52.4F.50.4F.52.54.49.4F.4E.41.4C
		; `PROPORTIONAL`
	/ %x46.55.4C.4C.57.49.44.54.48
		; `FULLWIDTH`
```
{: id="prod.CharacterWidth"}
```abnf
SegmentationClass =
	%x45.58.54.45.4E.44.53
		; `EXTENDS`
	/ %x44.49.56.49.44.45.53
		; `DIVIDER`
```
{: id="prod.SegmentationClass"}
```abnf
ConjoiningMode =
	%x43.4F.4E.4A.4F.49.4E.53.3C
		; `CONJOINS<`
	IRI %x3E
```
{: id="prod.ConjoiningType"}
```abnf
Conjoins = ConjoiningMode [Integer]
```
{: id="prod.Conjoins"}
```abnf
Combines = SegmentationClass [%x2B Integer]
```
{: id="prod.Combines"}
```abnf
AdditionalProperties =
	[
		*Space %x26
		*Space (
			Deprecated [
				1*Space (
					CharacterWidth [
						1*Space ConjoiningMode
					]
					/ Conjoins
					/ Combines
				)
			]
			/ CharacterWidth [
				1*Space ConjoiningMode
			]
			/ Conjoins
			/ Combines
		)
		*Space Break
		*SingleLineComment
	]
```
{: id="prod.AdditionalProperties"}

An [`<AdditionalProperties>`] defines a number of additional properties on a `kixt:Character`; in order, these are: whether the character is deprecated, whether the character is fullwidth or proportional, whether the character conjoins with previous characters of a similar type, and whether the character is a combining character.
All of these elements are optional, but at least one must be present if the production is nonempty as a whole.
[`<AdditionalProperties>`] begins with an `U+0026 AMPERSAND`.

Upon reaching an [`<AdditionalProperties>`]:

01. Create a new [RDF triple] with <var>current character</var> as its subject, `kixt:deprecated` as its predicate, and an object of `true`, as an [`xsd:boolean`], if [`<DecompositionMapping>`] contains [`<Deprecated>`], and `false`, as an [`xsd:boolean`], otherwise.

02. Create a new [RDF triple] with <var>current character</var> as its subject, `kixt:fullwidth` as its predicate, and an object of `YES`, as an [`xsd:string`], if [`<CharacterWidth>`] is `FULLWIDTH`; `NO`, as an [`xsd:string`], if [`<CharacterWidth>`] is `PROPORTIONAL`; and an empty [`xsd:string`] if [`<CharacterWidth>`] is not present.

03. Create a new [RDF triple] with <var>current character</var> as its subject, `kixt:segments` as its predicate, and an object of `YES`, as an [`xsd:string`], if [`<SegmentationClass>`] is `DIVIDER`; `NO`, as an [`xsd:string`], if [`<SegmentationClass>`] is `EXTENDS`; and an empty [`xsd:string`], if [`<SegmentationClass>`] is not present.

04. Create a new [RDF triple] with <var>current character</var> as its subject, `kixt:combiningClass` as its predicate, and the value of [`<Integer>`] in [`<Combines>`], if present, or `0`, otherwise, as its object, as an [`xsd:integer`].

05. If [`<ConjoiningMode>`] is present (including within a [`<Conjoins>`]), create a new [RDF triple] with <var>current character</var> as its subject, `kixt:conjoiningMode` as its predicate, and the value  [`<ConjoiningMode>`] as its object, as an [IRI].

06. Create a new [RDF triple] with <var>current character</var> as its subject, `kixt:conjoiningClass` as its predicate, and the value of [`<Integer>`] in [`<Conjoins>`], if present, or `0`, otherwise, as its object, as an [`xsd:integer`].

#### 3.9.6 References
{: id="definition.character.references"}

```abnf
Reference =
	*Space %x3E
	*Space Codepoint
	[1*Space CommentString]
	*Space Break
	*SingleLineComment
```
{: id="prod.Reference"}
```abnf
References = 1*Reference
```
{: id="prod.References"}

A [`<References>`] allows a `kixt:Character` to be associated with other `kixt:Character`s for the purposes of comparison.
It consists of one or more lines, each beginning with an `U+003E GREATER-THAN SIGN`, and followed by a [`<Codepoint>`] and optional comment.

Upon reaching a [`<References>`], for each [`<Codepoint>`]:

01. If there is already some subject [node], which is an object of the predicate `kixt:character` on the subject <var>current charset</var>, for whom the object of the predicate `kixt:codepoint` is the value of the current [`<Codepoint>`], set <var>current item</var> to that node.
    Otherwise:

    01. Set <var>current item</var> to a new [blank node].

    02. Create a new [RDF triple] with <var>current charset</var> as its subject, `kixt:character` as its predicate, and <var>current item</var> as its object.

    03. Create a new [RDF triple] with <var>current item</var> as its subject, `kixt:codepoint` as its predicate, and the value of [`<Codepoint>`], converted from hexadecimal, as its object, as an [`xsd:integer`].

02. Create a new [RDF triple] with <var>current character</var> as its subject, <code>kixt:compare</code> as its predicate, and <var>current item</var> as its object.

#### 3.9.7 Glyphs
{: id="definition.character.glyphs"}

```abnf
HexGlyph = 8*UpperHex
```
{: id="prod.HexGlyph"}
```abnf
Glyph =
	*Space %x29
	*Space HexGlyph
	*Space Break
	*SingleLineComment
```
{: id="prod.Glyph"}
```abnf
Glyphs = 1*Glyph
```
{: id="prod.Glyphs"}

A [`<Glyphs>`] provides a lofi black-and-white representative glyphs for a `kixt:Character`.
It consists of one or [`<Glyph>`]s, each beginning with a `U+0029 RIGHT PARENTHESIS` and consisting of one or more lines of binary data represented in hexadecimal.
Each bit of this data represents a pixel, with `0` indicating the background colour and `1` the foreground, beginning from the starting (in both horizontal and vertical directions, and travelling in the direction of the writing mode) corner of the glyph.

Upon reaching a [`<Glyphs>`], for each [`<Glyph>`], create a new [RDF triple] with <var>current character</var> as its subject, <code>kixt:representativeGlyph</code> as its predicate, and the value of [`<HexGlyph>`] as its object, as a [`xsd:hexBinary`] padded with additional terminal zeroes as necessary until the total length is even, and the total length times either four or eight is square.

<div role="note" markdown="block">
This effectively limits representative glyphs to having a height divisible by 4.
</div>

## 4. Conformance {#conformance}

A [Kixt Charset Definition] is <dfn id="dfn.well-formed">well-formed</dfn> if it matches the [ABNF] syntax for [`<CharsetDefinition>`] defined by this specification.
Processors of Kixt Charset Definitions must fail to process any Kixt Charset Definition which is not well-formed.

### 4.1 Validity
{: id="conformance.validity"}

In addition to the constraints made by the [ABNF] syntax, the following situations are all semantically <dfn id="dfn.invalid">invalid</dfn> in a [Kixt Charset Definition]:

01. Two or more [`<BlockDeclaration>`]s with identical [`<Name>`]s, when both are not `NO BLOCK`.

02. An [`<Aliases>`], [`<OtherNames>`], or [`<Notes>`] in a [`<BlockDeclaration>`] whose [`<Name>`] is `NO BLOCK`.

03. A [`<Combines>`], [`<Conjoins>`], or [`<CharacterWidth>`] in a [`<CharacterDefinition>`] which does not have a [`<BasicType>`] of `SPACING` or `NONSPACING`.

04. Assigning an object other than `https://vocab.KIBI.network/Kixt/#GENERIC` for the `kixt:compatibilityMode` predicate for a subject whose `kixt:compatibility` predicate has an object with one `kixt:slot` predicate whose object has one `kixt:item` predicate whose object is the subject itself.

    <div role="note" markdown="block">
    In other words, if a [character] has a compatibility decomposition of itself, then it must have the default compatibility mode of `kixt:GENERIC`.
    </div>

05. Assigning the same value as the object of a `kixt:name` or `kixt:alias` predicate for two different subjects of the same `rdf:type` (`kixt:name` and `kixt:alias` must be unique within a shared namespace).

06. Assigning `kixt:INHERITED` as the object of a `kixt:script` predicate while processing a [`<CharacterDefinition>`] which does not contain a [`<Combines>`].

07. Assigning the same object for a `kixt:codepoint` predicate while processing two different [`<CharacterInfo>`]s.

08. Assigning the multiple objects with the same length for a `kixt:representativeGlyph` predicate for a single subject.

09. Finishing processing the [Kixt Charset Definition] when not every `kixt:character` predicate with a subject of <var>current charset</var> has an object for which a `kixt:basicType` predicate has been assigned.

    <div role="note" markdown="block">
    Another way of expressing this constraint is that every [`<Codepoint>`] in a [`<CompatibilityMapping>`], [`<DecompositionMapping>`], or [`<Reference>`] must identify a `kixt:Character` defined in the same document.
    </div>

10. Creating a `kixt:Charset` which is not [variable-width compatible] but for which `kixt:variable` is `true`.

A [Kixt Charset Definition] is <dfn id="dfn.valid">valid</dfn> if it is not [invalid][invalid definition].

The processing behaviours for an [invalid][invalid definition] [Kixt Charset Definition] are undefined.

### 4.2 Compatibility
{: id="conformance.compatibility"}

The following predicates are <dfn id="dfn.compatibility_property">compatibility properties</dfn>:

+ `kixt:unicode`
+ `kixt:basicType`
+ `kixt:segments`
+ `kixt:combiningClass`
+ `kixt:conjoiningMode` (if defined on a character)
+ `kixt:conjoiningClass`

A [Kixt Charset Definition] is <dfn id="dfn.UTF-8_compatible">UTF-8 compatible</dfn> if it is [valid][valid definition] and does not assign any of the following codepoints:

+ `D800`–`DFFF`
+ `FEFF`
+ `FFFE`–`FFFF`

A [Kixt Charset Definition] is <dfn id="dfn.null_compatible">null compatible</dfn> if it is [valid][valid definition] and the objects of the [compatibility properties][compatibility property] are equal to those defined in the following Kixt Charset Definition for all characters so defined:

```kch
;CHARSET<https://charset.KIBI.network/Kixt/Null>1.0

% ASCII CONTROLS AND BASIC LATIN
' <https://vocab.KIBI.network/Kixt/#COMMON>

U+0000
; 00 NULL (FORMAT)
= NUL
* This is a meaningless format character which can be used for byte-padding when encoding texts
```

A [Kixt Charset Definition] is <dfn id="dfn.ASCII_compatible">ASCII compatible</dfn> if it is [valid][valid definition] and the objects of the [compatibility properties][compatibility property] are equal to those defined in <https://charset.KIBI.network/Kixt/ASCII> for all characters so defined.

<div role="note" markdown="block">
All [ASCII compatible]{::} [charsets][charset] are [null compatible].
</div>

## 5. Changelog {#changelog}

{: id="changelog.2019-09-10"} <time>2019-09-10</time>

: `kixt:TRANSMISSION` has been replaced by `kixt:MESSAGING` as a `kixt:basicType`.

{: id="changelog.2019-09-05"} <time>2019-09-05</time>

: Allowed the specification of other names and notes on charsets, blocks, and scripts, and aliases on blocks.

: Added a variable-width promise (`kixt:supportsVariableEncoding`) to charset declarations.

: The syntaxes for [`<Integer>`] and [`<InnerCommentLine>`] were improved.

{: id="changelog.2019-05-03"} <time>2019-05-03</time>

: Redefined a number of syntax components to make it possible to write a Kixt Charset Definition in any ECMA-6–compatible character set.
  By extension, you can now write a Kixt Charset Definition in any [XML compatible] charset.
  (This is a breaking change.)

: Allowed [UTF-16]–encoded documents with the addition of a BOM.

: Required processors to ignore `U+0000 NULL` characters which appear in Kixt Charset Definition documents.

: Removed compatibility definitions that are better-served in other specifications.

{: id="changelog.2019-05-02"} <time>2019-05-02</time>

: Added [`<MultiLineComment>`]s.

: Allowed [`<SingleLineComment>`]s to appear inside of [`<CharacterDefinition>`]s.

{: id="changelog.2019-05-01"} <time>2019-05-01</time>

: Initial specification.

{% include references.md %}
