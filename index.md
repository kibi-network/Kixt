# Kixt Overview

## Abstract {#abstract}

[Kixt] (<i>KIBI text</i>) groups together a number of related specifications pertaining to character sets, text rendering, and document storage.

<nav id="toc" markdown="block">
##  Contents

+ Table of Contents
{:toc id="toc.contents"}
</nav>

## 1. Introduction {#introduction}

Although [Unicode] generally provides an extensive and well-supported means of storing, classifying, rendering, and transforming text, its status as a universal character set means that minority and experimental scripts may not have a proper representation at a given time.
<dfn id="dfn.Kixt">Kixt</dfn> is a limited approach at a generalizable means of dealing with text which allows for custom encodings and properties in a simple and clearly-defined manner.

##  2. Specifications  {#specifications}

[Kixt Charset]

: Defines the [Kixt Charset Model] and the file format for [Kixt Charset Definitions][Kixt Charset Definition].

[Kixt Transmissions]

: Defines the [Kixt Transmission Format] for storing and communicating Kixt texts.

[Kixt Formatting and Controls]

: Defines the [Kixt controls], for use communicating with Kixt programs.

[Kixt XML]

: Defines the [Kixt XML document] format for using Kixt character sets with XML.

## 3. Changelog {#changelog}

{: id="changelog.2019-09-16"} <time>2019-09-16</time>

: Added link to [Kixt Formatting and Controls].

{: id="changelog.2019-05-01"} <time>2019-05-01</time>

: Initial specification.

{% include references.md %}
