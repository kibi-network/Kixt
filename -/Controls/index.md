# Kixt Formatting and Controls

## Abstract {#abstract}

The following specification defines standardized meanings for a number of characters common to all [control compatible] character sets.

<nav id="toc" markdown="block">
## Contents

+ Table of Contents
{:toc id="toc.contents"}
</nav>

## 1. Introduction {#introduction}

### 1.1 Purpose and Scope
{: id="introduction.purpose"}

Although the [Kixt Transmissions] specification defines a number of characters for use when transmitting [Kixt documents][document], it fails to define any characters (or sequences thereof) for controlling the applications or devices which interact with them.
This specification fills that gap by defining a set of [Kixt controls] which must be supported by any [terminal-compatible] character set.
It also defines a number of commonly-used [format characters][format character] for use in documents and transmission.

### 1.2 Relationship to Other Specifications
{: id="introduction.related"}

This specification is a part of the [Kixt family of specifications][Kixt].
It builds upon and expands many of the definitions established in [Kixt Transmissions].
However, the behaviours specified here are not [transmission]-specific, and may conceivably be applied in other contexts, for example in messages sent to a device from an external input method.

Like [Kixt Transmissions], this specification is built upon [RDF] technologies.

In this document, the following prefixes are used to represent the following strings:

| Prefix | Expansion |
| :--: | --- |
| `kixt:` | `https://vocab.KIBI.network/Kixt/#` |

## 2. Conformance {#conformance}

For a [Kixt charset][charset], the <dfn id="dfn.Kixt_controls">Kixt controls</dfn> are precisely the set of codepoints of the characters given in the <https://charset.KIBI.network/Kixt/Controls> charset.
For [Unicode], the Kixt controls are the set of codepoints mapped to by the characters in this charset, treated equivalently.
For other character sets, the Kixt controls are not defined by this specification.

<div role="note" markdown="block">
Although it is possible to define other characters in a [Kixt charset][charset] which map to Unicode codepoints which are [Kixt controls], such characters are not Kixt controls themselves.
</div>

[Kixt controls] are not necessarily [control characters][control character] proper; they also include [data characters][data character], [messaging characters][messaging character], [format characters][format character], [noncharacters][noncharacter], and others.
The [transmission characters][transmission character] are a subset of the [Kixt controls] for use in [transmissions][transmission].

A character set defined by a [Kixt Charset Definition] is <dfn id="dfn.control_compatible">control compatible</dfn> if and only if:

+ It is [transmission compatible].

+ The objects of the [compatibility properties][compatibility property] are equal to those defined in <https://charset.KIBI.network/Kixt/Controls> for all characters so defined.

The [Unicode] character set is assumed to be [control compatible].
Whether other character sets are control compatible is left undefined by this specification.

This specification refers to all [Kixt controls] using the names and codepoints given in <https://charset.KIBI.network/Kixt/Controls>.
However, these names are not normative—and in [Unicode] contexts, the corresponding Unicode codepoints should be handled instead.

## 3. Control Characters {#controls}

The [Kixt controls] which are [control characters][control character] are defined as followed:

### 3.1 Transmission Characters
{: id="controls.transmission"}

The [Kixt controls] which are [transmission characters][transmission character] are intended for use in transmissions with the meanings assigned in [Kixt Transmissions].
No further definition of them is provided here.

### 3.2 Positioning Characters
{: id="controls.positioning"}

The following characters change the position of a cursor within an application.

`08 BACK`
`0A ADVANCE`
`80D8 FORWARD`
`80DA RETRACT`

: These characters incrementally change the cursor position.
    The terms <dfn id="dfn.forward">forward</dfn> and <dfn id="dfn.back">back</dfn> refer to a change forwards or backwards in the inline direction.
    The terms <dfn id="dfn.advance">advance</dfn> and  <dfn id="dfn.retract">retract</dfn> refer to a change forwards or backwards in the block direction.

    <div role="note" markdown="block">
    This functionality is typically provided on keyboards through the arrow keys.
    </div>

`09 NEXT`
`0B LINE NEXT`
`80D9 PREVIOUS`
`80DB LINE PREVIOUS`

: These characters <dfn id="dfn.seek">seek</dfn> the cursor forwards or backwards to the next <dfn id="dfn.stop">stop</dfn>, the meaning of which is implementation-defined.
    `09 NEXT` and `80D9 PREVIOUS` give the inline direction precedence when seeking.
    `0B LINE NEXT` and `80DB LINE PREVIOUS` give the block direction precedence when seeking.

    <div role="note" markdown="block">
    This functionality is typically provided on keyboards through the Tab and Numpad Enter keys.
    </div>

`0C PAGE END`
`0D LINE START`
`80DC PAGE START`
`80DD LINE END`

: These characters <dfn id="dfn.skip">skip</dfn> the cursor forwards or backwards to certain predefined locations in a document.
	For `0D LINE START` and `80DD LINE END`, these locations are the beginning and ending of the current line.
	For `80DC PAGE START` and `80DD PAGE END`, these locations are the beginning and ending of the current page.

    <div role="note" markdown="block">
    This functionality is typically provided on keyboards through the Page Down, Home, Page Up, and End keys.
    </div>

### 3.3 Operational Characters
{: id="controls.operations"}

The following characters affect the high-level operations of an application.

`11 BOOT`

: This character requests a boot (or reboot) of the current application.

`12 RESUME`

: This character requests that a suspended application resume operations.

`13 SUSPEND`

: This character requests that an application suspend operations, to be resumed later.

`14 HALT`

: This character requests that an application cease operations.

`80D7 INTERRUPT`

: This character requests that an application cease its current operations and await new instructions.
    This differs from `13 SUSPEND` in that the application is left in an active, rather than suspended, state.

    <div role="note" markdown="block">
    This functionality is typically provided on keyboards through the Pause/Break key.
    </div>

### 3.4 Deletion Characters
{: id="controls.deletion"}

The following characters signal an application to delete content.

`80DE IGNORE`

: This character indicates that the character which follows the cursor is in error and should be deleted.

    <div role="note" markdown="block">
    This functionality is typically provided on keyboards through the Delete key.
    </div>

`80DF OOPS`

: This character indicates that the character which precedes the cursor is in error and should be deleted.
    After deletion, the cursor should be moved backwards to immediately precede the position of the deleted character.
    Consequently, this character is roughly equivalent to `08 BACK` followed by `80DF IGNORE`.

    <div role="note" markdown="block">
    This functionality is typically provided on keyboards through the Backspace key.
    </div>

## 4. Data Characters {#data}

[Kixt Transmissions] defines the `0E LEAVE` and `0F RETURN` [data characters][data character]; however, these are only allowed inside of [headers][header].
This specification defines five new data characters: `10 DATA`, `80C7 STRING BEGIN`, `80C8 DONT`, `80C9 STRING FINISH`, and `80D6 SHIFT`.
These characters are used to create the three types of [data block] defined below.

### 4.1 Data Strings
{: id="data.string"}

A <dfn id="dfn.data_string">data string</dfn> is a sequence of binary data embedded into a document.
They have an [opening data character] of `80C7 STRING BEGIN`, and a [closing data character] of the first `80C9 STRING FINISH` which is not preceded by an odd number of `80C8` codepoints.

<div role="note" markdown="block">
Because it is within a [data block], the `80C8` codepoint is technically not `80C8 DONT`.
However, `80C8 DONT` has no valid uses outside of a data block, and is essentially reserved to avoid confusion.
</div>

The <dfn id="dfn.string_contents">string contents</dfn> of a [data string] are simply the codepoints of its [data contents], ignoring all `80C8` codepoints except:

1.  When one is followed by another `80C8`.
    In this case, both codepoints together are interpreted as a single `80C8` value.
    (This value is not reinterpreted, so `80C8 80C8 80C8 80C8` is interpreted as two codepoints, `80C8 80C8`, not one.)

2.  When one is followed by a `7F`.
    In this case, both codepoints together are interpreted as a single `00` value.
    (This is the only way to include a `00` value in the [string contents] of a [data string], as all literal `00`s are ignored in data blocks.)

<div role="note" markdown="block">
Although the `80C8` will be ignored, the sequence `80C8 80C9` is the only way to include an `80C9` codepoint in the [string contents] of a [data string].
</div>

On their own, [data strings][data string] have no meaning, and their [Unicode mapping] is `FFFC`.
They may be sent in [messages][message], or used in other [data blocks][data block].

### 4.2 Embeds
{: id="data.embed"}

<dfn id="dfn.embed">Embeds</dfn> can be used to embed documents, images, or other content into a run of text.
They have an [opening data character] of `10 DATA`, and a [closing data character] of the first `80C9 STRING FINISH` which is not preceded by an odd number of `80C8` codepoints.

The <dfn id="dfn.media_type">media type</dfn> of an embed can optionally be provided immediately following the opening `10 DATA` through one of two mechanisms:

1.  As an [HTTP media type], encoded as [Unicode] codepoints in the range `21`–`7E`.

2.  As an [IRI], encoded as [Unicode] codepoints, preceded by a single `0E` character and followed by a single `0F` character.

    <div role="note" markdown="block">
    Because they are in a [data block], these characters are not interpreted as `0E LEAVE` and `0F RETURN` and thus are completely valid.
    </div>

Immediately following the [media type], if present, or the opening `10 DATA` character, otherwise, must be a sequence of characters (including the closing `80C9 STRING FINISH`) which, when interpreted in the surrounding character set (i.e., that of the `10 DATA` character), form a [data string].
The [string contents] of this data string are the [embed]'s <dfn id="dfn.embedded_content">embedded content</dfn>.

If the above requirements are not met, then the `10 DATA` character is invalid and does not begin a [data block].
(The closing `80C9 STRING FINISH` character, however, may still close a data block, depending on the other characters present.)

The [Unicode mapping] of an [embed] is `FFFC` and its meaning is left to implementations.

### 4.3 Shift Sequences
{: id="data.shift"}

A <dfn id="dfn.shift_sequence">shift sequence</dfn> can be used to choose a <dfn id="dfn.shifted_character">shifted character</dfn> character from a different character set.
Its [opening data character] is `80D6 SHIFT`, and it has no closing data characters.

The [data contents] of a [shift sequence] are the first of the following which matches:

1. A single `0E` character, followed by the [IRI] of a character set encoded as [Unicode] codepoints, followed by a single `0F` character, followed by a single codepoint, which is the codepoint of its [shifted character].

2. A single codepoint, which is the codepoint of its [shifted character], followed by `7F`.

3. A single codepoint, which is the codepoint of its [shifted character]

If an [IRI] is not provided, the character set of the [shifted character] is [Unicode].
Otherwise, the character set is that given by the IRI.

The [Unicode mapping] of a [shift sequence] is the [Unicode mapping] of its [shifted character], except in the case of adjacent shift sequences whose character set is [Unicode], whose [shifted characters][shifted character] must instead be interpreted together as [UTF-16] code units, interpreting any ill-formed code unit subsequence as `FFFD`.
Two such shift sequences may consequently map to a single character.

If the [Unicode mapping] of a [shifted character] cannot be determined, it is `FFFD`.

## 5. Messaging Characters {#messaging}

[Kixt Transmissions] defines the format of [messages][message], but not any [messaging characters][messaging character] with which to produce them.
This specification introduces several, defined below.

### 5.1 Generic Messages
{: id="messaging.generic"}

The following [messaging characters][messaging character] are characterized by the sorts of functions which they can be used to achieve.
They should generally only be assigned meaning at the [application tier] or higher.

`05 ENQUIRY`

: This character is used to open [messages][message] which request information, ask for help, or open a menu.

`06 CONFIRM`

: This character is used to open [messages][message] which confirm information, acknowledge a transmission, or accept a task.

`07 ALERT`

: This character is used to open [messages][message] which provide alerts or warnings, or which (de)activate certain devices or features.

`15 ERROR`

: This character is used to open [messages][message] which signal errors, cancel requests, or close out tasks.

`1B COMMAND`

: This character is used to open [messages][message] which issue commands or select tasks for individual processes, files, or procedures.
    Tasks which pertain to the application as a whole should instead use `80CA APPLICATION COMMAND`.

### 5.2 Tiered Messages
{: id="messaging.tiers"}

The following [messaging characters][messaging character] are scoped to specific tiers, the exact meaning of which is left to implementations.
The tiers are, from lowest to highest, <dfn id="dfn.device_tier">device</dfn>, <dfn id="dfn.operating_system_tier">operating system</dfn>, <dfn id="dfn.user_tier">user</dfn>, <dfn id="dfn.application_tier">application</dfn>.

Programs should generally pass on, rather than try to interpret, messages of a different tier; for example, devices and applications should not try to interpret operating system messages.
However, not all applications will necessarily have tiers which are clearly distinct, or necessarily have four of them.

The characters are: `80CA APPLICATION COMMAND`, `80CB USER COMMAND`, `80CC OPERATING SYSTEM COMMAND`, `80CD DEVICE COMMAND`.

## 6. Format Characters {#format}

<dfn id="dfn.format_characters">Format characters</dfn> are non-printed characters which signal information about how text should be laid out.
They include spaces, section separators, area markers, and similar.

In a [Kixt charset][charset], the [format characters][format character] are precisely those characters with a `kixt:basicType` of `kixt:FORMAT`.
The format characters of other character sets are not specifically defined by this specification.
However, like all other [Unicode]{::} [Kixt controls], the [Unicode mappings][Unicode mapping] of the format characters in <https://charset.KIBI.network/Kixt/Controls> are treated equivalently to their corresponding characters in the Kixt charset.

Unrecognized or invalid [format characters][format character] should not be removed from input, but they have no effect.

`00 NULL` is an explicitly meaningless character and is ignored in [transmissions][transmission].
The following remaining [format characters][format character] are defined by this specification:

### 6.1. Textual Divisions

`80D1 LINE SEPARATOR`
`80D0 PARAGRAPH SEPARATOR`

: These are low-level textual divisions for lines (or stanzas) and paragraphs (or verses).
    `80D1 LINE SEPARATOR` is the only character in the [Kixt controls] which produces a plain line break.

`1F SECTION SEPARATOR`
`1E CHAPTER SEPARATOR`
`1D PART SEPARATOR`
`1C FILE SEPARATOR`

: These characters have special meanings in [headers][header], but otherwise are simply progressively higher-level textual divisions for breaking up a [page].

### 6.2. Spaces and Breaks

`20 JUSTIFIABLE QUAD`
`80D5 JUSTIFIABLE SPACE`

: These are spaces of indefinite width, which may be expanded or contracted as needed to justify text.
    The distinction between the two is that `20 JUSTIFIABLE QUAD` is a breaking space whereas `80D5 JUSTIFIABLE SPACE` prevents line breaks on either side.

`80D2 WORD SEPARATOR`
`80D3 HYPHENATION`
`80D4 WORD JOINER`

: `80D2 WORD SEPARATOR` and `80D3 HYPHENATION` both signify line-breaking opportunities; in the latter case, any line break should be automatically preceded by a hyphen (including a line break hardcoded with `80D1 LINE SEPARATOR`).
    The actual character used for hyphenation is left to implementations.
    `80D4 WORD JOINER` performs the opposite function, and prevents a line break at its location.

### 6.3. Areas

This specification defines two types of <dfn id="dfn.area">areas</dfn>, <dfn id="dfn.selection">selections</dfn> and <dfn id="dfn.protection">protections</dfn>.
These begin with `80C0 SELECTED BEGIN` or `80C2 PROTECTED BEGIN`, respectively, and end with `80C1 SELECTED FINISH` or `80C3 PROTECTED FINISH` (or at the end of the given [text]).

In general, higher-level markup is preferred over using these characters.
They are intended for use in restricted, plain-text environments.

### 6.4. Annotations

<dfn id="dfn.annotation">Annotations</dfn> begin with `80C4 ANNOTATED BEGIN` and end with `80C6 ANNOTATED FINISH`.
Between these two characters, `80C5 ANNOTATION` introduces a new <dfn id="dfn.annotation_text">annotation text</dfn>, which runs until the next `80C5 ANNOTATION` or the final `80C6 ANNOTATION FINISH`.
The text which precedes the first annotation text is the text being annotated.

Annotations are intended primarily for interlinear marks, such as ruby; however, no explicit restrictions on their use are made.
Higher-level markup is preferred over using these characters where available; they are intended for use in restricted, plain-text environments.

## 7. Noncharacters {#noncharacter}

<dfn id="dfn.noncharacter">Noncharacters</dfn> are non-printed characters with an implementation-specific meaning, intended for internal use.
They fill a similar role to private-use characters, only for purposes of formatting and processing.

In a [Kixt charset][charset], the [noncharacters][noncharacter] are precisely those characters with a `kixt:basicType` of `kixt:NONCHARACTER`.
In [Unicode], the noncharacters are the 66 characters in the standard so defined.
In other character sets, the set of noncharacters is not defined by this specification.

The [Kixt controls] include 32 noncharacters in the range `80A0`–`80BF`.
These noncharacters are preferred for transmission contexts where their recognition by the receiving program is deemed important.
However, character sets may define additional noncharacters.

## 8. Other Characters {#others}

There are also a few [Kixt controls] which do not fit into the categories above.

### 8.1. Replacement Characters
{: id="others.replacement"}

The character `80CE OBJECT` is a printed character which replaces an unrecognized data block or other embedded object.
The character `80CF REPLACEMENT` is a printed character which replaces other invalid characters.

## 9. Changelog {#changelog}

{: id="changelog.2019-09-16"} <time>2019-09-16</time>

: Initial specification.

{% include references.md %}
