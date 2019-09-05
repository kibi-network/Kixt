# Kixt XML

## Abstract {#abstract}

The following specification defines a means of creating [XML documents][XML document] which are useable with [Kixt charsets][charset].

<nav id="toc" markdown="block">
## Contents

+ Table of Contents
{:toc id="toc.contents"}
</nav>

## 1. Introduction {#introduction}

### 1.1 Purpose and Scope
{: id="introduction.purpose"}

The [Kixt Transmission Format] allows for the association of metadata with [documents][document] through the use of [headers][header].
However, using this format to specify character sets in a manner compatible with non–Kixt-aware [XML processors][XML processor] is impossible, due to its reliance on characters prohibited in [XML documents][XML document].
This specification defines a subset of the [XML] syntax which may be used to encode texts written in a [Kixt charset][charset].
The resulting document is called a <dfn id="dfn.Kixt_XML_document">Kixt XML document</dfn>.

<div role="note" markdown="block">
The file extension `.xkixt` or `.xkx` is suggested for saved [Kixt XML documents][Kixt XML document].
</div>

### 1.2 Relationship to Other Specifications
{: id="introduction.related"}

This document is part of the [Kixt family of specifications][Kixt Overview].
It is also built upon [XML] and [RDF] technologies.

## 2. Character sets {#character}

A [Kixt Charset Definition] is <dfn id="dfn.XML_compatible">XML compatible</dfn> if it is [UTF-8 compatible] and the objects of the [compatibility properties][compatibility property] are equal to those defined in <https://charset.KIBI.network/Kixt/XML> for all characters so defined.

The [Unicode] character set, as well as the ASCII subset thereof, is assumed to be XML compatible.
Whether other character sets are XML compatible is left undefined by this specification.

The character set of a [Kixt XML document] may be any [XML compatible] character set.
Kixt XML documents must not be [fully normalized][XML fully normalized], as they do not necessarily contain [Unicode] contents.

### 2.1 Character encoding
{: id="character.encoding"}

[Kixt XML documents][Kixt XML document] must be transmitted as either [Generalized UTF-8], [Fullwidth-BE], or [Fullwidth-LE].
[Fullwidth-BE] or [Fullwidth-LE] Kixt XML documents must begin with the codepoint `FEFF`.
[Generalized UTF-8] Kixt XML documents may also begin with `FEFF`, but this is not required.

## 3. The Format

### 3.1 Restrictions on the XML syntax
{: id="format.restrictions"}

[Kixt XML documents][Kixt XML document] must follow the syntax defined by [XML], with the additional constraints:

01. [Kixt XML documents][Kixt XML document] must not contain the codepoints `000A`, `000D`, `0085`, or `2028`.

    <div role="note" markdown="block">
    As consequence of this rule, the only valid [XML `<S>`] whitespace in a [Kixt XML document] is `0020`.
    This does not prevent the presence of other, non-syntactic whitespace, however.
    </div>

02. [Kixt XML documents][Kixt XML document] must not contain any codepoints not defined in <https://charset.KIBI.network/Kixt/XML> in any [XML `<Name>`], [`<NCName>`][XML `<NCName>`], [`<Nmtoken>`][XML `<Nmtoken>`], or [`<PubidLiteral>`][XML `<PubidLiteral>`].

03. [Kixt XML documents][Kixt XML document] must not contain an [`<EncodingDecl>`][XML `<EncodingDecl>`] encoding declaration.

04. [Kixt XML documents][Kixt XML document] must not contain any codepoints not assigned in the current character set.

### 3.2 Defining the character set
{: id="format.charset"}

The starting character set for a [Kixt XML document] is [Unicode].

The character set for the [contents][XML content] of any [XML element] can be changed by setting the [attribute][XML attribute] with [local name][XML local name] `charset` and [namespace name][XML namespace name] `https://spec.KIBI.network/Kixt/-/XML/` on that element.
If the [value][XML attribute value] of this attribute is the IRI of a supported, [XML compatible] character set, then this is the character set of the element's contents.
Otherwise, the character set of the element's contents is the same as that for its parent, or, in the case of the [root element][XML root], the document as a whole.

## 4. Security {#security}

Using non-Unicode character sets within a document may make scripted [Kixt XML documents][Kixt XML document] more difficult to sanitize.
It is advised that processors of scripted documents which may contain unsafe information fail to recognize *all* character set IRIs, effectively locking the character set into Unicode, unless the character sets supported by a sanitization filter are known.

## 5. Changelog {#changelog}

{: id="changelog.2019-09-05"} <time>2019-09-05</time>

: Added [Security](#security) section.

{: id="changelog.2019-05-03"} <time>2019-05-03</time>

: Initial specification.

{% include references.md %}

